#!/usr/bin/env pwsh
#Requires -Version 7
<#
.SYNOPSIS
    Deterministic API-usage scan of a Companion module: cheap, grep-based HINTS for the
    compliance reviewer, keyed to the module's own @companion-module/base API level.
.DESCRIPTION
    validate-template.ps1 owns the template rules; this script owns the API surface. It greps
    the module's src/ (comments stripped) and companion/manifest.json for patterns whose
    meaning depends on the API level the module actually builds against — resolved with the
    shared Resolve-CompanionBaseVersion (lockfile first), exactly as module-facts.ps1 and the
    compliance skill do:

      any v2.x   v1 leftovers that v2 removed or changed (runEntrypoint,
                 parseVariablesInString, checkFeedbacks() with no ids, array-form
                 setVariableDefinitions, isVisible functions, optionsToIgnoreForSubscribe,
                 'button' presets with category, single-argument setPresetDefinitions,
                 required:, InputValue, relativeDelay), plus two v2 behaviours that compile
                 fine but misbehave: awaiting TCPHelper/UDPHelper send() (synchronous since
                 2.0 — the promise form is sendAsync) and
                 CreateConvertToBooleanFeedbackUpgradeScript (copies the wrapped
                 { isExpression, value } option into the style).
      2.0.x      LATER-API-2.1: features that need base >= 2.1 (hasResult, context.signal,
                 affectedProperties, layered/alternatives presets, internal:* ids,
                 feedback-type local variables, composite elements,
                 CreateUseActionResultStoreUpgradeScript, manifest node26).
      2.1+       advanced feedbacks without affectedProperties, action subscribe without
                 optionsToMonitorForSubscribe (both TypeScript errors at 2.1.3), and the
                 deprecated setCustomVariableValue.
      v1         nothing — v1 modules are judged by companion-v1-api-compliance.

    Everything here is a HINT, never a finding: grep can't see types, runtime data, or which
    object a property sits on. The compliance reviewer opens each file:line, confirms it, and
    only then reports it. Exit code is always 0 so a hint can never block a review on its own.
.PARAMETER ModuleDir
    Path to the cloned module under review.
.PARAMETER ApiLevel
    Override the resolved API level ('1', '2.0', '2.1', …). For tests and what-if runs.
.PARAMETER Json
    Emit JSON instead of the human-readable list.
.EXAMPLE
    pwsh scripts/api-scan.ps1 -ModuleDir ../companion-modules-reviewing/companion-module-foo
    pwsh scripts/api-scan.ps1 -ModuleDir ./mod -Json
#>

