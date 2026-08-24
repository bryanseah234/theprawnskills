---
name: bug-diagnosis
description: >-
  Structured bug diagnosis producing a written diagnosis document before any
  fix is attempted. Use when the user reports a bug, asks to investigate why
  something fails, says diagnose this bug, find the root cause, figure out why
  X broke, or when a bug is non-obvious, intermittent, or survived previous fix
  attempts. Pairs with systematic-debugging (the discipline) and backprop
  (recurrence prevention).
license: MIT
metadata:
  author: Local setup
  version: "1.0.0"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---

# Bug Diagnosis

Diagnose bugs by producing an evidence-based diagnosis document BEFORE proposing
or writing any fix. The deliverable of this skill is the diagnosis; fixing is a
separate decision.

## When To Use

- User reports a bug and wants to understand it first
- A bug survived one or more failed fix attempts
- The failure is intermittent, environmental, or multi-layer
- The user explicitly asks for root cause, diagnosis, or investigation

For simple obvious breaks, `systematic-debugging` discipline alone is enough.
Use this skill when the diagnosis itself needs structure and persistence.

## Iron Rules

1. No fix code until the diagnosis document exists and states a root cause with
   evidence.
2. Every claim in the diagnosis cites observed evidence (log line, command
   output, repro step), not inference alone.
3. If evidence contradicts the hypothesis, update the hypothesis, not the
   evidence.

## Workflow

### 1. Capture The Symptom Contract

Write down, before investigating:

| Field | Question |
|---|---|
| Expected | What should happen |
| Observed | What actually happens |
| Scope | Always? Sometimes? One machine? One user? |
| Onset | When did it start; what changed around then |
| Repro | Exact steps or inputs that trigger it |

If you cannot reproduce it, say so and gather data instead of guessing.

### 2. Collect Evidence

Work outward from the error site:

1. Read the full error message, stack trace, log context. Never skim.
2. Check recent diffs: `git log --oneline -15`, `git diff HEAD~3` for suspects.
3. For multi-layer systems (client -> API -> service -> DB), instrument each
   boundary once: what enters, what exits. Run once, read where truth diverges.
4. Note environment deltas: versions, env vars, config, OS, paths.

On Windows/PowerShell, capture evidence as text so it can be quoted in the
diagnosis:

```powershell
command 2>&1 | Out-String | Set-Content "$env:TEMP\evidence-01.txt"
```

### 3. Form And Test Hypotheses

One hypothesis at a time. State it as:

> Hypothesis H1: <cause> because <evidence>. Prediction: if true, <cheap test>
> will show <result>.

Run the cheapest discriminating test. Record result. Move to next hypothesis or
confirm. After 2+ failed fix attempts on the same symptom, stop and re-diagnose;
three failures usually means wrong layer or wrong architecture assumption.

### 4. Write The Diagnosis Document

Save as `.agents/diagnosis/YYYY-MM-DD-<slug>.md` (create folder if needed):

```markdown
# Diagnosis: <short title>

Date: YYYY-MM-DD | Repo: <path> | Status: CONFIRMED | SUSPECTED | BLOCKED

## Symptom Contract
(expected / observed / scope / onset / repro)

## Evidence
1. <fact> — source: <log/command/file + line>
2. ...

## Root Cause
<Plain statement of cause.>

## Why It Was Not Obvious
<What misled earlier attempts, if any.>

## Fix Options
| Option | Changes | Risk | Recommendation |

## Verification Plan
How we will prove the fix works and did not break neighbors.

## Recurrence Guard
Should this become an invariant/test? If yes -> hand to `backprop` / spec §V.
```

### 5. Hand Off

| Situation | Next |
|---|---|
| Fix agreed | implement per Verification Plan (`build` skill if SPEC-driven) |
| Recurring class of bug | `backprop` to add a §V invariant |
| Ambiguity about intended behavior | ask user before coding |
| Fix is large/multi-part | `to-spec` or `to-tickets` |

## Guardrails

- Do not write fix code while diagnosing. Diagnostic instrumentation only.
- Do not delete or "clean up" anything mid-diagnosis; preserve the crime scene.
- Do not present an unconfirmed hypothesis as fact; mark status honestly.
- Time-box rabbit holes: after ~30 minutes without new evidence, report findings
  and blockers to the user.

## Related Skills

- `systematic-debugging` - the four-phase discipline this skill documents output for
- `backprop` - turn confirmed root causes into recurrence-preventing invariants
- `to-spec`, `to-tickets` - hand off large fixes
