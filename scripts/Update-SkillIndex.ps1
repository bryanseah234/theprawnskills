# Regenerates INDEX.md from the canonical skill library.
# Usage: pwsh -File scripts/Update-SkillIndex.ps1
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$skillsDir = Join-Path $root 'skills'
$profilePath = Join-Path $root 'default-profile.toml'

$installedRoots = [ordered]@{
    codex   = "$env:USERPROFILE\.codex\skills"
    claude  = "$env:USERPROFILE\.claude\skills"
    cursor  = "$env:USERPROFILE\.cursor\skills"
}
# opencode loads skills via the ~/.agents junction to canonical; no installed copy.

function Get-FrontmatterField([string]$text, [string]$field) {
    if ($text -match "(?m)^${field}:\s*(.+)$") { return $Matches[1].Trim().Trim('"') }
    return ''
}

function Get-Description([string]$text) {
    # Folded (>-) or plain description; join continuation lines until next key.
    $lines = $text -split "`r?`n"
    $collecting = $false
    $parts = @()
    foreach ($line in $lines) {
        if ($line -match '^description:\s*>?-?\s*$') { $collecting = $true; continue }
        if ($line -match '^description:\s*(.+)$') { return $Matches[1].Trim() }
        if ($collecting) {
            if ($line -match '^\s{2,}(\S.*)$' -and $line -notmatch '^[a-z_]+:') {
                $parts += $Matches[1].Trim()
            } elseif ($line.Trim() -ne '') { break }
        }
    }
    return ($parts -join ' ')
}

$profileSkills = @()
foreach ($line in Get-Content $profilePath) {
    if ($line -match '^\s*"([a-z0-9-]+)",?\s*$') { $profileSkills += $Matches[1] }
}

$entries = foreach ($dir in Get-ChildItem $skillsDir -Directory | Sort-Object Name) {
    $skillFile = Join-Path $dir.FullName 'SKILL.md'
    if (-not (Test-Path $skillFile)) { continue }
    $head = (Get-Content $skillFile -TotalCount 30) -join "`n"
    $name = Get-FrontmatterField $head 'name'
    if (-not $name) { $name = $dir.Name }
    $desc = Get-Description $head
    if ($desc.Length -gt 180) { $desc = $desc.Substring(0,177) + '...' }
    $desc = $desc -replace '\|', '\|'
    $installedIn = @()
    foreach ($k in $installedRoots.Keys) {
        if (Test-Path (Join-Path $installedRoots[$k] $dir.Name)) { $installedIn += $k }
    }
    $status = if ($dir.Name -in $profileSkills) { 'INSTALLED' } else { 'ON-DEMAND' }
    [pscustomobject]@{
        Name = $name; Desc = $desc
        Installed = ($(if ($installedIn) { $installedIn -join ', ' } else { '-' }))
        Status = $status
    }
}

$defaultCount = ($entries | Where-Object Status -eq 'INSTALLED').Count
$canonicalCount = $entries.Count

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add('# Skills Index')
$lines.Add('')
$lines.Add("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')")
$lines.Add('Canonical skill root: `C:\Users\bryan\OneDrive\01 SKILLS\.agents\skills`')
$lines.Add('')
$lines.Add('This library keeps the full canonical skill set in OneDrive, while installed agent roots expose the lean profile from `default-profile.toml`. Use `skill-router` to discover and load on-demand skills from `skills/<kebab-name>/SKILL.md`. Use `dotagents install`, not `dotagents sync`.')
$lines.Add('')
$lines.Add('## Installed Root Counts')
$lines.Add('')
$lines.Add('| Root | Count | Notes |')
$lines.Add('|---|---:|---|')
$lines.Add("| canonical library | $canonicalCount | Full OneDrive source library |")
$lines.Add("| default profile | $defaultCount | Desired baseline from default-profile.toml |")
foreach ($k in $installedRoots.Keys) {
    $c = (Get-ChildItem $installedRoots[$k] -Directory -ErrorAction SilentlyContinue |
        Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') }).Count
    $notes = if ($k -eq 'codex') { 'Lean profile; Codex runtime/system folders excluded from count' } else { 'Lean installed profile' }
    $lines.Add("| $k | $c | $notes |")
}
$lines.Add('')
$lines.Add('## Skills')
$lines.Add('')
$lines.Add('| Skill | Purpose | Installed In | Default Status |')
$lines.Add('|---|---|---|---|')
foreach ($e in $entries) {
    $lines.Add("| ``$($e.Name)`` | $($e.Desc) | $($e.Installed) | $($e.Status) |")
}
$lines.Add('')

Set-Content -LiteralPath (Join-Path $root 'INDEX.md') -Value $lines -Encoding UTF8
Write-Host "INDEX.md regenerated: $canonicalCount canonical, $defaultCount default profile."
