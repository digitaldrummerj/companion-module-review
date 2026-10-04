#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Shared helpers for the BitFocus review scripts: workspace path resolution,
    tag normalization, TRACKER.md parsing, and local review-state lookup.
.DESCRIPTION
    Dot-source this file from a script in the scripts/ directory:

        . "$PSScriptRoot/lib/ReviewState.ps1"

    The functions here are the single source of truth for "has this module @ tag
    already been reviewed locally?" — used to keep the queue and setup scripts from
    recommending or re-reviewing work that's already done but whose feedback hasn't
    been uploaded to the developer portal yet.

    Review-state model (see reviews/TRACKER.md):
      needs-review     — no local review file AND no TRACKER row
      feedback-pending — a review file exists but feedback not marked submitted (the protect case)
      re-review        — a review file exists AND a TRACKER row is marked submitted (maintainer
                         re-pushed the same tag after we sent feedback, so it's back in the queue)
#>

Set-StrictMode -Version Latest

# Char that marks "feedback submitted" in the TRACKER.md first column.
$script:SubmittedMark = [char]0x2705   # ✅

function Resolve-ModulesDir {
    <# Resolve the workspace where modules under review are cloned: companion-modules-reviewing/
       INSIDE the repo (gitignored). Honors COMPANION_MODULES_DIR. #>
    param([Parameter(Mandatory)][string]$RepoRoot)

    if ($env:COMPANION_MODULES_DIR) { return $env:COMPANION_MODULES_DIR }
    return Join-Path $RepoRoot "companion-modules-reviewing"
}

function Resolve-ReviewsDir {
    <# Resolve the reviews/ directory inside the review repo. #>
    param([Parameter(Mandatory)][string]$RepoRoot)
    return Join-Path $RepoRoot "reviews"
}

function Resolve-TemplatesDir {
    <# Resolve where the official module templates live: companion-module-templates/
       INSIDE the repo (gitignored). Honors COMPANION_TEMPLATES_DIR. #>
    param([Parameter(Mandatory)][string]$RepoRoot)

    if ($env:COMPANION_TEMPLATES_DIR) { return $env:COMPANION_TEMPLATES_DIR }
    return Join-Path $RepoRoot "companion-module-templates"
}

function Get-TemplateV1Pins {
    <# The last v1.x commit of each official template, by language. The "-v1" template clones
       are checked out here in detached HEAD and MUST stay there — v1 modules are judged
       against the API surface as it stood at the v1/v2 boundary, not against main.

       Single source of truth: setup.ps1 creates the pins, update-templates.ps1 asserts they
       haven't drifted, and validate-template.ps1 treats a detached clone as intentionally
       pinned (and therefore exempt from the upstream freshness check). #>
    return @{
        js = '9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1'
        ts = '42609d8dab515a25ec2f3b3c7adafe57aa41b7be'
    }
}

function Invoke-GitRead {
    <# Run a git command and return its trimmed stdout, or $null if it failed.

       Every git call in the freshness path is READ-ONLY and is *expected* to fail in normal
       operation (symbolic-ref on a detached HEAD, ls-remote against an unreachable origin),
       so failure must be a return value rather than an exception. Two things are neutralized
       locally: $ErrorActionPreference (callers set 'Stop') and
       $PSNativeCommandUseErrorActionPreference, which turns a non-zero native exit into a
       terminating error on PowerShell configs where it's enabled. #>
    param([Parameter(Mandatory)][string[]]$Arguments)

    $ErrorActionPreference = 'Continue'
    $PSNativeCommandUseErrorActionPreference = $false

    try { $out = & git @Arguments 2>$null } catch { return $null }
    if ($LASTEXITCODE -ne 0) { return $null }
    if ($null -eq $out) { return '' }
    return (($out -join "`n").Trim())
}

function Get-GitRepoInfo {
    <# Read-only snapshot of a git work tree: HEAD, branch (or detached), commit date, origin.
       Never fetches, never writes a ref. Returns IsRepo=$false for a non-repo directory. #>
    param([Parameter(Mandatory)][string]$Dir)

    $info = [ordered]@{
        Dir = $Dir; IsRepo = $false; Branch = $null; Detached = $false
        Sha = $null; ShortSha = $null; CommittedAt = $null
        Remote = $null; OriginUrl = $null; OriginIsLocalDir = $false; OriginLocalPath = $null
    }
    if (-not (Test-Path -LiteralPath $Dir)) { return [pscustomobject]$info }

    if ((Invoke-GitRead @('-C', $Dir, 'rev-parse', '--is-inside-work-tree')) -ne 'true') {
        return [pscustomobject]$info
    }
    $info.IsRepo = $true

    # symbolic-ref -q fails on a detached HEAD — that is exactly the pinned-v1-clone signature,
    # and it's a purely local check (no network, no assumptions about the origin URL).
    $branch = Invoke-GitRead @('-C', $Dir, 'symbolic-ref', '-q', '--short', 'HEAD')
    if ([string]::IsNullOrWhiteSpace($branch)) { $info.Detached = $true } else { $info.Branch = $branch }

    $info.Sha         = Invoke-GitRead @('-C', $Dir, 'rev-parse', 'HEAD')
    $info.ShortSha    = Invoke-GitRead @('-C', $Dir, 'rev-parse', '--short', 'HEAD')
    $info.CommittedAt = Invoke-GitRead @('-C', $Dir, 'log', '-1', '--format=%cI', 'HEAD')

    $remote = $null
    if ($info.Branch) { $remote = Invoke-GitRead @('-C', $Dir, 'config', '--get', "branch.$($info.Branch).remote") }
    if ([string]::IsNullOrWhiteSpace($remote)) { $remote = 'origin' }
    $info.Remote = $remote

    $url = Invoke-GitRead @('-C', $Dir, 'remote', 'get-url', $remote)
    if (-not [string]::IsNullOrWhiteSpace($url)) {
        $info.OriginUrl = $url
        # A filesystem origin means a clone-of-a-clone — how the "-v1" templates are created.
        if ($url -notmatch '^[a-z][a-z0-9+.-]*://' -and $url -notmatch '^[^/]+@[^/]+:') {
            $resolved = try { (Resolve-Path -LiteralPath $url -ErrorAction Stop).Path } catch { $null }
            if ($resolved -and (Test-Path -LiteralPath $resolved -PathType Container)) {
                $info.OriginIsLocalDir = $true
                $info.OriginLocalPath  = $resolved
            }
        }
    }
    return [pscustomobject]$info
}

function Get-TemplateFreshnessCachePath {
    <# One small file per remote, in the system temp dir.

       Temp dir, not companion-module-templates/: that directory may be read-only or shared
       via COMPANION_TEMPLATES_DIR, and a stray file inside a git clone shows up in its
       status. One file per remote rather than one shared map: several review sessions write
       concurrently, and with a single merged file the last writer silently drops the other
       remotes' entries. Independent files can't lose an update, so no lock is needed. #>
    param([string]$Key)

    $dir = Join-Path ([System.IO.Path]::GetTempPath()) 'companion-module-review/template-freshness'
    if (-not $Key) { return $dir }
    $md5   = [System.Security.Cryptography.MD5]::Create()
    $hash  = [BitConverter]::ToString($md5.ComputeHash([Text.Encoding]::UTF8.GetBytes($Key))).Replace('-', '').ToLower()
    $md5.Dispose()
    return Join-Path $dir "$hash.json"
}

function Get-RemoteHeadSha {
    <#
    .SYNOPSIS
        Resolve a remote branch tip with `git ls-remote` — read-only, no fetch, no ref writes.
    .DESCRIPTION
        Cached with a short TTL because the validator runs twice per review (once nested in
        module-facts.ps1, once from the orchestrator) against up to two clones, and every extra
        network round-trip is another chance for a transient failure to become a blocking
        TEMPLATE-UNVERIFIED.

        ONLY the remote side is cached; the local SHA is always read fresh. That makes the
        cache self-invalidating: the moment update-templates.ps1 fast-forwards a clone,
        local == cachedRemote and the next run reads 'fresh' with no stale window.

        Failures are never cached — a cached failure would keep reviews blocked for the whole
        TTL after the network came back.
    .OUTPUTS
        [pscustomobject] Sha, Cached (bool), Error
    #>
    param(
        [Parameter(Mandatory)][string]$Url,
        [Parameter(Mandatory)][string]$Branch,
        [int]$TtlSeconds = -1
    )

    if ($TtlSeconds -lt 0) {
        $TtlSeconds = 600
        if ($env:COMPANION_TEMPLATE_FRESHNESS_TTL) {
            $parsed = 0
            if ([int]::TryParse($env:COMPANION_TEMPLATE_FRESHNESS_TTL, [ref]$parsed)) { $TtlSeconds = $parsed }
        }
    }

    $key       = "$Url#$Branch"
    $cachePath = Get-TemplateFreshnessCachePath -Key $key
    if ($TtlSeconds -gt 0 -and (Test-Path -LiteralPath $cachePath)) {
        # A partially-written or corrupt entry is indistinguishable from no entry: both mean
        # "look it up again". Never let a bad cache file fail a review.
        try {
            $entry = Get-Content -Raw -LiteralPath $cachePath | ConvertFrom-Json -AsHashtable
            $age = ([datetime]::UtcNow - ([datetime]$entry['checkedAt']).ToUniversalTime()).TotalSeconds
            if ($age -ge 0 -and $age -lt $TtlSeconds -and $entry['remoteSha'] -match '^[0-9a-f]{40}$') {
                return [pscustomobject]@{ Sha = $entry['remoteSha']; Cached = $true; Error = $null }
            }
        } catch { }
    }

    # Guard against a credential prompt or a dead connection hanging the whole review.
    $prevPrompt = $env:GIT_TERMINAL_PROMPT
    $prevLimit  = $env:GIT_HTTP_LOW_SPEED_LIMIT
    $prevTime   = $env:GIT_HTTP_LOW_SPEED_TIME
    $env:GIT_TERMINAL_PROMPT     = '0'
    $env:GIT_HTTP_LOW_SPEED_LIMIT = '1000'
    $env:GIT_HTTP_LOW_SPEED_TIME  = '10'
    try {
        $raw = Invoke-GitRead @('ls-remote', '--heads', $Url, $Branch)
    } finally {
        $env:GIT_TERMINAL_PROMPT      = $prevPrompt
        $env:GIT_HTTP_LOW_SPEED_LIMIT = $prevLimit
        $env:GIT_HTTP_LOW_SPEED_TIME  = $prevTime
    }

    if ($null -eq $raw) {
        return [pscustomobject]@{ Sha = $null; Cached = $false; Error = "git ls-remote failed for $Url" }
    }
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return [pscustomobject]@{ Sha = $null; Cached = $false; Error = "remote $Url has no branch '$Branch'" }
    }
    $sha = ($raw -split "`n")[0].Split("`t")[0].Trim()
    if ($sha -notmatch '^[0-9a-f]{40}$') {
        return [pscustomobject]@{ Sha = $null; Cached = $false; Error = "unparseable ls-remote output for $Url" }
    }

    if ($TtlSeconds -gt 0) {
        # Temp file + atomic move, so a concurrent reader never sees a half-written entry.
        # The cache is a pure optimization: if any of this fails, carry on silently.
        try {
            $dir = Split-Path -Parent $cachePath
            if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
            $tmp = "$cachePath.$PID-$([guid]::NewGuid().ToString('N').Substring(0,8)).tmp"
            @{ url = $Url; branch = $Branch; remoteSha = $sha; checkedAt = [datetime]::UtcNow.ToString('o') } |
                ConvertTo-Json -Depth 3 | Set-Content -LiteralPath $tmp -Encoding utf8NoBOM
            Move-Item -LiteralPath $tmp -Destination $cachePath -Force
        } catch { }
    }

    return [pscustomobject]@{ Sha = $sha; Cached = $false; Error = $null }
}

