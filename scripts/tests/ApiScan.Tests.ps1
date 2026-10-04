#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Self-contained tests for scripts/api-scan.ps1 (no Pester).
.DESCRIPTION
    Builds small module fixtures at API 1, 2.0 and 2.1 and asserts which hints fire. The
    point of the scan is "the right rules for the module's own API level": v1 leftovers on any
    v2 module, 2.1-only features flagged ONLY on 2.0 modules, the 2.1 typing rules ONLY on 2.1
    modules, and nothing at all on v1 modules. Comments must never produce a hint.

    Run:  pwsh scripts/tests/ApiScan.Tests.ps1
#>

$ErrorActionPreference = 'Stop'
$scan = Join-Path $PSScriptRoot '..' 'api-scan.ps1'

$script:pass = 0; $script:fail = 0
function Ok($cond, $msg) {
    if ($cond) { $script:pass++; Write-Host "  PASS  $msg" -ForegroundColor Green }
    else       { $script:fail++; Write-Host "  FAIL  $msg" -ForegroundColor Red }
}
function Set-File($Path, $Content) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
    Set-Content -LiteralPath $Path -Value $Content -Encoding utf8 -NoNewline
}
function New-Module($Name, $Version, [hashtable]$Src, [string]$Runtime = 'node22') {
    $d = Join-Path $root "companion-module-$Name"
    Set-File (Join-Path $d 'package.json') "{`"name`":`"$Name`",`"version`":`"1.0.0`",`"dependencies`":{`"@companion-module/base`":`"~$Version`"}}"
    Set-File (Join-Path $d 'yarn.lock') "`"@companion-module/base@npm:~$Version`":`n  version: $Version`n"
    Set-File (Join-Path $d 'companion/manifest.json') "{`n  `"type`": `"connection`",`n  `"runtime`": { `"type`": `"$Runtime`", `"api`": `"nodejs-ipc`" }`n}"
    foreach ($k in $Src.Keys) { Set-File (Join-Path $d "src/$k") $Src[$k] }
    return $d
}
function Scan($Dir, [string[]]$Extra = @()) {
    $out = & pwsh -NoProfile -File $scan -ModuleDir $Dir -Json @Extra 2>$null
    $script:lastExit = $LASTEXITCODE
    return ($out | ConvertFrom-Json)
}
function Ids($r) { return @($r.hints | ForEach-Object { $_.id }) }
function Hits($r, $Id) { return @($r.hints | Where-Object { $_.id -eq $Id }) }

# v1 leftovers, one per line, so each rule can be asserted on its own.
$v1Leftovers = @'
import { runEntrypoint, InstanceBase, InputValue } from '@companion-module/base'
runEntrypoint(ModuleInstance, UpgradeScripts)
const host = await this.parseVariablesInString(opts.host)
this.checkFeedbacks()
this.setVariableDefinitions([{ variableId: 'a', name: 'A' }])
const field = { id: 'x', type: 'textinput', isVisible: (o) => o.mode === 1, required: true }
const def = { optionsToIgnoreForSubscribe: ['label'] }
const step = { delay: 100, relativeDelay: true }
'@
$v1Presets = @'
export function GetPresets() {
  const presets = { a: { type: 'button', category: 'Transport', name: 'A' } }
  this.setPresetDefinitions(GetPresetList(this))
  return presets
}
'@
$comments = @'
// runEntrypoint(ModuleInstance, [])  — a line comment
/* parseVariablesInString( in a block comment */
/**
 * this.checkFeedbacks() inside JSDoc
 * setVariableDefinitions([ ... ])
 */
const glob = 'src/**/*.ts'
runEntrypoint(AfterGlob)
const url = 'http://example.com/x' // and a trailing comment: checkFeedbacks()
const inputValue = `${input}x`
const meta = { category: 'not-a-preset-file' }
this.setPresetDefinitions(structure, presets)
'@
$later21 = @'
const a = { hasResult: true, callback: async (e, context) => { if (context.signal.aborted) return } }
const f = { type: 'advanced', affectedProperties: ['bgcolor'], callback: () => ({}) }
const p = { type: 'layered', elements: [] }
const q = { type: 'alternatives', variants: [] }
const s = { actionId: 'internal:wait', options: { time: 500 } }
const lv = { variableType: 'feedback', variableName: 'lvl', feedbackId: 'level' }
this.setCompositeElementDefinitions({})
export const UpgradeScripts = [CreateUseActionResultStoreUpgradeScript({ read: 'var' })]
'@

$root = Join-Path ([System.IO.Path]::GetTempPath()) "apiscan-$([System.IO.Path]::GetRandomFileName())"
try {
    Write-Host "v2.1 module with v1 leftovers"
    $m = New-Module 'leftovers' '2.1.3' @{ 'main.ts' = $v1Leftovers; 'presets.ts' = $v1Presets }
    $r = Scan $m
    Ok ($script:lastExit -eq 0)                         "exit code 0 even with hints (hints never block)"
    Ok ($r.apiLevel -eq '2.1')                          "apiLevel resolved from yarn.lock"
    foreach ($id in 'V1-RUNENTRYPOINT', 'V1-PARSEVARIABLES', 'V1-CHECKFEEDBACKS-NOARGS', 'V1-VARDEFS-ARRAY',
                    'V1-ISVISIBLE-FN', 'V1-OPTIONS-IGNORE', 'V1-REQUIRED', 'V1-INPUTVALUE', 'V1-RELATIVEDELAY',
                    'V1-PRESETS-SINGLE-ARG') {
        Ok ((Hits $r $id).Count -ge 1) "fires $id"
    }
    $pb = Hits $r 'V1-PRESET-BUTTON-CATEGORY'
    Ok ($pb.Count -eq 2)                                "V1-PRESET-BUTTON-CATEGORY fires for type 'button' and category: in a preset file"
    $rp = (Hits $r 'V1-RUNENTRYPOINT')[0]
    Ok ($rp.file -eq 'src/main.ts' -and $rp.line -eq 2) "hint carries file and 1-based line"
    Ok ($rp.verify -and $rp.message)                    "hint carries message and verify text"

    Write-Host "comments, strings and look-alikes"
    $c = Scan (New-Module 'comments' '2.1.3' @{ 'main.ts' = $comments })
    $cIds = Ids $c
    Ok ((Hits $c 'V1-RUNENTRYPOINT').Count -eq 1)          "only the real runEntrypoint call fires, not the commented ones"
    Ok ((Hits $c 'V1-RUNENTRYPOINT')[0].line -eq 8)        "…the line after a '/**/*' glob string is still scanned"
    Ok (-not ($cIds -contains 'V1-PARSEVARIABLES'))        "block comment does not fire"
    Ok (-not ($cIds -contains 'V1-CHECKFEEDBACKS-NOARGS')) "JSDoc and trailing comments do not fire"
    Ok (-not ($cIds -contains 'V1-VARDEFS-ARRAY'))         "commented setVariableDefinitions does not fire"
    Ok (-not ($cIds -contains 'V1-INPUTVALUE'))            "a variable named inputValue is not the InputValue type (case-sensitive)"
    Ok (-not ($cIds -contains 'V1-PRESET-BUTTON-CATEGORY')) "category: outside a preset file does not fire"
    Ok (-not ($cIds -contains 'V1-PRESETS-SINGLE-ARG'))    "setPresetDefinitions(structure, presets) is the v2 form"

    Write-Host "2.0 module using 2.1-only features"
    $m20 = New-Module 'uses21' '2.0.4' @{ 'main.ts' = $later21; 'actions.ts' = "const a = { subscribe: () => {}, callback: () => { context.setCustomVariableValue('x', 1) } }" } 'node26'
    $r20 = Scan $m20
    $l = Hits $r20 'LATER-API-2.1'
    # 9 source features (hasResult, context.signal, affectedProperties, layered, alternatives,
    # internal:*, feedback local variable, composite elements, result-store helper) + manifest.
    Ok ($l.Count -eq 10)                                 "LATER-API-2.1 fires for each 2.1-only feature + manifest node26 (got $($l.Count))"
    Ok (@($l | Where-Object { $_.file -eq 'companion/manifest.json' }).Count -eq 1) "…including runtime node26 in the manifest"
    Ok (@($l | ForEach-Object { $_.level } | Sort-Object -Unique) -join ',' -eq '2.0-only') "LATER-API-2.1 is labelled 2.0-only"
    Ok ((Hits $r20 'SUBSCRIBE-NO-MONITOR').Count -eq 0)  "2.1 typing rules do not apply to a 2.0 module (subscribe)"
    Ok ((Hits $r20 'SETCUSTOMVAR-DEPRECATED').Count -eq 0) "setCustomVariableValue is not 'deprecated' on 2.0"

    Write-Host "the same code on a 2.1 module"
    $m21 = New-Module 'is21' '2.1.3' @{ 'main.ts' = $later21 } 'node26'
    $r21 = Scan $m21
    Ok ((Hits $r21 'LATER-API-2.1').Count -eq 0)         "no LATER-API-2.1 hints on a 2.1 module"
    Ok ((Hits $r21 'ADV-FEEDBACK-NO-AFFECTED').Count -eq 0) "advanced feedback WITH affectedProperties is fine"

    Write-Host "2.1 typing rules"
    $adv = New-Module 'adv' '2.1.3' @{
        'feedbacks.ts' = "export const f = {`n  status: {`n    type: 'advanced',`n    name: 'S',`n    options: [],`n    callback: () => ({ bgcolor: 1 }),`n  },`n}"
        'schema.ts'    = "export type FeedbacksSchema = { status: { type: 'advanced'; options: {} } }"
        'actions.ts'   = "export const a = {`n  watch: {`n    name: 'W', options: [],`n    subscribe: async (a) => {},`n    callback: async () => {},`n  },`n}"
        'actions-ok.ts' = "export const a = { w: { subscribe: async () => {}, optionsToMonitorForSubscribe: ['ch'], callback: () => {} } }"
        'custom.ts'    = "callback: async (a, ctx) => { ctx.setCustomVariableValue('v', 1) }"
    }
    $ra = Scan $adv
    $ah = Hits $ra 'ADV-FEEDBACK-NO-AFFECTED'
    Ok ($ah.Count -eq 1 -and $ah[0].file -eq 'src/feedbacks.ts' -and $ah[0].line -eq 3) "ADV-FEEDBACK-NO-AFFECTED fires once, at the advanced definition"
    Ok (-not (@($ah | ForEach-Object { $_.file }) -contains 'src/schema.ts')) "…not on a schema-only type declaration"
    $sh = Hits $ra 'SUBSCRIBE-NO-MONITOR'
    Ok ($sh.Count -eq 1 -and $sh[0].file -eq 'src/actions.ts') "SUBSCRIBE-NO-MONITOR fires only where optionsToMonitorForSubscribe is missing"
    Ok ((Hits $ra 'SETCUSTOMVAR-DEPRECATED').Count -eq 1) "SETCUSTOMVAR-DEPRECATED fires on 2.1"

    Write-Host "v2 behaviours that compile but misbehave (any v2.x)"
    $beh = @{
        'tcp.ts'     = "import { TCPHelper } from '@companion-module/base'`nasync function go(s: TCPHelper) {`n  await this.socket.send('x')`n  this.socket.send('y')`n}"
        'ws.ts'      = "async function go(ws) { await ws.send('hi') }"
        'upgrade.ts' = "export const UpgradeScripts = [CreateConvertToBooleanFeedbackUpgradeScript({ a: true })]"
    }
    foreach ($v in '2.0.4', '2.1.3') {
        $rb = Scan (New-Module "beh$($v -replace '\.','')" $v $beh)
        $sa = Hits $rb 'HELPER-SEND-AWAIT'
        Ok ($sa.Count -eq 1 -and $sa[0].file -eq 'src/tcp.ts' -and $sa[0].line -eq 3) "[$v] HELPER-SEND-AWAIT only on the awaited TCPHelper send"
        Ok ((Hits $rb 'BOOL-FEEDBACK-HELPER-BUG').Count -eq 1) "[$v] BOOL-FEEDBACK-HELPER-BUG fires"
    }

    Write-Host "v1 modules are not scanned"
    $v1 = New-Module 'v1' '1.14.1' @{ 'main.ts' = $v1Leftovers }
    $rv1 = Scan $v1
    Ok ($rv1.apiLevel -eq '1')                           "v1 apiLevel"
    Ok ($rv1.counts.total -eq 0)                         "v1 module: no hints (v1 skill owns it)"
    Ok ($rv1.note -match 'v1')                           "v1 module: note explains why"

    Write-Host "-ApiLevel override"
    $ro = Scan $v1 @('-ApiLevel', '2.1')
    Ok ((Hits $ro 'V1-RUNENTRYPOINT').Count -ge 1)       "-ApiLevel 2.1 scans a module whose lockfile says 1.x"

    Write-Host "human output"
    $txt = & pwsh -NoProfile -File $scan -ModuleDir $m 2>&1 | Out-String
    Ok ($LASTEXITCODE -eq 0 -and $txt -match 'V1-RUNENTRYPOINT') "human-readable output lists hints and exits 0"
}
finally {
    if (Test-Path $root) { Remove-Item -Recurse -Force $root }
}

Write-Host ""
Write-Host "$($script:pass) passed, $($script:fail) failed" -ForegroundColor ($(if ($script:fail) { 'Red' } else { 'Green' }))
if ($script:fail) { exit 1 }
