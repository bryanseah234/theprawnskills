---
name: project-db-autodetect
description: "Detect project database settings and map them to MCP runtime env. USE FOR: auto-detecting Postgres/SQLite from .env, docker-compose, Prisma, project folders. DO NOT USE FOR: provisioning cloud databases."
---

# Project DB Autodetect

## Purpose
Auto-resolve DB config per project so MCP can switch contexts without manual edits.

## Detection Order
1. `.env*` keys: `DATABASE_URL`, `POSTGRES_URL`, etc.
2. `docker-compose*.yml` postgres service and port mappings.
3. `prisma/schema.prisma` datasource providers + env reference.
4. local sqlite files: `*.db`, `*.sqlite*` under common folders.

## Output Contract
Return normalized object:
- `postgresUrl`
- `sqlitePath`
- `source`
- `confidence`

## Runtime Policy
Precedence: explicit user env > detected values > safe fallback > disable unresolved server.
