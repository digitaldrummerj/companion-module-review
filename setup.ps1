# setup.ps1 — one-time workspace setup after cloning
# Run this once per clone: pwsh setup.ps1
#
# This repo is a thin WORKSPACE: reviews/, the module clones under review, and the template
# clones. Everything that does the reviewing — the review skills, the three review subagents,
# /review-module, and the PowerShell pipeline scripts — ships as the `companion-module-review`
# plugin in the bitfocus-companion-skills marketplace, alongside the companion knowledge
# plugins the reviewers consult. .claude/settings.json declares the marketplace and the plugins
# (Claude Code prompts for them when the folder is trusted); this script installs whatever is
# still missing so the pipeline works the first time.
#
#   -SkipPluginInstall   don't call `claude plugin ...` (offline / development). The plugin is
#                        then located from COMPANION_REVIEW_PLUGIN_DIR or an existing install.
#
# Development against a local checkout of the skills repo:
#   $env:COMPANION_REVIEW_PLUGIN_DIR = '~/Development/bitfocus-companion-skills/plugins/companion-module-review'
#   claude --plugin-dir $env:COMPANION_REVIEW_PLUGIN_DIR

param([switch]$SkipPluginInstall)

$ErrorActionPreference = 'Stop'

$marketplaceName = 'bitfocus-companion-skills'
$marketplaceRepo = 'digitaldrummerj/bitfocus-companion-skills'
$reviewPlugin    = 'companion-module-review'

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

# 3. Marketplace + plugins. The list of plugins comes from .claude/settings.json
#    (enabledPlugins), so there is one place to edit when the set changes.
$settingsPath = Join-Path $PSScriptRoot '.claude/settings.json'
$wanted = @()
if (Test-Path $settingsPath) {
    $settings = Get-Content -Raw -LiteralPath $settingsPath | ConvertFrom-Json -AsHashtable
    if ($settings.ContainsKey('enabledPlugins')) {
        $wanted = @($settings['enabledPlugins'].Keys | Where-Object { $settings['enabledPlugins'][$_] -eq $true } | Sort-Object)
    }
}

$installedPluginsPath = Join-Path $HOME '.claude/plugins/installed_plugins.json'
function Get-InstalledPlugins {
    # Keys look like "companion-module-review@bitfocus-companion-skills"; values are a list of
    # install records with an installPath. Missing file = nothing installed yet.
    if (-not (Test-Path $installedPluginsPath)) { return @{} }
    try {
        $j = Get-Content -Raw -LiteralPath $installedPluginsPath | ConvertFrom-Json -AsHashtable
        if ($j.ContainsKey('plugins')) { return $j['plugins'] }
        return $j
    } catch { return @{} }
}

if ($SkipPluginInstall) {
    Write-Host "[--] Skipping marketplace/plugin install (-SkipPluginInstall)" -ForegroundColor DarkYellow
} else {
    if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
        Write-Host "[!!] The 'claude' CLI is not on PATH." -ForegroundColor Red
        Write-Host "     Install Claude Code (https://claude.com/claude-code), then re-run: pwsh setup.ps1" -ForegroundColor Red
        Write-Host "     (or pass -SkipPluginInstall if the plugins are already installed)" -ForegroundColor DarkGray
        exit 1
    }

    $marketplaces = (& claude plugin marketplace list 2>&1) -join "`n"
    if ($marketplaces -notmatch [regex]::Escape($marketplaceName)) {
        Write-Host "[..] Adding marketplace $marketplaceName ($marketplaceRepo) ..." -ForegroundColor DarkGray
        & claude plugin marketplace add $marketplaceRepo
        if ($LASTEXITCODE -ne 0) { Write-Host "[!!] Could not add marketplace $marketplaceRepo" -ForegroundColor Red; exit 1 }
    }
    Write-Host "[..] Updating marketplace $marketplaceName ..." -ForegroundColor DarkGray
    & claude plugin marketplace update $marketplaceName | Out-Null
    if ($LASTEXITCODE -ne 0) { Write-Host "[!!] Marketplace update failed — continuing with the cached catalog" -ForegroundColor DarkYellow }

    $installed = Get-InstalledPlugins
    foreach ($id in $wanted) {
        if ($installed.ContainsKey($id)) {
            Write-Host "[OK] Plugin installed: $id" -ForegroundColor Green
            continue
        }
        Write-Host "[..] Installing plugin $id ..." -ForegroundColor DarkGray
        & claude plugin install $id
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[!!] Install FAILED for $id" -ForegroundColor Red
        } else {
            Write-Host "[OK] Installed $id" -ForegroundColor Green
        }
    }
}

