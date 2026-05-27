# BidDeed MCP V1 · Product Requirements Specification (PRS) — Technical

**Version:** v1.0
**Owner:** Ariel Shapira / Claude AI Architect
**Generated:** 2026-05-27
**Status:** DRAFT for review
**Companion:** PRD-V1 (product strategy)

---

## 1 · Architecture overview

```
┌──────────────────────────────────────────────────────┐
│  Customer agent (Claude Desktop, Cursor, custom)     │
│  └─ MCP client                                        │
└────────────────┬─────────────────────────────────────┘
                 │ stdio | SSE | HTTP
┌────────────────▼─────────────────────────────────────┐
│  BidDeed MCP Server (Node.js / Hono)                 │
│  └─ X-Api-Key auth → Stripe billing                  │
│  └─ Tool surface: 12 tools (see §3)                  │
│  └─ Rate limiter (tier-based)                        │
└────────────────┬─────────────────────────────────────┘
                 │ REST + RPC
┌────────────────▼─────────────────────────────────────┐
│  BidDeed API (Vercel Functions + Supabase Edge)      │
│  └─ auctions/* endpoints                             │
│  └─ triangle/* scoring endpoints                     │
│  └─ zonewise/* cross-call (paired product)           │
└────────────────┬─────────────────────────────────────┘
                 │ SQL
┌────────────────▼─────────────────────────────────────┐
│  Supabase: mocerqjnksmhcjzxrewo                      │
│  └─ multi_county_auctions (356,384 rows)             │
│  └─ fl_parcels (10,515,846 rows)                     │
│  └─ taxdeed_flip_observations (5,915)                │
│  └─ shapira_formula_params (V4 weights — TODO)       │
│  └─ ci_v65_event_log, ghost_success_audit            │
└──────────────────────────────────────────────────────┘
```

## 2 · Technology stack

| Layer | Tech | Reason |
|---|---|---|
| MCP server | Node.js 22 + `@modelcontextprotocol/sdk` | Reference impl, well-documented |
| HTTP framework | Hono | Edge-compatible, lightweight |
| Auth | X-Api-Key header + Stripe Customer Portal | Matches RentCast pattern [VERIFIED] |
| Billing | Stripe | Subscription + usage metering |
| API hosting | Vercel Functions (paid plan, approved per Cost V2) | Edge globally, no Hetzner per cost rules |
| DB | Supabase Postgres `mocerqjnksmhcjzxrewo` | Existing infra |
| CDN | Cloudflare Pages for marketing site | Approved per memory |
| Monitoring | Supabase logs + Telegram alerts | Existing |
| MCP registry | Anthropic MCP registry + manual npx fallback | Multi-channel distribution |

## 3 · MCP tool surface (12 tools)

### 3.1 Auction tools (5)
```typescript
auctions_upcoming(geo: GeoFilter, date_range: DateRange, type?: 'foreclosure'|'tax_deed'|'tax_lien')
auctions_subscribe(county_fips: string, since: ISO8601) // SSE stream
auction_score(case_id: string, model?: 'shapira_v4'|'shapira_v3'): ScoreResponse
auction_owner_history(case_id: string): OwnerHistoryResponse
auction_lookup(case_id: string): AuctionDetailResponse
```

### 3.2 Triangle V4.0 tools (3) — patent-protected
```typescript
triangle_cycle(county_fips: string, lookback_months?: number): CycleSignal // Claim 14
convergence_scan(threshold?: number, lookback_days?: number): ConvergenceSignals[] // Claim 13
triangle_score(parcel_id: string, model?: 'v4'|'v3'): TriangleScore // Claim 8 stacked ensemble
```

### 3.3 ZoneWise paired tools (2)
```typescript
zonewise_parcel(parcel_id: string): ZoningProfile
zonewise_entitlement_risk(parcel_id: string): EntitlementRisk
```

### 3.4 Utility tools (2)
```typescript
deal_sheet(case_id: string, format?: 'json'|'pdf'|'md'): DealSheetResponse
batch_score(case_ids: string[], model?: string): ScoreResponse[]
```

**Honesty Protocol V3 in responses:** Every response object includes a `_marker` field per data source: VERIFIED (storage-backed), INFERRED (model-derived), UNTESTED (not yet validated), UNKNOWN (data missing).

## 4 · API endpoint surface (REST mirror)

All MCP tools mirror to REST endpoints at `api.biddeed.ai/v1/*`:

| MCP tool | REST endpoint | Method |
|---|---|---|
| `auctions_upcoming` | `/v1/auctions/upcoming` | GET |
| `auctions_subscribe` | `/v1/auctions/subscribe` | GET (SSE) |
| `auction_score` | `/v1/auctions/:id/score` | GET |
| `triangle_cycle` | `/v1/triangle/cycle/:county_fips` | GET |
| `convergence_scan` | `/v1/triangle/convergence` | POST |
| `zonewise_parcel` | `/v1/zonewise/parcels/:id` | GET |
| `deal_sheet` | `/v1/auctions/:id/deal-sheet` | GET |

