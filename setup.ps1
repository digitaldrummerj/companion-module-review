# setup.ps1 — one-time workspace setup after cloning
# Run this once per clone: pwsh setup.ps1

Write-Host ""
Write-Host "=== companion-module-review workspace setup ===" -ForegroundColor Cyan
Write-Host ""

# 1. Activate the committed pre-commit hook so companion-module-* dirs
#    can't be accidentally staged and committed.
$current = git config --local core.hooksPath 2>$null
if ($current -eq ".githooks") {
    Write-Host "[OK] Git hooks already configured (.githooks)" -ForegroundColor Green
} else {
    git config core.hooksPath .githooks
    Write-Host "[OK] Git hooks configured -> .githooks" -ForegroundColor Green
}

# 2. Make the hook executable (needed on Windows in some envs; no-op on Unix)
$hookFile = Join-Path $PSScriptRoot ".githooks/pre-commit"
if (Test-Path $hookFile) {
    if ($IsLinux -or $IsMacOS) {
        chmod +x $hookFile | Out-Null
    }
    Write-Host "[OK] pre-commit hook is ready" -ForegroundColor Green
}

# 3. Create the companion-modules-reviewing sibling directory if it doesn't exist.
#    This is where module git repos are cloned — outside the review repo so each
#    has its own independent git context.
$modulesDir = if ($env:COMPANION_MODULES_DIR) {
    $env:COMPANION_MODULES_DIR
} else {
    Join-Path (Split-Path -Parent $PSScriptRoot) "companion-modules-reviewing"
}

if (Test-Path $modulesDir) {
    Write-Host "[OK] Modules directory already exists: $modulesDir" -ForegroundColor Green
} else {
    New-Item -ItemType Directory -Path $modulesDir | Out-Null
    Write-Host "[OK] Created modules directory: $modulesDir" -ForegroundColor Green
}

Write-Host ""
Write-Host "Workspace structure:" -ForegroundColor Cyan
Write-Host "  $(Split-Path -Parent $PSScriptRoot)/"
Write-Host "  ├── companion-module-review/          <- this repo"
Write-Host "  └── companion-modules-reviewing/      <- module checkouts go here"
Write-Host ""
Write-Host "Open companion-module-review.code-workspace in VS Code for full multi-repo support." -ForegroundColor Cyan
Write-Host "Clone modules with: pwsh scripts/bitfocus-setup-module.ps1" -ForegroundColor Cyan
Write-Host ""