# 4. Locate the companion-module-review plugin: a dev override first, then the recorded
#    install path, then the newest version in the plugin cache.
function Resolve-ReviewPluginDir {
    if ($env:COMPANION_REVIEW_PLUGIN_DIR) {
        $p = [Environment]::ExpandEnvironmentVariables($env:COMPANION_REVIEW_PLUGIN_DIR) -replace '^~', $HOME
        if (Test-Path (Join-Path $p 'scripts')) { return (Resolve-Path $p).Path }
    }
    $installed = Get-InstalledPlugins
    $key = "$reviewPlugin@$marketplaceName"
    if ($installed.ContainsKey($key)) {
        foreach ($rec in @($installed[$key])) {
            $path = if ($rec -is [System.Collections.IDictionary]) { $rec['installPath'] } else { $null }
            if ($path -and (Test-Path (Join-Path $path 'scripts'))) { return $path }
        }
    }
    $cache = Join-Path $HOME ".claude/plugins/cache/$marketplaceName/$reviewPlugin"
    if (Test-Path $cache) {
        $newest = Get-ChildItem -LiteralPath $cache -Directory |
            Where-Object { Test-Path (Join-Path $_.FullName 'scripts') } |
            Sort-Object { try { [version]($_.Name -replace '[^0-9.].*$', '') } catch { [version]'0.0' } } -Descending |
            Select-Object -First 1
        if ($newest) { return $newest.FullName }
    }
    return $null
}

$pluginDir = Resolve-ReviewPluginDir
$libLoaded = $false
if ($pluginDir -and (Test-Path (Join-Path $pluginDir 'scripts/lib/ReviewState.ps1'))) {
    . (Join-Path $pluginDir 'scripts/lib/ReviewState.ps1')
    $libLoaded = $true
    Write-Host "[OK] $reviewPlugin plugin: $pluginDir" -ForegroundColor Green
} else {
    Write-Host "[!!] Could not find the $reviewPlugin plugin's scripts." -ForegroundColor Red
    Write-Host "     Install it (claude plugin install $reviewPlugin@$marketplaceName) or set" -ForegroundColor Red
    Write-Host "     COMPANION_REVIEW_PLUGIN_DIR to a local checkout, then re-run setup." -ForegroundColor Red
}

# The plugin's scripts resolve this workspace from COMPANION_REVIEW_ROOT (or the git toplevel
# of the current directory). Set it for anything this session runs.
$env:COMPANION_REVIEW_ROOT = $PSScriptRoot

# 5. Create the companion-modules-reviewing directory if it doesn't exist.
#    This is where module git repos are cloned. It lives INSIDE the repo and is
#    gitignored (see .gitignore + .githooks/pre-commit); each clone keeps its own
#    independent git context. Honors COMPANION_MODULES_DIR.
$modulesDir = if ($env:COMPANION_MODULES_DIR) { $env:COMPANION_MODULES_DIR } else { Join-Path $PSScriptRoot 'companion-modules-reviewing' }
if (Test-Path $modulesDir) {
    Write-Host "[OK] Modules directory already exists: $modulesDir" -ForegroundColor Green
} else {
    New-Item -ItemType Directory -Path $modulesDir | Out-Null
    Write-Host "[OK] Created modules directory: $modulesDir" -ForegroundColor Green
}

# 6. Clone the official module templates into companion-module-templates/ (gitignored).
#    validate-template.ps1 / module-facts.ps1 diff each module against these. v2 from
#    GitHub; v1 cloned from the v2 clone and checked out at the last v1.x commit.
#
#    This step CLONES but never PULLS. Existing clones are only reported on, because several
#    review sessions share them and a pull here would move the reference underneath a review
#    in progress. Refreshing is a separate, deliberate command: the plugin's
#    scripts/update-templates.ps1. Honors COMPANION_TEMPLATES_DIR.
$templatesDir = if ($env:COMPANION_TEMPLATES_DIR) { $env:COMPANION_TEMPLATES_DIR } else { Join-Path $PSScriptRoot 'companion-module-templates' }
if (-not (Test-Path $templatesDir)) { New-Item -ItemType Directory -Path $templatesDir | Out-Null }

if (-not $libLoaded) {
    Write-Host "[!!] Skipping template clones/freshness checks — they need the $reviewPlugin plugin's scripts." -ForegroundColor Red
} else {
    $updateTemplates = Join-Path $pluginDir 'scripts/update-templates.ps1'
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
                    Write-Host "     Refresh with:  pwsh `"$updateTemplates`"" -ForegroundColor Red
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
}

Write-Host ""
Write-Host "Workspace structure:" -ForegroundColor Cyan
Write-Host "  companion-module-review/              <- this repo (the workspace)"
Write-Host "  ├── reviews/                          <- review reports + TRACKER.md"
Write-Host "  ├── companion-modules-reviewing/      <- module checkouts go here (gitignored)"
Write-Host "  └── companion-module-templates/       <- official templates, v1/v2 js/ts (gitignored)"
Write-Host ""
Write-Host "Run a review in Claude Code: /review-module" -ForegroundColor Cyan
if ($pluginDir) {
    Write-Host "Run scripts with: pwsh $(Join-Path $pluginDir 'scripts')/<name>.ps1" -ForegroundColor Cyan
    Write-Host "  e.g. pwsh $(Join-Path $pluginDir 'scripts/bitfocus-setup-module.ps1')" -ForegroundColor DarkGray
}
Write-Host ""