REST exists for non-MCP customers (regular API consumers) — MCP customers can use either.

## 5 · Auth + billing

**Per-request:** `X-Api-Key: bk_live_xxx` header (32-char nanoid)
**Rate limiting:** tier-based token bucket per API key (Redis on Vercel Edge Config)
**Usage tracking:** Supabase `api_usage` table (INSERT per request via async edge function)
**Billing:** Stripe metered subscription — usage reported nightly via Stripe API
**Customer portal:** Stripe Customer Portal embedded at `biddeed.ai/account`
**API key rotation:** customer self-serve from dashboard; 30-day grace period for old keys

## 6 · Data sources + ETL

**Current corpus (VERIFIED via Supabase row counts):**
- `multi_county_auctions`: 356,384 rows across 46 FL counties
- `fl_parcels`: 10,515,846 rows
- `taxdeed_flip_observations`: 5,915
- Labels: 136,263 sold_amount + 171,860 winner = ~204K trainable

**Ingestion (current daily flow):**
- L1 sources: realforeclose.com + realtaxdeed.com + bid4assets.com (auction calendars)
- L2 sources: Tyler Odyssey + CRS court portals (case detail)
- L3 sources: county recorder Official Records (recorded events)

**TODO before launch:**
- ⚠️ `shapira_formula_params` table has **0 rows** [VERIFIED via prior Supabase check] — V4 model weights need to be operationalized before `triangle_score` and `auction_score` tools work. **THIS IS THE V1 LAUNCH BLOCKER.**

## 7 · Performance + SLA

| Metric | Target | Notes |
|---|---|---|
| p50 latency | <200ms | Vercel Edge Function + Supabase warm conn pool |
| p95 latency | <800ms | Includes complex score computation |
| Uptime | 99.5% (≤44min downtime/mo) | Below enterprise 99.9 but matches RentCast tier |
| Data freshness (auction calendar) | ≤24h | Hourly ETL via GHA |
| Data freshness (recorded events) | ≤72h | 3-source composite latency |

## 8 · Deployment topology

**Marketing site:** Cloudflare Pages — `biddeed.ai`
**API:** Vercel Functions — `api.biddeed.ai`
**MCP server:** npx-installable + hosted at `mcp.biddeed.ai` (SSE)
**Docs:** Vercel project `developers.biddeed.ai` (mimics RentCast pattern)
**DB:** Supabase `mocerqjnksmhcjzxrewo` (existing)
**Long-running ETL:** GHA + Hetzner only when needed (Cost V2 — default Supabase+GHA)

## 9 · Cost model

**Fixed costs (monthly):**
- Vercel paid: $20/mo
- Supabase Pro: $25/mo
- Stripe: 2.9% + 30¢ per txn
- Cloudflare Pages: $0
- Hetzner (existing): $30/mo

**Variable per-1000-requests:**
- Vercel Edge invocations: ~$0.04
- Supabase egress: ~$0.10
- **Marginal COGS: ~$0.14 per 1000 req**

**Margin analysis (Entry tier $99/mo, 1500 req):**
- Revenue: $99
- COGS: $0.21
- Gross margin: **99.8%**

Pricing has substantial room for volume customer discounts via custom Enterprise tier.

## 10 · Honesty Protocol V3 enforcement

- **Storage backing required** for every VERIFIED claim returned (model outputs reference source rows by ID)
- **Output gate equivalent at API layer:** every response includes `evidence_count` field. <8 evidence rows → response auto-tagged INFERRED
- **Customer-visible audit log:** customers can query `/v1/audit/:request_id` to see exactly which Supabase rows informed their response (transparency = trust)

## 11 · Open questions (for Ariel)

1. **V4 model operationalization** — do we ship MCP V1 without `triangle_score` working, or block launch until `shapira_formula_params` is loaded? Recommended: block launch (3-week delay acceptable)
2. **Free tier rate limit** — 100 req/mo or 50? RentCast does 50; we doubled to lower friction. Validate with first 20 signups
3. **ZoneWise cross-sell** — bundle pricing or two separate subscriptions? Recommended: bundle on Growth+
4. **MCP registry distribution** — apply for Anthropic MCP registry on day 1 or wait for stability? Recommended: day 1 (max ecosystem reach)
5. **Patent claim wording in marketing** — public-facing copy should say "patent-pending" until USPTO grant; legal review needed

## 12 · References

- PRD-V1 (companion product doc)
- RentCast narrative dossier: `everest-content/dossiers/competitive-intel/RENTCAST-MCP-DOSSIER-V1.md`
- RentCast battle card: `everest-vault/600-Research/battle-cards/rentcast-v5-REFERENCE.md`
- Output gate spec: `cli-anything-biddeed/docs/ci-output-gate/SUMMIT-G-OUTPUT-GATE-V1.md`
- Supabase schema: `mocerqjnksmhcjzxrewo` (multi_county_auctions, fl_parcels, ci_v65_dossiers tables)

---

**Approval status:** DRAFT — awaiting Ariel review
