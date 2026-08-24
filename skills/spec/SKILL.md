---
name: spec
description: >-
  Create, amend, or maintain SPEC.md at repo root: goals, contracts, invariants,
  tasks, and backpropped bugs. Sole mutator of the project spec. Triggers when
  the user asks to write a spec, start a new spec, add invariants, amend
  sections, or record a bug. Companion skills: build (executes §T), check
  (audits drift), backprop (files bugs into §B).
license: MIT
metadata:
  author: Local setup
  version: "1.0.1"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---

# Spec

Own SPEC.md at repo root. Nothing else edits it — build/check/backprop read it,
this skill writes it.

## File Contract

```markdown
# SPEC: <Project>

## §G Goals
- G1: <outcome, testable>

## §C Contracts
Public surfaces other code depends on: APIs, schemas, CLIs.
| ID | Contract |

## §I Invariants
Properties that must ALWAYS hold. Each is testable and numbered.
- V1: <statement>
- V2: ...

## §T Tasks
Ordered, small, each with files + acceptance check.
| ID | Task | Files | Acceptance | Status |
|---|---|---|---|---|
| T1 | ... | src/x.ts | <command/observable> | pending | done

## §B Bugs (backprop)
Filed via `backprop` after root-cause confirmation.
| ID | Bug | Root cause | New invariant |
|---|---|---|---|
| B1 | ... | ... | V7 |
```

Rules: pipe tables for §T/§B; every task has an acceptance check; every bug
lands a new invariant; statuses are only pending/done.

## Workflow

### New spec
Interview briefly (problem, outcome, non-goals), inspect code, then draft all
sections. Get explicit user approval before marking anything done.

### Amend
Small additive changes: edit directly, keep numbering monotonic (never renumber
existing IDs; append).

### Record bug (via backprop)
When `backprop` confirms a root cause, it hands you: bug summary + root cause +
proposed invariant. Add row to §B and the invariant to §I.

## Guardrails

- Never delete history; supersede with new rows.
- No vague invariants ("should be fast") — testable only.
- Spec stays lean: if a paragraph fits in chat, it does not need a section.

## Related Skills

- `build` - executes §T tasks; on failure invokes backprop
- `check` - read-only drift audit of code vs this file
- `backprop` - converts confirmed bugs into new §I invariants via this skill
- `to-spec` - drafts specs OUTSIDE repos that use SPEC.md
