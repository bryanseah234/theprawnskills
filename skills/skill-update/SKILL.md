---
name: skill-update
description: >-
  Update one skill or improve the skill library by learning from current coding
  practices, agent configs, project conventions, failures, or new preferences.
  Use when the user says update this skill, improve my skills, make skills match
  my coding style, refresh all skills, or change what a skill can do.
license: MIT
metadata:
  author: Local setup
  version: "1.0.0"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---

# Skill Update

Update an existing skill, a group of skills, or shared skill-management behavior.

## Required Context

Read before acting:

```text
C:\Users\bryan\OneDrive\01 SKILLS\.agents\skills\skill-authoring\SKILL.md
C:\Users\bryan\OneDrive\01 SKILLS\.agents\machines.toml
C:\Users\bryan\OneDrive\01 SKILLS\.agents\default-profile.toml
```

When routing or cross-skill discovery matters, also read:

```text
C:\Users\bryan\OneDrive\01 SKILLS\.agents\skills\skill-router\SKILL.md
```

## Scope Modes

- Targeted: update one named skill.
- Related set: update skills in one domain, such as planning, Cloudflare,
  documents, media, or cleanup.
- Library-wide: audit patterns and propose or apply focused updates across
  multiple skills.

## Learning From Practice

Use only roots listed in `machines.toml` unless the user gives additional scope.
For each enabled machine, inspect canonical roots, installed roots, and relevant
agent config roots that are explicitly documented in `skill-authoring`.

Exclude secrets and credentials:

```text
.env
.env.*
.ssh/**
.aws/**
.docker/config.json
.npmrc
.git-credentials
*.pem
*.key
id_rsa*
id_ed25519*
*secret*
*token*
*credential*
```

Do not quote secret values. If a token is found in a non-excluded file, report
that a token exists and recommend rotation without reproducing it.

## Workflow

1. Identify the skill or set to update.
2. Read the current `SKILL.md` fully before editing.
3. Gather evidence from allowed machine roots and configs.
4. Make the smallest useful update.
5. Validate changed skills.
6. Update `INDEX.md`.
7. Update `skill-router` if routing changed.
8. If default membership changed, update `default-profile.toml`.
9. Propagate updated default-visible skills to enabled installed roots from
   `machines.toml`.

Archive old installed copies before overwriting:

```text
_removed\<yyyy-MM-dd>\<machine-id>\pre-skill-update\<skill-name>
```

## Constraints

Do not turn one observed habit into a universal rule unless it is clearly a
stable preference or repeated practice.

Do not run `dotagents sync`.

If a machine is unreachable, continue and report it.

When a new CLI agent root is added, update `machines.toml` and apply the
default profile to that root.
