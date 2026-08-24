---
name: skill-remove
description: >-
  Remove, archive, uninstall, or retire a skill from the canonical library and
  installed agent roots. Use when the user says remove this skill, delete this
  skill, uninstall a skill, retire a skill, or make a skill no longer available.
license: MIT
metadata:
  author: Local setup
  version: "1.0.0"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---

# Skill Remove

Archive skills from canonical or installed roots without permanent deletion.

## Required Context

Read before acting:

```text
C:\Users\bryan\OneDrive\01 SKILLS\.agents\skills\skill-authoring\SKILL.md
C:\Users\bryan\OneDrive\01 SKILLS\.agents\machines.toml
C:\Users\bryan\OneDrive\01 SKILLS\.agents\default-profile.toml
```

If the removal affects discovery, also read:

```text
C:\Users\bryan\OneDrive\01 SKILLS\.agents\skills\skill-router\SKILL.md
```

## Removal Modes

- Installed-only: remove from default agent roots but keep canonical on-demand.
- Canonical archive: move the canonical skill to `_removed/` after confirmation.
- Rename/merge cleanup: move obsolete copies after a replacement exists.

## Workflow

1. Identify exact skill name and scope: installed-only, canonical, or both.
2. Check current presence in the canonical library and installed roots listed in
   `machines.toml`.
3. If canonical removal is requested, produce a short confirmation report first
   unless the user has already explicitly confirmed that exact skill and scope.
4. Archive, never hard-delete:

   ```text
   _removed\<yyyy-MM-dd>\<machine-id>\skill-remove\<skill-name>
   ```

5. Remove or update references in `INDEX.md`, `skill-router`,
   `default-profile.toml`, and local config comments when relevant.
6. Propagate installed-root removal to every enabled machine in `machines.toml`.
7. Continue if a remote machine is down and report the failure.

## Safety

Do not remove a skill just because it is on-demand.

Do not remove bundled/system/plugin skills from plugin caches. Only manage the
canonical library and user installed roots.

Do not run `dotagents sync`.

## Output

Report:

- what was archived
- where it was archived
- what references were updated
- which machines succeeded, failed, or were skipped
