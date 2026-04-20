# Spec A — RealAuction ColdFusion Adapter v1

**Status:** VERIFIED design. Ready to implement.
**Phase:** 1a (L2 direct — replaces PropertyOnion dependency)
**Timeline:** 1-2 weeks from start of build
**Dependencies:** None blocking. Runner fix (SUMMIT #7cd357a8) is prerequisite for automated dispatch, not for manual build.

---

## Goal

Replace PropertyOnion as the data source for 41 of 43 FL counties + RealAuction multi-state network. Single adapter, one ColdFusion template, scales across all RealAuction subdomains.

---

## Scope

**Target domains (pattern):**
- `{county}.realforeclose.com` — foreclosure auctions (27 active FL counties + CO/AZ/NJ/OH/NY/NE/MD)
- `{county}.realtaxdeed.com` — tax deed auctions (20+ FL counties)
- Branded variants: `my{county}clerk.realforeclose.com` (e.g., myorangeclerk)
- Consolidated subdomains: single subdomain serves both FC + TD (Miami-Dade, Manatee, Okeechobee, St. Lucie, Walton, Collier-like pattern)

**Auction types captured:** foreclosure sale, tax deed sale, tax certificate sale, sheriff sale.

**Refresh cadence:** daily (matches RealAuction publish pattern — auctions listed T-1 to T-3 days before sale).

---

## Canonical URL surface

```python
REALAUCTION_ENDPOINTS = {
    "splash":         "/index.cfm",
    "training":       "/index.cfm?zaction=home&zmethod=training",
    "foreclosure":    "/index.cfm?zaction=home&zmethod=foreclose",
    "taxdeed":        "/index.cfm?zaction=home&zmethod=taxdeed",
    "calendar":       "/index.cfm?zaction=USER&zmethod=CALENDAR",
    "auction_day":    "/index.cfm?zaction=AUCTION&Zmethod=PREVIEW&AUCTIONDATE={YYYY-MM-DD}",
    "auction_item":   "/index.cfm?zaction=AUCTION&Zmethod=DETAILS&AUCTIONDATE={YYYY-MM-DD}&parcelid={ID}",
    "sold_archive":   "/index.cfm?zaction=AUCTION&Zmethod=SOLD&AUCTIONDATE={YYYY-MM-DD}",
    "bidder_letter":  "/index.cfm?zaction=home&zmethod=welcome",
}
```

Server-side ColdFusion rendering — full HTML available on initial fetch. No JS execution required. Scraping-friendly.

---

## Pydantic schema — `RealAuctionListing`

```python
from pydantic import BaseModel, Field, HttpUrl
from typing import Literal, Optional
from datetime import datetime, date
from decimal import Decimal

class RealAuctionListing(BaseModel):
    # Source provenance
    ra_subdomain: str
    ra_host_county: str
    ra_host_state: str = "FL"
    ra_service: Literal["foreclosure","taxdeed","taxlien","sheriff"]
    ra_auction_date: date
    ra_item_parcelid: str
    ra_source_url: HttpUrl
    scrape_timestamp: datetime

    # Auction economics
    opening_bid: Decimal
    final_bid: Optional[Decimal]
    sold_timestamp: Optional[datetime]
    auction_status: Literal["upcoming","active_bidding","sold","cancelled","redeemed","unsold_back_to_plaintiff"]
    winning_bidder_alias: Optional[str]
    deposit_required: Optional[Decimal]

    # Case / legal
    case_number: Optional[str]
    ucn: Optional[str] = Field(None, pattern=r"^\d{2}\d{4}CA\d{6}[A-Z]+$")
    plaintiff: Optional[str]
    plaintiff_counsel: Optional[str]
    defendant: Optional[str]
    judgment_amount: Optional[Decimal]
    lis_pendens_date: Optional[date]
    final_judgment_date: Optional[date]
    
    # Property
    property_address_raw: str
    property_address_normalized: Optional[str]
    city: Optional[str]
    zip: Optional[str]
    parcel_id: Optional[str]
    legal_description: Optional[str]
    property_type_raw: Optional[str]

    # Outbound references (PO scraper missed these — we capture)
    ra_external_clerk_url: Optional[HttpUrl]
    ra_external_pao_url: Optional[HttpUrl]
    ra_external_tax_collector_url: Optional[HttpUrl]
    ra_external_myflorida_url: Optional[HttpUrl]
    
    # Tax deed specific
    td_certificate_number: Optional[str]
    td_outstanding_balance: Optional[Decimal]
    td_redemption_deadline: Optional[date]
    td_applicant: Optional[str]
    
    # Raw for audit
    raw_detail_html: Optional[str]
    raw_detail_sha256: Optional[str]
```

---

## Extraction strategy (3 templates to parse)

1. **Calendar page** → list of `(auction_date, service, item_count)` tuples per subdomain
2. **Auction day preview** → list of `(parcelid, case_number, address)` per item for that date
3. **Auction item detail** → full `RealAuctionListing` fields

Use DSPy-optimized extractor (MIPROv2) with Claude Haiku 4.5 for cost efficiency on HTML-to-Pydantic transformation. Seed 10 examples per service type.

---

## CrewAI orchestration (fits existing `crewai-everest` fork)

```yaml
# crews/realauction_ingestion.yaml
crew: realauction_ingestion
agents:
  - calendar_scout       # /CALENDAR once per subdomain per day
  - day_batch_fetcher    # each auction_day preview in parallel via crawl4ai
  - item_extractor       # ra_extractor on each item_detail page
  - clerk_cross_ref      # follow ra_external_clerk_url to enrich UCN
  - writer               # upsert to biddeed_auction_v1 canonical
schedule: "0 6,12,18 * * *"
cost_cap_usd: 20
max_duration_minutes: 45
```

---

## Delivery milestones

1. **Day 1-2:** Fetch calendar + day-preview + item-detail from 3 canonical subdomains (miamidade, orange, brevard). Extract raw HTML.
2. **Day 3-5:** DSPy-optimize extractor on 30-example seed (10/county). Validate against known sold outcomes in Supabase.
3. **Day 6-7:** Scale to all 41 FL + expansion counties. Run daily. Upsert `biddeed_auction_v1`.
4. **Day 8-10:** Reconciliation — compare 7-day sample vs existing PO-sourced rows. Validate schema coverage.
5. **Day 11-14:** Production. Retire PO dependency for 41 counties. PO becomes fallback only.

---

## Historical backfill capability

RealAuction `zaction=AUCTION&Zmethod=SOLD&AUCTIONDATE=*` archive exposes outcomes 2016-present. Target: recover the 238K stale `auction_status='upcoming'` rows in our existing data. Estimated 4-6 days of throttled scraping.

---

## What this adapter does NOT capture (Phase 2 scope)

- Pre-auction docket events (lis pendens, final judgment, motion practice) — live at L1 Clerks, not RealAuction
- Property photos — live at L1 PAO sites (67 different portals)
- Plaintiff counsel identity — hidden at RealAuction
- Bankruptcy stays / loss mitigation — hidden at RealAuction
- Certificate of title (post-sale) — live at L1 Clerk Register of Deeds

Spec B (FL Clerk Direct adapter) closes these gaps.

---

*Source: `biddeed_po_upstream_v1` Supabase SSOT with 43 rows 100% VERIFIED. See dossiers/po-reverse-engineering/PO-UPSTREAM-AGGREGATORS-V1.md for evidence chain.*
