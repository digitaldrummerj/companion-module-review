#!/usr/bin/env pwsh
#Requires -Version 7
# Removes all companion-module-* folders from the modules workspace,
# preserving the two template folders. Honors COMPANION_MODULES_DIR.

$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/lib/ReviewState.ps1"

$workspace    = Split-Path -Parent $PSScriptRoot
$reviewingDir = Resolve-ModulesDir $workspace
$keep = @("companion-module-template-ts", "companion-module-template-js")

if (-not (Test-Path $reviewingDir)) {
    Write-Host "Modules directory does not exist: $reviewingDir"
    return
}

Write-Host "Scanning: $reviewingDir`n"

$removed = 0
$skipped = 0

Get-ChildItem -Path $reviewingDir -Directory -Filter "companion-module-*" | ForEach-Object {
    if ($keep -contains $_.Name) {
        Write-Host "  ✅ Keeping  $($_.Name)"
        $skipped++
    } else {
        Write-Host "  🗑️  Removing $($_.Name)"
        Remove-Item -Recurse -Force $_.FullName
        $removed++
    }
}

Write-Host "`nDone. Removed: $removed | Kept: $skipped"
