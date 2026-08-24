---
name: merge-conflict-resolution
description: >-
  Resolve git merge/rebase conflicts systematically without losing either
  side's intent. Use when the user says fix this merge conflict, resolve the
  rebase, there are conflicts, git is stuck on a conflict, or after pulling/
  rebasing/merging when markers appear. Covers reading both sides' intent,
  semantic (not just textual) resolution, and verification before continuing.
license: MIT
metadata:
  author: Local setup
  version: "1.0.1"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---

# Merge Conflict Resolution

Resolve conflicts by understanding BOTH sides' intent, then reconstructing what
the code should be — never by picking a side blindly or deleting markers.

## Iron Rules

1. Never resolve a conflict you do not understand; investigate until you do.
2. Never just delete `<<<<<<<` markers keeping one side by default.
3. After resolving every file, the branch must build and pass tests BEFORE
   `git continue`/commit.

## Workflow

### 1. Establish Context

```powershell
git status                 # which files, which operation (merge/rebase/cherry-pick)
git log --oneline --all -15 --graph   # what is meeting what
git log MERGE_HEAD -5      # incoming side (during merge); rebase refs differ
```

Know: what change am I integrating into what? Read both commit messages.

### 2. Triage Conflicted Files

```powershell
git diff --name-only --diff-filter=U
```

Classify each:

| Type | Examples | Strategy |
|---|---|---|
| Trivial | whitespace, imports order, lockfiles | mechanical union or regenerate |
| Textual overlap | both edited different parts of same area | often both-keep with ordering thought through |
| Semantic collision | both changed same logic differently | requires intent reconstruction |
| Delete/edit | one side deleted, other modified | decide fate from WHY it was deleted |
| Binary/generated | images, `package-lock.json`, builds | regenerate via toolchain, never hand-edit |

Resolve trivial ones first to shrink the problem.

### 3. Resolve By Intent

For each real conflict:

1. **Read ours context:** surrounding function + its tests + recent commits
   touching it (`git log -p <file> -5`).
2. **Read theirs intent:** same for incoming side.
3. **Ask:** what SHOULD this code be now that both changes exist? The answer is
   usually a synthesis, sometimes a superset, rarely either raw side.
4. Edit to the resolved version, remove ALL markers, keep formatting sane.

When genuinely ambiguous (both sides ship different behaviors users may depend
on): STOP and ask the user. Present both intents in one sentence each.

Special cases:

- **Lockfiles:** delete and regenerate (`npm install`, `pnpm install`), never merge.
- **Rename storms:** `git log --follow` to track moved files; resolve at new paths.
- **Rebase conflicts repeat per commit:** consider `git rebase --onto` or merging
  instead if the same file conflicts >2 times; report the pain.

### 4. Verify Before Continuing

Check resolved files for stray markers, then:

1. Build/typecheck passes
2. Test suite passes (at least affected areas)
3. `git add <resolved files>`

Only then `git merge --continue` / `git rebase --continue`. For aborts,
`git merge --abort` / `git rebase --abort` restores pre-conflict state cleanly —
offer this when the user prefers to redo differently.

### 5. Report

Summarize per file: conflict type, how resolved (both-kept / theirs / ours /
regenerated / asked-user), and any follow-ups (e.g. "their refactor renamed X;
callers updated").

## Guardrails

- No force-pushes during conflict work unless user explicitly demands it.
- Do not silently drop one side's behavior; that is how production bugs are born.
- Generated files: always regenerate, never negotiate line-by-line.
- If conflicts reveal diverging architecture, surface it — maybe the merge
  should not happen yet (`codebase-design` conversation).

## Related Skills

- `systematic-debugging` - when post-merge tests fail mysteriously
- `bug-diagnosis` - if a conflict resolution itself introduced a bug
- `requesting-code-review` - high-risk resolutions deserve review before push
