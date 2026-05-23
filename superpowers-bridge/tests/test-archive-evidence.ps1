param()

$ErrorActionPreference = "Stop"
$EvidenceDir = ".specify/evidence"
$ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath "..\scripts\powershell\archive-evidence.ps1"
$PowerShellExe = (Get-Process -Id $PID).Path

# Clean up before testing
if (Test-Path -Path $EvidenceDir) {
    Remove-Item -Path $EvidenceDir -Recurse -Force
}
New-Item -ItemType Directory -Path $EvidenceDir | Out-Null

# Test 1: Successful archiving
Write-Host "Test 1: Successful Archiving"
$InputData = @"
- [x] R01
- [x] R02

---OUTPUT---
Tests passing: 5
Tests failing: 0
"@

$InputData | & $PowerShellExe -NoProfile -NonInteractive -File "$ScriptPath" -FeatureName "test-feature" -BuildStatus "PASS" -CommitHash "12345abc"

$ArchivedFiles = Get-ChildItem -Path $EvidenceDir -Filter "*.md"
if ($ArchivedFiles.Count -gt 0) {
    $ArchivedFile = $ArchivedFiles[0].FullName
    Write-Host "  -> Passed: File created: $ArchivedFile"
    
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
    $InputData | & $PowerShellExe -NoProfile -NonInteractive -File "$ScriptPath" @Arguments *> $null
    if ($LASTEXITCODE -eq 0) {
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
Remove-Item -Path $EvidenceDir -Recurse -Force
