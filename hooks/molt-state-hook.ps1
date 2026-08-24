param(
  [string]$Event = "manual",
  [string]$Harness = "unknown",
  [int]$DebounceSeconds = 300,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)

function Exit-Clean {
  param([string]$Message)
  if ($DryRun -and $Message) {
    Write-Output $Message
  }
  exit 0
}

try {
  $repoRoot = (& git rev-parse --show-toplevel 2>$null).Trim()
  if (-not $repoRoot) {
    Exit-Clean "MOLT: not in a git repo"
  }

  $statePath = Join-Path $repoRoot ".agents\STATE.md"
  $journalPath = Join-Path $repoRoot ".agents\JOURNAL.md"
  if (-not (Test-Path -LiteralPath $statePath)) {
    Exit-Clean "MOLT: .agents/STATE.md not present"
  }

  $remoteUrl = (& git -C $repoRoot remote get-url origin 2>$null).Trim()
  if ($remoteUrl -notmatch "(github\.com[:/](hongyime|bryanseah234)/)") {
    Exit-Clean "MOLT: repo origin not owned"
  }

  $branch = (& git -C $repoRoot branch --show-current 2>$null).Trim()
  if (-not $branch) {
    $branch = "detached"
  }
  $head = (& git -C $repoRoot rev-parse --short HEAD 2>$null).Trim()
  if (-not $head) {
    $head = "unknown"
  }
  $statusLines = @(& git -C $repoRoot status --porcelain 2>$null)
  $dirtyCount = (
    $statusLines |
      Where-Object {
        $_ -notmatch "\s\.agents/JOURNAL\.md$" -and
        $_ -notmatch "\s\.agents/STATE\.md$"
      } |
      Measure-Object
  ).Count
  $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss zzz")
  $machine = $env:COMPUTERNAME
  if (-not $machine) {
    $machine = "unknown-machine"
  }

  $event = ($Event -replace "[^A-Za-z0-9_.:-]", "-")
  $harness = ($Harness -replace "[^A-Za-z0-9_.:-]", "-")
  $resumeHint = "Read .agents/STATE.md, then the latest file in .agents/handoffs/ if present."

  $cacheRoot = Join-Path $env:LOCALAPPDATA "MOLT"
  $cacheInput = "$repoRoot|$branch|$harness|$event"
  $sha = [System.Security.Cryptography.SHA256]::Create()
  $hashBytes = $sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($cacheInput))
  $cacheName = ([BitConverter]::ToString($hashBytes) -replace "-", "").ToLowerInvariant()
  $cachePath = Join-Path $cacheRoot "$cacheName.stamp"
  if (-not $DryRun -and $DebounceSeconds -gt 0 -and (Test-Path -LiteralPath $cachePath)) {
    $lastWrite = (Get-Item -LiteralPath $cachePath).LastWriteTimeUtc
    if (((Get-Date).ToUniversalTime() - $lastWrite).TotalSeconds -lt $DebounceSeconds) {
      Exit-Clean "MOLT: debounced"
    }
  }

  $journalLine = "- $timestamp [$machine/$harness/$event] branch=$branch head=$head dirty=$dirtyCount"
  $autoBlock = @(
    "<!-- MOLT_AUTO_START -->",
    "## Auto State",
    "",
    "- Updated: $timestamp",
    "- Machine: $machine",
    "- Harness: $harness",
    "- Event: $event",
    "- Branch: $branch",
    "- HEAD: $head",
    "- Dirty files: $dirtyCount",
    "- Resume hint: $resumeHint",
    "<!-- MOLT_AUTO_END -->"
  ) -join [Environment]::NewLine

  if ($DryRun) {
    Write-Output "MOLT dry run"
    Write-Output "Repo: $repoRoot"
    Write-Output "Journal: $journalLine"
    Write-Output $autoBlock
    exit 0
  }

  $agentsDir = Split-Path -Parent $statePath
  if (-not (Test-Path -LiteralPath $agentsDir)) {
    Exit-Clean "MOLT: .agents missing"
  }

  if (-not (Test-Path -LiteralPath $cacheRoot)) {
    New-Item -ItemType Directory -Path $cacheRoot -Force | Out-Null
  }

  $mutexName = "Global\MOLT_STATE_" + $cacheName
  $mutex = [System.Threading.Mutex]::new($false, $mutexName)
  $lockTaken = $false
  try {
    $lockTaken = $mutex.WaitOne(2000)
    if (-not $lockTaken) {
      Exit-Clean "MOLT: lock busy"
    }

    if (-not (Test-Path -LiteralPath $journalPath)) {
      [System.IO.File]::WriteAllText($journalPath, "", $Utf8NoBom)
    }
    [System.IO.File]::AppendAllText($journalPath, $journalLine + [Environment]::NewLine, $Utf8NoBom)

    $state = [System.IO.File]::ReadAllText($statePath)
    $pattern = "(?s)<!-- MOLT_AUTO_START -->.*?<!-- MOLT_AUTO_END -->"
    if ($state -match $pattern) {
      $state = [regex]::Replace($state, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $autoBlock }, 1)
    } else {
      $state = $state.TrimEnd() + [Environment]::NewLine + [Environment]::NewLine + $autoBlock + [Environment]::NewLine
    }
    [System.IO.File]::WriteAllText($statePath, $state, $Utf8NoBom)
    [System.IO.File]::WriteAllText($cachePath, $timestamp, $Utf8NoBom)
  } finally {
    if ($lockTaken) {
      $mutex.ReleaseMutex()
    }
    $mutex.Dispose()
  }
  exit 0
} catch {
  if ($DryRun) {
    Write-Output "MOLT hook skipped: $($_.Exception.Message)"
  }
  exit 0
}
