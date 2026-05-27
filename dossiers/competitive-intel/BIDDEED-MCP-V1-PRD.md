# BidDeed MCP V1 · Product Requirements Document (PRD)

**Version:** v1.0
**Owner:** Ariel Shapira (Everest Capital USA)
**Generated:** 2026-05-27 from SUMMIT-E competitive intelligence
**Status:** DRAFT for review
**Companion docs:** PRS-V1 (technical spec), RENTCAST-MCP-DOSSIER-V1, rentcast-v5-REFERENCE battle card
**Honesty Protocol V3:** All strategic claims tagged. Competitive references VERIFIED unless marked.

---

## 1 · Executive Summary

BidDeed.AI MCP V1 exposes the **356,384-row Florida distressed-property auction corpus + 10.5M FL parcel database** as a B2B agentic API, paired with ZoneWise (67-county zoning + parcel intelligence) [VERIFIED via Supabase counts]. We adopt the RentCast self-serve B2B envelope ($0 / $99 / $249 / $499 / custom) with **MCP on every paid tier** [INFERRED from RentCast's verified pricing structure proving solo-founder viability]. We differentiate on FL distressed depth, the 14-claim Shapira Triangle V4.0 IP portfolio, and the BidDeed + ZoneWise paired-product wedge. **Target: 100 paying API customers by Q4 2026; $500K ARR run-rate by Q2 2027** [PLANNING TARGET].

## 2 · Problem Statement

Institutional and high-volume distressed-property investors in Florida currently rely on:
- **Manual scraping** of 67 county auction sites (realforeclose / realtaxdeed / realtdm) — fragile, time-expensive
- **Generic real estate APIs** (ATTOM, RentCast, PriceHubble) — nationwide rental focus, **0 coverage of distressed inventory** [INFERRED — none of these vendors expose foreclosure/tax-deed auction calendars in their MCP surface]
- **Enterprise data licenses** (Cherre, $50K+/year floor) — incompatible with solo-investor / agent ICPs
- **Single-county vendors** (PropertyOnion, Daveco/FloridaBidder) — limited cross-county aggregation, no MCP

**The gap:** no agent-accessible, self-serve, single-source-of-truth API for FL distressed inventory + zoning context. BidDeed + ZoneWise closes it.

## 3 · Target Users (ICP)

**Primary (P0):**
- **Distressed-property investor agents** building AI workflows (Claude Desktop, Cursor, custom agents) for deal-flow monitoring across multiple FL counties
- **Institutional buyer ops teams** (private equity funds, real estate hedge funds) needing programmatic auction calendars

**Secondary (P1):**
- **Real estate wholesalers + flippers** doing manual deal scoring at higher volume than spreadsheets allow
- **FL-licensed brokerages** with distressed-specialty teams (e.g. Property360, Mariam's brokerage as in-house reference customer)

**Tertiary (P2):**
- **PropTech developers** building consumer apps for FL inventory discovery
- **Government / housing-policy researchers** needing distressed-market signals

## 4 · Use Cases (8 anchor flows)

| # | Use case | MCP tool surface | Daily query volume estimate |
|---|---|---|---|
| 1 | "What FL tax-deed auctions are happening this week within 50mi of Miami?" | `auctions_upcoming(geo, date_range, type)` | ~50 |
| 2 | "Score this Brevard County tax-deed sale 41-2024-CA-012345 — investment-grade?" | `auction_score(case_id, model='shapira_v4')` | ~200 |
| 3 | "Pull the Triangle V4.0 cycle signal for Palm Beach County" | `triangle_cycle(county_fips)` | ~30 |
| 4 | "Get parcel-level zoning + entitlement risk for FL parcel 12345-67-89" | `zonewise_parcel(parcel_id)` *via ZoneWise* | ~150 |
| 5 | "Stream new realforeclose cases for Duval County since yesterday" | `auctions_subscribe(county, since)` | ~20 (streaming) |
| 6 | "Cross-reference this auction property with current owner Official Records" | `auction_owner_history(case_id)` | ~80 |
| 7 | "Show me convergence-detection signals across all 67 FL counties" | `convergence_scan(threshold, lookback_days)` *Triangle Claim 13* | ~10 |
| 8 | "Generate a deal sheet PDF for case X with all 4 Triangle vertices" | `deal_sheet(case_id, format='pdf')` | ~40 |

## 5 · Functional Requirements

**F1 — Coverage breadth:** All 67 FL counties on day 1 [VERIFIED 67/67 URL matrix live in `fl_67_consolidated_matrix.csv`]
**F2 — Data freshness:** Auction calendar ≤24h stale; recorded events ≤72h stale
**F3 — MCP-native:** Tools shipped with MCP server on every paid tier — NOT enterprise-gated [DIFFERENTIATOR vs Cherre/ATTOM]
**F4 — Auth:** X-Api-Key header + Stripe billing [INFERRED match RentCast]
**F5 — Self-serve onboarding:** $0 developer tier with 100 req/mo, no sales call, MCP active on day 1
**F6 — Triangle V4.0 scoring API:** All 14 patent claims accessible via tools; Claim 13 (convergence) + Claim 14 (RE cycle) as dedicated endpoints
**F7 — Pairing:** Every customer who signs up for BidDeed gets a ZoneWise read-only tier free (cross-sell hook)
**F8 — Honesty markers in responses:** Every JSONB response field carries `_marker` (VERIFIED/INFERRED/UNTESTED) so customer agents know data confidence — Honesty Protocol V3 as a product feature

## 6 · Pricing Tiers (matches RentCast envelope)

| Tier | $/mo | Requests/mo | Overage/req | MCP | Target customer |
|---|---|---|---|---|---|
| Developer | $0 | 100 | $0.15 | ✅ | Hobbyists, agent builders, evaluators |
| Entry | $99 | 1,500 | $0.05 | ✅ | Solo investors, small brokerages |
| Growth | $249 | 7,500 | $0.025 | ✅ | Mid-size flipping operations, wholesalers |
| Scale | $499 | 30,000 | $0.012 | ✅ | Institutional ops teams |
| Enterprise | custom | custom | custom | ✅ | FL state agencies, large PE funds |

**Pricing rationale:** RentCast proves $0 → $449 self-serve envelope works for solo-founder API platforms [VERIFIED RentCast tier structure]. BidDeed adds $50 floor uplift because FL distressed data is more specialized than nationwide rental.

## 7 · Success Metrics (90/180/365 day)

**Day 90 (Aug 2026):**
- 10 paying customers across Entry/Growth tiers
- 50 Developer tier signups
- MCP installed in Claude Desktop registry
- $1,500/mo MRR

**Day 180 (Nov 2026):**
- 40 paying customers
- 200 Developer signups (10% conversion benchmark)
- 1 Scale-tier customer
- $10K/mo MRR

**Day 365 (May 2027):**
- 100 paying customers
- $40K/mo MRR ($480K ARR run-rate)
- 1 Enterprise contract
- ZoneWise cross-sell attached to >70% of BidDeed customers

## 8 · Out of Scope (V1)

- **Nationwide coverage** — FL only. Expansion to GA/AL/SC = V2 (Q4 2026).
- **Consumer SaaS app** — DealCheck owns this category, no overlap.
- **MLS data licensing** — separate workstream, not in MCP V1.
- **Patent prosecution** — separate IP workstream (14 claims already filed).
- **Hardware/IoT** — N/A.

## 9 · Competitive Context

| Competitor | Threat | Pricing pattern | MCP? | Our wedge |
|---|---|---|---|---|
| **RentCast** [VERIFIED] | MEDIUM (positioning collision) | $0-$449/mo 5-tier | YES every tier | FL distressed ≠ nationwide rental |
| **DealCheck** [VERIFIED] | LOW (different category) | $0-$20/mo consumer | NO | Different ICP entirely |
| **Cherre** [PRIOR-SESSION] | LOW (different price floor) | $50K+/year enterprise | UNKNOWN | We undercut + MCP-native |
| **ATTOM** [PRIOR-SESSION] | MEDIUM | Enterprise data API | UNKNOWN | FL specialization |
| **PropertyOnion** [PRIOR-SESSION] | MEDIUM (FL focus overlap) | Subscription | NO | We have MCP + IP + ZoneWise pairing |
| **FloridaBidder/Daveco** [PRIOR-SESSION] | MEDIUM (FL focus + 15 counties) | Subscription | NO | We have 67/67 county coverage + MCP |

Full battle cards: `breverdbidder/everest-vault/600-Research/battle-cards/`

## 10 · Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| RentCast expands into FL distressed | LOW | Solo founder, 5yo company, no announcements [INFERRED] |
| ATTOM cuts price floor 80% | LOW | Strategic moat is data, not price |
| FL county tech vendor change (Tyler → other) breaks scrapers | MEDIUM | Multi-source ingestion (L1 real*.com + L2 Tyler + L3 OR Books) — 3-source composite already proven |
| Claude/Anthropic MCP registry policy changes | MEDIUM | Maintain backup distribution via direct npx install |
| Solo founder burnout | HIGH | Aggressive automation (existing flywheel), one-FTE hiring trigger at $20K/mo MRR |

---

**Approval status:** DRAFT — awaiting Ariel review
**Next document:** PRS V1 (technical specification)