param(
    [Parameter(Mandatory)][string]$ModuleDir,
    [string]$ApiLevel,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. "$PSScriptRoot/lib/ReviewState.ps1"

if (-not (Test-Path $ModuleDir)) { Write-Error "ModuleDir not found: $ModuleDir"; exit 2 }
$ModuleDir = (Resolve-Path $ModuleDir).Path

$base = Resolve-CompanionBaseVersion $ModuleDir
$level = if ($ApiLevel) { $ApiLevel } else { $base.apiLevel }
$major = 2; $minor = 0
if ($level -match '^(\d+)(?:\.(\d+))?$') { $major = [int]$Matches[1]; if ($Matches[2]) { $minor = [int]$Matches[2] } }
$isV2      = $major -ge 2
$is20      = $major -eq 2 -and $minor -eq 0
$isAtLeast21 = ($major -gt 2) -or ($major -eq 2 -and $minor -ge 1)

# ── Comment stripping ────────────────────────────────────────────────────────
# Quote-aware, so a glob like 'src/**/*.ts' or a URL 'http://x' inside a string is not taken
# for a comment. String CONTENTS are kept — several rules match on them ('internal:wait',
# type: 'button'). Template literals are treated like quotes but reset per line; a multi-line
# template literal can at worst hide or expose a line, which is acceptable for a hint.
function Get-CodeLines {
    param([string[]]$Lines)
    $out = [System.Collections.Generic.List[object]]::new()
    $inBlock = $false
    for ($n = 0; $n -lt $Lines.Count; $n++) {
        $line = $Lines[$n]
        $sb = [System.Text.StringBuilder]::new()
        $inStr = [char]0
        $i = 0
        while ($i -lt $line.Length) {
            $c = $line[$i]
            $next = if ($i + 1 -lt $line.Length) { $line[$i + 1] } else { [char]0 }
            if ($inBlock) {
                if ($c -eq '*' -and $next -eq '/') { $inBlock = $false; $i += 2; continue }
                $i++; continue
            }
            if ($inStr -ne [char]0) {
                [void]$sb.Append($c)
                if ($c -eq '\') { if ($next -ne [char]0) { [void]$sb.Append($next) }; $i += 2; continue }
                if ($c -eq $inStr) { $inStr = [char]0 }
                $i++; continue
            }
            if ($c -eq '/' -and $next -eq '/') { break }
            if ($c -eq '/' -and $next -eq '*') { $inBlock = $true; $i += 2; continue }
            if ($c -eq "'" -or $c -eq '"' -or $c -eq '`') { $inStr = $c }
            [void]$sb.Append($c)
            $i++
        }
        $code = $sb.ToString()
        if ($code.Trim()) { $out.Add([pscustomobject]@{ Line = $n + 1; Text = $code }) }
    }
    return $out
}

# ── Rules ────────────────────────────────────────────────────────────────────
# Scope: v2 = any 2.x · 2.0 = only 2.0.x modules · 2.1+ = 2.1 and later.
# Line rules match a regex against each comment-stripped line. File-scope rules are below.
$lineRules = @(
    @{ Id = 'V1-RUNENTRYPOINT';         Scope = 'v2'; Sev = 'Critical'; Re = '\brunEntrypoint\s*\('
       Msg = 'runEntrypoint() was removed in API 2.0'
       Verify = 'Use `export default class … extends InstanceBase` and export UpgradeScripts by name.' }
    @{ Id = 'V1-PARSEVARIABLES';        Scope = 'v2'; Sev = 'Critical'; Re = '\bparseVariablesInString\s*\('
       Msg = 'parseVariablesInString() was removed in API 2.0 (instance and callback context)'
       Verify = 'Companion now parses the option itself — the field must have useVariables: true (textinput) or be expression-capable.' }
    @{ Id = 'V1-CHECKFEEDBACKS-NOARGS'; Scope = 'v2'; Sev = 'Critical'; Re = '\bcheckFeedbacks\s*\(\s*\)'
       Msg = 'checkFeedbacks() with no ids no longer checks everything in API 2.0'
       Verify = 'Use checkAllFeedbacks(), or pass the feedback ids.' }
    @{ Id = 'V1-VARDEFS-ARRAY';         Scope = 'v2'; Sev = 'Critical'; Re = '\bsetVariableDefinitions\s*\(\s*\['
       Msg = 'setVariableDefinitions() takes an object keyed by variable id in API 2.0, not an array'
       Verify = 'Confirm the argument is { id: { name } }.' }
    # Deliberately NOT matching a bare `variableId:` — migrated modules keep it in their own
    # catalog data (ecamm-live: 40 false hits), so only the array-literal call is a signal.
    @{ Id = 'V1-ISVISIBLE-FN';          Scope = 'v2'; Sev = 'High';     Re = '\bisVisible\s*:'
       Msg = 'isVisible functions are ignored in API 2.0'
       Verify = 'Replace with isVisibleExpression; in actions/feedbacks it may only reference fields with disableAutoExpression: true.' }
    @{ Id = 'V1-OPTIONS-IGNORE';        Scope = 'v2'; Sev = 'High';     Re = '\boptionsToIgnoreForSubscribe\b'
       Msg = 'optionsToIgnoreForSubscribe was replaced by the allowlist optionsToMonitorForSubscribe'
       Verify = 'Invert the list into optionsToMonitorForSubscribe.' }
    @{ Id = 'V1-PRESET-BUTTON-CATEGORY'; Scope = 'v2'; Sev = 'Critical'; Re = '\btype\s*:\s*[''"]button[''"]'
       Msg = "v1 preset shape type: 'button' — API 2.0 presets are type: 'simple' placed by setPresetDefinitions(structure, presets)"
       Verify = 'Confirm this is a preset definition (not unrelated data).' }
    @{ Id = 'V1-REQUIRED';              Scope = 'v2'; Sev = 'High';     Re = '\brequired\s*:\s*true\b'
       Msg = '`required` was removed from input fields in API 2.0'
       Verify = 'On a textinput use minLength: 1; on other field types delete it. Ignore if this is not an input field.' }
    @{ Id = 'V1-INPUTVALUE';            Scope = 'v2'; Sev = 'High';     Re = '\bInputValue\b'
       Msg = 'The InputValue type was replaced by JsonValue in API 2.0'
       Verify = 'Prefer the schema-typed options; otherwise JsonValue.' }
    @{ Id = 'V1-RELATIVEDELAY';         Scope = 'v2'; Sev = 'High';     Re = '\brelativeDelay\b'
       Msg = 'relativeDelay was removed — preset delays are always relative in API 2.0'
       Verify = 'Remove the property; convert any absolute delays.' }
    @{ Id = 'BOOL-FEEDBACK-HELPER-BUG'; Scope = 'v2'; Sev = 'High';     Re = '\bCreateConvertToBooleanFeedbackUpgradeScript\b'
       Msg = 'In base 2.x this helper copies the wrapped { isExpression, value } option object into feedback.style'
       Verify = 'Check whether users can still upgrade from the pre-boolean version; if so the script should unwrap .value before writing the style.' }

    @{ Id = 'LATER-API-2.1'; Scope = '2.0'; Sev = 'Critical'; Re = '\bhasResult\s*:'
       Msg = 'hasResult (action results) needs base >= 2.1 (Companion 5.0+)'; Verify = 'Bump base to ~2.1.x or remove.' }
    @{ Id = 'LATER-API-2.1'; Scope = '2.0'; Sev = 'Critical'; Re = '\b(context|ctx)\s*\.\s*signal\b'
       Msg = 'context.signal (abort signals) needs base >= 2.1 (Companion 5.0+)'; Verify = 'Bump base to ~2.1.x or remove.' }
    @{ Id = 'LATER-API-2.1'; Scope = '2.0'; Sev = 'Critical'; Re = '\baffectedProperties\s*:'
       Msg = 'affectedProperties needs base >= 2.1 (not in the 2.0 types)'; Verify = 'Bump base to ~2.1.x or remove.' }
    @{ Id = 'LATER-API-2.1'; Scope = '2.0'; Sev = 'Critical'; Re = '\btype\s*:\s*[''"](layered|alternatives)[''"]'
       Msg = 'layered / alternatives presets need base >= 2.1 (Companion 5.0+)'; Verify = 'Confirm this is a preset; bump base or use a simple preset.' }
    @{ Id = 'LATER-API-2.1'; Scope = '2.0'; Sev = 'Critical'; Re = '[''"]internal:[A-Za-z]+[''"]'
       Msg = 'internal:* action/feedback ids in presets need base >= 2.1 (dropped with a warning before)'; Verify = 'Confirm it is inside a preset step; bump base or remove.' }
    @{ Id = 'LATER-API-2.1'; Scope = '2.0'; Sev = 'Critical'; Re = '\bvariableType\s*:\s*[''"]feedback[''"]'
       Msg = 'feedback-type preset local variables need base >= 2.1'; Verify = 'Bump base to ~2.1.x or use a simple local variable.' }
    @{ Id = 'LATER-API-2.1'; Scope = '2.0'; Sev = 'Critical'; Re = '\bsetCompositeElementDefinitions\s*\('
       Msg = 'composite elements need base >= 2.1'; Verify = 'Bump base to ~2.1.x or remove.' }
    @{ Id = 'LATER-API-2.1'; Scope = '2.0'; Sev = 'Critical'; Re = '\bCreateUseActionResultStoreUpgradeScript\b'
       Msg = 'CreateUseActionResultStoreUpgradeScript needs base >= 2.1.1'; Verify = 'Bump base to ~2.1.x or remove.' }

    @{ Id = 'SETCUSTOMVAR-DEPRECATED'; Scope = '2.1+'; Sev = 'Medium'; Re = '\bsetCustomVariableValue\s*\('
       Msg = 'context.setCustomVariableValue is deprecated in API 2.1 — use the action result flow (hasResult)'
       Verify = 'Consider hasResult + CreateUseActionResultStoreUpgradeScript (2.1.1+) to migrate saved actions.' }
)

function Test-InScope { param([string]$Scope)
    switch ($Scope) {
        'v2'   { return $isV2 }
        '2.0'  { return $is20 }
        '2.1+' { return $isAtLeast21 }
    }
    return $false
}

$hints = [System.Collections.Generic.List[object]]::new()
function Add-Hint {
    param([string]$Id, [string]$Scope, [string]$Sev, [string]$File, [int]$Line, [string]$Msg, [string]$Verify, [string]$Code)
    $label = switch ($Scope) { 'v2' { 'v2.x' } '2.0' { '2.0-only' } '2.1+' { '2.1+' } default { $Scope } }
    $hints.Add([pscustomobject]@{
        id = $Id; level = $label; severityHint = $Sev; file = $File; line = $Line
        message = $Msg; verify = $Verify; code = if ($Code) { $Code.Trim() } else { $null }
    })
}

$filesScanned = 0
$srcDir = Join-Path $ModuleDir 'src'
if ($isV2 -and (Test-Path $srcDir)) {
    $files = @(Get-ChildItem -LiteralPath $srcDir -Recurse -File -Include '*.ts', '*.js', '*.mjs', '*.cjs', '*.mts', '*.cts' -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notlike '*.d.ts' -and $_.FullName -notmatch '[\\/]node_modules[\\/]' })
    foreach ($f in $files) {
        $filesScanned++
        $rel = $f.FullName.Substring($ModuleDir.Length).TrimStart('/', '\') -replace '\\', '/'
        $raw = @(Get-Content -LiteralPath $f.FullName -ErrorAction SilentlyContinue)
        $code = @(Get-CodeLines -Lines $raw)
        $all = ($code | ForEach-Object { $_.Text }) -join "`n"

        foreach ($cl in $code) {
            foreach ($r in $lineRules) {
                if (-not (Test-InScope $r.Scope)) { continue }
                if ($cl.Text -cmatch $r.Re) { Add-Hint $r.Id $r.Scope $r.Sev $rel $cl.Line $r.Msg $r.Verify $cl.Text }
            }

            # v1 preset category — only in preset files: `category:` is too common elsewhere.
            if ($isV2 -and $f.Name -match '(?i)preset' -and $cl.Text -cmatch '\bcategory\s*:') {
                Add-Hint 'V1-PRESET-BUTTON-CATEGORY' 'v2' 'Critical' $rel $cl.Line `
                    'v1 preset `category:` — API 2.0 places presets with setPresetDefinitions(structure, presets) sections/groups' `
                    'Confirm this is a preset definition; move the grouping into the structure argument.' $cl.Text
            }

            # setPresetDefinitions(x) with ONE argument — the v1 call. Arguments are read with a
            # balanced-paren scan on the same line, so setPresetDefinitions(GetPresets(this)) is
            # one argument and setPresetDefinitions(structure, presets) is two.
            if ($isV2 -and $cl.Text -cmatch '\bsetPresetDefinitions\s*\(') {
                $start = $cl.Text.IndexOf('(', $cl.Text.IndexOf('setPresetDefinitions')) + 1
                $depth = 1; $commas = 0; $closed = $false
                for ($k = $start; $k -lt $cl.Text.Length; $k++) {
                    $ch = $cl.Text[$k]
                    if ($ch -in '(', '[', '{') { $depth++ }
                    elseif ($ch -in ')', ']', '}') { $depth--; if ($depth -eq 0) { $closed = $true; break } }
                    elseif ($ch -eq ',' -and $depth -eq 1) { $commas++ }
                }
                $argText = if ($closed) { $cl.Text.Substring($start, $k - $start).Trim() } else { '' }
                if ($closed -and $argText -and $commas -eq 0) {
                    Add-Hint 'V1-PRESETS-SINGLE-ARG' 'v2' 'Critical' $rel $cl.Line `
                        'setPresetDefinitions() takes (structure, presets) in API 2.0 — this call passes one argument' `
                        'Confirm the call site; build a CompanionPresetSection[] structure.' $cl.Text
                }
            }
        }

        # await on TCPHelper/UDPHelper/TelnetHelper send(): synchronous since base 2.0 (returns
        # boolean / void). Awaiting it compiles, but the old promise behaviour (rejections,
        # waiting for the write) is now sendAsync(). Only in files that use the helpers.
        if ($isV2 -and $all -cmatch '\b(TCPHelper|UDPHelper|TelnetHelper)\b') {
            foreach ($cl in $code) {
                if ($cl.Text -cmatch '\bawait\s+[\w$.?\[\]()]*\.send\s*\(') {
                    Add-Hint 'HELPER-SEND-AWAIT' 'v2' 'High' $rel $cl.Line `
                        'TCPHelper/UDPHelper send() is synchronous in base 2.x; awaiting it no longer waits for or surfaces the write' `
                        'If the caller relies on the promise (await / .catch), use sendAsync(); otherwise drop the await.' $cl.Text
                }
            }
        }

        if ($isAtLeast21) {
            # Advanced feedback without affectedProperties — a TypeScript error at base 2.1.3
            # (required key) and a debug-log warning for JS. File-level: the definition and the
            # property normally sit in the same file; schema-only files (no callback) are skipped.
            $adv = @($code | Where-Object { $_.Text -cmatch '\btype\s*:\s*[''"]advanced[''"]' } | Select-Object -First 1)
            if ($adv.Count -gt 0 -and $all -cmatch '\bcallback\b' -and $all -cnotmatch '\baffectedProperties\b') {
                Add-Hint 'ADV-FEEDBACK-NO-AFFECTED' '2.1+' 'High' $rel $adv[0].Line `
                    'Advanced feedback without affectedProperties (required key at base 2.1.3; warning in the debug log otherwise)' `
                    "Add affectedProperties: ['bgcolor', …] or undefined — or prefer a boolean/value feedback." $adv[0].Text
            }
            # Action subscribe without optionsToMonitorForSubscribe — required alongside
            # subscribe in the 2.1 types. (v2 feedbacks have no subscribe, so any hit is an action.)
            $sub = @($code | Where-Object { $_.Text -cmatch '(^\s*(async\s+)?subscribe\s*\()|\bsubscribe\s*:' } | Select-Object -First 1)
            if ($sub.Count -gt 0 -and $all -cnotmatch '\boptionsToMonitorForSubscribe\b') {
                Add-Hint 'SUBSCRIBE-NO-MONITOR' '2.1+' 'High' $rel $sub[0].Line `
                    'Action subscribe without optionsToMonitorForSubscribe (required with subscribe in the 2.1 types)' `
                    'List the options whose change should re-run subscribe/unsubscribe.' $sub[0].Text
            }
        }
    }
}

# Manifest runtime node26 on a 2.0 module (validate-template reports it too, as MAN-RUNTIME;
# listing it here keeps every "needs 2.1" signal in one place for the compliance reviewer).
$manPath = Join-Path $ModuleDir 'companion/manifest.json'
if ($is20 -and (Test-Path $manPath)) {
    $mLines = @(Get-Content -LiteralPath $manPath)
    for ($n = 0; $n -lt $mLines.Count; $n++) {
        if ($mLines[$n] -match '"node26"') {
            Add-Hint 'LATER-API-2.1' '2.0' 'Critical' 'companion/manifest.json' ($n + 1) `
                'runtime.type node26 needs base >= 2.1 (Companion 5.0+)' 'Use node22 or bump base to ~2.1.x.' $mLines[$n]
            break
        }
    }
}

$sorted = @($hints | Sort-Object file, line, id)
$byId = [ordered]@{}
foreach ($g in ($sorted | Group-Object id | Sort-Object Name)) { $byId[$g.Name] = $g.Count }

$result = [pscustomobject]@{
    module            = (Split-Path $ModuleDir -Leaf) -replace '^companion-module-', ''
    moduleDir         = $ModuleDir
    apiLevel          = $level
    baseVersion       = $base.version
    baseVersionSource = $base.source
    filesScanned      = $filesScanned
    note              = if (-not $isV2) { 'v1 module: no scan rules — judged by companion-v1-api-compliance.' } else { 'Hints only — verify each file:line before reporting.' }
    counts            = [pscustomobject]@{ total = $sorted.Count; byId = [pscustomobject]$byId }
    hints             = $sorted
}

if ($Json) {
    $result | ConvertTo-Json -Depth 6
    exit 0
}

Write-Host ""
Write-Host "api-scan — $($result.module)  (API $level; base $($base.version) from $($base.source))" -ForegroundColor Cyan
Write-Host ("─" * 70)
if (-not $isV2) {
    Write-Host "  v1 module — no scan rules; the v1 compliance skill covers it." -ForegroundColor DarkGray
} elseif ($sorted.Count -eq 0) {
    Write-Host "  No hints in $filesScanned source files." -ForegroundColor Green
} else {
    foreach ($h in $sorted) {
        $c = switch ($h.severityHint) { 'Critical' { 'Red' } 'High' { 'DarkYellow' } default { 'Gray' } }
        Write-Host ("  [{0}] {1}  {2}:{3} — {4}" -f $h.level, $h.id, $h.file, $h.line, $h.message) -ForegroundColor $c
    }
}
Write-Host ("─" * 70)
Write-Host ("{0} hints in {1} files. Hints are leads for the compliance reviewer, not findings." -f $sorted.Count, $filesScanned) -ForegroundColor DarkGray
Write-Host ""
exit 0
