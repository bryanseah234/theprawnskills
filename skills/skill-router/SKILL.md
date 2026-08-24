---
name: skill-router
description: >-
  Route user requests to on-demand skills in the OneDrive canonical skill
  library. Use when a task sounds like it may need a non-installed skill, when
  the user asks which skill to use, or when work involves media, documents,
  presentations, writing, cloud platforms, agent setup, skill creation, or
  unfamiliar specialized tooling.
license: MIT
metadata:
  author: Local setup
  version: "1.0.0"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---

# Skill Router

Use this skill to find and load on-demand skills without installing the
whole library into every agent session.

## Source of Truth

Canonical skill library:

```text
C:\Users\bryan\OneDrive\01 SKILLS\.agents\skills
```

Skill file convention:

```text
C:\Users\bryan\OneDrive\01 SKILLS\.agents\skills\<kebab-name>\SKILL.md
```

Installed agent roots are only exposure targets. The canonical OneDrive
`skills/` folder is the durable library.

## Routing Workflow

When the user's request may match an on-demand skill:

1. Search canonical skill names and frontmatter descriptions.
2. Pick the smallest set of relevant skills.
3. Open and read each selected `SKILL.md` fully before using it.
4. If the selected skill links to task-specific references, read only the
   relevant referenced files.
5. If no skill clearly fits, continue normally and mention that no exact skill
   matched.

Use PowerShell-compatible search from this machine:

```powershell
$root = "C:\Users\bryan\OneDrive\01 SKILLS\.agents\skills"
Get-ChildItem -LiteralPath $root -Directory |
  ForEach-Object {
    $skill = Join-Path $_.FullName "SKILL.md"
    if (Test-Path -LiteralPath $skill) {
      Select-String -LiteralPath $skill -Pattern "description:|name:|# " -Context 0,2
    }
  }
```

Prefer `rg` for targeted text search:

```powershell
rg -n "deck|presentation|pptx|slides|pdf|image|video|azure|supabase|vercel" "C:\Users\bryan\OneDrive\01 SKILLS\.agents\skills" -g "SKILL.md"
```

Do not read secret files while routing. Skill folders should normally contain
instructions, references, scripts, assets, templates, and examples, not secrets.

## Common Routes

Use these as starting points, then verify by reading the actual `SKILL.md`.

| User intent | Candidate skills |
|---|---|
| Create a brand-new local skill | `skill-create`, `skill-authoring`, `skill-creator` |
| Add a skill from GitHub, link, pasted text, or tool docs | `skill-add`, `skill-create` |
| Update one skill or improve skills from coding practice | `skill-update`, `skill-authoring` |
| Clean up, prune, dedupe, or reduce skill context | `skill-cleanup`, `skill-remove` |
| Remove or retire a skill | `skill-remove`, `skill-cleanup` |
| Find a skill or decide what applies | `skill-router`, `find-skills`, `skill-authoring` |
| Coding, refactor, review, testing | `refactor`, `requesting-code-review`, `systematic-debugging`, `webapp-testing` |
| Bug investigation and root cause | `bug-diagnosis`, `systematic-debugging`, `backprop` |
| Merge conflicts and git surgery | `merge-conflict-resolution`, `commit-work`, `git-commit` |
| Spec writing (one clear feature) | `to-spec`, `spec`, `build`, `check` |
| Ticket breakdown / work planning | `to-tickets`, `to-spec`, `postplan-upload` |
| Prototypes / feasibility spikes | `prototype`, `wayfinder` |
| Large ambiguous initiatives | `wayfinder`, `domain-modeling`, `codebase-design` |
| Guided step-by-step setup | `wizard`, `azure-prepare`, `wrangler` |
| Session continuity across agents | `cross-harness-state`, `session-handoff` |
| Repo standardization and compliance | `repo-standardization` |
| Compare repo with competitors / market upgrades | `competitive-upgrade`, `competitor-teardown` |
| Web or frontend design | `frontend-design`, `web-design-guidelines`, `shadcn`, `impeccable` |
| Cloudflare and Workers | `cloudflare`, `wrangler`, `workers-best-practices`, `durable-objects`, `agents-sdk`, `turnstile-spin` |
| Azure | `azure-prepare`, `azure-deploy`, `azure-validate`, `azure-diagnostics`, `azure-cost`, `azure-ai`, `microsoft-foundry` |
| Supabase or Postgres | `supabase`, `supabase-postgres-best-practices`, `postgres-mcp-onboarding` |
| Vercel | `deploy-to-vercel`, `vercel-react-best-practices`, `vercel-cli-with-tokens` |
| Documents, PDFs, spreadsheets, decks | `docx`, `pdf`, `xlsx`, `pptx` |
| Writing and communication | `technical-blog-writing`, `press-release-writing`, `case-study-writing`, `newsletter-curation` |
| Marketing and launch content | `seo-content-brief`, `product-hunt-launch`, `linkedin-content`, `content-repurposing` |
| Image generation or editing | `ai-image-generation`, `gpt-image`, `flux-image`, `background-removal`, `image-upscaling`, `product-photography` |
| Video, audio, voice, podcasts | `image-to-video`, `ai-avatar-video`, `text-to-speech`, `speech-to-text`, `ai-podcast-creation` |
| Social content | `ai-social-media-content`, `social-media-carousel`, `twitter-thread-creation`, `youtube-thumbnail-design` |
| Agent tooling and delegation | `cli-agent-router`, `claude-code-cli`, `opencode-cli`, `codex`, `agent-browser` |

## Maintenance Rules

When adding, deleting, renaming, pruning, or auditing skills, also use
`skill-authoring`.

After skill library changes:

1. Ensure each new skill lives at `skills/<kebab-name>/SKILL.md`.
2. Update `default-profile.toml` if default-installed membership changed.
3. Update `INDEX.md` so installed/on-demand status stays accurate.
4. Update this router only when a new skill changes the common routing table or
   a renamed/deleted skill appears in the table.
5. Install this router into the default agent roots so future agents can find
   on-demand skills.

Do not run:

```powershell
dotagents sync
```

Use `dotagents install` only when `agents.toml` is known to be safe and the user
explicitly wants the manifest-installed defaults refreshed.

## Default Install Strategy

Keep default-installed skills lean:

- Always install this `skill-router`.
- Always install `skill-create`, `skill-add`, `skill-update`, `skill-cleanup`,
  and `skill-remove`.
- Always install `postplan-upload` so substantial plans become clickable HTML
  drafts.
- Keep essential coding, review, debugging, Cloudflare, and local setup skills
  installed when the user wants automatic discovery.
- Leave media, writing, document, presentation, Azure, Supabase, and Vercel
  skills on demand unless the user asks to make one default again.

Use `default-profile.toml` as the source of truth for default profile
membership. When a new CLI agent is installed, add its skill root to
`machines.toml` and apply the default profile.

Do not delete on-demand skills just because they are not installed.
