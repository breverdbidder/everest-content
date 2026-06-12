# COMMITMENT ACCEPTANCE — GOLD STANDARD 24/7 ZERO-HITL AUTOPILOT (2026-06-12)

I, Claude (AI Architect), accept the mandate: continuous zero-HITL Claude Code coverage on the
Brevard + Duval gold-standard mission, with no staleness gaps, until both counties are certified
(gold on two consecutive evals). Platforms never pause — Shabbat applies to Ariel personally, never to agents.

## What now runs (all VERIFIED live in prod)
- `gold_standard_autopilot()` — cron job 161, every 5 minutes:
  - RULE 1: brevard+duval are NEVER unowned — if no live session holds them, AUTOPILOT-BD launches within 5 min.
  - RULE 2: global floor of 2 concurrent gold sessions, non-overlapping next-best counties (AUTOPILOT-NEXT).
  - EXIT: stands down automatically when both mission counties show certified in gold_standard_certifications.
  - GUARDS: R3 cap (≤10 open summits), anti-flap (10-min cooldown), cost cap (≤24 autopilot launches/day,
    on top of the 3 daily fleet windows of up to 14 shards). Caps are raisable on Ariel's word; raising
    spend-relevant caps surfaces first per the >$10 rule.
- Certification cadence upgraded: `gold_standard_certify()` now attached to ALL FOUR daily eval slots
  (07:30/13:30/19:30/01:30Z) — two consecutive golds achievable within ~6h of the last criterion flipping.
- Self-healing chain (pre-existing, now closed-loop): dispatcher-v7 (1-min) → R5 stale-TTL enforcer (5-min,
  quarantines queued>60s/dispatched>5m/running>30m/awaiting>2h/failed>10m) → autopilot relaunch (≤5-min).
  A dead session costs the mission at most ~10 minutes before a replacement owns its counties.

## Test evidence (this session)
- First fire: detected ZERO live gold sessions (dead air between fleet windows — the exact staleness the
  mandate targets), launched AUTOPILOT-BD (f18f1178) + AUTOPILOT-NEXT charlotte/citrus/broward (61851369).
- Bug caught and fixed in test, not production drift: pipeline state `issue_created` missing from alive-set
  (would have caused duplicate launches) — patched v1.2, re-verified: cooling/inflight=2/bd_covered=true.
- Telemetry arithmetic fix v1.1.

## Honesty terms of this acceptance
- Zero-HITL covers execution, verification, quarantine, relaunch. It does NOT cover: prod-table schema
  changes, >$10 spend, security changes, or litmus-source redefinition (C/D) — those surface to Ariel by
  standing rule, with autopilot continuing on everything else meanwhile.
- Timeline of record: gold-standard-timeline-commitment-v1 (Brevard Jul 31 / Duval Aug 14, gates Jun 16 + Jun 29).
- Ghost-success remains banned: autopilot launches sessions; only the unmodified evaluator flips criteria.

— Claude, AI Architect. cron 161 / fn gold_standard_autopilot v1.2 / accepted 2026-06-12T11:2xZ.
