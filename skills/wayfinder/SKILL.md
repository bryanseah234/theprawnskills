---
name: wayfinder
description: >-
  Navigate large, ambiguous initiatives where the destination or path is
  unclear. Use when the user says figure out how to approach this, this is too
  vague to spec, help me find a path, map the territory, we need a plan for a
  big messy project, or when to-spec/wayfinder routing keeps failing because
  scope itself is unknown. Produces a wayfinding map: knowns, unknowns,
  options, and a first concrete step.
license: MIT
metadata:
  author: Local setup
  version: "1.0.1"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---

# Wayfinder

Turn "we need to do something big but it is fuzzy" into a map with one concrete
next step. Wayfinder does not solve the problem; it makes the problem solvable.

## When To Use

- Initiative spans multiple features/systems with unclear boundaries
- Repeated failed attempts to spec it (a sign scope is undefined)
- Destination is contested (stakeholders disagree on what "done" means)
- Many unknowns block any single plan

Route out as soon as ambiguity drops enough that `to-spec` works again.

## Workflow

### 1. State The Territory

Write one paragraph: what are we actually trying to achieve, in outcome terms,
and why now. If you cannot, interview the user with:

- What triggers this need today? (pain, opportunity)
- Who benefits and who decides?
- What would make us say "worth it" six months later?

### 2. Inventory Knowns / Unknowns / Constraints

| Bucket | Contents |
|---|---|
| Knowns | Facts verifiable from code/docs/user statements |
| Unknowns | Questions whose answers change the plan |
| Constraints | Fixed: stack, budget, deadlines, politics, compat |

Critical unknowns get classification: answerable by READING CODE, by
PROTOTYPING (`prototype`), by RESEARCHING (web/competitive-upgrade), or only by
ASKING the user.

### 3. Generate Routes

Draft 2-4 genuinely different approaches (not variations of one). For each:

| Field | Meaning |
|---|---|
| Sketch | The shape of the solution in 2-3 sentences |
| First step | Smallest real move that creates information |
| Cost | Rough effort/risk profile |
| Kills | Which unknowns this route resolves early |
| Risks | What could sink it |

Include the "do nothing / minimal patch" route when credible; it calibrates.

### 4. Recommend And Map

Pick one route (or hybrid) with reasoning tied to their priorities. Produce
`.agents/maps/YYYY-MM-DD-<slug>.md`:

```markdown
# Wayfinding Map: <Initiative>
Date | Status: EXPLORING | COMMITTED | DONE

## Territory
<one paragraph>

## Knowns / Unknowns / Constraints
(three lists)

## Routes Considered
(table from step 3)

## Chosen Route + Why
<reasoning>

## Phase Outline
P1: <outcome> — exit signal: <checkable condition>
P2: ...

## Immediate Next Step
ONE action, owner=agent-or-user, produces <artifact/information>.
```

Exit signals must be observable ("tests X pass", "user approves mock"), never
"make progress".

### 5. Recurse Or Hand Off

| After the next step | Next |
|---|---|
| Scope of P1 now clear enough | `to-spec`, then `to-tickets` per phase |
| Still blocked on an unknown | `prototype` / research loop, update map |
| Plan should be shared/reviewed | `postplan-upload` render |
| Market/product framing missing | `competitive-upgrade` or `competitor-teardown` |

Update the same map file as reality changes; keep status current. A stale map
is worse than no map.

## Guardrails

- Do not silently start implementing P1; maps end with agreement.
- Do not fake precision: ranges and open questions are honest output.
- Do not let the map become the deliverable; every session ends in a next step.
- Cap routes at 4; more options rarely improve decisions, they delay them.

## Related Skills

- `to-spec` - when a phase becomes concrete
- `to-tickets` - when a phase has an approved spec
- `prototype` - resolving technical unknowns cheaply
- `domain-modeling` - when the confusion is conceptual, not logistical
- `postplan-upload` - shareable rendering