function Test-TemplateFreshness {
    <#
    .SYNOPSIS
        Is this template clone missing upstream changes? Read-only; never fetches or pulls.
    .DESCRIPTION
        Templates are shared by every concurrent review session, so this never modifies them —
        it only reports. Refreshing is a deliberate, separate act (scripts/update-templates.ps1).

        Status values:
          fresh      local HEAD == origin/<branch>
          stale      local HEAD != origin/<branch>            -> blocking
          unverified could not reach the remote                -> blocking
          pinned     detached HEAD (the "-v1" clones)          -> exempt by design
          unmanaged  not a git work tree (a plain copy or a test fixture)
          skipped    caller opted out
    .OUTPUTS
        [pscustomobject] dir, leaf, status, localSha, localShortSha, localDate, remoteSha,
                         branch, originUrl, cached, message
    #>
    param(
        [Parameter(Mandatory)][string]$TemplateDir,
        [switch]$SkipCheck
    )

    # Resolve-TemplatesDir returns COMPANION_TEMPLATES_DIR verbatim without validating it,
    # so a bad env var reaches here as a nonexistent path.
    $resolved = try { (Resolve-Path -LiteralPath $TemplateDir -ErrorAction Stop).Path } catch { $TemplateDir }
    $out = [ordered]@{
        dir = $resolved; leaf = (Split-Path $resolved -Leaf); status = 'unmanaged'
        localSha = $null; localShortSha = $null; localDate = $null; remoteSha = $null
        branch = $null; originUrl = $null; cached = $false; message = $null
    }

    if ($SkipCheck -or $env:COMPANION_SKIP_TEMPLATE_FRESHNESS -eq '1') {
        $out.status = 'skipped'
        $out.message = 'Freshness check skipped by request.'
        return [pscustomobject]$out
    }

    $info = Get-GitRepoInfo -Dir $resolved
    if (-not $info.IsRepo) {
        $out.message = "Not a git work tree — cannot verify against upstream."
        return [pscustomobject]$out
    }

    $out.localSha      = $info.Sha
    $out.localShortSha = $info.ShortSha
    $out.localDate     = if ($info.CommittedAt) { ($info.CommittedAt -split 'T')[0] } else { $null }
    $out.branch        = $info.Branch
    $out.originUrl     = $info.OriginUrl

    if ($info.Detached) {
        $out.status = 'pinned'
        $out.message = "Detached HEAD at $($info.ShortSha) — intentionally pinned, not checked against upstream."
        return [pscustomobject]$out
    }
    if (-not $info.OriginUrl) {
        # No remote configured is "not set up for upstream tracking", the same category as a
        # plain directory copy — NOT the same as a clone that names an upstream we then
        # failed to reach. The caller decides whether that's tolerable (it is for an
        # explicitly-passed -TemplateDir, it isn't for an auto-resolved production template).
        $out.status = 'unmanaged'
        $out.message = "No '$($info.Remote)' remote configured — cannot verify against upstream."
        return [pscustomobject]$out
    }

    $remote = Get-RemoteHeadSha -Url $info.OriginUrl -Branch $info.Branch
    $out.cached = $remote.Cached
    if (-not $remote.Sha) {
        $out.status  = 'unverified'
        $out.message = $remote.Error
        return [pscustomobject]$out
    }

    $out.remoteSha = $remote.Sha
    if ($remote.Sha -eq $info.Sha) {
        $out.status  = 'fresh'
        $out.message = "Up to date at $($info.ShortSha) ($($out.localDate), $($info.Branch))."
    } else {
        $out.status  = 'stale'
        # No commit count: without a fetch the remote object isn't local, so "N commits behind"
        # would be a guess. State the inequality and let update-templates.ps1 show the log.
        $out.message = "Local HEAD $($info.ShortSha) ($($out.localDate)) != $($info.Remote)/$($info.Branch) $($remote.Sha.Substring(0,7)) on $($info.OriginUrl)."
    }
    return [pscustomobject]$out
}

