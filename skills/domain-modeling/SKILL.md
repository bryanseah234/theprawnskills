---
name: domain-modeling
description: >-
  Extract and refine the conceptual model of a problem space: entities,
  relationships, invariants, and ubiquitous language, then map it to code. Use
  when the user says model this domain, what are the core entities, design the
  data model, untangle these concepts, or when code fights the business logic
  because concepts are muddled (god objects, boolean-flag entities, duplicated
  meanings).
license: MIT
metadata:
  author: Local setup
  version: "1.0.1"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---

# Domain Modeling

Make the concepts of the problem space explicit before encoding them, so the
code mirrors how the business actually works.

## When To Use

- Designing a new feature area's data/types from scratch
- Code smells reveal concept confusion: god objects, `type` + 10 optional
  fields, status booleans, same word meaning two things
- User asks "what are the core entities / how should we model X"
- Integration between systems keeps breaking on semantic mismatches

Not for module/file layout decisions (use `codebase-design`) or vague big-picture
direction (`wayfinder`).

## Workflow

### 1. Harvest The Language

From user words + existing code/docs, collect candidate nouns and verbs.
Flag immediately:

- Same term, two meanings (overloading)
- Two terms, one meaning (synonyms)
- Vague containers: `data`, `info`, `manager`, `helper`, `misc`

### 2. Define Candidates

For each candidate entity/concept:

| Field | Question |
|---|---|
| Definition | What IS it, in one sentence a domain expert would accept |
| Identity | What distinguishes one from another over time |
| Lifecycle | Created when? Becomes what? When dead/archived? |
| Invariants | What must always be true about it |
| Not | What it is explicitly NOT (boundary setter) |

Reject candidates that cannot pass this table; they are attributes or events in
disguise.

### 3. Map Relationships

Draw (mermaid or text) connections with cardinality and direction:

- Has-a vs is-a vs refers-to
- Aggregates: which entity is the consistency boundary for writes
- Events: past-tense facts worth modeling (`OrderCancelled`, not `cancel flag`)

Prefer composition over taxonomies; premature inheritance freezes bad models.

### 4. Stress-Test Scenarios

Walk 3-5 real scenarios through the model ("customer refunds half the order",
"user changes plan mid-cycle"):

- Where do invariants strain?
- Which relationship cardinality breaks?
- What state combinations are impossible-but-representable? Add constraints.

Fix the model now; this is the cheapest moment it will ever be fixed.

### 5. Map To Code

| Model element | Typical code form |
|---|---|
| Entity w/ identity + lifecycle | class/struct with id + repository/table |
| Value object (no identity) | immutable type with validation |
| Invariant | constructor validation + DB constraint + test |
| Event | typed record + handler seam |
| Aggregate root | transaction/write boundary |

Deliverable: `.agents/models/<slug>.md` with the tables above, the diagram, and
the mapping table plus open questions for the user.

### 6. Hand Off

| Situation | Next |
|---|---|
| Model approved, feature scoped | `to-spec` |
| Schema migration needed | `database-schema-designer`, then tickets |
| Layout/refactor of modules to match | `codebase-design`, `refactor` |
| Big initiative context | fold map into `wayfinder` territory section |

## Guardrails

- Do not invent entities the user did not mention and code does not imply.
- Do not model reports/views as entities; they are projections.
- Keep ubiquitous language consistent in ALL artifacts afterwards (specs,
  tickets, commit messages). Renaming later is expensive.
- Mark speculative parts clearly; models are negotiated, not decreed.

## Related Skills

- `codebase-design` - physical organization once concepts are clear
- `to-spec` - encode the model into buildable requirements
- `database-schema-designer` - persistence realization
