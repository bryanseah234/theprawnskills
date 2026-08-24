---
name: to-spec
description: >-
  Turn one clear feature, bug fix, or change request into an
  implementation-ready spec. Use when the user says write a spec for this,
  turn this into a spec, spec out this feature, make this buildable, or when a
  discussed change needs precise requirements before coding. Produces or amends
  SPEC.md-compatible output and hands off to tickets or direct implementation.
license: MIT
metadata:
  author: Local setup
  version: "1.0.0"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---

# To-Spec

Convert ONE well-understood change into a precise, implementation-ready spec.
Not for vague multi-direction initiatives (use `wayfinder`) and not for breaking
work into many tasks (that is `to-tickets`).

## When To Use

- "Write a spec for X", "spec this out", "make it concrete"
- A bug diagnosis produced a fix that needs requirements agreement first
- A feature was discussed in chat and must survive context loss
- Before `build` on a SPEC-driven repo

If the repo already has SPEC.md governed by the `spec` skill, AMEND it through
that skill's format instead of creating a competing document. This skill drafts;
the `spec` skill owns the file.

## Workflow

### 1. Clarify Intent

Answer before writing:

- Problem: what is wrong or missing, for whom
- Outcome: observable behavior after the change
- Scope boundary: explicitly what is OUT of scope
- Constraints: stack, perf, security, compat, deadlines

Ask the user only what cannot be inferred from code. Never invent requirements.

### 2. Ground In The Codebase

Inspect relevant files first; a spec disconnected from real code is fiction.

- Where does the change land (files/modules)?
- What existing patterns/conventions must it follow?
- What tests exist that will constrain behavior?
- What breaks if we do nothing?

### 3. Write The Spec

Use this shape (adapt headings to repo conventions):

```markdown
# Spec: <Title>

Date / Author / Status: DRAFT | REVIEW | APPROVED

## Problem
<1-3 sentences with evidence.>

## Goal
<Observable end state, testable.>

## Non-Goals
- Explicitly excluded item
- ...

## Design
<Approach at the level a reviewer can evaluate: data flow, API surface,
modules touched, key tradeoffs considered and rejected.>

## Invariants
- V1: <property that must always hold>
- V2: ...

## Tasks
- T1: <concrete unit of work> — files: <paths>
- T2: ...

## Verification
| Check | How |
|---|---|
| Unit/functional tests | <commands> |
| Manual verification | <steps> |

## Risks
- <risk>: <mitigation>
```

Rules: every task names files; every goal maps to a verification row; invariants
are testable statements, not vibes.

### 4. Review Loop

1. Present the spec summary (problem, goal, non-goals, task count).
2. Ask for objections on scope and design, not wording.
3. Incorporate feedback; bump status DRAFT -> REVIEW -> APPROVED.

Do not start implementing from a DRAFT spec unless the user says so.

### 5. Hand Off

| Situation | Next |
|---|---|
| Approved, single-session work | implement directly (`build` if repo uses SPEC.md) |
| Many tasks across sessions | `to-tickets` |
| Big plan should be shareable | render via `postplan-upload` |
| Discovered mid-spec it is actually vague | stop, escalate to `wayfinder` |

## Guardrails

- No implementation code while drafting the spec.
- Do not pad: if it fits in a paragraph, the answer is a paragraph, not a spec.
- Keep specs dated and status-marked; stale unmarked specs are dangerous.
- Secrets never go into specs (endpoints yes, keys no).

## Related Skills

- `spec` - owner of repo-root SPEC.md format (amend via it)
- `build` - executes SPEC-driven tasks with backprop on failure
- `check` - audits drift between SPEC.md and code
- `to-tickets` - split approved spec into trackable tickets
- `bug-diagnosis` - upstream source of fix specs
