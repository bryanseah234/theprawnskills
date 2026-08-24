---
name: repo-standardization
description: >-
  Standardize repositories to a common baseline: repo tiers, Apache-2.0 LICENSE
  and NOTICE files, GitHub description/homepage/topics metadata, README
  identity block, secret/identity scanning, compliance reports, and new-repo
  scaffolding. Use when the user says standardize this repo, make repos
  compliant, add license and topics, audit my repos, scaffold a new repo,
  SHELL check, or bring this repo to house standard.
license: MIT
metadata:
  author: Local setup
  version: "1.0.1"
  platform: "Codex, Claude, Cursor, OpenCode on Windows"
---

# Repo Standardization (SHELL)

Bring any repository to the house standard: correct tier-appropriate files,
metadata, licensing, and hygiene — then prove it with a compliance report.

## Repo Tiers

Determine the tier FIRST; requirements scale with exposure:

| Tier | Definition | Examples |
|---|---|---|
| T1 Public/product | Public-facing, others may depend on it | published tools, OSS |
| T2 Internal/shared | Cross-machine/cross-agent working repos | toolkits, skills libs |
| T3 Personal/scratch | Private experiments, throwaway spikes | prototypes |

T3 minimum: README one-liner + `.gitignore`. Do not gold-plate scratch repos.

## Standard Checklist

### Identity Block (all tiers, in README)

```markdown
# <Name>

<One-sentence description.>

- Status: <active | maintained | archived>
- Owner: <person/team>
- License: Apache-2.0 (T1/T2)
```

### Licensing (T1/T2)

- `LICENSE` — Apache-2.0 full text, correct copyright line:
  `Copyright <year> <holder>`.
- `NOTICE` — present when the project includes/bundles third-party works or
  brand marks; name them and their licenses. Absent only when genuinely nothing
  to attribute.
- Verify no leftover MIT/ISC text from template clones: search for the old
  license name before adding Apache headers.

### GitHub Metadata (T1/T2)

Set via `gh` CLI:

```powershell
gh repo edit --description "<<=350 char description>" --homepage "<url if any>"
gh repo edit --add-topic <topic1> --add-topic <topic2>   # lowercase, hyphenated
```

Topics reflect what the repo IS (language, domain, platform), not aspirations.
Description must match the README one-liner in substance.

### Hygiene (all tiers)

- `.gitignore` present and appropriate to stack
- No secrets in history tip: run identity/secret scan (below)
- CI config matches reality (skip check on T3)

## Identity & Secret Scanning

Run before any compliance sign-off:

```powershell
rg -n "(?i)(api[_-]?key|secret|password|token)\s*[:=]\s*['\"][A-Za-z0-9+/_-]{16,}" --glob '!package-lock.json' --glob '!pnpm-lock.yaml'
rg -n "(?i)(AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{30,}|sk-[A-Za-z0-9]{20,}|xox[baprs]-)"
git log --oneline -10   # confirm nothing sensitive was recently committed
```

Any hit = FAILED report. Remediation is rotate-and-purge, not delete-and-hope;
escalate to the user immediately.

## Compliance Report

Emit `.agents/compliance/YYYY-MM-DD-<repo>.md` (or inline for quick checks):

```markdown
# Compliance Report: <repo>
Date | Tier: T1/T2/T3 | Verdict: PASS | FAIL | PARTIAL

| Check | Status | Notes |
|---|---|---|
| Tier determined | OK | rationale |
| README identity block | OK/FAIL | |
| LICENSE Apache-2.0 | OK/FAIL/N-A | year+holder correct? |
| NOTICE | OK/FAIL/N-A | attributions listed? |
| GH description/homepage | OK/FAIL | actual value found |
| Topics | OK/FAIL | current list |
| .gitignore | OK/FAIL | |
| Secret scan | CLEAN/HITS | counts |
```

Every FAIL gets a fix row in the same report (what would resolve it).

## New-Repo Scaffolding

When creating a repo, apply in order: init + .gitignore -> README with identity
block -> LICENSE (+NOTICE) -> gh repo create with description/topics ->
first commit. Confirm remote visibility with `gh repo view` before reporting done.

## Guardrails

- Never guess the copyright holder name; read it from an existing file or ask.
- Never fabricate attribution entries; NOTICE lists only real bundled works.
- License changes on repos with external contributors need user confirmation.
- Report FAIL honestly; a clean-looking false PASS is worse than a red flag.

## Related Skills

- `crafting-effective-readmes` - README quality beyond identity block
- `cross-harness-state` - where compliance reports live (.agents/)
- `commit-work`, `git-commit` - committing standardization changes cleanly
