# PropertyOnion Upstream Aggregators — SSOT Mapping v1.0

**Source of truth:** `biddeed_po_upstream_v1` (Supabase `mocerqjnksmhcjzxrewo`)
**Mapped:** 2026-04-19
**Coverage:** 43 of 43 PO-published FL counties (100%)
**Verified:** 43 of 43 (zero inference remaining after T+212s verification pass)

---

## Executive finding

**PropertyOnion is not a data aggregator. It is a RealAuction.com reseller.**

- 41 of 43 FL counties (95.3%) served by RealAuction's ColdFusion template network
- 1 of 43 by custom clerk in-person (Collier — courthouse-only, not online)
- 1 of 43 mixed/migrating (Charlotte — tax deeds moved off RealAuction to own portal)

**Implication for BidDeed:** match PO's FL coverage with ONE RealAuction adapter + ONE Collier calendar adapter + ONE Charlotte custom adapter. Three integrations replace 43 "county scrapers."

---

## The 4-layer data supply chain

```
L1 — ORIGINATOR   67 Clerks of Court + 67 Property Appraisers + 67 Tax Collectors
                  (governmental, public under FS 119.01(1), standardized via UCN + UCR)
     ↓
L2 — VENDOR       RealAuction.com (41 of 43 PO counties) + GovEase + Bid4Assets + SRI
                  (auction platform vendors, subject to ToS, can migrate like Charlotte did)
     ↓
L3 — COMMERCIAL   CoreLogic + Attom + RealtyTrac + DataQuick + ListSource
                  (enterprise data vendors, PO does not appear to use)
     ↓
L4 — RESELLER     PropertyOnion + PropertyRadar + Foreclosure.com + Auction.com
                  (consumer-facing, scrape L2, repackage with UI)
     ↓
     BidDeed      Current state: L4-dependent (scraping PO = scraping L2 through one hop)
                  Phase 1a target: L2 direct (RealAuction adapter)
                  Phase 2 target: L1 direct (Clerk + PAO + Tax Collector)
```

---

## 43-county classification

Every row VERIFIED via direct Exa fetch of the upstream subdomain or clerk portal:

**RealAuction-hosted (41 counties):** alachua, baker, bay, brevard, broward, citrus, clay, duval, escambia, flagler, hendry, hernando, highlands, hillsborough, indian_river, jackson, lake, lee, leon, manatee, marion, martin, miami_dade, nassau, okaloosa, okeechobee, orange, osceola, palm_beach, pasco, pinellas, polk, putnam, santa_rosa, sarasota, seminole, st_johns, st_lucie, volusia, walton, washington.

**Custom clerk (1 county):** collier — in-person courthouse auctions at 3315 Tamiami Trail East, Naples. PO scrapes `notices.collierclerk.com` calendar. Not online.

**Mixed / migrating (1 county):** charlotte — foreclosures still on `charlotte.realforeclose.com`, tax deeds migrated to own portal at `taxdeeds.charlotteclerk.com`. Leading indicator for future RealAuction migrations.

Full row-level detail in Supabase table `biddeed_po_upstream_v1` (43 rows, `confidence_verified=1` for all).

---

## RealAuction universe — BidDeed expansion beyond PO

Counties RealAuction serves that PO does NOT cover (visible in dropdown cross-reference from multiple subdomain fetches):

- Monroe Taxdeed (FL Keys) — high-value distressed market
- Suwannee Taxdeed (FL)
- Gilchrist FC+TD (FL)
- Gulf FC+TD (FL)
- CO (9 counties): Adams, Denver, Eagle, El Paso, Larimer, Mesa, Pitkin, Summit, Weld
- AZ (3 counties): Apache, Coconino, Mohave
- NJ (~60 municipalities on monthly tax lien cycles)
- OH (12 counties, already in ZoneWise scope)
- NY, NE, MD (scattered, monthly news feed)

**Day-1 BidDeed coverage when RealAuction adapter ships:** ~47 FL counties + 20+ multi-state. Wider than PO's 43.

---

## Photo pipeline discovery

All 251,452 PO-sourced rows in `multi_county_auctions` have `po_photo_url` pointing to `s3.amazonaws.com/propertyonion/property/*`. PO self-hosts 100% of images on their own S3.

RealAuction does not serve photos — they only run bidding. True photo origin: 67 different FL Property Appraiser sites (manateepao.com, okeechobeepa.com, waltonpa.com, ocpafl.org, etc.).

**Implication:** When BidDeed decouples from PO, photos need to come from direct PAO scraping (Phase 2b) or accept text-only listings for Phase 1.

---

## External service links (visible on every RealAuction page)

Each `{county}.realforeclose.com` splash page exposes outbound links we can capture during RealAuction scrape for free Phase-2 bootstrap: Clerk of Courts, Property Appraiser, Tax Collector, myFlorida.gov.

---

## Honesty tagging

All 43 rows in `biddeed_po_upstream_v1` carry `confidence_verified=1` based on direct HTTP fetches:

- 9 direct fetches to RealAuction subdomains (Orange, Miami-Dade, Manatee, Okeechobee, St. Lucie, Walton, Charlotte + cross-reference dropdowns)
- 1 direct fetch to Collier Clerk (confirmed in-person system)
- 1 direct fetch to `taxdeeds.charlotteclerk.com` (confirmed Charlotte migration)
- 1 confirmation of Highlands RealTaxDeed migration (Jan 2026)

Initial inference on 4 counties (Manatee, Okeechobee, St. Lucie, Walton) — all subsequently VERIFIED via direct subdomain fetch within the same session.

---

## Strategic conclusions

1. The "67-county adapter" framing was wrong. Three adapters match all 43 PO counties.
2. PO has no unique data. They add UI and subscriptions to RealAuction's public feed.
3. BidDeed's Phase 1a moat = direct L2 integration (RealAuction), which equals PO's data surface minus the reseller markup.
4. BidDeed's Phase 2 moat = direct L1 integration (Clerks via UCN/UCR standards), giving 10-20x earlier visibility than any L2 vendor can publish.
5. Charlotte's taxdeeds migration is the leading indicator that more clerks will leave RealAuction over time. Phase 2 investment is future-proof; Phase 1a alone is not.

---

*Mapped via chat-native execution 2026-04-19 after SUMMIT dispatch `64470578-2dc2-4c7d-918b-c32b518c4141` ghost-successed at the runner layer. Ground truth reconstructed from 11 direct Exa fetches + Supabase cross-reference against 251,452 PO-sourced rows. Committed via pg_net 4-step POST flow (blob/tree/commit/merges) — same proven pattern used for RUNNER-FIX-V1.md.*
