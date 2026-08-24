---
name: skill-authoring
description: >-
  Conventions for creating, editing, pruning, or auditing AI-agent skills on
  this Windows dotagents setup. Canonical skills live under OneDrive
  `01 SKILLS/.agents/skills`; PowerShell is preferred; secrets are excluded
  from scans; use `dotagents install` not `dotagents sync`. Trigger strongly
  for add a skill, make a skill, edit this skill, clean up skills, audit
  frontmatter, or any SKILL.md surgery.
license: MIT
metadata:
  author: Local setup
  version: "1.0.1"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---

# Skill Authoring

House conventions for every SKILL.md in the canonical library.

## Layout & Registry

- Canonical root: `C:\Users\bryan\OneDrive\01 SKILLS\.agents\skills`
- One folder per skill: `skills/<kebab-name>/SKILL.md` (folder name = `name`)
- Registry files at `.agents` root: `machines.toml`, `default-profile.toml`,
  `agents.toml`, `INDEX.md`
- Installed roots receive ONLY the default profile; canonical holds everything.
- opencode loads skills via the `~/.agents` junction — never re-copy skills into
  `.config/opencode/skills`.

## Frontmatter Contract

```yaml
---
name: kebab-name            # required, matches folder, <=64 chars
description: >-             # required; WHAT it does + WHEN to trigger,
  ...                       # third person, front-load user phrasing/keywords;
                            # gate with "Use ONLY when..." if narrow
license: MIT
metadata:
  author: Local setup
  version: "1.0.0"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---
```

A weak description = a dead skill (never triggers) or a noisy one (always
triggers). Write the trigger phrases users will actually type.

## Body Standards

- Open with one-line purpose; then When To Use / When NOT To Use.
- Prefer tables over prose for checklists and field contracts.
- PowerShell examples (this is Windows); no bash-only syntax.
- No comments-as-content, no TODO stubs, no half-finished flows — say what is
  not supported explicitly.
- Cross-link with backticked skill names only if the target exists.

## Windows + OneDrive Rules

- Never write into remote machines' canonical folders directly; OneDrive syncs
  the shared tree — concurrent writes cause conflict storms.
- Never run propagation while any machine's OneDrive shows pending/error state.
- Secrets never in SKILL.md, scripts/, or registry files.

## Change Protocol

1. New skill: create folder + SKILL.md, then update INDEX.md
   (`scripts/Update-SkillIndex.ps1`) and router table if routing changes.
2. Default-profile membership changes: edit `default-profile.toml`, then run
   `scripts/Install-DefaultSkillProfile.ps1` (WhatIf first).
3. Deprecate: move folder to `_removed/<date>/`, remove router/profile entries,
   regen INDEX.
4. Never `dotagents sync`; `dotagents install` only when agents.toml is known-good.

## Quality Bar

Before finishing: frontmatter parses, name=folder, description >=40 chars with
trigger words, body has no dangling skill refs, no secrets, INDEX regenerated.

## Related Skills

- `skill-create` - scaffold a new local skill through this convention set
- `skill-cleanup`, `skill-remove` - pruning flows
- `skill-judge` - scoring rubric for finished skills