function Test-ModuleIsTypeScript {
    <# Single source of truth for TS-vs-JS classification, shared by validate-template.ps1
       and module-facts.ps1 so the two can't drift.

       TS is signalled ONLY by a tsconfig.json or actual .ts source files. A genuine TS
       module always ships a tsconfig.json (it can't compile without one), so this is
       sufficient. Deliberately NOT signalled by:
         - a `typescript` devDependency — now a standard peer of typescript-eslint for
           linting plain-JS modules with flat config (a JS module can declare it).
         - package.json "type": "module" — only marks the JS as ESM; pure-JS can be ESM too. #>
    param([Parameter(Mandatory)][string]$ModuleDir)

    if (Test-Path (Join-Path $ModuleDir 'tsconfig.json')) { return $true }
    $tsSrc = @(Get-ChildItem -Path (Join-Path $ModuleDir 'src') -Filter '*.ts' -Recurse -File -ErrorAction SilentlyContinue)
    return ($tsSrc.Count -gt 0)
}

function Get-CompanionBaseLockfileVersion {
    <# Internal: pull the resolved @companion-module/base version out of a lockfile's text.

       Lockfiles are parsed with regexes rather than a YAML/JSON library on purpose — the
       scripts stay dependency-free, and only one package's entry is ever needed. Returns the
       version string, or $null when the lockfile has no entry for the package (a stub or a
       lockfile from a different package manager). When the lockfile resolves the package more
       than once (a transitive copy alongside the direct one), the entry whose descriptor
       carries the package.json range wins; otherwise the first entry. #>
    param(
        [Parameter(Mandatory)][string]$Kind,
        [Parameter(Mandatory)][string]$Text,
        [string]$Range
    )

    $entries = [System.Collections.Generic.List[object]]::new()
    switch ($Kind) {
        'yarn' {
            # Yarn Berry:  "@companion-module/base@npm:~2.1.3":      then   version: 2.1.3
            # Yarn 1:      "@companion-module/base@~1.12.1":          then   version "1.12.1"
            # A header may list several descriptors ("a@npm:x, a@npm:y":). The block's version
            # line is the first `version` line indented under the header.
            $lines = $Text -split "`r?`n"
            for ($i = 0; $i -lt $lines.Count; $i++) {
                $h = $lines[$i]
                if ($h -notmatch '^\S' -or $h -notmatch '@companion-module/base@' -or $h -notmatch ':\s*$') { continue }
                for ($j = $i + 1; $j -lt $lines.Count -and $lines[$j] -match '^\s'; $j++) {
                    if ($lines[$j] -match '^\s+version:?\s+"?([0-9][^"\s]*)"?\s*$') {
                        $entries.Add([pscustomobject]@{ Header = $h; Version = $Matches[1] })
                        break
                    }
                }
            }
        }
        'npm' {
            try { $j = $Text | ConvertFrom-Json -AsHashtable } catch { return $null }
            if ($j -and $j.ContainsKey('packages') -and $j['packages'].ContainsKey('node_modules/@companion-module/base')) {
                return [string]$j['packages']['node_modules/@companion-module/base']['version']
            }
            # lockfileVersion 1 layout
            if ($j -and $j.ContainsKey('dependencies') -and $j['dependencies'].ContainsKey('@companion-module/base')) {
                return [string]$j['dependencies']['@companion-module/base']['version']
            }
            return $null
        }
        'pnpm' {
            # pnpm v6+ importer block:   '@companion-module/base':  specifier: ~2.1.3  version: 2.1.3
            if ($Text -match "(?m)^\s+'?@companion-module/base'?:\s*\r?\n\s+specifier:.*\r?\n\s+version:\s*'?([0-9][^'\s(]*)") {
                return $Matches[1]
            }
            # older inline importer form:   '@companion-module/base': 2.1.3
            if ($Text -match "(?m)^\s+'?@companion-module/base'?:\s*'?([0-9][^'\s(]*)'?\s*$") { return $Matches[1] }
            # packages section key:   /@companion-module/base@2.1.3:   or   '@companion-module/base@2.1.3':
            if ($Text -match "(?m)^\s+'?/?@companion-module/base@([0-9][^'\s:(]*)") { return $Matches[1] }
            return $null
        }
    }

    if ($entries.Count -eq 0) { return $null }
    if ($Range) {
        $want = [regex]::Escape($Range)
        $hit = @($entries | Where-Object { $_.Header -match "@companion-module/base@(npm:)?$want(\s*[,`"']|:\s*$)" } | Select-Object -First 1)
        if ($hit.Count -gt 0) { return $hit[0].Version }
    }
    return $entries[0].Version
}

function Resolve-CompanionBaseVersion {
    <#
    .SYNOPSIS
        Which @companion-module/base version does this module actually build against?
    .DESCRIPTION
        Mirrors Step 1 of the companion-v2-api-compliance skill, so the scripts and the
        reviewer agree on the API level being judged. A module on base 2.1 must be reviewed
        with the 2.1 rules, and a module on 2.0 must NOT be asked for 2.1 features — so the
        major version alone (what the scripts used before) is not enough.

        Sources, first hit wins — the installed version beats the declared range:
          1. yarn.lock            (Yarn Berry `"…@npm:range":` / `version: X`, and Yarn 1)
          2. package-lock.json
          3. pnpm-lock.yaml
          4. node_modules/@companion-module/base/package.json
          5. the package.json range:
               exact `2.1.3`                → that version
               `~2.1.3` / `2.1.x` / `2.1`  → 2.1 (patch-only range: unambiguous)
               `^2.0.0`, `>=2`, `*`, …      → AMBIGUOUS — spans minors; the lowest allowed
                                              minor is used and `ambiguous` is set so the
                                              review can suggest pinning
        A module with no @companion-module/base dependency at all keeps the scripts' old
        default (major 2) and is marked ambiguous.
    .OUTPUTS
        [pscustomobject] range, version, source, major, minor, apiLevel ('1' | '2.0' | '2.1'
        | '2.N'), ambiguous
    #>
    param([Parameter(Mandatory)][string]$ModuleDir)

    $range = $null
    $pkgPath = Join-Path $ModuleDir 'package.json'
    if (Test-Path -LiteralPath $pkgPath) {
        try {
            $pkg = Get-Content -Raw -LiteralPath $pkgPath | ConvertFrom-Json -AsHashtable
            if ($pkg -and $pkg.ContainsKey('dependencies') -and $pkg['dependencies'] -and $pkg['dependencies'].ContainsKey('@companion-module/base')) {
                $range = [string]$pkg['dependencies']['@companion-module/base']
            }
        } catch { }
    }

    $version = $null; $source = $null; $ambiguous = $false
    foreach ($lf in @(
            @{ File = 'yarn.lock';         Kind = 'yarn' }
            @{ File = 'package-lock.json'; Kind = 'npm' }
            @{ File = 'pnpm-lock.yaml';    Kind = 'pnpm' })) {
        $p = Join-Path $ModuleDir $lf.File
        if (-not (Test-Path -LiteralPath $p)) { continue }
        $text = Get-Content -Raw -LiteralPath $p -ErrorAction SilentlyContinue
        if (-not $text) { continue }
        $v = Get-CompanionBaseLockfileVersion -Kind $lf.Kind -Text $text -Range $range
        if ($v -match '^\d+\.\d+') { $version = $v; $source = $lf.File; break }
    }

    if (-not $version) {
        $nm = Join-Path $ModuleDir 'node_modules/@companion-module/base/package.json'
        if (Test-Path -LiteralPath $nm) {
            try {
                $v = (Get-Content -Raw -LiteralPath $nm | ConvertFrom-Json).version
                if ("$v" -match '^\d+\.\d+') { $version = "$v"; $source = 'node_modules' }
            } catch { }
        }
    }

    if (-not $version -and $range) {
        # Strip an aliased spec (npm:@companion-module/base@~2.1.3) down to the range itself.
        $r = ($range -replace '^npm:.*@', '').Trim()
        $source = 'package.json range'
        if ($r -match '^=?\s*v?(\d+)\.(\d+)\.(\d+)(-[0-9A-Za-z.-]+)?$') {
            $version = "$($Matches[1]).$($Matches[2]).$($Matches[3])$($Matches[4])"
        } elseif ($r -match '^~\s*v?(\d+)\.(\d+)(?:\.(\d+))?') {
            $version = "$($Matches[1]).$($Matches[2]).$(if ($Matches[3]) { $Matches[3] } else { '0' })"
        } elseif ($r -match '^v?(\d+)\.(\d+)(?:\.[xX*])?$') {
            $version = "$($Matches[1]).$($Matches[2]).0"
        } elseif ($r -match '(\d+)(?:\.(\d+|[xX*]))?(?:\.(\d+|[xX*]))?') {
            # ^X.Y.Z, >=X, X.x, X — anything that lets the minor float. Capture the groups
            # first: the -match calls below overwrite $Matches.
            $ma = $Matches[1]; $mi = "$($Matches[2])"; $pa = "$($Matches[3])"
            if ($mi -notmatch '^\d+$') { $mi = '0' }
            if ($pa -notmatch '^\d+$') { $pa = '0' }
            $version = "$ma.$mi.$pa"
            $ambiguous = $true
        }
    }

    $major = 2; $minor = 0
    if ($version -match '^(\d+)\.(\d+)') { $major = [int]$Matches[1]; $minor = [int]$Matches[2] }
    else { $source = 'none'; $ambiguous = $true }

    # A floating minor only matters once there is more than one API level per major.
    # Every 1.x module is reviewed with the single v1 skill, so it is never "ambiguous".
    if ($major -le 1) { $ambiguous = $false }

    return [pscustomobject]@{
        range     = $range
        version   = $version
        source    = $source
        major     = $major
        minor     = $minor
        apiLevel  = if ($major -le 1) { '1' } else { "$major.$minor" }
        ambiguous = $ambiguous
    }
}

function Get-CompanionApiProfile {
    <#
    .SYNOPSIS
        What a given API level means for a review: which compliance skill, which of that
        skill's per-version reference files, the minimum Companion release, and which
        manifest runtimes are legitimate.
    .DESCRIPTION
        The v2 compliance skill keeps one reference file per minor version
        (references/v2.0.md, references/v2.1.md, …) and a module is judged against every file
        up to its own level — never a later one. That is what stops a 2.0 module being told to
        adopt 2.1-only features. apiReferences lists the files that SHOULD apply; when
        -SkillsDir is given, any that don't exist there are reported in referencesMissing
        (e.g. a 2.2 module reviewed before anyone wrote references/v2.2.md).

        allowedRuntimes is $null for v1: v1 runtimes are judged against the pinned v1
        template exactly as before. For v2 the template still pins node22, but API 2.1 added
        node26 — so the runtime check can't be a plain template comparison any more.
    #>
    param(
        [Parameter(Mandatory)][string]$ApiLevel,
        [string]$SkillsDir
    )

    $major = 2; $minor = 0
    if ($ApiLevel -match '^(\d+)(?:\.(\d+))?$') {
        $major = [int]$Matches[1]
        if ($Matches[2]) { $minor = [int]$Matches[2] }
    }

    if ($major -le 1) {
        return [pscustomobject]@{
            apiSkill = 'companion-v1-api-compliance'; apiReferences = @(); referencesMissing = @()
            minCompanion = $null; allowedRuntimes = $null
        }
    }

    $skill = "companion-v$major-api-compliance"
    $refs = @(0..$minor | ForEach-Object { "references/v$major.$_.md" })
    $missing = @()
    if ($SkillsDir) {
        $skillDir = Join-Path $SkillsDir $skill
        $missing = @($refs | Where-Object { -not (Test-Path -LiteralPath (Join-Path $skillDir $_)) })
    }
    # Companion release that introduced each module API level. Unknown future levels report
    # $null rather than a guess.
    $minCompanion = @{ '2.0' = '4.3'; '2.1' = '5.0' }["$major.$minor"]
    # Assigned inside the branches: `$x = if (…) { @('a') }` would unroll the one-element
    # array to a bare string, and the JSON consumers expect a list.
    if ($major -eq 2 -and $minor -eq 0) { $runtimes = @('node22') } else { $runtimes = @('node22', 'node26') }

    return [pscustomobject]@{
        apiSkill          = $skill
        apiReferences     = $refs
        referencesMissing = $missing
        minCompanion      = $minCompanion
        allowedRuntimes   = $runtimes
    }
}

function ConvertTo-NormalizedTag {
    <# Strip a single leading 'v' so 'v2.1.0' and '2.1.0' compare equal. #>
    param([string]$Tag)
    if ($null -eq $Tag) { return '' }
    return ($Tag -replace '^v', '').Trim()
}

function Get-TrackerRows {
    <#
    .SYNOPSIS
        Parse reviews/TRACKER.md into row objects.
    .OUTPUTS
        [pscustomobject] with: Submitted (bool), Module, Version, Date, ReviewFile
        Tolerates freeform Review-File cells (e.g. "published. manual review.").
    #>
    param([Parameter(Mandatory)][string]$TrackerPath)

    if (-not (Test-Path $TrackerPath)) { return @() }

    $rows = foreach ($line in (Get-Content -LiteralPath $TrackerPath)) {
        $trimmed = $line.Trim()
        if (-not $trimmed.StartsWith('|')) { continue }            # not a table row
        if ($trimmed -match '^\|\s*:?-{2,}') { continue }          # separator row |:--|...
        if ($trimmed -match 'Feedback Submitted') { continue }     # header row

        # Split on '|'; outer empties from leading/trailing pipes are dropped by indexing.
        $cells = $trimmed.Trim('|').Split('|') | ForEach-Object { $_.Trim() }
        if ($cells.Count -lt 4) { continue }                       # malformed; skip

        [pscustomobject]@{
            Submitted  = $cells[0].Contains($script:SubmittedMark)
            Module     = $cells[1]
            Version    = $cells[2]
            Date       = $cells[3]
            ReviewFile = if ($cells.Count -ge 5) { $cells[4] } else { '' }
        }
    }
    return @($rows)
}

function Get-ReviewFile {
    <# Return review files under reviews/{Module}/ matching {Module} @ {GitTag} (v-insensitive). #>
    param(
        [Parameter(Mandatory)][string]$ReviewsDir,
        [Parameter(Mandatory)][string]$ModuleName,
        [Parameter(Mandatory)][string]$GitTag
    )

    $moduleDir = Join-Path $ReviewsDir $ModuleName
    if (-not (Test-Path $moduleDir)) { return @() }

    $normTag = ConvertTo-NormalizedTag $GitTag
    # Match both with and without the leading 'v' as written in the filename.
    $patterns = @(
        "review-$ModuleName-v$normTag-*.md",
        "review-$ModuleName-$normTag-*.md"
    )
    $files = foreach ($p in $patterns) {
        Get-ChildItem -LiteralPath $moduleDir -Filter $p -File -ErrorAction SilentlyContinue
    }
    return @($files | Sort-Object FullName -Unique)
}

function Get-ReviewState {
    <#
    .SYNOPSIS
        Determine the local review state for a module @ tag.
    .OUTPUTS
        [pscustomobject] with: State, ReviewFiles[], TrackerSubmitted (bool?), LastReviewDate
    #>
    param(
        [Parameter(Mandatory)][string]$ReviewsDir,
        [Parameter(Mandatory)][string]$TrackerPath,
        [Parameter(Mandatory)][string]$ModuleName,
        [Parameter(Mandatory)][string]$GitTag,
        # Optional pre-parsed rows so callers can parse TRACKER.md once for the whole queue.
        [object[]]$TrackerRows
    )

    $normTag = ConvertTo-NormalizedTag $GitTag

    if ($null -eq $TrackerRows) { $TrackerRows = @(Get-TrackerRows -TrackerPath $TrackerPath) }
    $matchingRows = @($TrackerRows | Where-Object {
        $_.Module -eq $ModuleName -and (ConvertTo-NormalizedTag $_.Version) -eq $normTag
    })

    $files = @(Get-ReviewFile -ReviewsDir $ReviewsDir -ModuleName $ModuleName -GitTag $GitTag)

    $hasReview    = ($files.Count -gt 0) -or ($matchingRows.Count -gt 0)
    $anySubmitted = @($matchingRows | Where-Object { $_.Submitted }).Count -gt 0

    $state =
        if (-not $hasReview)  { 'needs-review' }
        elseif ($anySubmitted) { 're-review' }
        else                   { 'feedback-pending' }

    $trackerSubmitted = if ($matchingRows.Count -eq 0) { $null } else { [bool]$anySubmitted }

    # Latest review date: prefer TRACKER row dates (YYYY-MM-DD sorts lexically), else file mtime.
    $lastDate = $null
    if ($matchingRows.Count -gt 0) {
        $lastDate = ($matchingRows | Sort-Object Date -Descending | Select-Object -First 1).Date
    } elseif ($files.Count -gt 0) {
        $lastDate = ($files | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime.ToString('yyyy-MM-dd')
    }

    return [pscustomobject]@{
        State           = $state
        ReviewFiles     = @($files | ForEach-Object { $_.Name })
        TrackerSubmitted = $trackerSubmitted
        LastReviewDate  = $lastDate
    }
}

function Get-ReviewStateLabel {
    <# Human-readable label for a state value. #>
    param([Parameter(Mandatory)][string]$State)
    switch ($State) {
        'needs-review'     { 'needs review' }
        'feedback-pending' { 'reviewed - feedback pending' }
        're-review'        { 're-review?' }
        default            { $State }
    }
}
