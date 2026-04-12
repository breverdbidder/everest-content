---
layout: dono-v5
title: "The AI Document Extraction Funnel"
dek: "A consulting tutorial independently lands on the same 3× wrong-answer penalty Everest has been running for months. Validation of the HONESTY PROTOCOL — plus two concrete schema deltas worth shipping."
date: 2026-04-12
type: transcript
verdict: "CONFIRM + DELTA"
verdict_class: confirm
source: "https://youtu.be/h58OFb4xfZQ"
author: "Dylan Cleppe"
tags:
  - research
  - intake
  - extraction
  - honesty-protocol
permalink: /research/transcripts/dylan-extraction-funnel/
---

## Source

- **Video:** [youtu.be/h58OFb4xfZQ](https://youtu.be/h58OFb4xfZQ)
- **Author:** Dylan Cleppe
- **Duration:** ~15 min
- **Classification:** Pattern, not repo

## TL;DR

Dylan's "AI funnel" validates the HONESTY PROTOCOL's 3× penalty **verbatim** and contributes a cleaner per-field completeness taxonomy (`extracted / inferred / missing / ambiguous`) that is **orthogonal** to Everest's existing claim-confidence axis (`VERIFIED / UNTESTED / INFERRED`). Both should coexist. Two schema deltas worth shipping.

## Core thesis

Chaos in (PDFs, scans, emails of arbitrary shape) → AI funnel → consistent template out. Three-step build: **define output → set rules → build and test**. The output is the thing most people skip, and it's the most important.

### 1. Output-first design

Pull fields from the existing template: name, type (text/date/number), required/optional. No template? Feed 3–5 completed examples to a high-reasoning model and have it reverse-engineer the schema. Aliases absorb client naming variance.

### 2. Three anti-hallucination rules

1. **Grounding** — "Base extraction only in the uploaded document. No internet. No prior knowledge."
2. **Incentive flip** — **"Any wrong answer is 3× worse than a blank answer."**
3. **Force evidence** — Every extracted value must include the exact source quote from the document for fast audit.

### 3. Audit table schema

Dylan's output format before the final deliverable is a four-column audit table:

`field_name | value | source_quote | status`

Status is one of: `extracted` (word-for-word match), `inferred` (AI admits guessing — double-check these), `missing` (blank), or `ambiguous` (conflicting source signals).

### 4. Self-improvement loop

When the AI makes a mistake, log it to an `errors.md` file in the project folder. On a weekly or monthly cadence, ask the AI to review the error file, identify themes, and make a **"minimal, surgical"** update to the system prompt to systematically fix the class of error. Critical warning: emphasize *minimal and surgical*, or the AI over-engineers the prompt into bloat and makes things worse.

### 5. Browser to desktop agent migration

Move from Claude/GPT/Gemini projects to Claude Code / Cowork / Codex when processing exceeds ~8–10 files per day. Desktop agents unlock folder-scale processing (50–100+ files), persistent error logs, self-healing prompt updates, and tool/connector creation for downstream system integration.

## Cross-pollination to the Everest stack

| Dylan's pattern | Everest equivalent | Action |
|---|---|---|
| 3× wrong-answer penalty | HONESTY PROTOCOL (already running) | External validation. No change. |
| `extracted/inferred/missing/ambiguous` | `VERIFIED / UNTESTED / INFERRED` | Orthogonal axis. Add both. |
| `source_quote` audit column | No direct equivalent in OSINT events | Add `source_quote` column. |
| `errors.md` → surgical prompt refinement | AUTOLOOP V2 (deploy → verify → RCA → evolver) | **Shipped 2026-04-12 as K3 surgical-changes guardrail on the evolver.** |
| Reverse-engineer template → Claude Skill → pixel-perfect output | Dono v5 battle card template replication | Already doing this. Confirmation only. |

## Verdict

**Pattern — not a repo.** Nothing to fork. The value is external validation of HONESTY PROTOCOL's 3× rule plus a cleaner per-field completeness vocabulary that fills a real gap.

## Concrete actions

- **[P1] Schema:** Add `source_quote` column to `osint_events`, `zw_parcels` extraction outputs. ~15 min Supabase migration.
- **[P1] Schema:** Add `extraction_status` enum (`extracted / inferred / missing / ambiguous`). Coexists with VERIFIED/UNTESTED/INFERRED — different axis.
- **[DONE 2026-04-12] AUTOLOOP:** K3 surgical-changes guardrail on V2 evolver — rejects prompt updates exceeding 20% line growth. Commit `1533af22513e` on cli-anything-biddeed.
- **[P2] Content:** LinkedIn validation post — "A consultant just independently landed on the 3× rule Everest has run for 4 months." PAIRING RULE applies.
