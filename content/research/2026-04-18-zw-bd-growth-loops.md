---
slug: 2026-04-18-zw-bd-growth-loops
title: "ZoneWise + BidDeed Growth-Loops GTM Brief"
date: 2026-04-18
author: Ariel Shapira / AI Architect
block: "ZW GTM 10-day (Apr 17–26)"
pairing: "BidDeed + ZoneWise (mandatory)"
skills_used:
  - pm-go-to-market/growth-loops
  - pm-marketing-growth/marketing-ideas
brand:
  navy: "#1E3A5F"
  orange: "#F59E0B"
  font: Inter
repoeval_source: "phuryn/pm-skills (82/100, ADOPT)"
---

# ZoneWise + BidDeed — Growth-Loops GTM Brief

Two-site MVP context: `zonewise.ai` is the free choropleth lead magnet (tip-of-spear SEO/funnel); `chat.zonewise.ai` is the paid Dify+RAG product on Hetzner. Pairing rule applies — every loop below ships across BidDeed.AI (foreclosure + tax deed auctions) and ZoneWise.AI (zoning intelligence, 67 FL counties) simultaneously. Both apps share the `zw_parcels` SSOT (77 cols, 23 indexes, 3 RPCs).

## 1. Core value per product

### ZoneWise (`chat.zonewise.ai`)
Primary user action: ask a zoning question about a specific FL parcel → receive instant AI answer with parcel map, zoning citations, and municipal code references.
Value created: collapses 30–60 minutes of MapWise / county-portal hunting into ~12 seconds. MapWise is a 26-year incumbent running on identical public-source data — the moat is UX, not data.
Network effects: weak at signup; grow through shared parcel cards (see loop §3.1).
Friction: paywall gate, first-time users unclear what queries the system answers well.

### BidDeed (`biddeed.ai`)
Primary user action: evaluate a foreclosure or tax-deed auction property → receive buy-box score, lien stack, title forensics, ARV/yield model, and zoning overlay (via ZoneWise cross-call).
Value created: replaces a 4–8 hour per-property investor workup with a 45-second one.
Network effects: JV/LLC partners forward analyses to one another.
Friction: trust — investors must believe the numeric outputs before they bid.

## 2. Five-loop evaluation (scored 1–10 for fit)

| Loop | ZoneWise | BidDeed | Notes |
|------|---------:|--------:|-------|
| Viral (shareable cards)      | **8** | **8** | Both produce assets users already need to forward. Highest leverage. |
| Usage (saved watchlists)     | 6 | 7 | Works; lower compounding than viral. |
| Collaboration (firm/JV invite) | **7** | **8** | B2B strength — Mariam's FL Broker license at Property360 is the wedge. |
| User-generated content       | 4 | 5 | Niche audiences; limited outside curated "horror stories" content. |
| Referral (bonus codes)       | 6 | 6 | Commodity — Reventure already runs this. Do it, don't lead with it. |

Primary loop: **Viral shareable cards.** Secondary: **Collaboration (firm/JV workspaces).** Referral runs as a background driver, not the headliner.

## 3. Loop mechanics

### 3.1 Primary — Parcel / Property Intelligence Cards

Every completed `chat.zonewise.ai` query and every BidDeed auction analysis auto-generates a public card URL (pattern: `zonewise.ai/parcel/{parcel_id}` and `biddeed.ai/property/{auction_id}`). Each card carries:

- AI answer (or buy-box summary for BidDeed)
- Parcel map (MapBox tile, Navy `#1E3A5F` base, Orange `#F59E0B` highlights, Inter)
- Top 3 zoning citations / lien-stack entries
- Watermark: "Analyzed by {user_handle} via ZoneWise.AI" (or BidDeed.AI)
- CTA: "Ask your own question" → unauth user hits paywall at query 2

Share mechanism: single-tap copy-link, prefilled iMessage/email/SMS, LinkedIn quote post. Every outbound URL carries a referral code tied to the sharer — referral loop runs inside the viral loop at zero additional UX cost.

Cross-app trigger: a ZoneWise card where the underlying parcel has an upcoming tax-deed sale surfaces an inline BidDeed upgrade offer. A BidDeed property analysis with a zoning question shows an inline ZoneWise upgrade. Single parcel row, two funnels.

### 3.2 Secondary — Firm / JV Collaboration workspaces

"Invite colleague" button on every card. Firm-level workspace with shared parcel library, saved queries, and an activity feed. Anchor the trust story in licensed credentials: Mariam Shapira (FL Broker, Property360; GC, Kenstrekt; insurance, Protection Partners). Target buyers: brokerages, title firms, real-estate attorneys, fix-and-flip LLCs.

## 4. Loop coefficient (ZoneWise, conservative)

- Cards shared per active user per week: **1.2** (realtor-behavior benchmark)
- Card open rate: **65%**
- Signup rate from card open: **3%** low-intent, **12%** high-intent (active transaction)
- Blended K-factor per week: **~0.047**
- Not self-sustaining in isolation — pairs with the free choropleth funnel (`zonewise.ai` → email capture → card trial → paid) to reach compounding behavior. Reventure's flywheel sits upstream, viral cards sit downstream, referral rides inside.

