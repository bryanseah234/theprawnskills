---
name: backprop
description: >-
  Bug-to-invariant protocol. When a bug is confirmed or a test fails, trace the
  root cause, then decide whether a new §I invariant would prevent recurrence
  and file it into SPEC.md §B via the spec skill. Triggers on test failure,
  bug report, post-mortem, or after any systematic-debugging session confirms
  a cause.
license: MIT
metadata:
  author: Local setup
  version: "1.0.1"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---

# Backprop

Every confirmed bug is a missing invariant until proven otherwise. Backpropagate
the lesson into the spec so the same bug cannot return silently.

## When To Use

- A test failed and root cause was just confirmed
- A production bug was fixed (or is about to be)
- Post-mortem completed
- build/check flagged drift caused by a real defect

Skip only when the cause is pure environment flakiness with no code-level guard
possible — and say so explicitly.

## Workflow

### 1. Confirm The Cause

Require an evidence-backed root cause (from `bug-diagnosis` or
`systematic-debugging` Phase 1-3). No cause = no backprop; go diagnose first.

### 2. Classify Recurrence Risk

| Question | If NO | If YES |
|---|---|---|
| Could this exact failure return via normal change? | note in commit, stop | continue |
| Would a check have caught it earlier? | reconsider | candidate invariant |
| Is the check cheap to run? | document only, stop | file it |

### 3. Draft The Invariant

One testable statement, named by what must hold:

> V7: Every exported API function validates its `limit` parameter to 1..100
> before use.

Anti-pattern: "Be careful with limits" — not testable, reject your own draft.

### 4. File It Via spec

Hand to the `spec` skill: append row to §B (bug + root cause + new invariant ID)
and the invariant text to §I. Never edit SPEC.md directly.

### 5. Land The Guard With The Fix

The fix PR includes: the fix, a failing-first test that encodes the new
invariant, and the spec amendment. All three or none.

## Guardrails

- One bug may yield at most one invariant; if you drafted three, you found three
  bugs — file them separately.
- Do not backprop style preferences or hypotheticals.
- If the fix makes an old invariant obsolete, supersede it via spec (never delete).

## Related Skills

- `bug-diagnosis` - upstream evidence gathering
- `systematic-debugging` - Phase 4 hands off here after confirmation
- `spec` - sole writer of §B/§I sections
- `build` - invokes this automatically on task failure
