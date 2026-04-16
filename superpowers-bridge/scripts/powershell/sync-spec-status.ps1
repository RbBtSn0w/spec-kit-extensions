param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Tasked', 'Implementing', 'Verified', 'In Review', 'Abandoned')]
    [string]$Status
)

$ErrorActionPreference = 'Stop'

function Resolve-FeatureJson {
    $scriptRelativePath = 'scripts/powershell/check-prerequisites.ps1'
    $scriptCandidates = [System.Collections.Generic.List[string]]::new()
    $scriptPath = $null

    if ((Get-Location).Path) {
        $scriptCandidates.Add((Join-Path (Get-Location).Path $scriptRelativePath))
    }

    $currentScriptDir = if ($PSScriptRoot) {
        $PSScriptRoot
    } elseif ($PSCommandPath) {
        Split-Path -Parent $PSCommandPath
    } else {
        $null
    }

    if ($currentScriptDir) {
        # Try extension scripts dir and project root relative to script location
        $scriptCandidates.Add((Join-Path $currentScriptDir 'check-prerequisites.ps1'))
        $projectRootPath = Join-Path $currentScriptDir '../../..'
        $scriptCandidates.Add((Join-Path $projectRootPath $scriptRelativePath))
    }

    foreach ($candidate in $scriptCandidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) {
            $scriptPath = (Resolve-Path -LiteralPath $candidate).ProviderPath
            break
        }
    }

    if (-not $scriptPath) {
        $checkedCandidates = @($scriptCandidates | Where-Object { $_ })
        $checkedLocations = if ($checkedCandidates.Count -gt 0) {
            [string]::Join(', ', $checkedCandidates)
        } else {
            'none'
        }
        throw "ERROR: check-prerequisites.ps1 not found (checked: $checkedLocations)"
    }

    $powerShellExecutable = (Get-Process -Id $PID).Path
    if (-not $powerShellExecutable) {
        throw 'ERROR: Unable to determine current PowerShell executable for child script execution'
    }

    $commandArgsList = @(
        @('-Json', '-RequireTasks', '-IncludeTasks'),
        @('-Json', '-PathsOnly'),
        @('-Json')
    )
    $lastResolutionError = $null

    foreach ($commandArgs in $commandArgsList) {
        try {
            $result = & $powerShellExecutable -NoProfile -NonInteractive -File $scriptPath @commandArgs 2>&1
            $exitCode = $LASTEXITCODE
            $resultText = if ($result) {
                [string]::Join([Environment]::NewLine, [string[]]$result)
            } else {
                ''
            }

            if ($exitCode -eq 0 -and $resultText) {
                $null = $resultText | ConvertFrom-Json -ErrorAction Stop
                return $resultText
            }

            $lastResolutionError = if ($resultText) {
                "exit code ${exitCode}: $resultText"
            } else {
                "exit code ${exitCode}: no output"
            }
        } catch {
            $lastResolutionError = $_
        }
    }

    if ($lastResolutionError) {
        $detail = if ($lastResolutionError -is [System.Management.Automation.ErrorRecord]) {
            $lastResolutionError.Exception.Message
        } else {
            [string]$lastResolutionError
        }
        throw "Unable to resolve active feature via ${scriptPath}: $detail"
    }

    throw "Unable to resolve active feature via $scriptPath"
}

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

$specStream = [System.IO.File]::OpenRead($specPath)
try {
    $reader = [System.IO.StreamReader]::new($specStream, [System.Text.Encoding]::UTF8, $true)
    try {
        $rawContent = $reader.ReadToEnd()
    } finally {
        $reader.Dispose()
    }
} finally {
    $specStream.Dispose()
}
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
        if ($lines.Count -gt 1 -and -not [string]::IsNullOrWhiteSpace($lines[1])) {
            $lines.Insert(1, "")
        }
    } else {
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
    $fileBytes = [System.IO.File]::ReadAllBytes($specPath)
    $outputEncoding = $null

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
    } else {
        $outputEncoding = New-Object System.Text.UTF8Encoding($false)
    }

    [System.IO.File]::WriteAllText($specPath, $content, $outputEncoding)
}

[pscustomobject]@{
    spec_path = $specPath
    previous_status = $previousStatus
    new_status = $Status
    changed = $changed
} | ConvertTo-Json -Compress
