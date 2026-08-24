---
name: prototype
description: >-
  Build small throwaway proofs that answer one technical question fast. Use
  when the user says prototype this, spike it, try a quick proof of concept,
  test if X is feasible, validate the approach, or when a design decision is
  blocked on unknowns (library behavior, performance, API quirks). Output is a
  verdict plus evidence, not production code.
license: MIT
metadata:
  author: Local setup
  version: "1.0.0"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---

# Prototype

Answer ONE question with the cheapest runnable thing possible, then throw the
code away (or graduate it deliberately).

## When To Use

- "Will X work with Y?" needs evidence, not opinion
- A spec/design decision hangs on an unverified assumption
- Comparing two approaches and docs are insufficient
- User asks for a spike / PoC / feasibility check

Not for: building the actual feature (that is normal implementation), or
exploring product direction without a technical question (use
`game-changing-features` or `competitive-upgrade`).

## The One Rule

Define the QUESTION before writing any code:

> This prototype answers: <question>. Verdict will be: WORKS | FAILS | IT DEPENDS
> (with conditions).

If you cannot state the question in one sentence, you are not prototyping yet.

## Workflow

### 1. Frame

| Field | Example |
|---|---|
| Question | Can lib X stream-parse 2GB files under 512MB RAM? |
| Success signal | Peak RSS < 512MB on sample file |
| Fail signal | OOM, wrong output, > budget |
| Time box | 45 minutes hard stop |

Get user agreement on the time box when it exceeds ~1 hour.

### 2. Isolate

- Work outside the real repo unless interaction with real code IS the question.
  Use `$env:TEMP\proto-<slug>\` or a `scratch/` gitignored dir otherwise.
- Smallest possible harness: single script/file preferred.
- Realistic data matters; synthetic data that avoids the hard case proves
  nothing.

### 3. Build Ugly

- No error handling beyond what the experiment needs.
- No abstractions, no config, hardcoded inputs fine.
- Copy-paste is a feature here.

### 4. Measure And Verdict

Run it, capture output as evidence, then write the verdict block:

```markdown
## Prototype Verdict: <slug>
Question: ...
Result: WORKS | FAILS | IT DEPENDS
Evidence:
- <measurement/log/output line>
Conditions / caveats:
- <what was NOT tested>
Recommendation: <proceed with approach A / avoid / need bigger spike of Z>
Artifact: <path kept for reference>
```

### 5. Dispose

- Default: delete the scratch code. Git/history/this document preserves learning.
- Graduate ONLY if the user explicitly says keep it — then it must pass normal
  review/tests/refactor (`refactor`, `requesting-code-review`) before merging.

## Guardrails

- Never let prototype code leak into production paths silently.
- Never exceed the time box without reporting back first.
- Secrets never go into prototypes (use dummies); prototypes get committed by
  accident all the time.
- If mid-spike the question changes, stop, re-frame, restart the clock.

## Related Skills

- `to-spec` - a successful verdict often becomes a spec constraint
- `bug-diagnosis` - use its evidence discipline for surprising results
- `wayfinder` - many open questions at once = map them first
