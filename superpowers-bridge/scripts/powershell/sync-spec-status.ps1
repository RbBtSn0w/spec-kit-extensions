param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Tasked', 'Implementing', 'Verified', 'In Review', 'Abandoned')]
    [string]$Status
)

$ErrorActionPreference = 'Stop'

function Resolve-FeatureJson {
    $scriptPath = 'scripts/powershell/check-prerequisites.ps1'

    if (-not (Test-Path $scriptPath)) {
        throw 'scripts/powershell/check-prerequisites.ps1 not found in project root'
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

    throw 'Unable to resolve active feature via scripts/powershell/check-prerequisites.ps1'
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

$lines = [System.Collections.Generic.List[string]]::new()
$lines.AddRange([string[]](Get-Content $specPath))
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
        $insertAt = $headingIndex + 1
        if ($insertAt -lt $lines.Count -and [string]::IsNullOrWhiteSpace($lines[$insertAt])) {
            $insertAt++
        }
        $lines.Insert($insertAt, $statusLine)
    }
}

Set-Content -Path $specPath -Value $lines -Encoding utf8

[pscustomobject]@{
    spec_path = $specPath
    previous_status = $previousStatus
    new_status = $Status
    changed = ($previousStatus -ne $Status)
} | ConvertTo-Json -Compress
