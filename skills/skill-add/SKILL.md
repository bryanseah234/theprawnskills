---
name: skill-add
description: >-
  Add a skill from an upstream GitHub repository, URL, pasted markdown, pasted
  instructions, or a described tool workflow. Use when the user says add this
  skill, install this skill, from GitHub, from a link, from pasted text, or make
  this into a skill.
license: MIT
metadata:
  author: Local setup
  version: "1.0.0"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---

# Skill Add

Turn an external source or pasted content into a canonical local skill, then
optionally expose it in enabled agent roots.

## Required Context

Read before acting:

```text
C:\Users\bryan\OneDrive\01 SKILLS\.agents\skills\skill-authoring\SKILL.md
C:\Users\bryan\OneDrive\01 SKILLS\.agents\machines.toml
C:\Users\bryan\OneDrive\01 SKILLS\.agents\default-profile.toml
```

If the source is a GitHub repository, URL, or external package, inspect only the
files needed to understand the skill. Do not copy large docs wholesale into
`SKILL.md`; summarize the agent-facing procedure and link or place conditional
detail in `references/`.

## Accepted Sources

- GitHub repository or path
- webpage or documentation link
- pasted `SKILL.md`
- pasted instructions, README text, CLI usage, or workflow notes
- short natural-language description of a desired skill

## Workflow

1. Determine the intended skill name, purpose, trigger phrases, and target agents.
2. Create or update:

   ```text
   C:\Users\bryan\OneDrive\01 SKILLS\.agents\skills\<kebab-name>\SKILL.md
   ```

3. Preserve useful upstream attribution in metadata or body when appropriate.
4. Keep local setup rules local: PowerShell, OneDrive canonical source, no
   `dotagents sync`, no secrets.
5. Validate the skill.
6. Update `INDEX.md`.
7. Update `skill-router` if the added skill creates a new common route.
8. If it should be default-visible, add it to `default-profile.toml` and
   propagate to every enabled machine root in `machines.toml`.

## Safety

Do not paste secrets, tokens, credentials, private env files, or raw sensitive
logs into a skill. If a source contains sensitive values, omit them and note the
redaction.

Do not overwrite an existing canonical skill without first understanding whether
this is an update or a duplicate.

## Output

Report the source, canonical path, validation status, propagation status, and any
manual follow-up such as adding an upstream `agents.toml` entry.
