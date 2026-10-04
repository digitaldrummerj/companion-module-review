#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Self-contained tests for scripts/module-facts.ps1 (no Pester).
.DESCRIPTION
    Builds minimal module fixtures and asserts the fact sheet's language / API version /
    selected api-compliance skill / protocol detection. Uses -SkipTemplateCheck so the test
    doesn't depend on template repos.

    Run:  pwsh scripts/tests/ModuleFacts.Tests.ps1
#>

$ErrorActionPreference = 'Stop'
$facts = Join-Path $PSScriptRoot '..' 'module-facts.ps1'

$script:pass = 0; $script:fail = 0
function Ok($cond, $msg) {
    if ($cond) { $script:pass++; Write-Host "  PASS  $msg" -ForegroundColor Green }
    else       { $script:fail++; Write-Host "  FAIL  $msg" -ForegroundColor Red }
}
function Set-File($Path, $Content) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
    Set-Content -LiteralPath $Path -Value $Content -Encoding utf8 -NoNewline
}
function Facts($dir) {
    $out = & pwsh -NoProfile -File $facts -ModuleDir $dir -SkipTemplateCheck -Json 2>$null
    return ($out | ConvertFrom-Json)
}

$root = Join-Path ([System.IO.Path]::GetTempPath()) "modulefacts-$([System.IO.Path]::GetRandomFileName())"
try {
    # v1 TS module that speaks OSC
    $ts = Join-Path $root 'companion-module-v1ts'
    Set-File (Join-Path $ts 'tsconfig.json') '{}'
    Set-File (Join-Path $ts 'package.json') '{"name":"v1ts","version":"1.0.0","type":"module","dependencies":{"@companion-module/base":"~1.14.1","osc":"^2.4.0"}}'
    Set-File (Join-Path $ts 'src/main.ts') 'import osc from "osc"'
    Set-File (Join-Path $ts 'companion/manifest.json') '{"id":"v1ts","runtime":{"entrypoint":"../dist/main.js"}}'

    $f = Facts $ts
    Ok ($f.language -eq 'TS')                           "TS detected (tsconfig + type module)"
    Ok ($f.apiVersion -eq 'v1')                         "v1 detected from base ~1.14.1"
    Ok ($f.apiSkill -eq 'companion-v1-api-compliance')  "selects v1 api-compliance skill"
    Ok (@($f.protocols) -contains 'OSC')                "detects OSC protocol"
    Ok ($f.srcFileCount -eq 1)                          "counts src files"

    # v2 JS module, HTTP
    $js = Join-Path $root 'companion-module-v2js'
    Set-File (Join-Path $js 'package.json') '{"name":"v2js","version":"2.0.0","dependencies":{"@companion-module/base":"~2.0.4","axios":"^1"}}'
    Set-File (Join-Path $js 'src/main.js') 'const axios = require("axios")'

    $f2 = Facts $js
    Ok ($f2.language -eq 'JS')                           "JS detected (no tsconfig, no type module)"
    Ok ($f2.apiVersion -eq 'v2')                         "v2 detected from base ~2.0.4"
    Ok ($f2.apiSkill -eq 'companion-v2-api-compliance')  "selects v2 api-compliance skill"
    Ok (@($f2.protocols) -contains 'HTTP')               "detects HTTP protocol"

    # JS module that declares a `typescript` devDependency (the typescript-eslint peer).
    # Must stay JS — a devDep is not a TS signal. (Regression: yunxi-yolobox v1.0.3.)
    $jsTsDep = Join-Path $root 'companion-module-jstsdep'
    Set-File (Join-Path $jsTsDep 'package.json') '{"name":"jstsdep","version":"1.0.0","type":"module","dependencies":{"@companion-module/base":"~1.12.0"},"devDependencies":{"typescript":"^5.6.0","typescript-eslint":"^8.44.1"}}'
    Set-File (Join-Path $jsTsDep 'src/index.js') 'export default {}'

    $f3 = Facts $jsTsDep
    Ok ($f3.language -eq 'JS')  "JS with a typescript devDependency stays JS"

    # ESM JS module (type: module, no tsconfig, no .ts) — must stay JS.
    $jsEsm = Join-Path $root 'companion-module-jsesm'
    Set-File (Join-Path $jsEsm 'package.json') '{"name":"jsesm","version":"1.0.0","type":"module","dependencies":{"@companion-module/base":"~1.12.0"}}'
    Set-File (Join-Path $jsEsm 'src/index.js') 'export default {}'

    $f4 = Facts $jsEsm
    Ok ($f4.language -eq 'JS')  "ESM JS module (type:module, no tsconfig) stays JS"

    # ── API level (not just the major) ───────────────────────────────────────
    # v1: one skill, no reference files, apiVersion/apiSkill unchanged.
    Ok ($f.apiLevel -eq '1')                            "v1 module => apiLevel '1'"
    Ok (@($f.apiReferences).Count -eq 0)                "v1 module => no v2 reference files"

    # 2.0 from the package.json range: only references/v2.0.md, Companion 4.3+.
    Ok ($f2.apiLevel -eq '2.0')                         "~2.0.4 => apiLevel 2.0"
    Ok ((@($f2.apiReferences) -join ',') -eq 'references/v2.0.md') "2.0 => loads only references/v2.0.md"
    Ok ($f2.minCompanion -eq '4.3')                     "2.0 => Companion 4.3+"
    Ok ($f2.baseVersionSource -eq 'package.json range') "no lockfile => version from the range"
    Ok ($f2.apiAmbiguous -eq $false)                    "~2.0.4 is not ambiguous"

    # 2.1 from a Yarn Berry lockfile, even though package.json says ^2.0.0.
    $v21 = Join-Path $root 'companion-module-v21'
    Set-File (Join-Path $v21 'tsconfig.json') '{}'
    Set-File (Join-Path $v21 'package.json') '{"name":"v21","version":"3.0.0","type":"module","dependencies":{"@companion-module/base":"^2.0.0"}}'
    Set-File (Join-Path $v21 'yarn.lock') "`"@companion-module/base@npm:^2.0.0`":`n  version: 2.1.3`n"
    Set-File (Join-Path $v21 'src/main.ts') 'export default class X {}'
    $f5 = Facts $v21
    Ok ($f5.apiVersion -eq 'v2')                        "2.1 module keeps apiVersion 'v2' (backward compatible)"
    Ok ($f5.apiSkill -eq 'companion-v2-api-compliance') "2.1 module keeps the v2 skill"
    Ok ($f5.apiLevel -eq '2.1')                         "lockfile 2.1.3 => apiLevel 2.1"
    Ok ($f5.baseVersion -eq '2.1.3')                    "baseVersion from the lockfile"
    Ok ($f5.baseVersionSource -eq 'yarn.lock')          "baseVersionSource yarn.lock"
    Ok ((@($f5.apiReferences) -join ',') -eq 'references/v2.0.md,references/v2.1.md') "2.1 => v2.0 + v2.1 references"
    Ok ($f5.minCompanion -eq '5.0')                     "2.1 => Companion 5.0+"
    Ok ($f5.apiAmbiguous -eq $false)                    "lockfile-resolved caret range is not ambiguous"

    # Caret range, no lockfile: ambiguous, lowest minor.
    $amb = Join-Path $root 'companion-module-amb'
    Set-File (Join-Path $amb 'package.json') '{"name":"amb","version":"1.0.0","dependencies":{"@companion-module/base":"^2.0.0"}}'
    Set-File (Join-Path $amb 'src/main.js') 'export default {}'
    $f6 = Facts $amb
    Ok ($f6.apiLevel -eq '2.0' -and $f6.apiAmbiguous -eq $true) "^2.0.0 without a lockfile => 2.0, ambiguous"

    # ── API scan hints are included (and can be skipped) ─────────────────────
    $scanMod = Join-Path $root 'companion-module-scanme'
    Set-File (Join-Path $scanMod 'package.json') '{"name":"scanme","version":"1.0.0","dependencies":{"@companion-module/base":"~2.1.3"}}'
    Set-File (Join-Path $scanMod 'src/main.js') "runEntrypoint(ModuleInstance, [])`nthis.checkFeedbacks()"
    $f7 = Facts $scanMod
    Ok ($null -ne $f7.apiScan -and $f7.apiScan.count -eq 2)  "apiScan included with its hint count"
    Ok ($f7.apiScan.byId.'V1-RUNENTRYPOINT' -eq 1)          "apiScan.byId groups hints by rule id"
    Ok (@($f7.apiScan.hints).Count -eq 2 -and -not $f7.apiScan.truncated) "apiScan.hints carries the hints"
    Ok (@($f.apiScan.hints).Count -eq 0)                     "v1 module => no api-scan hints"
    $f8 = (& pwsh -NoProfile -File $facts -ModuleDir $scanMod -SkipTemplateCheck -SkipApiScan -Json 2>$null) | ConvertFrom-Json
    Ok ($null -eq $f8.apiScan)                               "-SkipApiScan omits apiScan"
}
finally {
    if (Test-Path $root) { Remove-Item -Recurse -Force $root }
}

Write-Host ""
Write-Host "$($script:pass) passed, $($script:fail) failed" -ForegroundColor ($(if ($script:fail) { 'Red' } else { 'Green' }))
if ($script:fail) { exit 1 }
