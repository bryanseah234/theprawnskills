---
name: cross-harness-state
description: >-
  Maintain MOLT-style persistent agent state in a repo's .agents/ folder so any
  harness (Codex, Claude Code, Cursor, OpenCode) can resume work with zero
  ambiguity. Use when starting or ending significant work in a repo, when the
  user says update the state, save progress, journal this, resume from state,
  what were we doing, or when switching agents/machines mid-task and continuity
  must survive.
license: MIT
metadata:
  author: Local setup
  version: "1.0.0"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---

# Cross-Harness State (MOLT)

Keep durable, harness-agnostic work state inside each repo's `.agents/` folder so
the NEXT session — any agent, any machine that syncs the repo — resumes from
files, not from a chat transcript.

## Layout

```text
.agents/
  STATE.md          # NOW: current task + latest progress bullets
  JOURNAL.md        # HISTORY: dated one-line decisions/changes
  handoffs/         # SESSION DOCS: timestamped deep-recovery documents
  diagnosis/        # from bug-diagnosis skill (optional)
```

Create `.agents/` in the repo root if absent. These files are committed with the
repo unless it is a private scratch repo; they must never contain secrets.

## File Contracts

### STATE.md — always reflects NOW

```markdown
# Agent State

Current task: <one sentence describing the active goal>

Progress:
- Completed <ID/slug> locally: <what changed>. Verification passed: <exact checks>.
  <Explicitly what was NOT executed/persisted if relevant.>
- ...
```

Rules:

- Top of file = current truth. Old completed bullets get compacted: keep last
  ~10 detailed, compress older ones into one-liners, never delete silently.
- Every bullet ends with verification evidence (tests run, commands checked)
  and explicit negative claims where safety matters ("no deploy, no secret
  persistence").
- Written AFTER verification, not before.

### JOURNAL.md — append-only history

```markdown
# Agent Journal

- YYYY-MM-DD: <decision or change, one line, past tense>
- ...
```

One line per meaningful decision/change, newest at top. Include WHY for non-obvious
calls. Never edit old entries; corrections get new entries.

### handoffs/ — deep recovery docs

Timestamped `YYYY-MM-DD-HHMMSS-<slug>.md` documents created via the
`session-handoff` skill when a task pauses mid-flight or context is nearly full.
STATE.md gets ONE bullet pointing to it ("paused X, see .agents/handoffs/...").

Thin pointer files: any doc elsewhere (plans, specs, maps under `.agents/`) may be
referenced from STATE.md by path instead of being copied in. STATE stays lean;
pointers stay valid.

## Workflow

### Session start (resume)

1. Read `.agents/STATE.md` first, then referenced pointers/handoffs as needed.
2. Skim JOURNAL.md tail for recent decisions.
3. Confirm repo reality matches state (branch, key files exist). If drifted,
   update STATE.md noting drift BEFORE working.

### During work

- Journal entries at each real decision point.
- Update wizard/ticket/map artifacts in place; STATE points to them.

### Session end / milestone (save)

1. Add/update the STATE.md "Current task" + progress bullet with verification.
2. Append journal lines.
3. If pausing mid-task: create a handoff doc (`session-handoff`) and link it.
4. Commit `.agents/` changes together with related code when possible.

## No-Secrets Rules (hard)

- Never write tokens, keys, passwords, connection strings, client IPs of
  sensitive infra, or personal data into STATE/JOURNAL/handoffs.
- Reference secrets by NAME only ("uses GITHUB_TOKEN env var").
- Before committing, scan: `rg -n "(?i)(api[_-]?key|token|secret|password)\s*[:=]" .agents`
  and review hits.

## Harness Notes

- Works identically from Codex, Claude Code, Cursor, OpenCode — plain files, no
  tooling required.
- On OneDrive-synced repos, files sync across machines automatically; watch for
  sync conflicts after simultaneous edits on two machines — resolve by newest
  verified content, then re-append a journal line about the conflict.

## Related Skills

- `session-handoff` - creates the deep recovery docs stored in `.agents/handoffs/`
- `to-tickets`, `wayfinder` - artifacts STATE.md points to
- `bug-diagnosis` - diagnosis docs under `.agents/diagnosis/`
