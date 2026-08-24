---
name: to-tickets
description: >-
  Break an approved spec, plan, or large change into small ordered
  implementation tickets with dependencies, file scope, and acceptance checks.
  Use when the user says break this into tickets, turn the spec into tasks,
  make a work breakdown, create the ticket list, or when work must span
  multiple sessions or agents.
license: MIT
metadata:
  author: Local setup
  version: "1.0.0"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---

# To-Tickets

Convert one approved spec/plan into a sequence of small, independently
verifiable tickets sized for a single focused session each.

## When To Use

- After `to-spec` produces an APPROVED spec with multiple tasks
- User says "break this into tickets/tasks", "work breakdown", "sprint plan"
- Work will span sessions, agents, or machines and needs resumable units

## Ticket Sizing Rules

A good ticket is:

| Property | Test |
|---|---|
| Small | One session; ideally < ~400 changed lines |
| Verifiable | Has explicit acceptance check (test command, observable behavior) |
| Independent | Does not require unstarted siblings to compile/pass |
| Scoped | Names the files/modules it may touch |
| Ordered | States what must exist first |

If a ticket cannot be made small, it is really a sub-project: split again or
escalate to `wayfinder`.

## Workflow

### 1. Read The Source Plan

Read the approved spec/plan fully. Extract: invariants, task hints, risks,
verification methods. If no spec exists and the change is non-trivial, route to
`to-spec` first.

### 2. Slice Into Tickets

Cut along seams that minimize coupling, in this order of preference:

1. By data contract (schema/types first, then producers, then consumers)
2. By vertical slice (thin end-to-end path, then thicken)
3. By module boundary

Always schedule: scaffolding -> contracts -> core logic -> integrations ->
polish/cleanup. Tests for a unit land in the SAME ticket as the unit.

### 3. Write The Ticket File

Save as `.agents/tickets/YYYY-MM-DD-<slug>/tickets.md`:

```markdown
# Tickets: <Plan Title>
Source: <spec path> | Created: YYYY-MM-DD

## T1: <Title>
- Depends on: none
- Files: src/foo.ts, tests/foo.test.ts
- Do: <precise instruction>
- Acceptance: <command or observable check>
- Done when: acceptance passes AND no existing test breaks

## T2: ...
```

Numbering is execution order. Dependencies reference ticket IDs only.

### 4. Verify The Graph

Before presenting:

- [ ] Every ticket has acceptance + files + dependency line
- [ ] No cycles; graph is a DAG
- [ ] T1 is startable immediately (no phantom prerequisite)
- [ ] Invariants from the spec appear as acceptance checks somewhere
- [ ] Total scope still matches the spec's non-goals

### 5. Hand Off

| Situation | Next |
|---|---|
| Execute sequentially now | start T1 (`build --next` pattern if SPEC-driven) |
| Track/share the board | render via `postplan-upload` |
| A ticket turns out ambiguous mid-flight | stop, mini-spec it via `to-spec` |
| Initiative reveals deeper ambiguity | escalate to `wayfinder` |

## Guardrails

- No ticket without an acceptance check. "Implement auth" is not a ticket.
- Do not pre-implement anything while slicing.
- Keep file scopes honest; overlapping scopes between parallel tickets = merge pain.
- Mark blockers/questions inline rather than silently guessing.

## Related Skills

- `to-spec` - upstream source of approved specs
- `build`, `check`, `backprop` - SPEC-driven execution loop
- `postplan-upload` - shareable HTML rendering of the ticket board
- `session-handoff` / `cross-harness-state` - persist progress across sessions
