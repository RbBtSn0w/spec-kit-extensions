# PowerShell Status Sync Test
#
# Usage: pwsh superpowers-bridge/tests/test-status-sync.ps1
#
# This script validates that the sync-spec-status.ps1 script correctly
# handles status insertion/updates and preserves file encoding/line-endings.

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BridgeDir = Split-Path -Parent $ScriptDir
$SyncScript = Join-Path $BridgeDir 'scripts/powershell/sync-spec-status.ps1'

function Set-MockFeatureSpec {
    param(
        [Parameter(Mandatory = $true)]
        [string]$MockPrereqPath,
        [Parameter(Mandatory = $true)]
        [string]$SpecPath
    )

    $FeatureDir = Split-Path -Parent $SpecPath
    $EscapedFeatureDir = $FeatureDir -replace '\\', '\\'
    $EscapedSpecPath = $SpecPath -replace '\\', '\\'

@"
param([switch]`$Json)
if (`$Json) {
    @{
        FEATURE_DIR = '$EscapedFeatureDir'
        FEATURE_SPEC = '$EscapedSpecPath'
    } | ConvertTo-Json -Compress
    exit 0
}
exit 1
"@ | Set-Content $MockPrereqPath -Encoding utf8
}

function Assert-ContainsLine {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Content,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedLine,
        [Parameter(Mandatory = $true)]
        [string]$FailureMessage
    )

    $Pattern = "^{0}$" -f [regex]::Escape($ExpectedLine)
    if (-not [regex]::IsMatch($Content, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)) {
        throw $FailureMessage
    }
}

# Create a temporary working directory
$TmpDir = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Path $TmpDir | Out-Null

try {
    # 1. Setup mock check-prerequisites.ps1
    $MockScriptsDir = New-Item -ItemType Directory -Path (Join-Path $TmpDir 'scripts/powershell')
    $MockPrereq = Join-Path $MockScriptsDir 'check-prerequisites.ps1'

    # 2. Setup initial spec.md
    $SpecDir = New-Item -ItemType Directory -Path (Join-Path $TmpDir 'specs/001-demo')
    $SpecFile = Join-Path $SpecDir 'spec.md'
    
    $InitialContent = @"
# Demo Feature

## Overview

Testing status sync.
"@
    $InitialContent | Set-Content $SpecFile -Encoding utf8
    Set-MockFeatureSpec -MockPrereqPath $MockPrereq -SpecPath $SpecFile

    # 3. Test: Initial Insertion
    Write-Host "Running Test 1: Initial Insertion..."
    Push-Location $TmpDir
    try {
        & $SyncScript -Status 'Tasked' | Out-Null
        $Content = Get-Content $SpecFile -Raw
        Assert-ContainsLine -Content $Content -ExpectedLine '**Status**: Tasked' -FailureMessage 'Test 1 failed: Status line not found or incorrect.'
        # Verify the inserted status sits directly below the fixture's H1 block.
        $Lines = Get-Content $SpecFile
        if (
            $Lines.Count -lt 5 -or
            $Lines[0] -ne "# Demo Feature" -or
            $Lines[1] -ne "" -or
            $Lines[2] -ne "**Status**: Tasked" -or
            $Lines[3] -ne "" -or
            $Lines[4] -ne "## Overview"
        ) {
            throw "Test 1 failed: Status line sequence incorrect."
        }
    } finally {
        Pop-Location
    }

    # 4. Test: Status Update
    Write-Host "Running Test 2: Status Update..."
    Push-Location $TmpDir
    try {
        & $SyncScript -Status 'Verified' | Out-Null
        $Content = Get-Content $SpecFile -Raw
        Assert-ContainsLine -Content $Content -ExpectedLine '**Status**: Verified' -FailureMessage 'Test 2 failed: Status not updated to Verified.'
    } finally {
        Pop-Location
    }

    # 5. Test: Insertion Without H1
    Write-Host "Running Test 3: No H1 Insertion..."
    $NoH1File = Join-Path $SpecDir 'spec_noh1.md'
    "Just some text without an H1 heading." | Set-Content $NoH1File -Encoding utf8
    Set-MockFeatureSpec -MockPrereqPath $MockPrereq -SpecPath $NoH1File
    
    Push-Location $TmpDir
    try {
        & $SyncScript -Status 'Tasked' | Out-Null
        $Lines = Get-Content $NoH1File
        if ($Lines[0] -ne "**Status**: Tasked") {
            throw "Test 3 failed: Status not at top."
        }
        if ($Lines[1] -ne "") {
             throw "Test 3 failed: Missing empty line after status."
        }
    } finally {
        Pop-Location
    }

    # 6. Test: Encoding Preservation (UTF-8 with BOM)
    Write-Host "Running Test 4: BOM Preservation..."
    $BomFile = Join-Path $SpecDir 'spec_bom.md'
    $Utf8WithBom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($BomFile, $InitialContent, $Utf8WithBom)
    Set-MockFeatureSpec -MockPrereqPath $MockPrereq -SpecPath $BomFile

    Push-Location $TmpDir
    try {
        & $SyncScript -Status 'Implementing' | Out-Null
        $Bytes = [System.IO.File]::ReadAllBytes($BomFile)
        if ($Bytes[0] -ne 0xEF -or $Bytes[1] -ne 0xBB -or $Bytes[2] -ne 0xBF) {
            throw "Test 4 failed: BOM lost."
        }
    } finally {
        Pop-Location
    }

    Write-Host "`nAll PowerShell sync-spec-status tests PASSED." -ForegroundColor Green

} finally {
    if (Test-Path $TmpDir) {
        Remove-Item -Path $TmpDir -Recurse -Force
    }
}
