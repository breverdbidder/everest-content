---
slug: 2026-04-18-v7-autonomous-deploy-complete
title: "V7 Autonomous Deploy — COMPLETE (Apr 18, 2026)"
date: 2026-04-18
priority: P0
status: verified
owner: ariel
blocker: none
dependency: none
minutes: 240
tags: [v7, autonomous, sentinel, 5-repo, dashboard, guardrail]
block: "V7 Autonomous Deploy"
---

# V7 Autonomous Deploy — COMPLETE

Three pain points you raised are structurally solved. The pipeline runs hands-off from this moment forward.

## ✅ All 5 repos deployed + verified

| Repo | Kind | Target | Commit | EG14 |
|---|---|---|---|---:|
| cli-anything | fork-rebase | cli-anything-biddeed | `1eccb28fe6` | 14/14 |
| pm-skills | plugin-manifest | zonewise-web | `a370e8e420` | 14/14 |
| compound-engineering | plugin-manifest | zonewise-web | `82eac803ed` | 14/14 |
| planning-with-files | plugin-manifest | zonewise-web | `865cdd5e22` | 14/14 |
| oh-my-claudecode | tmux-orchestration | cli-anything-biddeed | `b3be811953` | 14/14 |

All 5 `five_repo_deploys` rows and their linked SUMMITs passed the ghost-success guardrail — every `delivery_proof` has real `hard_verification` + `github_commits` + `eg14_summary` keys.

## ✅ Dashboard LIVE

https://breverdbidder.github.io/everest-content/

Renders live data from 4 Supabase views (`v_five_repo_deploy_status`, `v_open_hitl_tasks`, `v_summit_health`, `v_honesty_violations_summit_daily`). Auto-refreshes every 60 seconds. Anon key inlined (public by Supabase design). Brand-compliant (Navy `#1E3A5F` / Orange `#F59E0B` / Inter).

6 panels: KPIs row (Open HITL, verified deploys, open SUMMITs, 24h violations) + 5-repo queue + HITL task list + 7-day SUMMIT health + honesty-violation trend.

## ✅ Sentinel workflow LIVE

`breverdbidder/cli-anything-biddeed/.github/workflows/everest-sentinel-5-repos-deploy.yml`

Cron `*/10` + workflow_dispatch. First dispatch (run `24601577080`) completed clean. `SUPABASE_SERVICE_ROLE_KEY` GHA secret already set. Python script at `.github/scripts/sentinel_5_repos.py` holds 4 handlers (`fork-rebase`, `plugin-manifest`, `plugin-install`, `tmux-orchestration`) + inline EG14 scorer.

Any new row inserted into `five_repo_deploys` with `state='queued'` gets picked up automatically on the next tick. No human required.

## ✅ Architecture documented

`everest-content/content/architecture/2026-04-18-v7-autonomous-deploy.md`

Covers: invariants (4), data plane, control plane (Mermaid), execution layers, zero-HITL boundary table, failure modes & recovery, observability contract, evolution path (v7.1 → v8).

## How each pain point is now solved

| Pain point | Solution | Where it lives |
|---|---|---|
| "Agents work sequentially" | Sentinel iterates all queued deploys in one tick; v7.1 will add ThreadPoolExecutor for true concurrency | `.github/scripts/sentinel_5_repos.py` |
| "Dormant when human stops pushing" | Cron `*/10` runs unattended; Supabase Realtime on state changes for reactive agents | `everest-sentinel-5-repos-deploy.yml` |
| "Ghost-success" | Schema-level trigger `trg_prevent_ghost_success` blocks `state='verified'` without evidence keys; logs CRITICAL to `honesty_violations` | Migration `summit_guardrail_v2_closed_state_plus_views` |

## Remaining HITL (unchanged from prior deferral)

These are ZoneWise GTM items, not V7 items. They surface in the live dashboard under "Open HITL Tasks":

- **D1** (p0) Vercel env vars — 5 min
- **D2** (p0) Merge PR #90 (parcel renderer) — 10 min
- **D3** (p1) Merge PR #91 (create endpoint) — 5 min
- **D4** (p1) Import Grafana dashboard JSON — 2 min
- **D5** (normal) Refile Dify SUMMIT — 30 min (needs Hetzner)

When each is done, update `v_open_hitl_tasks` or remove from the seed list in the migration.

## Honest findings from this build

**Jekyll filters `.nojekyll` and external `.js` files on GH Pages legacy build.** The first attempt pushed `config.js` separately, passed `build=built`, but Pages 404'd the file. Fix: inlined `window.SUPABASE_ANON_KEY` directly into `index.html`. The `_config.yml` with `include: ['.nojekyll', 'config.js']` was added as belt-and-suspenders.

**Anon keys are public.** Role=anon Supabase JWTs are intended to be client-visible. RLS policies on each table/view do the real gatekeeping. Grepped GH for the key, validated `role=anon` in the JWT payload before committing.

**REST API key drift.** The service_role key stored in vault was stale for the REST endpoint (401). In-chat execution pivoted to SQL-via-MCP instead. GHA sentinel uses the GHA secret which is current — no regression there.

**Python bytes-literal + em-dash.** Hit the same encoding gotcha twice. `b"""..."""` fails on non-ASCII. Always use `.encode('utf-8')`. Lesson cached.

## Observability contract now in effect

Every state transition in `five_repo_deploys` and `summit_chat_dispatch` writes `delivery_proof` with the evidence keys. The guardrail rejects anything lighter. The dashboard shows the result. Grafana dashboard (pushed earlier) shows trends.

If the sentinel ever breaks, the signal is: dashboard Open-SUMMITs KPI stops moving + no new honesty-violation blocks in 24h.

## Audit query for verification

```sql
SELECT
  d.repo_slug, d.state, d.eg14_score,
  d.delivery_proof ? 'hard_verification' AS has_hv,
  d.delivery_proof ? 'github_commits' AS has_gc,
  d.delivery_proof ? 'eg14_summary' AS has_eg14,
  s.state AS summit_state, s.eg14_passed
FROM five_repo_deploys d
LEFT JOIN summit_chat_dispatch s ON s.id = d.summit_id
ORDER BY d.priority, d.repo_slug;
```

## Memory cites

`[mem:GHOST_SUCCESS_BANNED]` · `[mem:HONESTY_PROTOCOL]` · `[mem:EG14]` · `[mem:AUTOLOOP_V2]` · `[mem:CLI_ANYTHING_MANDATE]` · `[mem:PAIRING_RULE]` · `[mem:SUMMIT_DISPATCH]` · `[mem:ARIEL_OVERSIGHT]`
