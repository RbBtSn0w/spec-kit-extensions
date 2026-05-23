param (
    [Parameter(Mandatory=$true)]
    [string]$FeatureName,
    
    [Parameter(Mandatory=$true)]
    [string]$BuildStatus,
    
    [Parameter(Mandatory=$true)]
    [string]$TestOutput,
    
    [Parameter(Mandatory=$true)]
    [string]$Checklist,
    
    [Parameter(Mandatory=$false)]
    [string]$CommitHash = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($CommitHash)) {
    try {
        $CommitHash = (git rev-parse HEAD 2>$null).Trim()
    } catch {
        $CommitHash = "N/A"
    }
}

$EvidenceDir = ".specify/evidence"
if (!(Test-Path -Path $EvidenceDir)) {
    New-Item -ItemType Directory -Path $EvidenceDir | Out-Null
}

$Timestamp = (Get-Date).ToString("yyyyMMddHHmmss")
# Clean feature name for file path
$SafeFeatureName = $FeatureName -replace '[^a-zA-Z0-9_-]', '_'
$FileName = "${Timestamp}-${SafeFeatureName}-verify.md"
$FilePath = Join-Path -Path $EvidenceDir -ChildPath $FileName

$UtcTimestamp = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")

$Content = @"
# Verification Evidence: $FeatureName

- **Timestamp**: $UtcTimestamp (UTC)
- **Git Commit Hash**: $CommitHash
- **Build/Lint Status**: $BuildStatus

## Spec-Coverage Checklist

$Checklist

## Test Suite Output

```text
$TestOutput
```
"@

$Content | Out-File -FilePath $FilePath -Encoding utf8 -NoNewline

Write-Output "Evidence successfully archived to $FilePath"