BidDeed coefficient runs lower in volume but higher in $/signup (investor LTV > agent LTV).

## 5. 30-60-90 implementation roadmap

**Phase 1 — days 1–10 (Apr 17–26, the current GTM block)**
- Schema + endpoint: `public.parcel_cards(id, parcel_id, user_id, ai_answer_jsonb, created_at, shared_count, view_count, signup_attributed)` on Supabase `mocerqjnksmhcjzxrewo`.
- Hetzner Dify writes card payload on every completed chat turn.
- Share-URL generator on both apps, single Vercel project `prj_EaXgEO6WDoSpCeLhuCemtbPr6e8E` serves both `zonewise.ai` and `www.zonewise.ai` per INFRASTRUCTURE.md SSOT.

**Phase 2 — Apr 27 → May 10**
- Public card renderer (server-rendered, SEO-indexable — these URLs are the SEO flywheel).
- Paywall gate at 2nd query.
- Referral code embedded in every shared URL; reward: 1 free month paid.

**Phase 3 — May 11 → May 31**
- Firm / JV workspaces.
- Brokerage partnership pilot (Brevard-area first, via Mariam's Property360 license).
- Cross-app upsell banners (ZoneWise ↔ BidDeed).

## 6. Five marketing ideas (per `marketing-ideas` skill)

**1. FL Zoning & Auction Horror Stories — weekly series**
- Channel: YouTube Shorts + LinkedIn
- Message: one real parcel per week where zoning misunderstanding or lien discovery cost six figures (setback violations, non-conforming use, wetland overlap, junior-lien surprise at tax-deed).
- Why it works: the ICP (real-estate agents, investors, attorneys, GCs) forwards cautionary tales to their clients — viral distribution directly inside the buying audience.
- Cost: $0 — narrate from public case data; ZoneWise / BidDeed parses the parcel live on camera.

**2. "ZoneWise vs MapWise in 30 seconds" side-by-side demos**
- Channel: LinkedIn + Twitter/X
- Message: same zoning question — MapWise 6 clicks + 4 min vs ZoneWise 1 query + 12 sec.
- Why it works: MapWise's 26-year incumbency is also complacency. A visible speed delta is the shortest path to "obviously better."
- Cost: $0 — one query per post.

**3. Free Parcel Card API for Realtor associations**
- Channel: partnerships
- Message: 500 free branded parcel cards / month for member-facing portals (pilot: Brevard Realtors, then Space Coast, then statewide).
- Why it works: MLS/association embed puts the tool in front of thousands of agents without ads. Mariam's FL Broker license opens the door.
- Cost: compute only.

**4. "Zoning Questions to Ask Before You Buy" 47-item lead magnet**
- Channel: SEO + email drip
- Message: downloadable PDF with 47 pre-built questions and a ZoneWise-populated example parcel (e.g., sample Brevard waterfront lot).
- Why it works: stacks on top of the existing free choropleth funnel in Sprint 1 — same user flows magnet → drip → `chat.zonewise.ai` trial.
- Cost: $0 — reuses SEO content already in the pipeline.

**5. 625 Ocean Street coastal-development war-room thread**
- Channel: LinkedIn long-form
- Message: live-document the FDEP CCCL permit process (hard deadline June 25); use ZoneWise and BidDeed to answer parcel / property questions publicly in the thread.
- Why it works: authenticity outperforms polish. The audience (RE agents, contractors, attorneys, coastal engineers) sees real stakes and real tooling on a real deadline.
- Cost: $0 — this is work Ariel is already doing.
- Guardrail: share only what does not compromise permit strategy or coastal engineer / civil PE work product.

## 7. Measurement

North-star for the Apr 17–26 block: **cards generated / week** (leading indicator for the entire funnel). Supporting KPIs: card-to-signup conversion, shared-URL CTR, paywall-to-paid conversion, referral-attributed signups. All land in `zw_parcels` + `parcel_cards` in Supabase; dashboard via Grafana on Hetzner.

## 8. Cross-reference

- Infrastructure SSOT: `INFRASTRUCTURE.md` in 5 canonical repos. One Vercel project (`prj_EaXgEO6WDoSpCeLhuCemtbPr6e8E`). Deprecated: `prj_B478bSAAf0yLnY3owbhN7a1W7mQs`.
- Parcel SSOT: `zw_parcels` (77 cols, 23 idx, 3 RPCs).
- Brand: Navy `#1E3A5F`, Orange `#F59E0B`, Inter, bg `#020617`.
- Patents: Shapira V3.1 claims #1 (RL Engine), #8 (Cross-Auction FC+TD), #9 (Behavioral Match / BuyBox), #11 (Compounding EDP) all touch the flywheel mechanics above — filed under Ariel Shapira individual.

---

*Generated against `pm-go-to-market/skills/growth-loops` and `pm-marketing-growth/skills/marketing-ideas` from `phuryn/pm-skills` (RepoEval 82/100, ADOPT). Memory cites: [mem:ZW_GTM], [mem:PAIRING_RULE], [mem:INFRA_SSOT], [mem:SHAPIRA_V3_1].*
