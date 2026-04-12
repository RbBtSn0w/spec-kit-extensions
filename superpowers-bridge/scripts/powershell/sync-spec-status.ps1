param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Tasked', 'Implementing', 'Verified', 'In Review', 'Abandoned')]
    [string]$Status
)

$ErrorActionPreference = 'Stop'

function Resolve-FeatureJson {
    $scriptRelativePath = 'scripts/powershell/check-prerequisites.ps1'
    $scriptPath = $scriptRelativePath

    # 1. Try relative to current directory (project root)
    if (-not (Test-Path $scriptPath)) {
        # 2. Try relative to the script's own location (extension scripts dir)
        $currentScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
        if ($currentScriptDir) {
            $scriptPath = Join-Path $currentScriptDir 'check-prerequisites.ps1'
            if (-not (Test-Path $scriptPath)) {
                # 3. Fallback to assuming we are in superpowers-bridge/scripts/powershell/
                $scriptPath = Join-Path $currentScriptDir '../../..' $scriptRelativePath
            }
        }
    }

    if (-not (Test-Path $scriptPath)) {
        throw "scripts/powershell/check-prerequisites.ps1 not found (checked project root and extension scripts dir)"
    }

    $commandArgsList = @(
        @('-Json', '-RequireTasks', '-IncludeTasks'),
        @('-Json', '-PathsOnly'),
        @('-Json')
    )

    foreach ($commandArgs in $commandArgsList) {
        try {
            $result = & $scriptPath @commandArgs 2>$null
            if ($result) {
                $resultText = [string]::Join([Environment]::NewLine, [string[]]$result)
                $null = $resultText | ConvertFrom-Json -ErrorAction Stop
                return $resultText
            }
        } catch {
        }
    }

    throw "Unable to resolve active feature via $scriptPath"
}


# ... (previous code for Resolve-FeatureJson) ...
$jsonPayload = Resolve-FeatureJson
$payload = $jsonPayload | ConvertFrom-Json

$specPath = if ($payload.FEATURE_SPEC) {
    $payload.FEATURE_SPEC
} elseif ($payload.FEATURE_DIR) {
    Join-Path $payload.FEATURE_DIR 'spec.md'
} else {
    throw 'Feature resolution did not provide FEATURE_SPEC or FEATURE_DIR'
}

if (-not (Test-Path $specPath)) {
    throw "Resolved spec file does not exist: $specPath"
}

# 1. Detect encoding and BOM first
$fileBytes = [System.IO.File]::ReadAllBytes($specPath)
$outputEncoding = New-Object System.Text.UTF8Encoding($false) # Default

if ($fileBytes.Length -ge 3 -and $fileBytes[0] -eq 0xEF -and $fileBytes[1] -eq 0xBB -and $fileBytes[2] -eq 0xBF) {
    $outputEncoding = New-Object System.Text.UTF8Encoding($true)
} elseif ($fileBytes.Length -ge 4 -and $fileBytes[0] -eq 0xFF -and $fileBytes[1] -eq 0xFE -and $fileBytes[2] -eq 0x00 -and $fileBytes[3] -eq 0x00) {
    $outputEncoding = New-Object System.Text.UTF32Encoding($false, $true)
} elseif ($fileBytes.Length -ge 4 -and $fileBytes[0] -eq 0x00 -and $fileBytes[1] -eq 0x00 -and $fileBytes[2] -eq 0xFE -and $fileBytes[3] -eq 0xFF) {
    $outputEncoding = New-Object System.Text.UTF32Encoding($true, $true)
} elseif ($fileBytes.Length -ge 2 -and $fileBytes[0] -eq 0xFF -and $fileBytes[1] -eq 0xFE) {
    $outputEncoding = New-Object System.Text.UnicodeEncoding($false, $true)
} elseif ($fileBytes.Length -ge 2 -and $fileBytes[0] -eq 0xFE -and $fileBytes[1] -eq 0xFF) {
    $outputEncoding = New-Object System.Text.UnicodeEncoding($true, $true)
}

# 2. Read with detected encoding
$rawContent = [System.IO.File]::ReadAllText($specPath, $outputEncoding)

$lineEnding = if ($rawContent.Contains("`r`n")) {
    "`r`n"
} elseif ($rawContent.Contains("`n")) {
    "`n"
} elseif ($rawContent.Contains("`r")) {
    "`r"
} else {
    "`n"
}
$hadTrailingNewline = $rawContent.EndsWith("`r`n") -or $rawContent.EndsWith("`n") -or $rawContent.EndsWith("`r")
$lines = [System.Collections.Generic.List[string]]::new()
$splitPattern = "\r\n|\n|\r"
if ($rawContent.Length -gt 0) {
    $lines.AddRange([string[]]([regex]::Split($rawContent, $splitPattern)))
    if ($hadTrailingNewline -and $lines.Count -gt 0 -and $lines[$lines.Count - 1] -eq '') {
        $lines.RemoveAt($lines.Count - 1)
    }
}
$statusPattern = '^\*\*Status\*\*:\s*(.+?)\s*$'
$matchIndexes = [System.Collections.Generic.List[int]]::new()
$previousStatus = $null

for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match $statusPattern) {
        if (-not $previousStatus) {
            $previousStatus = $Matches[1]
        }
        $matchIndexes.Add($i)
    }
}

if ($previousStatus -eq 'Abandoned' -and $Status -ne 'Abandoned') {
    [pscustomobject]@{
        spec_path = $specPath
        previous_status = $previousStatus
        new_status = $previousStatus
        changed = $false
        reason = 'preserved_terminal_abandoned'
    } | ConvertTo-Json -Compress
    exit 0
}

$statusLine = "**Status**: $Status"

if ($matchIndexes.Count -gt 0) {
    $lines[$matchIndexes[0]] = $statusLine
    for ($i = $matchIndexes.Count - 1; $i -ge 1; $i--) {
        $lines.RemoveAt($matchIndexes[$i])
    }
} else {
    $headingIndex = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i].StartsWith('# ')) {
            $headingIndex = $i
            break
        }
    }

    if ($headingIndex -lt 0) {
        $lines.Insert(0, $statusLine)
    } else {
        # Insert BELOW the heading
        $lines.Insert($headingIndex + 1, "")
        $lines.Insert($headingIndex + 2, $statusLine)
    }
}

$content = [string]::Join($lineEnding, [string[]]$lines)
if ($hadTrailingNewline) {
    $content += $lineEnding
}

$changed = $content -ne $rawContent
if ($changed) {
    [System.IO.File]::WriteAllText($specPath, $content, $outputEncoding)
}

[pscustomobject]@{
    spec_path = $specPath
    previous_status = $previousStatus
    new_status = $Status
    changed = $changed
} | ConvertTo-Json -Compress

