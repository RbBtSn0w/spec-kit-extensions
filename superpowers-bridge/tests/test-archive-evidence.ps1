param()

$ErrorActionPreference = "Stop"
$EvidenceDir = ".specify/evidence"
$ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath "..\scripts\powershell\archive-evidence.ps1"

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

$InputData | powershell -ExecutionPolicy Bypass -File "$ScriptPath" -FeatureName "test-feature" -BuildStatus "PASS" -CommitHash "12345abc"

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

# Test 2: Missing required arguments
Write-Host "Test 2: Missing Required Arguments"
try {
    powershell -ExecutionPolicy Bypass -File "$ScriptPath" -FeatureName "test-feature" 2>$null
    Write-Error "Failed: Script should have failed due to missing -BuildStatus."
    exit 1
} catch {
    Write-Host "  -> Passed: Script correctly failed."
}

Write-Host "All tests passed successfully."
Remove-Item -Path $EvidenceDir -Recurse -Force
