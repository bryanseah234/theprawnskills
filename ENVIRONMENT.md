# Environment: Windows 11 (PowerShell)

**This machine runs Windows 11. Bash is broken (fork errors). Always use PowerShell.**

## Shell rules

- Tool: use `PowerShell` tool, NOT `Bash` tool
- Shell: `pwsh` / `powershell` — NOT `bash`, `sh`, `zsh`
- Paths: `C:\Users\...` or `C:/Users/...` — NOT `/c/Users/...`

## Command translation

| Unix (avoid) | PowerShell (use) |
|---|---|
| `find . -name "*.ts"` | `Get-ChildItem -Recurse -Filter "*.ts"` |
| `grep -r "text" .` | `Select-String -Recurse -Pattern "text"` |
| `cat file.txt` | `Get-Content file.txt` |
| `ls` | `Get-ChildItem` or `ls` (alias works) |
| `mkdir -p a/b` | `New-Item -ItemType Directory -Force a/b` |
| `rm -rf dir` | `Remove-Item -Recurse -Force dir` |
| `chmod +x` | skip (not applicable) |
| `cmd 2>/dev/null` | `cmd 2>$null` |
| `&&` chaining | `&&` works in PowerShell 7+, or use `;` |
| `export VAR=val` | `$env:VAR = "val"` |

## File paths

Always use Windows-style paths or forward-slash equivalents:
- `C:\Users\bryan\` or `C:/Users/bryan/`
- UNC: `\\server\share` or `//server/share`
- Drive X: `X:\01 REPOSITORIES\` or `X:/01 REPOSITORIES/`

## Available tools

- `git`, `node`, `npm`, `docker`, `python` — all available via PowerShell
- Python: `python` (NOT `python3`)
- Node: `node`, `npx`

## dotagents

- **Use `npx @sentry/dotagents --user install`** to update skills from remote sources.
- **NEVER run `dotagents sync`** — it re-adopts ~76 unmanaged local skills as `path:` entries, which are broken on this Windows + symlink setup and will cause the next `install` to fail with "resolves outside project root".
- The symlink error (`EPERM: symlink`) at the end of `install` is harmless — the `~/.claude/skills` junction is set up manually.
- If `sync` was run accidentally: remove all `source = "path:skills/..."` lines from `agents.toml`.

## Skill library backup (theprawnskills)

The canonical skill library is a git repo backed up offsite:

- Remote: the private remote `theprawnskills` (see `git remote -v`)
- Repo root = this folder (.agents). Branch: main.
- After ANY meaningful change to skills/, registry files, or scripts:

```powershell
git -C "C:\Users\bryan\OneDrive\01 SKILLS\.agents" add -A
git -C "C:\Users\bryan\OneDrive\01 SKILLS\.agents" commit -m "chore(library): <what changed>"
git -C "C:\Users\bryan\OneDrive\01 SKILLS\.agents" push
```

- Disaster recovery: git clone the private repo, copy contents over .agents,
  excluding nothing; installed roots re-propagate via
  scripts/Install-DefaultSkillProfile.ps1.
- Ignored: node_modules/, packages/, _removed/ (re-fetchable artifacts).
