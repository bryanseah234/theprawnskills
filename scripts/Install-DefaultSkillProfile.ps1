param(
  [string]$Workspace = "C:\Users\bryan\OneDrive\01 SKILLS\.agents",
  [switch]$WhatIfOnly
)

$ErrorActionPreference = "Stop"

function Read-TomlWithPython {
  param([string]$Path)
  $json = python -c "import json, pathlib, tomllib; print(json.dumps(tomllib.loads(pathlib.Path(r'$Path').read_text(encoding='utf-8-sig'))))"
  return $json | ConvertFrom-Json
}

function Add-Result {
  param($Results, [string]$Machine, [string]$Root, [string]$Status, [string]$Detail)
  $Results.Add([pscustomobject]@{ Machine=$Machine; Root=$Root; Status=$Status; Detail=$Detail })
}

function Install-ProfileLocally {
  param(
    [string]$MachineId,
    [string]$WorkspacePath,
    [array]$InstalledRoots,
    [array]$Skills,
    [bool]$WhatIfMode,
    $Results
  )

  $skillsRoot = Join-Path $WorkspacePath "skills"
  $today = Get-Date -Format "yyyy-MM-dd"

  foreach ($root in $InstalledRoots) {
    if (-not $WhatIfMode) {
      New-Item -ItemType Directory -Force -Path $root | Out-Null
    }

    foreach ($skillName in $Skills) {
      $src = Join-Path $skillsRoot $skillName
      $dst = Join-Path $root $skillName
      if (-not (Test-Path -LiteralPath (Join-Path $src "SKILL.md"))) {
        Add-Result $Results $MachineId $root "MISSING" $skillName
        continue
      }

      if ($WhatIfMode) {
        Add-Result $Results $MachineId $root "WOULD-INSTALL" $skillName
        continue
      }

      if (Test-Path -LiteralPath $dst) {
        $rootKey = ($root -replace "[:\\]+", "_").Trim("_")
        $archiveDir = Join-Path $WorkspacePath "_removed\$today\$MachineId\pre-default-profile\$rootKey"
        New-Item -ItemType Directory -Force -Path $archiveDir | Out-Null
        $archiveTarget = Join-Path $archiveDir $skillName
        if (Test-Path -LiteralPath $archiveTarget) {
          $archiveTarget = Join-Path $archiveDir ("$skillName-" + (Get-Date -Format "HHmmss"))
        }
        Move-Item -LiteralPath $dst -Destination $archiveTarget -Force
      }

      Copy-Item -LiteralPath $src -Destination $dst -Recurse -Force
      Add-Result $Results $MachineId $root "INSTALLED" $skillName
    }
  }
}

function Install-ProfileOverSsh {
  param(
    $Machine,
    [array]$Skills,
    [bool]$WhatIfMode,
    $Results
  )

  if (-not $Machine.ssh) {
    Add-Result $Results $Machine.id "-" "FAILED" "missing ssh alias"
    return
  }

  $canonicalRoot = [string]$Machine.canonical_root
  $installedRootsJson = @($Machine.installed_roots) | ConvertTo-Json -Compress
  $skillsJson = @($Skills) | ConvertTo-Json -Compress
  $whatIfLiteral = if ($WhatIfMode) { '$true' } else { '$false' }

  $remoteScript = @"
`$ErrorActionPreference = 'Stop'
`$workspacePath = '$($canonicalRoot.Replace("'", "''"))'
`$installedRoots = ConvertFrom-Json '$($installedRootsJson.Replace("'", "''"))'
`$skills = ConvertFrom-Json '$($skillsJson.Replace("'", "''"))'
`$whatIfMode = $whatIfLiteral
`$machineId = '$($Machine.id.Replace("'", "''"))'
`$skillsRoot = Join-Path `$workspacePath 'skills'
`$today = Get-Date -Format 'yyyy-MM-dd'
`$rows = New-Object System.Collections.Generic.List[object]
foreach (`$root in @(`$installedRoots)) {
  if (-not `$whatIfMode) { New-Item -ItemType Directory -Force -Path `$root | Out-Null }
  foreach (`$skillName in @(`$skills)) {
    `$src = Join-Path `$skillsRoot `$skillName
    `$dst = Join-Path `$root `$skillName
    if (-not (Test-Path -LiteralPath (Join-Path `$src 'SKILL.md'))) {
      `$rows.Add([pscustomobject]@{ Machine=`$machineId; Root=`$root; Status='MISSING'; Detail=`$skillName })
      continue
    }
    if (`$whatIfMode) {
      `$rows.Add([pscustomobject]@{ Machine=`$machineId; Root=`$root; Status='WOULD-INSTALL'; Detail=`$skillName })
      continue
    }
    if (Test-Path -LiteralPath `$dst) {
      `$rootKey = (`$root -replace '[:\\]+', '_').Trim('_')
      `$archiveDir = Join-Path `$workspacePath "_removed\`$today\`$machineId\pre-default-profile\`$rootKey"
      New-Item -ItemType Directory -Force -Path `$archiveDir | Out-Null
      `$archiveTarget = Join-Path `$archiveDir `$skillName
      if (Test-Path -LiteralPath `$archiveTarget) {
        `$archiveTarget = Join-Path `$archiveDir ("`$skillName-" + (Get-Date -Format 'HHmmss'))
      }
      Move-Item -LiteralPath `$dst -Destination `$archiveTarget -Force
    }
    Copy-Item -LiteralPath `$src -Destination `$dst -Recurse -Force
    `$rows.Add([pscustomobject]@{ Machine=`$machineId; Root=`$root; Status='INSTALLED'; Detail=`$skillName })
  }
}
`$rows | ConvertTo-Json -Compress
"@

  $encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($remoteScript))
  try {
    $output = ssh -o BatchMode=yes -o ConnectTimeout=10 $Machine.ssh "powershell -NoProfile -EncodedCommand $encoded"
    $jsonLine = ($output | Where-Object { $_ -match '^\[|^\{' } | Select-Object -First 1)
    if (-not $jsonLine) {
      Add-Result $Results $Machine.id "-" "FAILED" "no JSON result from ssh"
      return
    }
    $remoteRows = $jsonLine | ConvertFrom-Json
    foreach ($row in @($remoteRows)) {
      Add-Result $Results $row.Machine $row.Root $row.Status $row.Detail
    }
  } catch {
    Add-Result $Results $Machine.id "-" "FAILED" $_.Exception.Message
  }
}

$workspacePath = (Resolve-Path -LiteralPath $Workspace).Path
$profilePath = Join-Path $workspacePath "default-profile.toml"
$machinesPath = Join-Path $workspacePath "machines.toml"

$profile = Read-TomlWithPython -Path $profilePath
$machinesData = Read-TomlWithPython -Path $machinesPath
$skills = @($profile.skills)

$results = New-Object System.Collections.Generic.List[object]

foreach ($machine in @($machinesData.machines)) {
  if ($machine.enabled -ne $true) {
    Add-Result $results $machine.id "-" "SKIPPED" "disabled"
    continue
  }

  if ($machine.local -eq $true) {
    Install-ProfileLocally -MachineId $machine.id -WorkspacePath $workspacePath -InstalledRoots @($machine.installed_roots) -Skills $skills -WhatIfMode ([bool]$WhatIfOnly) -Results $results
  } else {
    Install-ProfileOverSsh -Machine $machine -Skills $skills -WhatIfMode ([bool]$WhatIfOnly) -Results $results
  }
}

$results | Format-Table -AutoSize
