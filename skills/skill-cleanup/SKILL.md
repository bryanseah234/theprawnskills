---
name: skill-cleanup
description: >-
  Audit, prune, deduplicate, archive, or reorganize the local AI-agent skill
  library. Use when the user says clean up skills, too many skills, prune
  installed roots, remove unused skills, find redundant skills, or reduce skill
  context. Produces a report before archiving canonical skills.
license: MIT
metadata:
  author: Local setup
  version: "1.0.0"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---

# Skill Cleanup

Clean up the canonical skill library and installed agent roots without losing
recoverability.

## Required Context

Read before acting:

```text
C:\Users\bryan\OneDrive\01 SKILLS\.agents\skills\skill-authoring\SKILL.md
C:\Users\bryan\OneDrive\01 SKILLS\.agents\skills\skill-router\SKILL.md
C:\Users\bryan\OneDrive\01 SKILLS\.agents\machines.toml
C:\Users\bryan\OneDrive\01 SKILLS\.agents\default-profile.toml
```

## Cleanup Rules

- Never permanently delete skills; move them to `_removed/<yyyy-MM-dd>/`.
- Always archive old installed copies before overwriting or removing.
- Do not archive canonical skills until the user confirms a report.
- Installed-root pruning may proceed when the user has clearly approved a lean
  profile.
- Do not treat on-demand skills as useless just because they are not installed.
- Do not run `dotagents sync`.

## Analysis Labels

Use one primary label per item:

| Label | Meaning |
|---|---|
| `DEFAULT` | Should stay installed in coding agents. |
| `ON-DEMAND` | Useful, but should not load by default. |
| `DUPLICATE` | Functionally overlaps another skill; name the survivor. |
| `BROKEN` | Missing required files, bad frontmatter, dead paths, or parse/load failure. |
| `STALE` | Old and no evidence of use, but not enough to delete without review. |
| `REMOVE-CANDIDATE` | Safe to archive after confirmation. |
| `KEEP` | Functional and should remain canonical. |

## Workflow

1. Inventory canonical and installed roots from `machines.toml`.
2. Inspect skill names, frontmatter, `SKILL.md`, and referenced files as needed.
3. Check evidence of active use only within machine roots and config roots allowed
   by `skill-authoring`.
4. Produce a report before canonical archiving.
5. After confirmation, archive remove candidates and update installed roots.
6. Regenerate `INDEX.md`.
7. Update `skill-router` if categories, names, or defaults changed.
8. Update `default-profile.toml` when default membership changes.
9. Propagate installed profile changes to enabled machines; continue and report
   if a remote machine is unreachable.

## Report Requirements

Prefer tables:

| Path | Label | Reason | Referenced By | Recommended Action |
|---|---|---|---|---|

Recommended actions:

- `KEEP`
- `MAKE ON-DEMAND`
- `INSTALL DEFAULT`
- `MERGE INTO <skill>`
- `ARCHIVE AFTER CONFIRMATION`
- `RENAME`

## Lean Default Bias

Default-installed skills should stay small and high-signal:

- `skill-router`
- `skill-create`
- `skill-add`
- `skill-update`
- `skill-cleanup`
- `skill-remove`
- `postplan-upload`
- core coding/debug/review skills
- core Cloudflare/local platform skills the user repeatedly uses

Treat `default-profile.toml` as the source of truth for this default baseline.

Media, writing, document, presentation, Azure, Supabase, and Vercel skills are
normally on-demand unless the user promotes one.
