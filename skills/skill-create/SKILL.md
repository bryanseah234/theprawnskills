---
name: skill-create
description: >-
  Create a new local AI-agent skill from a requested capability or workflow.
  Use when the user says create a skill, make a skill, new skill, future agents
  should know, or teach agents how to do something. Installs the finished skill
  through the machine registry when it should be default-visible.
license: MIT
metadata:
  author: Local setup
  version: "1.0.0"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---

# Skill Create

Create a new skill in the canonical OneDrive library and propagate it to enabled
agent roots when the user wants it default-visible.

## Required Context

Before creating or installing a skill, read:

```text
C:\Users\bryan\OneDrive\01 SKILLS\.agents\skills\skill-authoring\SKILL.md
C:\Users\bryan\OneDrive\01 SKILLS\.agents\machines.toml
C:\Users\bryan\OneDrive\01 SKILLS\.agents\default-profile.toml
```

Use `skill-router` only when another existing on-demand skill should inform the
new skill.

## Workflow

1. Choose a short lowercase kebab-case name.
2. Create the canonical file only under:

   ```text
   C:\Users\bryan\OneDrive\01 SKILLS\.agents\skills\<kebab-name>\SKILL.md
   ```

3. Write focused instructions with useful trigger language and local constraints.
4. Add supporting `references/`, `scripts/`, `assets/`, `templates/`, or
   `examples/` only when they provide concrete value.
5. Validate with:

   ```powershell
   python "C:\Users\bryan\.codex\skills\.system\skill-creator\scripts\quick_validate.py" "<skill-folder>"
   ```

6. Update `INDEX.md`.
7. If the skill changes common discovery categories, update `skill-router`.
8. If the skill should be default-visible, add it to `default-profile.toml` and
   copy it to every enabled `installed_roots` entry in `machines.toml`.

## Propagation

Never hardcode a fixed machine count. Read enabled machines from `machines.toml`.
Read the desired installed skill set from `default-profile.toml`.

For `local = true`, copy directly with PowerShell. For `ssh = "<alias>"`, try to
run equivalent PowerShell commands through SSH. If a remote machine is down,
unreachable, or has missing paths, continue with other machines and report the
failure clearly.

Before overwriting an existing installed skill, move the old installed folder to:

```text
_removed\<yyyy-MM-dd>\<machine-id>\pre-skill-create\<skill-name>
```

Do not run `dotagents sync`.

## Output

Report:

- canonical skill path
- validation result
- machines and agent roots updated
- machines that failed or were skipped
- whether `skill-router` or `INDEX.md` changed
