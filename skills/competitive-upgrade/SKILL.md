---
name: competitive-upgrade
description: >-
  Compare the current repo, app, or product against real live companies,
  competitors, SaaS tools, and best-in-class examples using current web research,
  then turn findings into repo-specific upgrade ideas, specs, tickets, or plans.
  Use when the user says compare this project with competitors, learn from real
  companies, what features are missing, upgrade this repo based on market research,
  benchmark against live products, product capability gap, make this more like the
  best tools, or find what we should build next. Do NOT use for pure marketing
  teardowns (competitor-teardown) or ideation without research
  (game-changing-features).
license: MIT
metadata:
  author: Local setup
  version: "1.0.1"
  platform: Codex, Claude, Cursor, OpenCode on Windows
---

# Competitive Upgrade

Compare the current repo or product against real companies and turn the findings
into practical upgrades for this codebase.

Use this for product/code strategy, not generic market research. Every output must
connect external findings back to concrete repo capabilities, gaps, and buildable
next steps.

## When To Use

Use this when the user asks to:

- compare the current project with real companies or live products
- research competitors and improve the repo from what they do well
- find missing features based on market leaders
- benchmark this app against best-in-class tools
- turn competitor/product research into specs, tickets, or a roadmap
- identify 10x feature opportunities grounded in real examples

Routing out:

- Marketing/positioning teardown only -> `competitor-teardown`
- Pure ideation without live research -> `game-changing-features`
- Output becomes a large ambiguous project -> `wayfinder` (if installed)
- Implementation-ready work -> hand off to `to-spec` / `to-tickets` (if installed)

## Required Behavior

Live company capabilities change. Perform current web research before making any
claim about real products, pricing, features, positioning, public traction, or
recent changes. Never answer competitor questions from memory alone.

Prefer primary or high-quality sources:

- official product pages and docs
- pricing pages
- changelogs and release notes
- GitHub repos (stars, activity, issues)
- launch posts and credible reviews
- app store listings

Do not invent competitor capabilities. Mark uncertainty explicitly and date every
research claim.

## Workflow

### 1. Understand The Current Repo

Inspect the codebase before researching competitors. Determine:

| Area | Questions |
|---|---|
| Product category | What kind of app/tool is this? |
| Target user | Who is it for? |
| Current capabilities | What can it do today? |
| Core workflow | What is the main user action? |
| Stack | What technologies constrain or enable upgrades? |
| Maturity | Prototype, MVP, production, portfolio, internal tool? |

Output a short current-state summary before recommending anything.

### 2. Pick Comparison Targets

Choose 3-7 relevant examples. Prioritize:

- direct competitors
- best-in-class tools in the same workflow
- adjacent products with transferable patterns
- open-source equivalents if the repo is developer-facing
- local/regional examples if the product is geography-specific

If the category is unclear, ask the user or propose one with stated caveats.

### 3. Research Capabilities

For each target gather current evidence:

| Field | Meaning |
|---|---|
| Product | Company/tool name |
| Source | URL or evidence |
| Core promise | What they claim to solve |
| Key capabilities | Main user-facing features |
| Workflow patterns | UX/product patterns worth learning from |
| Integrations | APIs, exports, auth, platform hooks |
| Pricing/gating | Free, paid, enterprise-only, usage limits |
| Trust signals | Security, compliance, reliability, social proof |
| Differentiators | What makes them stand out |
| Weaknesses | Complaints, missing pieces, complexity, cost |

Date the research.

### 4. Build A Capability Matrix

| Capability | Current Repo | Company A | Company B | Company C | Upgrade Potential |
|---|---|---|---|---|---|
| Fast onboarding | Partial | Strong | Strong | Basic | High |
| Export/share | Missing | PDF/CSV | Public links | API | High |
| Team workflow | Missing | Comments | Roles | Activity log | Medium |

Rules:

- `Current Repo` column must come from code inspection, not guesswork.
- Competitor columns must cite sources.
- Not every missing feature is worth building; separate "must match" from
  "interesting but irrelevant".

### 5. Extract Upgrade Opportunities

Group by value and effort:

- **Do Now** - small, high-value, low-risk changes.
- **Do Next** - medium features improving the core workflow.
- **Explore** - large bets, unclear scope, strategy-heavy.
- **Do Not Copy** - patterns unsuitable for this repo.

Each recommendation includes: Upgrade | Source pattern | Why it matters | Repo fit |
Effort (Low/Medium/High) | Risk | Next artifact (Spec/Ticket/Prototype/Wayfinder map).

Recommend fewer, higher-value upgrades over exhaustive lists.

### 6. Convert To Buildable Work

| Situation | Next skill |
|---|---|
| Clear feature | `to-spec` |
| Multiple build tasks | `to-tickets` |
| Large ambiguous direction | `wayfinder` |
| Quick validation needed | prototype approach directly |
| Clickable plan wanted | `postplan-upload` |
| Architecture change needed | `codebase-design` |

For substantial plans, produce a clean HTML plan via `postplan-upload`.

## Output Format

```markdown
# Competitive Upgrade: <Project>

## Current Repo Summary
- Category:
- Target user:
- Current capabilities:
- Main constraints:

## Comparison Targets
| Target | Why included | Sources |

## Capability Matrix
| Capability | Current Repo | Target A | Target B | Target C | Upgrade Potential |

## Key Findings
1. Finding with source-backed evidence (dated).

## Recommended Upgrades
### Do Now / Do Next / Explore
| Upgrade | Inspired by | Why | Effort | Next |

## Do Not Copy
- Pattern: ... Reason: ...

## Proposed Next Step
One concrete recommended action.
```

## Guardrails

- Do not recommend cloning a feature without adapting it to this repo's stack,
  users, and maturity.
- No undated or memory-only claims about competitors.
- Do not hide uncertainty; flag gaps in evidence.
- Do not pad the report; fewer high-confidence upgrades beat long lists.

## Related Skills

- `competitor-teardown` - marketing/positioning teardown
- `game-changing-features` - 10x ideation without research
- `to-spec`, `to-tickets`, `wayfinder` - implementation handoffs (when installed)
- `postplan-upload` - clickable HTML plan for large outputs
