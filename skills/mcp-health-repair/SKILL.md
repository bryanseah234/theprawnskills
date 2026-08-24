---
name: mcp-health-repair
description: "Troubleshoot OpenCode MCP failures fast. USE FOR: /status failures, timeout errors, connection closed, broken MCP command args, intermittent MCP flapping. DO NOT USE FOR: feature implementation unrelated to MCP health."
---

# MCP Health Repair

## Purpose
Stabilize MCP servers and remove recurring `/status` failures.

## Workflow
1. Capture baseline: run `opencode mcp list` 2-3 times for intermittent failures.
2. Classify failure type:
   - `Connection closed`: usually bad args/env/credentials.
   - timeout: startup/download/port bind issues.
   - schema invalid: bad config key shape (`env` vs `environment`).
3. Validate command paths in `opencode.json` against installed package entry points.
4. Apply surgical fixes:
   - correct command args
   - set safe port env when needed
   - disable unresolved servers to stop noisy failures
5. Re-verify with `opencode mcp list` and keep evidence logs.

## Guardrails
- Never keep an enabled server that is known broken.
- Prefer env vars for secrets.
- Add validator checks for repeated regressions.
