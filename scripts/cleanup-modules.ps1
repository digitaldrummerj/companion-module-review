# Removes all companion-module-* folders from companion-modules-reviewing,
# preserving the two template folders.

$reviewingDir = Resolve-Path "$PSScriptRoot\..\..\companion-modules-reviewing"
$keep = @("companion-module-template-ts", "companion-module-template-js")

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
