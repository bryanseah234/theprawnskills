param(
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)

$hookScript = Join-Path $PSScriptRoot "molt-state-hook.ps1"

function Convert-ToJsonStable {
  param([object]$Value)
  return ($Value | ConvertTo-Json -Depth 50)
}

function Write-Utf8NoBom {
  param(
    [string]$Path,
    [string]$Value
  )
  [System.IO.File]::WriteAllText($Path, $Value + [Environment]::NewLine, $Utf8NoBom)
}

function Backup-File {
  param([string]$Path)
  if ($DryRun) {
    return
  }
  $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
  $backup = "$Path.molt-bak.$stamp"
  Copy-Item -LiteralPath $Path -Destination $backup -Force
}

function Add-CommandHook {
  param(
    [object]$Config,
    [string]$EventName,
    [string]$Command,
    [int]$Timeout = 10
  )

  if (-not $Config.hooks) {
    $Config | Add-Member -NotePropertyName hooks -NotePropertyValue ([pscustomobject]@{})
  }
  if (-not $Config.hooks.PSObject.Properties[$EventName]) {
    $Config.hooks | Add-Member -NotePropertyName $EventName -NotePropertyValue @()
  }

  $existing = @($Config.hooks.$EventName)
  foreach ($entry in $existing) {
    foreach ($hook in @($entry.hooks)) {
      if ($hook.command -eq $Command) {
        return $false
      }
    }
  }

  $newEntry = [pscustomobject]@{
    hooks = @(
      [pscustomobject]@{
        type = "command"
        command = $Command
        timeout = $Timeout
      }
    )
  }
  $Config.hooks.$EventName = @($Config.hooks.$EventName) + $newEntry
  return $true
}

function Install-Codex {
  $path = Join-Path $env:USERPROFILE ".codex\hooks.json"
  if (-not (Test-Path -LiteralPath $path)) {
    return "codex: hooks.json not found"
  }
  $config = Get-Content -Raw -LiteralPath $path -Encoding utf8 | ConvertFrom-Json
  $cmd = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$hookScript`" -Harness codex -Event session-start"
  $changed = Add-CommandHook -Config $config -EventName "SessionStart" -Command $cmd
  if ($changed -and -not $DryRun) {
    Backup-File -Path $path
    Write-Utf8NoBom -Path $path -Value (Convert-ToJsonStable $config)
  }
  return "codex: " + ($(if ($changed) { "installed" } else { "already installed" }))
}

function Install-Claude {
  $path = Join-Path $env:USERPROFILE ".claude\settings.json"
  if (-not (Test-Path -LiteralPath $path)) {
    return "claude: settings.json not found"
  }
  $config = Get-Content -Raw -LiteralPath $path -Encoding utf8 | ConvertFrom-Json
  $start = "pwsh -NoProfile -NonInteractive -File `"$hookScript`" -Harness claude -Event session-start"
  $stop = "pwsh -NoProfile -NonInteractive -File `"$hookScript`" -Harness claude -Event stop"
  $herdrScript = Join-Path $env:USERPROFILE ".claude\hooks\herdr-agent-state.ps1"
  $herdr = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$herdrScript`" session"
  $changedStart = Add-CommandHook -Config $config -EventName "SessionStart" -Command $start
  $changedStop = Add-CommandHook -Config $config -EventName "Stop" -Command $stop
  $changedHerdr = $false
  if (Test-Path -LiteralPath $herdrScript) {
    $changedHerdr = Add-CommandHook -Config $config -EventName "SessionStart" -Command $herdr
  }
  if (($changedStart -or $changedStop -or $changedHerdr) -and -not $DryRun) {
    Backup-File -Path $path
    Write-Utf8NoBom -Path $path -Value (Convert-ToJsonStable $config)
  }
  $status = if ($changedStart -or $changedStop -or $changedHerdr) { "installed" } else { "already installed" }
  return "claude: $status"
}

function Report-Detected {
  $items = @()
  if (Test-Path -LiteralPath (Join-Path $env:USERPROFILE ".gemini\settings.json")) {
    $items += "gemini: detected, not wired until hook schema is confirmed"
  }
  if (Test-Path -LiteralPath (Join-Path $env:USERPROFILE ".config\opencode\opencode.jsonc")) {
    $items += "opencode: detected, not wired until hook schema is confirmed"
  }
  if (Test-Path -LiteralPath (Join-Path $env:USERPROFILE ".kiro")) {
    $items += "kiro: detected, not wired until hook schema is confirmed"
  }
  return $items
}

if (-not (Test-Path -LiteralPath $hookScript)) {
  throw "Missing hook script: $hookScript"
}

$results = @()
$results += Install-Codex
$results += Install-Claude
$results += Report-Detected
$results | ForEach-Object { Write-Output $_ }
