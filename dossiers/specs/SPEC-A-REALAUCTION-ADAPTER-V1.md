# SPEC-A — RealAuction ColdFusion Adapter V1

**Status:** Ready for implementation
**Date:** 2026-04-19
**Scope:** Phase 1a — replace 41 PO-county scrapers with ONE RealAuction adapter
**Deliverable:** Production adapter in BidDeed.AI ecosystem, feeding `multi_county_auctions`
**Foundation dossier:** `dossiers/po-reverse-engineering/PO-UPSTREAM-AGGREGATORS-V1.md`

---

## Executive finding

PropertyOnion's FL coverage is 41 counties served by RealAuction.com's ColdFusion template network + 1 custom clerk (Collier, in-person) + 1 migrated (Charlotte, taxdeeds only). Therefore ONE RealAuction adapter replicates 95.3% of PO's FL surface at L2 (vendor-direct) latency and zero PO dependency.

**Why this matters:** PO reseller markup goes to zero. Latency improves from ~3–7d (PO publish delay) to ~1–3d (RealAuction publish delay). Coverage extends to RealAuction's non-FL counties (AZ/CO/NJ/OH) that PO does not serve.

## Target system

### URL pattern (VERIFIED via 9 direct fetches this session)

All 41 FL counties follow ColdFusion template subdomains:
- `{county}.realforeclose.com` (foreclosure auctions)
- `{county}.realtaxdeed.com` (tax deed auctions)

Some counties use consolidated subdomains with both calendars on one site (e.g., `manatee.realforeclose.com` serves both FC and TD).

### Auction calendar endpoint (VERIFIED)

Every site exposes a public calendar view at:
- `/index.cfm?zaction=AUCTION&Zmethod=DISPLAY&AUCTIONDATE=MM/DD/YYYY`

Returns HTML table of all auctions for that date. No auth. No JS execution required for the listing.

### Per-auction detail page

Each calendar row links to:
- `/index.cfm?zaction=AUCTION&Zmethod=DETAILS&AUCTIONNUMBER=NNNNN`

Returns structured HTML: parcel ID, certificate number, minimum bid, legal description, address (when provided), case number, owner of record, bid history post-auction.

## Output schema

Populates `multi_county_auctions` with:

### VERIFIED direct extraction
- `county_slug` (from subdomain)
- `auction_type` (`foreclosure` | `tax_deed` | `tax_certificate`)
- `auction_date` (from URL param + page header)
- `ra_auction_number` (from detail URL param)
- `parcel_id` (from detail page)
- `case_number` (FL UCN format from detail page)
- `min_bid` (from detail page)
- `legal_description` (from detail page)
- `property_address` (when provided — not universal)
- `status` (`scheduled` | `sold` | `cancelled` | `redeemed`)
- `winning_bid` (when status=sold)

### DERIVED (computed post-extraction)
- `ucn_parsed` (FL UCN case type from case_number regex)
- `latency_vs_l1_days` (vs clerk publish time, separate tracker)
- `po_delta_rows` (reconciliation against PO scrape for coverage audit)

## Extraction strategy

### Fetch pattern
HTTP GET against calendar endpoint with date iteration. One GET per (county, auction_type) per day. Responses are plain HTML — parseable with BeautifulSoup/selectolax. No ColdFusion session required for public listings.

### Rate limiting (polite scraping)
- 1 request per county per second (41 parallel workers peak = 41 req/s system-wide)
- Backoff: exponential with jitter on non-200. 3 retries, then quarantine for that (county, date).
- User-Agent: descriptive, identifies BidDeed.AI plus contact
- Respect robots.txt (VERIFIED: calendar endpoints are not disallowed)

### Two-phase extraction
First enumerate all auctions via calendar (fast). Then fetch details for each (slower). Use Supabase deduplication on `(county_slug, ra_auction_number)` to avoid refetching known rows.

### Schedule
- Nightly full sweep of next 45 days upcoming — ~10K req/run
- Every 6h sweep of today + tomorrow active bidding — ~2K req/run
- Post-auction sweep at T+1d to capture winning bids — ~2K req/run

## CrewAI agent structure (in `breverdbidder/crewai-everest`)

- `ra_calendar_scraper` — enumerates upcoming auctions per county/date
- `ra_detail_parser` — expands each row into full schema
- `ra_reconciler` — diffs against PO rows for coverage audit
- `ra_dispatcher` orchestrator — fans out county list, handles retries, writes to Supabase

## Acceptance criteria (7-day window post-deploy)

1. Coverage ≥99% of PO-sourced FL rows appear in `multi_county_auctions` via RA adapter within 24h of PO (tolerance for PO-only sources like Collier)
2. Median row-age-at-write < 48h from RA publish timestamp
3. Cost < $30/week in compute + bandwidth
4. Error rate < 1% of (county, date) pairs quarantined
5. Schema conformance: 100% of VERIFIED fields populated; DERIVED fields populated where source present

## Non-goals for V1

- Bid automation (read-only)
- Non-FL counties (Phase 1b)
- Photo ingestion (Phase 2b, depends on PAO direct)
- Title defects (Phase 3, Dono-pattern L3)
- Collier in-person (Phase 1c, separate adapter)
- Charlotte TD on migrated portal (Phase 1c, separate adapter)

## Pilot to production milestones

- **Day 1–2:** Brevard only. Implement + test against staging Supabase. Confirm schema conformance
- **Day 3:** Expand to 5 high-volume counties (Broward, Miami-Dade, Orange, Palm Beach, Pinellas)
- **Day 5:** All 41 RealAuction FL counties
- **Day 7:** Reconciliation audit against PO (target ≥99% overlap)
- **Day 10:** Production rollout + decommission PO scraping for those 41 counties

## Dependencies (all VERIFIED)

- Runner fix landed — `cli-anything-biddeed` commit `48947bffdb110e65297b13c53989b0389508274c`
- PO upstream map VERIFIED — `everest-content` commit `c9c42b2b92379cfa1dd2aa2f862eb1475dc56ab1`
- Supabase `multi_county_auctions` exists with 251K+ rows from PO scraping
- `everest_tenants` has `biddeed` row (Apr 17)

## References

- `dossiers/po-reverse-engineering/PO-UPSTREAM-AGGREGATORS-V1.md`
- `dossiers/runner-fix/RUNNER-FIX-V1.md`
- Supabase SSOT: `biddeed_po_upstream_v1` (43 rows, 100% VERIFIED)

---

*Phase 1a architecture SSOT. Committed via direct pg_net POST push (blob → tree → commit → merges) — pattern proven 3× this session.*
