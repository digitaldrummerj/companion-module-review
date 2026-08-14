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
#
#    This step CLONES but never PULLS. Existing clones are only reported on, because several
#    review sessions share them and a pull here would move the reference underneath a review
#    in progress. Refreshing is a separate, deliberate command: scripts/update-templates.ps1.
$templatesDir = Resolve-TemplatesDir $PSScriptRoot
if (-not (Test-Path $templatesDir)) { New-Item -ItemType Directory -Path $templatesDir | Out-Null }

$v1Commits = Get-TemplateV1Pins
foreach ($lang in 'js', 'ts') {
    $v2 = Join-Path $templatesDir "companion-module-template-$lang"
    if (Test-Path $v2) {
        $fr = Test-TemplateFreshness -TemplateDir $v2
        switch ($fr.status) {
            'fresh' {
                Write-Host "[OK] companion-module-template-$lang - up to date ($($fr.localShortSha), $($fr.localDate))" -ForegroundColor Green
            }
            'stale' {
                Write-Host "[!!] companion-module-template-$lang - BEHIND UPSTREAM" -ForegroundColor Red
                Write-Host "     local $($fr.localShortSha) ($($fr.localDate))   upstream $($fr.remoteSha.Substring(0,7))" -ForegroundColor Red
                Write-Host "     Refresh with:  pwsh scripts/update-templates.ps1" -ForegroundColor Red
                Write-Host "     (never auto-updated - concurrent review sessions would fight over them)" -ForegroundColor DarkGray
            }
            default {
                Write-Host "[??] companion-module-template-$lang - freshness unknown at $($fr.localShortSha) ($($fr.localDate))" -ForegroundColor DarkYellow
                Write-Host "     $($fr.message)" -ForegroundColor DarkGray
            }
        }
    } else {
        Write-Host "[..] Cloning companion-module-template-$lang ..." -ForegroundColor DarkGray
        git clone --quiet "https://github.com/bitfocus/companion-module-template-$lang" $v2
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[!!] Clone FAILED for companion-module-template-$lang - reviews cannot run without it" -ForegroundColor Red
            continue
        }
        Write-Host "[OK] Cloned companion-module-template-$lang" -ForegroundColor Green
    }

    # The v1 clone is pinned in detached HEAD at the last v1.x commit, so v1 modules are
    # judged against the API surface of their own era rather than against main. It is never
    # fetched; setup only creates it, and update-templates.ps1 only asserts it hasn't moved.
    $v1 = Join-Path $templatesDir "companion-module-template-$lang-v1"
    if (Test-Path $v1) {
        $info = Get-GitRepoInfo -Dir $v1
        if ($info.Sha -eq $v1Commits[$lang] -and $info.Detached) {
            Write-Host "[OK] companion-module-template-$lang-v1 - pinned at $($info.ShortSha) (detached, intentional)" -ForegroundColor Green
        } else {
            Write-Host "[!!] companion-module-template-$lang-v1 - HEAD $($info.ShortSha) is not the pinned v1.x commit" -ForegroundColor Red
            Write-Host "     Re-pin:  git -C `"$v1`" checkout --detach $($v1Commits[$lang])" -ForegroundColor Red
        }
    } elseif (Test-Path $v2) {
        Write-Host "[..] Creating companion-module-template-$lang-v1 (pinned to last v1.x commit) ..." -ForegroundColor DarkGray
        git clone --quiet $v2 $v1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[!!] Clone FAILED for companion-module-template-$lang-v1" -ForegroundColor Red
            continue
        }
        git -C $v1 checkout --quiet $v1Commits[$lang]
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[!!] Could not check out the pinned v1.x commit in companion-module-template-$lang-v1" -ForegroundColor Red
            continue
        }
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
