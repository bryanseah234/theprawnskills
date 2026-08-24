---
name: claude-code-cli
description: Delegate tasks to Claude Code CLI in a hidden background process. Use when the user asks to use Claude Code, or when a task needs multi-file reasoning, complex refactoring, or Claude-quality analysis. Spawns claude in --print mode with no visible terminal — output tee'd to $env:TEMP\hermes-claude-out.txt.
---

# Claude Code CLI Skill

Delegate coding tasks to Claude Code by spawning it as a **hidden background PowerShell process**. Output tee'd to a temp file so you can poll for completion and read results. Bryan tail the file with `Get-Content -Wait` if he wants to watch live.

## When to Use

- Complex multi-file refactoring
- Security or architecture review requiring deep reasoning
- Tasks where Claude Opus/Sonnet quality is needed
- User explicitly says "use claude", "delegate to claude", "ask claude"
- Tasks in a specific project directory (use `-C` flag)

## Running a Task

### 1. Choose the model

| Model | Best for | Cost |
|---|---|---|
| `sonnet` (default) | Standard coding, reviews, refactors | Included in Max plan |
| `opus` | Hard reasoning, architecture, security | Higher usage |
| `haiku` | Trivial lookups, formatting, simple edits | Cheapest |

### 2. Choose the mode

| Mode | Flag | Use case |
|---|---|---|
| One-shot print | `-p "prompt"` | Default. Non-interactive, captures output |
| Continue session | `--continue -p "follow-up"` | Resume previous context |
| With tool restrictions | `--allowedTools "Read,Grep,Glob" -p "prompt"` | Read-only analysis |
| Full auto (edits allowed) | `--dangerously-skip-permissions -p "prompt"` | Autonomous edits (ask user first!) |
| Specific directory | `-C /path/to/project -p "prompt"` | Work in another project |
| JSON output | `-p "prompt" --output-format json` | Structured output for parsing |

### 3. Spawn as hidden background process

```powershell
# Standard: sonnet, read + analyze
$out = "$env:TEMP\hermes-claude-out.txt"; Remove-Item $out -EA SilentlyContinue
$proc = Start-Process pwsh -WindowStyle Hidden -PassThru -ArgumentList '-NoProfile','-Command',"claude -p --model sonnet 'YOUR_PROMPT_HERE' 2>&1 | Tee-Object -FilePath '$out'; Add-Content '$out' '=== CLAUDE COMPLETE ==='"

# Opus for hard tasks
$out = "$env:TEMP\hermes-claude-out.txt"; Remove-Item $out -EA SilentlyContinue
$proc = Start-Process pwsh -WindowStyle Hidden -PassThru -ArgumentList '-NoProfile','-Command',"claude -p --model opus 'YOUR_PROMPT_HERE' 2>&1 | Tee-Object -FilePath '$out'; Add-Content '$out' '=== CLAUDE COMPLETE ==='"

# With edits allowed (ask user first!)
$out = "$env:TEMP\hermes-claude-out.txt"; Remove-Item $out -EA SilentlyContinue
$proc = Start-Process pwsh -WindowStyle Hidden -PassThru -ArgumentList '-NoProfile','-Command',"claude --dangerously-skip-permissions -p --model sonnet 'YOUR_PROMPT_HERE' 2>&1 | Tee-Object -FilePath '$out'; Add-Content '$out' '=== CLAUDE COMPLETE ==='"

# In a specific project directory
$out = "$env:TEMP\hermes-claude-out.txt"; Remove-Item $out -EA SilentlyContinue
$proc = Start-Process pwsh -WindowStyle Hidden -PassThru -ArgumentList '-NoProfile','-Command',"claude -C 'C:\path\to\project' -p --model sonnet 'YOUR_PROMPT_HERE' 2>&1 | Tee-Object -FilePath '$out'; Add-Content '$out' '=== CLAUDE COMPLETE ==='"

# Read-only analysis (no edit tools)
$out = "$env:TEMP\hermes-claude-out.txt"; Remove-Item $out -EA SilentlyContinue
$proc = Start-Process pwsh -WindowStyle Hidden -PassThru -ArgumentList '-NoProfile','-Command',"claude --allowedTools 'Read,Grep,Glob,Bash(git *)' -p --model sonnet 'YOUR_PROMPT_HERE' 2>&1 | Tee-Object -FilePath '$out'; Add-Content '$out' '=== CLAUDE COMPLETE ==='"
```

### 4. For long prompts (use stdin pipe)

```powershell
$out = "$env:TEMP\hermes-claude-out.txt"; Remove-Item $out -EA SilentlyContinue
$proc = Start-Process pwsh -WindowStyle Hidden -PassThru -ArgumentList '-NoProfile','-Command',"Get-Content 'C:\path\to\prompt.txt' | claude -p --model sonnet 2>&1 | Tee-Object -FilePath '$out'; Add-Content '$out' '=== CLAUDE COMPLETE ==='"
```

### 5. Poll for completion

```powershell
$outFile = "$env:TEMP\hermes-claude-out.txt"
$timeout = 300; $start = Get-Date
while (((Get-Date) - $start).TotalSeconds -lt $timeout) {
    if ((Test-Path $outFile) -and (Get-Content $outFile -Raw) -match "=== CLAUDE COMPLETE ===") { break }
    Start-Sleep -Seconds 10
}
$result = Get-Content $outFile -Raw -ErrorAction SilentlyContinue
```

### 6. Report results

After reading the output file, summarize the key findings or changes to the user. Include:
- What Claude found or changed
- Any warnings or errors
- Whether follow-up is needed (`--continue` flag)

## Max Turns Control

Limit how many tool-use loops Claude performs:
```powershell
claude -p --model sonnet --max-turns 5 "YOUR_PROMPT"
```
Use `--max-turns 1` for simple questions. Default is unlimited (will keep working until done).

## Critical Rules

1. **ALWAYS use `--print` / `-p`** — bare `claude` opens interactive TUI which hangs in automated contexts
2. **NEVER use `--dangerously-skip-permissions` without asking the user** — equivalent to Codex `--full-auto`
3. **Default to `sonnet`** — it's fast, cheap, and included in Max plan. Only use `opus` when the task genuinely needs it
4. **Set `--max-turns`** for tasks that shouldn't run long (prevents runaway tool loops)
5. **Use `-C` flag** to target a specific project directory rather than cwd

## Authentication

Claude Code must be authenticated on each machine:
```powershell
claude auth login
```
Opens browser for Anthropic account login.

## Comparison with Other Agents

| Feature | Claude Code | Codex | Gemini |
|---|---|---|---|
| Best at | Multi-file reasoning, refactoring | OpenAI model access | Huge context (1M tokens) |
| Context window | 200K | 400K | 1M |
| Edit capability | Full (with permissions) | Sandbox-based | Approval-based |
| Cost | Max plan included | OpenAI credits | Free (Google account) |
| Speed | Fast (sonnet) / Slow (opus) | Fast | Fast (flash) / Slow (pro) |
