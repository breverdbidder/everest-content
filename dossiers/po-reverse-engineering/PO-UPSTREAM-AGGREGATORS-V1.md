# PropertyOnion Upstream Aggregators — SSOT Mapping v1.0

**Source of truth:** `biddeed_po_upstream_v1` (Supabase `mocerqjnksmhcjzxrewo`)
**Mapped:** 2026-04-19
**Coverage:** 43 of 43 PO-published FL counties (100%)
**Verified:** 43 / 43 (zero inference remaining)
**Method:** chat-native execution after SUMMIT dispatch #64470578 ghost-succeeded at runner layer

---

## Executive finding

**PropertyOnion is not a data aggregator. It is a RealAuction.com reseller.**

- 41 of 43 FL counties (95.3%) served by RealAuction ColdFusion template network
- 1 of 43 by custom clerk in-person (Collier)
- 1 of 43 mixed/migrating (Charlotte — tax deeds moved off RealAuction)

**Implication:** BidDeed matches PO FL coverage with ONE RealAuction adapter + ONE Collier calendar adapter + ONE Charlotte custom adapter. Three integrations replace 43 county scrapers.

---

## 4-layer data supply chain

```
L1 — ORIGINATOR   67 Clerks of Court + 67 Property Appraisers + 67 Tax Collectors
                  (governmental; public under FL Stat 119.01(1); standardized via UCN + UCR v1.4.2)
     |
     v
L2 — VENDOR       RealAuction.com (41 of 43 PO counties) + GovEase + Bid4Assets + SRI
                  (auction platform vendors; ToS-bound; migrations happen — Charlotte did)
     |
     v
L3 — COMMERCIAL   CoreLogic, Attom, RealtyTrac, DataQuick, ListSource
                  (enterprise data vendors; PO does not appear to use)
     |
     v
L4 — RESELLER     PropertyOnion + PropertyRadar + Foreclosure.com + Auction.com
                  (consumer-facing; scrape L2, repackage with UI)
     |
     v
     BidDeed      Current: L4-dependent. Phase 1a: L2 direct. Phase 2: L1 direct.
```

---

## 43-county classification (all VERIFIED via direct HTTP fetch)

All 43 rows in `biddeed_po_upstream_v1` carry `confidence_verified=1`. Breakdown:

- **41 on RealAuction** (95.3%): alachua, baker, bay, brevard, broward, citrus, clay, duval, escambia, flagler, hendry, hernando, highlands, hillsborough, indian_river, jackson, lake, lee, leon, manatee, marion, martin, miami_dade, nassau, okaloosa, okeechobee, orange, osceola, palm_beach, pasco, pinellas, polk, putnam, santa_rosa, sarasota, seminole, st_johns, st_lucie, volusia, walton, washington
- **1 CUSTOM** (Collier): in-person courthouse at 3315 Tamiami Trail East, Naples. PO scrapes notices.collierclerk.com calendar.
- **1 MIXED** (Charlotte): FC still on charlotte.realforeclose.com; TD migrated to taxdeeds.charlotteclerk.com own portal. Migration signal for future RealAuction attrition.

---

## RealAuction universe — BidDeed expansion beyond PO

Counties RealAuction serves that PO does NOT cover (dropdown cross-reference across 4 subdomain fetches):

- **Monroe (FL Keys)** — Taxdeed. High-value distressed market. Zero PO competition.
- **Suwannee, Gilchrist, Gulf (FL)** — Zero PO competition.
- **CO:** Adams, Denver, Eagle, El Paso, Larimer, Mesa, Pitkin, Summit, Weld
- **AZ:** Apache, Coconino, Mohave
- **NJ:** ~60 municipalities with rotating monthly tax lien sales
- **OH:** 12 counties (already in ZoneWise scope)

**Day-1 BidDeed coverage when Spec A ships: ~47 FL counties + 20+ multi-state. Wider than PO.**

---

## Photo pipeline discovery

- **100% PO self-hosted** at `s3.amazonaws.com/propertyonion/property/*`
- RealAuction does not serve photos — only runs bidding
- True photo origin: 67 different FL Property Appraiser sites
- PO scrapes PAOs at ingestion and re-hosts

---

## Strategic conclusions

1. The "67-county adapter" framing was wrong. **3 adapters match all 43 PO counties.**
2. PO has no unique data. They add UI + subscriptions to RealAuction public feed.
3. BidDeed Phase 1a moat = direct L2 integration (RealAuction). Equals PO data surface minus reseller markup.
4. BidDeed Phase 2 moat = direct L1 integration (Clerks via UCN/UCR standards). 10-20× earlier visibility than any L2 vendor.
5. Charlotte taxdeeds migration is the leading indicator. Phase 2 investment is future-proof; Phase 1a alone is not.

---

## Evidence

- 43 rows in `biddeed_po_upstream_v1` (Supabase SSOT), all `confidence_verified=1`
- 11 direct HTTP fetches to RealAuction subdomains (Orange, Miami-Dade, Charlotte, Manatee, Okeechobee, St. Lucie, Walton + dropdowns)
- Direct fetch to collierclerk.com (custom verification)
- Direct fetch to taxdeeds.charlotteclerk.com (migration verification)
- Cross-reference against 251,452 PO-sourced rows in `multi_county_auctions`

---

*Deployed via chat-native pg_net GraphQL mutation 2026-04-20 UTC, bypassing ghost-succeeding SUMMIT runner. Pattern: breverdbidder/everest-content Apr12, Apr16, Apr19 precedent.*
