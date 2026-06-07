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

# 3. Create the companion-modules-reviewing directory if it doesn't exist.
#    This is where module git repos are cloned. It lives INSIDE the repo and is
#    gitignored (see .gitignore + .githooks/pre-commit); each clone keeps its own
#    independent git context.
. "$PSScriptRoot/scripts/lib/ReviewState.ps1"
$modulesDir = Resolve-ModulesDir $PSScriptRoot

if (Test-Path $modulesDir) {
    Write-Host "[OK] Modules directory already exists: $modulesDir" -ForegroundColor Green
} else {
    New-Item -ItemType Directory -Path $modulesDir | Out-Null
    Write-Host "[OK] Created modules directory: $modulesDir" -ForegroundColor Green
}

# 4. Clone the official module templates into companion-module-templates/ (gitignored).
#    validate-template.ps1 / module-facts.ps1 diff each module against these. v2 from
#    GitHub; v1 cloned from the v2 clone and checked out at the last v1.x commit.
$templatesDir = Resolve-TemplatesDir $PSScriptRoot
if (-not (Test-Path $templatesDir)) { New-Item -ItemType Directory -Path $templatesDir | Out-Null }

$v1Commits = @{ js = '9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1'; ts = '42609d8dab515a25ec2f3b3c7adafe57aa41b7be' }
foreach ($lang in 'js', 'ts') {
    $v2 = Join-Path $templatesDir "companion-module-template-$lang"
    if (Test-Path $v2) {
        Write-Host "[OK] Template already present: companion-module-template-$lang" -ForegroundColor Green
    } else {
        Write-Host "[..] Cloning companion-module-template-$lang ..." -ForegroundColor DarkGray
        git clone --quiet "https://github.com/bitfocus/companion-module-template-$lang" $v2
        Write-Host "[OK] Cloned companion-module-template-$lang" -ForegroundColor Green
    }
    $v1 = Join-Path $templatesDir "companion-module-template-$lang-v1"
    if (Test-Path $v1) {
        Write-Host "[OK] Template already present: companion-module-template-$lang-v1" -ForegroundColor Green
    } elseif (Test-Path $v2) {
        Write-Host "[..] Creating companion-module-template-$lang-v1 (pinned to last v1.x commit) ..." -ForegroundColor DarkGray
        git clone --quiet $v2 $v1
        git -C $v1 checkout --quiet $v1Commits[$lang]
        Write-Host "[OK] Created companion-module-template-$lang-v1" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Workspace structure:" -ForegroundColor Cyan
Write-Host "  companion-module-review/              <- this repo"
Write-Host "  ├── companion-modules-reviewing/      <- module checkouts go here (gitignored)"
Write-Host "  └── companion-module-templates/       <- official templates, v1/v2 js/ts (gitignored)"
Write-Host ""
Write-Host "Open companion-module-review.code-workspace in VS Code for full multi-repo support." -ForegroundColor Cyan
Write-Host "Clone modules with: pwsh scripts/bitfocus-setup-module.ps1" -ForegroundColor Cyan
Write-Host ""
