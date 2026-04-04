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

Write-Host ""
Write-Host "Setup complete. You can now clone companion modules into this directory" -ForegroundColor Cyan
Write-Host "and reference them with @companion-module-* in Copilot." -ForegroundColor Cyan
Write-Host ""
