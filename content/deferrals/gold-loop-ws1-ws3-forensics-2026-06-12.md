# DEFERRAL — GOLD-LOOP WS1–WS3 Forensics (2026-06-12, chat-MCP session)

## Verdicts (all VERIFIED via direct MCP queries against loop_run latest, eval 2026-06-12 07:30Z)

### WS1 — G zoning: NOT an eval bug. CONFIRMED DATA GAP.
- Evaluator `gold_standard_loop()` G-logic audited end-to-end: parcel_zones→zoning_districts join = 0 misses on 361,733 rows; v_zoning_district_applicability covers ALL districts (0 NULL); arithmetic reconciles exactly to scoreboard (brevard FAR 25,305/51,766 = 48.9%).
- DUVAL: zero zoning parcel rows in this project. parcel_zones=0, zoning_assignments=0, zw_zoning=EMPTY (table-wide), mca_zoning=EMPTY (table-wide), zw_parcels has no duval rows and zoning_code is 100% NULL even for brevard. Brief premise "duval has deployed ZoneWise data" is FALSE in mocerqjnksmhcjzxrewo.
- BREVARD gaps (95% target): density 57.3%, FAR 48.9% (binding), pk1000 67.5%.
  - Density gap = 149,786 parcels / 71 districts; 78,261 parcels (31 districts) derivable from existing min_lot_sqft (SF 1-du/lot math) — needs per-district review before fill (duplex=2du, PUDs vary). Marker if filled: INFERRED, with ordinance_section cite.
  - FAR gap = 26,461 parcels in FAR-applicable districts with NULL max_far → ordinance extraction work (zoning_gold_standard_vault pipeline).
  - Top gap districts: Melbourne R-1AAA (53,435), Titusville R-1AAA (22,252), Rockledge R-1A (17,085), Titusville R-1B (9,855), West Melbourne R-1AAA (9,024).

### WS2 — I/J: J generator confirmed ABSENT; I is zoning-bound.
- bid_decisions = 21 rows total; 0 have ml_score; 0 have any factors keys. J = 0/19,586 brevard, 0/20,022 duval.
- J build spec (contract = pencil_dod_criteria letter J, evaluator predicate in gold_standard_loop §1): per-auction bid_decisions row with arv, max_bid, ml_score (Shapira V14) + factors{distress_location, distress_property, distress_owner, cma_distressed{value,sources}, cma_resale{value,sources}}. Arm-2 CMA requires external retail comps pipeline (HUD/HH, Zillow, Redfin, Realtor) — multi-session Claude Code build, dispatch via SUMMIT.
- I evaluator gates on v_zoning_gold_standard_card.zone_code NOT NULL → duval I mathematically blocked until duval zoning data exists. I is NOT independent of G's data gap.

### WS3 — Suwannee C/D pass = FALSE POSITIVE (volume artifact).
- suwannee auctions_total = 3; matched_clean 3/3. Not a replicable reference. Parity must be solved properly for majors: brevard C=20.9% (4,095/19,586) D=33.4%; duval C=16.1% (3,217/20,022) D=52.9%.

## Scoreboard deltas noted vs brief snapshot
- duval F now 63.3% (3,995/6,307) — improved from 46.8% via tier1 promotion. brevard F 40.6%.
- brevard E 73.9%, duval E 79.2% — E is the closest systemic criterion to threshold.

## Revised next-window priorities (leverage ÷ effort, post-forensics)
1. WS5/E first (data): parcel-linkage backfill brevard+duval (73.9/79.2 → 95) — nearest flip.
2. J generator build (Claude Code SUMMIT, 16:00Z window) — county-agnostic, critical-three letter.
3. Brevard zoning standards fill: derivable density (78K parcels, per-district INFERRED fill) + FAR ordinance extraction queue.
4. Duval ZoneWise acquisition = new data campaign (jurisdictions exist: 6; parcels: 0). Scope before committing.
5. Parity (C/D): litmus-match pipeline coverage audit — why only ~16–33% of majors match.

— Claude (AI Architect), chat-MCP session. Honesty: every number above read directly from prod via MCP this session.
