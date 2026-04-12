---
layout: dono-v5
title: "Karpathy's CLAUDE.md Discipline Layer"
dek: "A 14k-star single-file instruction layer that fixes Claude Code's worst behaviors: silent assumptions, over-engineering, off-scope edits, and unverified completion. Karpathy himself starred it. Four principles. MIT license. Adopted across 52 Everest repos."
date: 2026-04-12
type: repo
verdict: "ADOPT + MERGE"
verdict_class: adopt
repoeval_score: 92
source: "https://youtu.be/PzhTLHQfdRE"
repo: "https://github.com/forrestchang/andrej-karpathy-skills"
tags:
  - research
  - intake
  - claude-code
  - discipline
  - autoloop
  - repoeval
permalink: /research/transcripts/karpathy-skills-review/
---

## Source

- **Video:** [youtu.be/PzhTLHQfdRE](https://youtu.be/PzhTLHQfdRE)
- **Repo:** [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills)
- **License:** MIT ✓
- **Stars / Forks:** ~14k / ~970

## TL;DR

Single `CLAUDE.md` file (plus Claude Code plugin wrapper) encoding four behavioral principles to stop Claude Code from making silent assumptions, over-engineering, touching unrelated code, and claiming completion without verification. These map **directly** onto gaps in the current SUMMIT + AUTOLOOP discipline — particularly "surgical changes" and "goal-driven execution."

## The four principles

1. **Think before coding** — surface assumptions, present multiple interpretations, push back when warranted, never pick silently.
2. **Simplicity first** — minimum code that solves the problem. No speculative abstractions. No framework for a one-function task.
3. **Surgical changes** — only touch what the task requires. No drive-by cleanups, refactors, or comment rewrites in adjacent code.
4. **Goal-driven execution** — turn vague requests into verifiable success criteria. Reproduce → fix → verify → stop.

## REPOEVAL

| Metric | Value |
|---|---|
| License | **MIT** ✓ clean |
| Size | ~27 KB |
| Stars / Forks | ~14k / ~970 |
| Social proof | Starred by Karpathy himself, Chip Huyen, Wing Lian, Junyang Lin |
| Integration cost | < 10 min |
| Relevance | Direct to SUMMIT/AUTOLOOP |
| **Score** | **92 / 100** |

## Install paths (from upstream README)

```bash
# Option A: Claude Code plugin
/plugin marketplace add forrestchang/andrej-karpathy-skills
/plugin install andrej-karpathy-skills@karpathy-skills

# Option B: per-project CLAUDE.md append
curl https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/CLAUDE.md >> CLAUDE.md
```

## Cross-pollination to Everest stack

| Karpathy principle | Everest equivalent | Delta |
|---|---|---|
| Think before coding | HONESTY PROTOCOL | Already covered. External validation. |
| Simplicity first | XGBoost efficiency (90 min/chat) | Complementary axis (per-diff vs per-session). |
| **Surgical changes** | **Was gap in AUTOLOOP V2 evolver** | **SHIPPED 2026-04-12 as K3 guardrail.** |
| Goal-driven execution | EG14 + SUMMIT verdict phase | Already mature. |

## Warning — merged, not byte-concatenated

Everest CLAUDE.md files already carry PAIRING RULE, HONESTY PROTOCOL, COST DISCIPLINE, CLI-anything mandates. A wholesale `curl ... >> CLAUDE.md` would duplicate rules and bury Everest-specific invariants. The adoption across all 52 repos on 2026-04-12 was a **semantic merge** — a bounded section labeled K1–K4 that references the existing Everest rules instead of duplicating them.

## Verdict: ADOPT + MERGE (executed)

Principles 02 and 03 filled real gaps. The specific win was making **surgical changes** an explicit hard constraint on the AUTOLOOP V2 evolver. This closed the bloat failure mode flagged independently by Dylan Cleppe (extraction funnel) and Karpathy (surgical changes) in the same week. Two independent sources converging on the same gap = shipped.

## Concrete actions — status

- **[DONE 2026-04-12] Merge:** Added `## Behavioral Discipline (Karpathy)` section to 52 Everest repos' CLAUDE.md, idempotent via `<!-- KARPATHY_DISCIPLINE_BEGIN v1.0 -->` markers. Zero failures.
- **[DONE 2026-04-12] AUTOLOOP:** Surgical diff constraint shipped on V2 evolver — `_MAX_LINE_GROWTH_PCT = 20`, `_surgical_filter()` method, hook point in `generate()`. Commit `1533af22513e` on `cli-anything-biddeed`. Patch itself is +7% growth, respects its own rule.
- **[P3] Plugin:** Evaluate `/plugin install andrej-karpathy-skills@karpathy-skills` on one dev box before fleet-wide adoption.
- **[P2] Content:** LinkedIn post — "Two-source convergence: Dylan + Karpathy on prompt bloat within 48 hours. Here's the enforcement commit." PAIRING RULE applies.

## Related intake

- [Dylan extraction funnel](/research/transcripts/dylan-extraction-funnel/) — independent "minimal surgical" warning, same week.
