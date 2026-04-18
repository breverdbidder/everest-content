# Backfill Audit Report — Closed SUMMITs with NULL delivery_proof

**Date:** 2026-04-18
**Scope:** All closed SUMMITs in `summit_chat_dispatch` with `delivery_proof IS NULL OR delivery_proof = '{}'::jsonb`.
**Outcome:** 3 rows found. Each logged to `honesty_violations` with `severity='AUDIT'` (not CRITICAL — these are retroactive observations, not live violations).

---

## Original hypothesis vs. reality

My earlier claim in SUMMIT `cb13fa63`: *"24 historical closed SUMMITs with workflow_run_url IS NOT NULL AND delivery_proof IS NULL"*. That number was wrong — **24** is the total count of closed rows, not the ghost-success candidate count.

| Metric | Count | Note |
|---|---:|---|
| `state='closed'` total | 24 | |
| `state='closed'` with any proof | 21 | |
| `state='closed'` with NULL/empty proof | **3** | the actual audit scope |
| `state='closed'` with NULL proof **AND** `workflow_run_url` | **0** | no runner ghost-successes under `closed` |
| `state='verified'` with NULL proof | 0 | the v1 guardrail already enforced this |

The correction matters: no runner-side closed ghost-successes were found. The 3 null-proof closed rows had no `workflow_run_url` and no `github_issue_number` — they were manual closures, not ghosted runner outcomes.

---

## The 3 audited rows

| SUMMIT ID | Created | Completed | Title (truncated) | Likely cause |
|---|---|---|---|---|
| `719be44f-c4f2-434d-a37e-89f92aaf2845` | 04-17 01:54 | 04-17 02:39 | `[RE-DISPATCH] BUILD v3: Anchor-Bidder Counter-Proxy ML Archi…` | Re-dispatch superseded by a later SUMMIT; closed manually |
| `c07baadd-1a26-4b50-8f75-651a456dbcbd` | 04-17 01:54 | 04-17 02:39 | `[RE-DISPATCH] HUB-DAY0: Marketing Hub v0.1 scaffold + repo c…` | Same cluster — re-dispatch closed manually |
| `fc112cc3-870a-422d-87e6-4126b5714a37` | 04-15 09:31 | 04-16 19:59 | `SUMMIT #479 — AgentRemote V6 Daemon Bootstrap (ONE-TIME, EVE…` | Superseded by the canonical Supabase MCP dispatch rebuild per memory update |

All 3 closed cleanly on the same day or shortly after creation. None were open long enough to trigger the "max 10 open" rule. None have incomplete runner artifacts.

## What got logged

3 rows inserted into `public.honesty_violations`:

```
domain             = 'summit_dispatch'
tag_used           = 'CLOSED'
severity           = 'AUDIT'
session_source     = 'backfill-2026-04-18'
corrective_action  = 'None required — historical record. Future closures must include delivery_proof per guardrail v2.'
```

These are findable via:

```sql
SELECT * FROM honesty_violations
WHERE severity = 'AUDIT' AND session_source = 'backfill-2026-04-18'
ORDER BY created_at;
```

## Why AUDIT severity (not CRITICAL or HIGH)

Severity hierarchy for this domain going forward:

| Severity | Trigger | Semantic |
|---|---|---|
| `CRITICAL` | verified without evidence keys | 3× honesty penalty — lied about completion |
| `HIGH` | closed without any proof (post-guardrail-v2) | runner/user closed a SUMMIT with no trail — cannot audit outcome |
| `AUDIT` | retroactive observation | not a live violation — documented for history |

The 3 backfilled rows predate the guardrail and had no runner involvement — they belong in `AUDIT`, not `HIGH`.

## Guardrail v2 coverage (applied same day)

Any future `UPDATE summit_chat_dispatch SET state='closed'` lacking a non-empty `delivery_proof` will be blocked (SQLSTATE 23514) and logged to `honesty_violations` with severity=`HIGH`.

Minimal compliant payloads:
- `delivery_proof = jsonb_build_object('runner_note', '<why>')`
- `delivery_proof = jsonb_build_object('eval_findings', '...')`
- `delivery_proof = jsonb_build_object('cancellation_reason', 'pivoted')`

---

## Conclusion

The backfill found **no evidence of missed runner ghost-successes under `closed` state** — all 3 null-proof closures were manual. The real risk was under `verified` state, which v1 of the guardrail (applied 2026-04-18 earlier) already addressed. V2 extends the net to catch future `closed` transitions that lose their audit trail.

The Grafana dashboard at `dashboards/summit-dispatch-health.json` visualizes the honesty-violations trend and delivery-proof coverage going forward.
