# Phase 1b — 10-Day Brevard Title Intelligence Pilot

**Status:** Ready to dispatch post-Shabbat (Saturday night havdalah).
**Purpose:** Close the 5 zero-row tables that back our title search claim.
**Source:** Extracted from `breverdbidder.github.io/everest-battle-cards/dono-ai` (April 10 2026).

---

## Zero-row tables to fill

Per Supabase audit:
- `property_documents` — 0 rows
- `lien_results` — 0 rows
- `title_defects` — 0 rows
- `document_extractions` — 0 rows
- `documents` — 0 rows

Existing assets we build on:
- `title_rules` — 24 FL-statute-mapped rules across 8 categories ✅
- `fl_parcels` — 10,378,594 rows ✅
- `multi_county_auctions` — 256,714 rows ✅
- `biddeed_po_upstream_v1` — 43/43 VERIFIED (today's work) ✅

---

## Scraper 1 — FL County ROD (Brevard pilot)

- **Target:** Brevard Clerk of Court recording search (same site we already scrape for auctions)
- **Extract:** deeds, mortgages, satisfactions, releases, UCC filings
- **Volume:** ~8,000 recording events/week in Brevard
- **Tech:** Gemini Flash 2.5 OCR + entity extraction for document images
- **Target table:** `property_documents`
- **Pilot timeline:** 5 days
- **Marginal cost:** ~$0.02/document
- **Scale target:** 30 days → 67 counties

## Scraper 2 — Municipal Lien (5 Brevard cities)

- **Targets:** Palm Bay, Melbourne, Titusville, Cocoa, Rockledge code enforcement portals
- **Extract:** open code enforcement cases, daily fines, municipal liens, utility liens
- **Why this matters:** Dono does NOT pull FL municipal liens. Direct FL-specific advantage.
- **Target table:** `lien_results`
- **Pilot timeline:** 3 days
- **Marginal cost:** ~$0.01/property
- **Scale target:** 5 cities initial, all FL cities post-pilot

## Scraper 3 — FL Tax Collector (Brevard)

- **Target:** Brevard Tax Collector public portal (free, public, no rate limit observed)
- **Extract:** current year due, delinquent years, tax certificate status, tax deed risk signal
- **Why this matters:** Feeds BidDeed tax deed intelligence. Dono doesn't touch tax deeds at all.
- **Target table:** `tax_years`
- **Pilot timeline:** 2 days
- **Marginal cost:** $0 (public source)

---

## Quality parity plan (3 approaches, run in order)

**Approach 3 — Rule engine audit (1 day, run first)**
Map each of our 24 `title_rules` to corresponding ALTA Standard Exception codes (ACCX01, DTSX10, CONX02, etc.). Gap analysis identifies uncovered codes. Add rules until coverage ≥ 85-90% of ALTA codes relevant to distressed/investor use cases. Skip fresh-closing-only codes explicitly.

**Approach 2 — Historical validation (3 days, post-pilot)**
Use 200 resolved auctions from 2023-2025 where outcomes are known. Run our pipeline against pre-auction state. Score whether we flag the actual title issues that emerged. Target: precision ≥ 85%, recall ≥ 80%.

**Approach 1 — Blind panel (2 weeks, only if needed)**
50 Brevard foreclosure properties. Compare our pipeline vs paid traditional title abstractor ($75-150/search) vs Dono published claim. Score on 7 investor-relevant elements. Target: ≥ 90% vs abstractor baseline.

---

## Dispatch sequence

Sunday 00:00 UTC onwards:
1. Verify runner fix landed (SUMMIT #7cd357a8)
2. Dispatch Scraper 1 (Brevard ROD) — 5 days
3. Dispatch Scraper 2 (Municipal Liens) parallel — 3 days
4. Dispatch Scraper 3 (Tax Collector) parallel — 2 days
5. Approach 3 audit runs concurrently — 1 day
6. Day 10: all 5 zero-row tables populated for Brevard. Parity audit complete.

---

## Success criteria

- `property_documents` > 5,000 rows (Brevard only, week 1)
- `lien_results` > 1,000 rows (5 cities, week 1)
- `tax_years` > 200,000 rows (Brevard parcels with current tax data)
- `title_defects` populated via rule engine running against property_documents
- ALTA coverage ≥ 85% on investor-relevant codes

---

*10-day plan source: Dono.ai battle card v3-replacement, April 10 2026.*
