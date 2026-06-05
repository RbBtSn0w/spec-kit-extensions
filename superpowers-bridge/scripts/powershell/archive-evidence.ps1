[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$FeatureName,
    
    [Parameter(Mandatory=$true)]
    [string]$BuildStatus,
    
    [Parameter(Mandatory=$false)]
    [string]$CommitHash = "",

    [Parameter(Mandatory=$false)]
    [string]$InputFile = "",

    [Parameter(ValueFromPipeline=$true)]
    [AllowEmptyString()]
    [string]$PipelineInput
)

begin {
    $ErrorActionPreference = "Stop"
    $InputLines = [System.Collections.Generic.List[string]]::new()
}

process {
    if ($null -ne $PipelineInput) {
        $InputLines.Add($PipelineInput)
    }
}

end {
    if ([string]::IsNullOrWhiteSpace($FeatureName)) {
        Write-Error "ERROR: -FeatureName is required"
        exit 1
    }

    if ([string]::IsNullOrWhiteSpace($BuildStatus)) {
        Write-Error "ERROR: -BuildStatus is required"
        exit 1
    }

    if ($BuildStatus -notin @("PASS", "FAIL", "N/A")) {
        Write-Error "ERROR: -BuildStatus must be one of PASS, FAIL, or N/A"
        exit 1
    }

    $InputData = $InputLines -join "`n"

    if ([string]::IsNullOrWhiteSpace($InputData) -and -not [string]::IsNullOrWhiteSpace($InputFile)) {
        if (!(Test-Path -LiteralPath $InputFile -PathType Leaf)) {
            Write-Error "ERROR: -InputFile does not exist or is not a file."
            exit 1
        }

        $InputData = Get-Content -LiteralPath $InputFile -Raw
    }

    if ([string]::IsNullOrWhiteSpace($InputData) -and [Console]::IsInputRedirected) {
        $InputData = [Console]::In.ReadToEnd()
    }

    if ([string]::IsNullOrWhiteSpace($InputData)) {
        Write-Error "ERROR: Standard input is empty. Checklist and test output are required."
        exit 1
    }

    $Separator = "---OUTPUT---"
    $Parts = $InputData -split $Separator, 2

    if ($Parts.Length -lt 2) {
        Write-Error "ERROR: Separator '---OUTPUT---' not found in input."
        exit 1
    }

    $Checklist = $Parts[0].Trim()
    $TestOutput = $Parts[1].Trim()

    if ([string]::IsNullOrWhiteSpace($Checklist)) {
        Write-Error "ERROR: Checklist is required before the '---OUTPUT---' separator."
        exit 1
    }

    if ([string]::IsNullOrWhiteSpace($TestOutput)) {
        Write-Error "ERROR: Test output is required after the '---OUTPUT---' separator."
        exit 1
    }

    if ([string]::IsNullOrWhiteSpace($CommitHash)) {
        try {
            $CommitHash = (git rev-parse HEAD 2>$null).Trim()
        } catch {
            $CommitHash = "N/A"
        }
    }

    $Timestamp = (Get-Date).ToString("yyyyMMddHHmmss")
    $SafeFeatureName = $FeatureName -replace '[^a-zA-Z0-9_-]', '_'
    $UniqueSuffix = [System.Guid]::NewGuid().ToString("N")
    $FileName = "speckit-superb-evidence-${SafeFeatureName}-${Timestamp}-${UniqueSuffix}.md"
    $EvidenceDir = [System.IO.Path]::GetTempPath()
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

    Write-Output "Evidence captured at $FilePath"
}
