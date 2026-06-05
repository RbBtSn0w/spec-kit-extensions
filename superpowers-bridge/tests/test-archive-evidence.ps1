param()

$ErrorActionPreference = "Stop"
$ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath "..\scripts\powershell\archive-evidence.ps1"
$PowerShellExe = (Get-Process -Id $PID).Path
$TempDir = [System.IO.Path]::GetTempPath().TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)

# Clean up before testing
if (Test-Path -Path ".specify/evidence") {
    Remove-Item -Path ".specify/evidence" -Recurse -Force
}

# Test 1: Successful evidence capture
Write-Host "Test 1: Successful Evidence Capture"
$InputData = @"
- [x] R01
- [x] R02

---OUTPUT---
Tests passing: 5
Tests failing: 0
"@

function Invoke-ArchiveEvidence {
    param(
        [string]$InputData,
        [string[]]$Arguments
    )

    $InputFile = New-TemporaryFile
    try {
        Set-Content -LiteralPath $InputFile.FullName -Value $InputData -NoNewline
        $Output = & $PowerShellExe -NoProfile -NonInteractive -File "$ScriptPath" @Arguments -InputFile "$($InputFile.FullName)" 2>&1
        return @{
            ExitCode = $LASTEXITCODE
            Output = $Output
        }
    } finally {
        Remove-Item -LiteralPath $InputFile.FullName -Force -ErrorAction SilentlyContinue
    }
}

$Result = Invoke-ArchiveEvidence $InputData @("-FeatureName", "test-feature", "-BuildStatus", "PASS", "-CommitHash", "12345abc")
if ($Result.ExitCode -ne 0) {
    Write-Error "Failed: Script exited with status $($Result.ExitCode)."
    exit 1
}

$OutputText = ($Result.Output | Out-String).Trim()
$ArchivedFile = $OutputText -replace '^Evidence captured at ', ''
if (Test-Path -LiteralPath $ArchivedFile -PathType Leaf) {
    Write-Host "  -> Passed: File created: $ArchivedFile"

    $ArchivedDir = [System.IO.Path]::GetDirectoryName($ArchivedFile).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    if ($ArchivedDir -eq $TempDir -and ([System.IO.Path]::GetFileName($ArchivedFile) -like "speckit-superb-evidence-test-feature-*.md")) {
        Write-Host "  -> Passed: File created in system temp directory."
    } else {
        Write-Error "Failed: File was not created in system temp directory."
        exit 1
    }

    if (Test-Path -Path ".specify/evidence") {
        Write-Error "Failed: Repo evidence directory should not be created."
        exit 1
    } else {
        Write-Host "  -> Passed: Repo evidence directory not created."
    }
    
    $Content = Get-Content -Path $ArchivedFile -Raw
    
    if ($Content -match "12345abc") {
        Write-Host "  -> Passed: Commit hash found."
    } else {
        Write-Error "Failed: Commit hash not found."
        exit 1
    }
    
    if ($Content -match "Tests passing: 5") {
        Write-Host "  -> Passed: Test output found."
    } else {
        Write-Error "Failed: Test output not found."
        exit 1
    }
} else {
    Write-Error "Failed: File not created."
    exit 1
}

function Assert-Fails {
    param(
        [string]$Name,
        [string]$InputData,
        [string[]]$Arguments
    )

    Write-Host $Name
    $Result = Invoke-ArchiveEvidence $InputData $Arguments
    if ($Result.ExitCode -eq 0) {
        Write-Error "Failed: Script should have failed."
        exit 1
    }
    Write-Host "  -> Passed: Script correctly failed."
}

# Test 2: Missing required arguments
Assert-Fails "Test 2: Missing Required Arguments" $InputData @("-FeatureName", "test-feature")

# Test 3: Missing separator
Assert-Fails "Test 3: Missing Separator" "- [x] R01" @("-FeatureName", "test-feature", "-BuildStatus", "PASS")

# Test 4: Missing checklist
Assert-Fails "Test 4: Missing Checklist" "---OUTPUT---`nTests passing: 5" @("-FeatureName", "test-feature", "-BuildStatus", "PASS")

# Test 5: Missing test output
Assert-Fails "Test 5: Missing Test Output" "- [x] R01`n---OUTPUT---" @("-FeatureName", "test-feature", "-BuildStatus", "PASS")

# Test 6: Invalid build status
Assert-Fails "Test 6: Invalid Build Status" "- [x] R01`n---OUTPUT---`nTests passing: 5" @("-FeatureName", "test-feature", "-BuildStatus", "BROKEN")

Write-Host "All tests passed successfully."
Remove-Item -LiteralPath $ArchivedFile -Force -ErrorAction SilentlyContinue
