---
name: wizard
description: >-
  Run a guided, step-by-step interactive workflow with the user: one question
  or decision at a time, visible progress, resumable state. Use when the user
  says walk me through this, guide me step by step, set this up with me,
  help me decide interactively, or for multi-decision setups (configuring a
  service, choosing options, filling forms, onboarding flows) where dumping one
  giant form would overwhelm.
license: MIT
metadata:
  author: Local setup
  version: "1.0.1"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---

# Wizard

Guide a user through multi-step decisions ONE step at a time, keeping state so
the flow survives interruptions.

## When To Use

- Setup/config flows with several dependent choices (provider selection, keys,
  region, plan)
- Decision processes needing sequential commitment (architecture picks,
  migration strategy)
- User explicitly asks to be walked through something

Not for: single questions (just ask), fully automatable tasks (just do them),
or discovery of requirements (use `to-spec` interview style).

## Flow Design Rules

1. **One question per turn.** Never stack multiple questions; progress stalls.
2. **Defaults first.** Every question offers a recommended default and why.
   Users should be able to press through on defaults safely.
3. **Show position.** "Step 2/5 — Choosing database" every turn.
4. **Commit visibly.** After each answer, echo the running configuration:
   `so far: A=x, B=y`.
5. **Resumable.** Persist partial state after each committed step (see below).

## Workflow

### 1. Frame The Flow

Before step 1, present the whole map (cheap, non-binding):

```markdown
Wizard: <goal> — 5 steps
1. Provider (default: X because ...)
2. Region (default: ...)
3. Auth method (default: ...)
4. Review -> confirm
5. Apply + verify
Say 'back' anytime to redo a step, 'status' to see progress, 'abort' to stop.
```

### 2. Execute Steps

Per step:

1. Ask ONE question via the question tool or inline prompt.
2. Validate the answer immediately (format, availability, dependency checks —
   run real commands when cheap, e.g. `az account list-locations`).
3. Echo committed config so far.
4. Persist state BEFORE advancing (below), so crashes lose nothing.

If validation fails, show the error and re-ask the same step; never advance on
an invalid value.

### 3. Persist State

Write `.agents/wizard/<slug>-state.json` (or `.md` for human-readable flows):

```json
{
  "wizard": "<slug>",
  "step": 3,
  "committed": { "provider": "cloudflare", "region": "eu" },
  "updated": "2026-08-24T10:00:00Z"
}
```

On resume ("continue that setup"), read the file, echo committed state, continue
at `step`. Delete the file after successful completion.

### 4. Review Gate

Before any APPLY step, print the full final config as a table and require an
explicit confirm. Irreversible actions get a second explicit warning naming what
cannot be undone.

### 5. Apply And Verify

Execute the plan, verifying each effect right after it happens (resource exists?
endpoint responds? file parses?). Report per-step results, then delete state
file and summarize outcomes + follow-ups.

## Guardrails

- Never apply anything during question steps; apply only at the review gate.
- Never store secrets in the state file; reference env vars/keychain instead.
- Timeouts/failures mid-apply: report exactly which steps landed and which did
  not, keep the state file with an `"apply_state"` field.
- Max ~7 steps before suggesting splitting into two wizard runs.

## Related Skills

- `question` tool - the primary asking mechanism
- `azure-prepare`, `wrangler`, `postgres-mcp-onboarding` - common wizard targets
- `cross-harness-state` - where wizard state lives relative to other .agents files
