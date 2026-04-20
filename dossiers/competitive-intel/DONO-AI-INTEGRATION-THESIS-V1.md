# Dono.ai Integration Thesis — BidDeed 5-Layer Architecture v1

**Status:** Strategic integration memo. Informs Phase 1b + L3 title intelligence layer.
**Source dossier:** `breverdbidder.github.io/everest-battle-cards/dono-ai` (April 10 2026, EG14 14/14 PASS, Honesty Protocol enforced).
**Supabase:** `ci_dossiers` competitor_slug='dono-ai'. 51 features, 421 evidence rows, $10.2M total funding, ZERO patents.

---

## Key finding (corrects earlier assumption)

**Dono is NOT a chatbot/NLP competitor.** Pre-recon "chatbot + NLP" framing was corrected April 10. Dono is an **enterprise B2B AI title production platform** selling to title agencies and closing attorneys via SoftPro/Qualia/CATIC. "Ask Dono" NLP is scoped to title examiner queries, not investor bid decisions.

**Our conversational NLP/UI moat stands intact.** No L1-L4 aggregator — including Dono — ships a conversational investor UI for foreclosure/tax-deed bidding. This is real moat.

---

## Dono 4-layer moat (separated)

1. **Data (LOW)** — VCAP, Odyssey, NCliens, ROD. All public. Anyone matches.
2. **Distribution (MEDIUM)** — SoftPro Sync + Qualia Marketplace. Title agency lock-in.
3. **Regulatory (HIGH)** — CATIC hold-harmless (NC attorneys only). Indemnifies E&O. THE moat.
4. **Human Verification (HIGH COST)** — 10-15 FTE title examiners. Speed ceiling at 4-hour SLA.

Dono moat concentrated in Layers 3+4. Neither applies to our ICP (distressed property investors, not closing attorneys). **Their moat doesn't block us.**

---

## 5-layer BidDeed architecture (Dono pattern adapted)

```
L1 — Primary Source Adapters
    - 67 FL Clerks (Odyssey / Benchmark / Custom templates per Spec B)
    - 67 PAO scrapers (photos, parcels, owners)
    - 67 Tax Collectors (cert status, delinquency)
    - Municipal Lien portals (Brevard pilot: 5 cities)

L2 — Vendor Aggregator Adapters
    - RealAuction (41 FL counties, 1 adapter per Spec A)
    - GovEase, Bid4Assets, SRI where needed
    - Charlotte taxdeeds custom portal
    - Collier in-person calendar

L3 — Title Intelligence Layer  ← NEW, Dono-pattern
    - Gemini Flash OCR + entity extraction (32+ data points/document, matching Dono)
    - Canonical tables: property_documents, document_extractions, lien_results, title_defects
    - 24 FL-statute title_rules (exists) + gap-fill to ≥85% ALTA Standard Exception coverage
    - Shapira Formula scoring overlay (patent claim)

L4 — NLP / Conversational UI  ← OUR MOAT (none of L1-L4 has this)
    - Natural-language Q&A: "Does 625 Ocean St have clear title? What's max bid?"
    - Full audit-trail citations back to source documents
    - Dono's "Ask Dono" is title-only for underwriters; ours is investor-facing

L5 — BidDeed Native Intelligence  ← DEFENSIBILITY
    - Shapira Formula patent (filing April 26 — Dono has ZERO patents)
    - XGBoost ML scoring (Patent Claim 8)
    - Cross-auction intelligence (Patent Claim 7)
    - Tax deed coverage (Dono doesn't touch)
    - FL municipal liens (Dono doesn't pull)
```

---

## Quality parity without CATIC

Dono produces ALTA Title Commitment (100% accuracy, insurance-grade, 4hr SLA, $75-150/search).
We produce Investor Title Risk Report (90-95% accuracy, bid-decision-grade, <10s latency, $99/mo unlimited).

**Different artifact, different buyer, different quality bar. Both valid.**

Claim language (per battle card): "Investor-grade title risk report. Not title insurance. Not legal advice. Built for bid-decision support in under 10 seconds with 90-95% accuracy. CATIC-free, and that's the point: our customers aren't closing attorneys."

---

## Where Dono wins (we accept)

- 700+ county coverage (we: 67 FL) — geographic breadth
- $10.2M funding + 14 FTE + Israel R&D — resource breadth
- HousingWire TECH100 2026 recognition
- SoftPro Sync + Qualia Marketplace distribution

## Where we win

- ZERO patents vs our V3.1 filing April 26 (12 claims)
- Tax deed coverage (Dono doesn't)
- FL municipal liens (Dono doesn't)
- Conversational investor NLP UI (nobody does)
- Real-time auction monitoring (<10s vs their 4hr)
- Vercel + Next.js 2026 stack vs their Webflow + jQuery 3.5.1 12.4s page load

---

## What we do with this thesis

- Phase 1b 10-day pilot IS the Dono pattern adapted (see action-plans/PHASE-1B-10-DAY-TITLE-PIPELINE-V1.md)
- Phase 2 Clerk Direct adapter IS the L1 independence (see specs/fl-clerk-direct/SPEC-B-V1.md)
- Our conversational UI layer stays uncontested because Dono's "Ask Dono" serves a different buyer

---

*Integration thesis synthesizes: Supabase ci_dossiers dono-ai + everest-battle-cards dono-ai + PO-UPSTREAM-AGGREGATORS-V1 (today).*
