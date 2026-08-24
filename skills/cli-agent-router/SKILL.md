---
name: cli-agent-router
description: Smart routing for CLI agent delegation. Decides which CLI agent (Claude Code, Codex, Gemini, OpenCode) to delegate a task to based on task characteristics. Use when the user says "delegate", "use the best tool", "pick the right agent", or when Hermes needs to decide which agent handles a coding task.
---

# CLI Agent Router

Decide which CLI agent to delegate a task to, then spawn it in a Windows Terminal tab.

## Decision Matrix

| Task characteristic | Best agent | Why | Skill to invoke |
|---|---|---|---|
| Quick 1-2 file edit, simple fix | **Hermes itself** | No overhead, fastest | (none — do it inline) |
| Multi-file refactor, complex reasoning | **Claude Code** (sonnet) | Best multi-file understanding | `claude-code-cli` |
| Hard architecture/security analysis | **Claude Code** (opus) | Deepest reasoning | `claude-code-cli` |
| Huge codebase scan (>200k tokens) | **Gemini** (pro) | 1M context window | `gemini` |
| Fast analysis, speed-critical | **Gemini** (flash) | Sub-second latency | `gemini` |
| OpenAI model needed, user requests | **Codex** | GPT-5.2 access | `codex` |
| AWS Bedrock models, MCP tools | **OpenCode** | Bedrock auth + MCP | `opencode-cli` |
| Cost-sensitive bulk work | **Claude Code** (haiku) | Cheapest per token | `claude-code-cli` |
| Multiple independent tasks | **Parallel tabs** | Spawn 2-3 agents simultaneously | `wt-agent-manager` |

## Routing Logic

When deciding which agent to use, check these in order:

### 1. Did the user specify an agent?
If the user said "use claude", "ask codex", "run gemini", "delegate to opencode" — use that agent. No routing needed.

### 2. Does the task need a specific capability?
- **>200K token context** → Gemini (1M window)
- **GPT/OpenAI model** → Codex
- **AWS Bedrock** → OpenCode
- **MCP tools (ctftoolkit, ast_grep)** → OpenCode
- Otherwise → Claude Code (best general-purpose)

### 3. What's the complexity?
- **Trivial** (rename, format, typo fix) → Hermes inline, no delegation
- **Simple** (single file bug fix, small feature) → Claude Code (haiku) or Gemini (flash)
- **Standard** (multi-file feature, refactor) → Claude Code (sonnet)
- **Complex** (architecture, security audit, cross-repo) → Claude Code (opus) or Gemini (pro)

### 4. Cost sensitivity?
- **Free**: Gemini CLI (Google account, no API costs)
- **Cheap**: Claude Code haiku, Codex gpt-5.2-mini
- **Standard**: Claude Code sonnet (included in Max plan)
- **Premium**: Claude Code opus, Codex gpt-5.2-max

## Parallel Delegation

For independent subtasks, spawn multiple agents simultaneously as hidden background processes:

```powershell
# Example: security review + performance analysis + docs update
# Three agents fired in parallel, no visible windows

$outClaude = "$env:TEMP\hermes-claude-out.txt"; Remove-Item $outClaude -EA SilentlyContinue
$outGemini = "$env:TEMP\hermes-gemini-out.txt"; Remove-Item $outGemini -EA SilentlyContinue
$outCodex  = "$env:TEMP\hermes-codex-out.txt";  Remove-Item $outCodex  -EA SilentlyContinue

$pClaude = Start-Process pwsh -WindowStyle Hidden -PassThru -ArgumentList '-NoProfile','-Command',"claude -p --model opus 'Security review of auth module' 2>&1 | Tee-Object '$outClaude'; Add-Content '$outClaude' '=== CLAUDE COMPLETE ==='"

$pGemini = Start-Process pwsh -WindowStyle Hidden -PassThru -ArgumentList '-NoProfile','-Command',"gemini -m gemini-3-pro-preview -y 'Performance analysis of the entire codebase' 2>&1 | Tee-Object '$outGemini'; Add-Content '$outGemini' '=== GEMINI COMPLETE ==='"

$pCodex  = Start-Process pwsh -WindowStyle Hidden -PassThru -ArgumentList '-NoProfile','-Command',"codex exec --skip-git-repo-check --sandbox read-only --full-auto 'Generate API documentation' 2>&1 | Tee-Object '$outCodex'; Add-Content '$outCodex' '=== CODEX COMPLETE ==='"

# Wait for all three
foreach ($p in @($pClaude,$pGemini,$pCodex)) { $p.WaitForExit() }
```

Then poll all three output files and report combined results.

## Agent Availability Check

Before delegating, verify the agent is installed:

```powershell
$agents = @{
    "claude" = (Get-Command claude -ErrorAction SilentlyContinue)
    "codex"  = (Get-Command codex -ErrorAction SilentlyContinue)
    "gemini" = (Get-Command gemini -ErrorAction SilentlyContinue)
    "opencode" = (Get-Command opencode -ErrorAction SilentlyContinue)
}

$available = $agents.GetEnumerator() | Where-Object { $_.Value } | ForEach-Object { $_.Key }
```

If the preferred agent isn't available, fall back to the next best option per the decision matrix.

## Trigger Phrases

Activate this routing when the user says:
- "delegate this to..." / "use the best tool for..."
- "which agent should handle..." / "pick the right agent"
- "run this with claude/codex/gemini/opencode"
- "parallel review" / "multi-agent analysis"
- "delegate" (without specifying agent — route automatically)

## Anti-Patterns

- **Don't delegate trivial tasks** — if Hermes can do it in <30 seconds, just do it
- **Don't spawn 4+ tabs** — user can't watch more than 3 effectively
- **Don't delegate the same task to multiple agents** unless explicitly comparing outputs
- **Don't delegate interactive tasks** — CLI agents in WT tabs run non-interactively
