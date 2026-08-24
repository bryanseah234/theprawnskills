---
name: postgres-mcp-onboarding
description: "Enable PostgreSQL MCP correctly across providers. USE FOR: local Docker Postgres, Supabase, Railway, Neon, managed Postgres URLs. DO NOT USE FOR: SQL query optimization itself."
---

# Postgres MCP Onboarding

## Purpose
Get Postgres MCP connected with minimal errors.

## Required Input
A valid Postgres URL:
`postgresql://user:password@host:5432/database`

## Steps
1. Set env var (preferred): `POSTGRES_MCP_URL`.
2. Configure command argument to read URL from env placeholder.
3. Keep server disabled by default until URL exists.
4. Validate and run `/status` or `opencode mcp list`.

## Provider Notes
- Supabase/Neon/Railway: use pooled or direct DB URL from dashboard.
- Local Docker: map host port and use `localhost:<port>`.

## Common Failures
- Missing URL arg -> `Connection closed`
- Wrong sslmode or firewall block -> timeout/auth failures
