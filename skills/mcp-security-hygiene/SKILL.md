---
name: mcp-security-hygiene
description: "Harden MCP configuration security. USE FOR: removing inline secrets, env-var migration, log redaction, least-privilege MCP defaults. DO NOT USE FOR: unrelated auth implementations."
---

# MCP Security Hygiene

## Purpose
Reduce accidental secret leakage and risky MCP defaults.

## Checklist
1. Move API keys/passwords from config files to env vars.
2. Redact URLs in logs (`user:****@host`).
3. Disable servers that lack required credentials.
4. Restrict file-system MCP roots to minimum needed scope.
5. Keep backups and rollback scripts outside shared/public repos.

## Don’ts
- Don’t commit real secrets in `opencode.json`.
- Don’t keep failing credentialed MCPs enabled.
