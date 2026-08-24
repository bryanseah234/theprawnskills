---
name: codebase-design
description: >-
  Design how a change should be organized in the codebase: module boundaries,
  dependency direction, file layout, and seams for testing. Use when the user
  says where should this go, how should we structure this, design the
  architecture for this feature, split these modules, or when a repo/feature is
  growing tangled and needs structural decisions before more code lands.
license: MIT
metadata:
  author: Local setup
  version: "1.0.1"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---

# Codebase Design

Decide WHERE things live and HOW they depend on each other, so the next five
features are easy instead of hard.

## When To Use

- New feature/subsystem needs a home and boundaries
- Circular imports, god modules, or dependency spaghetti appeared
- User asks "where does this go / how to structure this"
- Preparing a refactor that moves significant code (`refactor` executes it)

Not for concept-level modeling (use `domain-modeling`) or line-level cleanup
(`refactor`).

## Principles

1. **Dependencies point toward stability.** Unstable (changing) code depends on
   stable; never reverse.
2. **One reason to change per module.** Split when two teams/two reasons collide.
3. **Boundaries at data contracts**, not folders. If types cross freely, the
   boundary is decoration.
4. **Make the easy path the right path.** Structure so the lazy option is the
   correct option.
5. **Match team/repo scale.** Solo prototype needs fewer layers than a platform.

## Workflow

### 1. Map Current Reality

Inspect before proposing:

- Directory tree of affected area, entry points, build graph
- Existing layering conventions (this repo's rules beat generic ideals)
- Import graph hotspots: most-imported, most-importing, cycles

```powershell
rg -n "^import|^from" src --type ts | Measure-Object   # scale check first
```

### 2. Identify The Pressure

Name precisely what hurts: slow builds? merge conflicts on one file? fear of
touching module X? tests requiring the world? The design must relieve THAT
pressure, not achieve abstract beauty.

### 3. Draw Target Structure

Propose:

| Element | Content |
|---|---|
| Units | modules/packages with one-line responsibility |
| Allowed deps | explicit direction diagram (mermaid `graph TD`) |
| Contracts | the types/interfaces that ARE the boundary |
| Testing seam | where fakes/stubs plug in |
| Migration path | how code moves without a big-bang |

Reject any unit you cannot name a responsibility for in one sentence.

### 4. Check Against Forces

- [ ] Cycles eliminated or explicitly justified
- [ ] Each unit testable in isolation (seam exists)
- [ ] Public API surface shrinks or stays equal (no accidental exports)
- [ ] Fits repo conventions (naming, framework idioms)
- [ ] Cheapest future change became cheaper; name which one

### 5. Document And Hand Off

Write `.agents/design/YYYY-MM-DD-<slug>.md` with the target diagram, contracts,
and migration path. Then:

| Situation | Next |
|---|---|
| Approved | `to-spec` -> `to-tickets` for the move |
| Executing mechanical moves | `refactor` discipline, small commits |
| Concept confusion found underneath | `domain-modeling` first |
| Verifying behavior preserved | `requesting-code-review` after each step |

## Guardrails

- Never propose a structure requiring simultaneous big-bang cutover unless user
  explicitly accepts the risk.
- Do not introduce layers "for later"; every layer must pay rent today.
- Framework conventions win over personal taste; note deviations explicitly.
- Keep the design doc dated; supersede rather than silently edit decisions.

## Related Skills

- `refactor` - executing the moves safely
- `domain-modeling` - upstream conceptual clarity
- `to-spec`, `to-tickets` - turning design into ordered work
- `understand` - knowledge-graph exploration of large unfamiliar repos
