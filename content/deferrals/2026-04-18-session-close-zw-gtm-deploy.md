---
slug: 2026-04-18-session-close-zw-gtm-deploy
title: "Session Close — ZW GTM Deploy (Apr 18, 2026)"
date: 2026-04-18
priority: P1
status: deferred
owner: ariel
blocker: HITL (3 items — Vercel env vars, PR merges, Dify admin access)
dependency: PR #90, PR #91, INTERNAL_AUTH_TOKEN generation
minutes: 180
tags: [zw-gtm, parcel-cards, guardrail, dify, session-close, honesty-protocol]
block: "ZW GTM Apr 17-26"
---

# Session Close — ZoneWise GTM Parcel-Cards Deploy

Three hours, one chat session, five SUMMITs, two PRs, one schema guardrail. Everything that could be done from this chat was done from this chat. Remaining work is bounded and needs Ariel or Hetzner access.

---

## What shipped (VERIFIED)

### 1. Supabase schema — `public.parcel_cards` family (live on `mocerqjnksmhcjzxrewo`)

- Table `parcel_cards`: 15 columns, 4 indexes, updated_at trigger.
- View `parcel_cards_public`: denormalized JOIN to `zw_parcels` for SEO-indexable card URLs.
- RPCs: `create_parcel_card()`, `increment_parcel_card_view()`, `increment_parcel_card_share()`.
- RLS: 5 policies — owner-scoped writes, public reads for cards flagged `is_public=true`.
- Smoke-tested against real Brevard parcel (1605 SWEETWOOD DR, PIN `27 3708-02-*-42`), card `29d7c24f-f10b-434b-be2e-81d5729e9457` incremented through the view-increment RPC.
- Migration: `parcel_cards_phase1_viral_loop_v2_clean` (superseded the runner's degraded `v1` with wrong FK type).

### 2. Anti-ghost-success guardrail v2 (live)

- Function `prevent_summit_ghost_success()` — SECURITY DEFINER, blocks state-transitions into `verified` (strict, evidence keys required) and `closed` (weak, non-empty proof required). Logs blocked attempts to `honesty_violations` with CRITICAL / HIGH severity.
- Trigger `trg_prevent_ghost_success` BEFORE UPDATE OF state on `summit_chat_dispatch`, enabled.
- Analytics views: `v_honesty_violations_summit_daily`, `v_summit_health`.
- Tested end-to-end: null proof BLOCKED, dispatch-markers-only BLOCKED, real evidence ACCEPTED, runner_note alone ACCEPTED for closed.
- Backfill: 3 historical closed null-proof SUMMITs logged to `honesty_violations` with severity `AUDIT` (none had runner involvement — all manual closures).

### 3. GitHub artifacts on `breverdbidder/everest-content`

| Path | Commit | Purpose |
|---|---|---|
| `content/research/2026-04-18-zw-bd-growth-loops.md` | `ea57a097` | GTM brief (pm-skills growth-loops output) |
| `content/research/2026-04-18-parcel-cards-DEPLOY.md` | `4a6620cf` | Runbook |
| `content/research/parcel-card-preview.html` | `af2dc33f` | Visual preview |
| `content/research/2026-04-18-backfill-audit-closed-summits.md` | `302a443f` | Backfill audit report |
| `migrations/2026-04-18-summit-ghost-success-guardrail.sql` | `072dd989` | Guardrail v1 |
| `migrations/2026-04-18-summit-guardrail-v2-closed-state.sql` | `a5fd2eb3` | Guardrail v2 |
| `dashboards/summit-dispatch-health.json` | `fa9b6262` | Grafana dashboard (6 panels) |
| `scripts/smoke-dify-parcel-cards.sh` | `801f16f9` | Dify integration smoke test |

### 4. Next.js files on `breverdbidder/zonewise-web`

- **PR #90** (branch `summit/77c39794-parcel-cards`): renderer — `app/parcel/[id]/page.tsx` + `view-pixel.tsx` + `not-found.tsx` + `middleware.ts` patch (allowlisting `/parcel` and `/property`).
- **PR #91** (branch `summit/77c39794-parcel-create-api`): creation endpoint — `lib/parcel-cards.ts` + `app/api/parcel-cards/create/route.ts`.

---

## Deferred — HITL required

Ordered by prerequisite chain. Each downstream item is blocked until the one above it clears.

### D1 — Vercel env vars on `prj_EaXgEO6WDoSpCeLhuCemtbPr6e8E`

**Who:** Ariel. **Time:** 5 min.

```
NEXT_PUBLIC_SUPABASE_URL       = https://mocerqjnksmhcjzxrewo.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY  = <from Supabase dashboard → API settings>
SUPABASE_SERVICE_ROLE_KEY      = <from Supabase dashboard → API settings, server-only>
INTERNAL_AUTH_TOKEN            = <new; generate with `openssl rand -hex 32`>
```

Service role key + internal auth are required for PR #91's route. Anon key is required for PR #90's server component.

### D2 — Merge PR #90 (renderer)

**Who:** Ariel. **Depends on:** D1 (anon key only). **Time:** 10 min including preview verification.

- Visit Vercel preview URL (auto-generated on PR open).
- Navigate to `/parcel/29d7c24f-f10b-434b-be2e-81d5729e9457` — should render the 1605 Sweetwood Dr card.
- Browser console: zero CSP violations. CSP is already strict via existing middleware.
- If preview green → merge.
- Unblocks EG14 points 1, 2, 14 on parent SUMMIT `77c39794`.

### D3 — Merge PR #91 (create endpoint)

**Who:** Ariel. **Depends on:** D1 (service role + internal auth). **Time:** 5 min.

- `curl -X POST https://zonewise-web-preview.vercel.app/api/parcel-cards/create` with no auth header → expect 401. That confirms auth gate works.
- Merge.

### D4 — Import Grafana dashboard

**Who:** Ariel (or whoever maintains Grafana). **Time:** 2 min.

- Dashboard → Import → paste contents of `dashboards/summit-dispatch-health.json`.
- Select Supabase Postgres datasource.
- 6 panels become visible: honesty-violations trend, SUMMITs by state, EG14 pass-rate, last-24h violations table, median duration by priority, delivery-proof coverage %.

### D5 — Refile Dify SUMMIT (was `ba0ea1fc`, closed today)

**Who:** Needs Hetzner Dify admin access. **Depends on:** D1 + D2 + D3. **Time:** 30 min.

Original SUMMIT body is correct; only needs:
- `target_repo = breverdbidder/cli-anything-biddeed` (not `zonewise` — that's why it 404'd)
- Confirmation that PR #90 + PR #91 are merged
- Confirmation `INTERNAL_AUTH_TOKEN` is accessible to Dify

Use the smoke script `scripts/smoke-dify-parcel-cards.sh` as the hard-verification gate (exit 0 required before SUMMIT can be marked verified — or the v2 guardrail will block it).

---

## Session SUMMIT ledger (5 rows)

| ID | Title | State | EG14 | Evidence keys |
|---|---|---|---|---|
| `77c39794` | Parcel cards viral loop (parent) | verified | 11/14 | 11 keys incl runner_ghost_success_detected |
| `cb13fa63` | Ghost-success guardrail v1 | verified | 14/14 | 5 evidence keys |
| `7d5f3046` | Guardrail v2 + backfill + Grafana | verified | 14/14 | 6 evidence keys incl dispatch_backfill |
| `ba0ea1fc` | Dify HTTP-node wiring | closed | — | runner_note, cancellation_reason, refile_when |
| `bddb2be7` | Guardrail (duplicate) | closed | — | runner_note citing CTE concurrency bug, superseded_by |

Open SUMMITs at session end: **0**.

---

## Known issues surfaced (honesty protocol)

### CTE INSERT + UPDATE on same table

Postgres CTEs with modifying statements run **concurrently**, not sequentially. `WITH inserted AS (INSERT ... RETURNING id) UPDATE ... WHERE id = (SELECT id FROM inserted)` will NOT work as expected — the UPDATE's subquery reads pre-INSERT state. Result: row is inserted but update silently does nothing. I hit this with `cb13fa63` / `bddb2be7` duplication. Fix: always split into two statements.

### Ghost-success pattern confirmed live

SUMMIT `77c39794` flipped to `verified` in 4 min with **zero commits** to its target repo and `null` EG14 score. The runner reported success, produced no deliverables, and the old system had no enforcement. Guardrail v2 now makes this structurally impossible.

### Scope correction (was honest-ly wrong)

I stated earlier that 24 historical closed SUMMITs might be ghost-success candidates. Actual scope: **3**, and none had `workflow_run_url` — all manual closures, not runner ghosts. Corrected in the backfill audit report.

---

## Audit queries Ariel can run anytime

```sql
-- Recent honesty violations in summit_dispatch domain
SELECT id, severity, LEFT(claim, 100), LEFT(actual_truth, 80), created_at
FROM honesty_violations
WHERE domain = 'summit_dispatch'
ORDER BY created_at DESC LIMIT 20;

-- Session SUMMITs rollup
SELECT state, count(*), round(avg(eg14_score), 1) AS avg_eg14
FROM summit_chat_dispatch
WHERE chat_session_id = 'chat-2026-04-18-zw-gtm-deploy'
GROUP BY state;

-- Open SUMMITs right now
SELECT id, LEFT(summit_title, 60), state, created_at
FROM summit_chat_dispatch
WHERE state IN ('queued','issue_created','dispatched','running')
ORDER BY created_at;

-- Verify guardrail still live
SELECT tgname, tgenabled FROM pg_trigger
WHERE tgrelid = 'public.summit_chat_dispatch'::regclass AND NOT tgisinternal;
```

---

## Next-session pickup guide

If opening a fresh session to continue this work, read in this order:

1. This deferral (you are here).
2. `content/research/2026-04-18-zw-bd-growth-loops.md` — the GTM brief that seeded this whole thread.
3. `content/research/2026-04-18-parcel-cards-DEPLOY.md` — the runbook.
4. PR #90 + PR #91 on GitHub — the code deliverables.
5. Audit query above to check current SUMMIT state.

Then tackle D1 → D5 in order.

---

## Memory cites

`[mem:ZW_GTM]` · `[mem:PAIRING_RULE]` · `[mem:INFRA_SSOT]` · `[mem:BRAND]` · `[mem:EG14]` · `[mem:HONESTY_PROTOCOL]` · `[mem:GHOST_SUCCESS_BANNED]` · `[mem:K1_K4]` · `[mem:SESSION_DEFERRAL]` · `[mem:ARIEL_OVERSIGHT]`
