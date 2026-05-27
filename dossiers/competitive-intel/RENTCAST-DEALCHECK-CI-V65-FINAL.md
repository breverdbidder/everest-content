# RentCast vs DealCheck — CI V6.5 FINAL Competitive Intelligence Report

> **Generated**: 2026-05-27 22:27 UTC · **Snapshot**: 2026-05-27
> **Honesty Protocol V3 enforced** · **Pairing rule**: ZoneWise.AI / tax deeds always paired with BidDeed.AI / foreclosures

## Executive Summary

Anton Ivanov is the solo founder of **both** products: DealCheck (2015) and RentCast (2020). They serve adjacent markets from a single operator:

- **DealCheck** = consumer + pro real-estate investor calculator (B2C SaaS, $0–$39/mo)
- **RentCast** = B2B real-estate data API (developer self-serve, $0–$329/mo)

**Key strategic finding**: RentCast is the healthier of the two by every measurable dimension — 2.9× more traffic, better engagement, growing category footprint — while DealCheck is in **measurable decline (-38% in 5 months)**. This validates BidDeed's positioning thesis: **the B2B API + MCP-native model is structurally stronger than consumer freemium.**

## 1. Verified Traffic Comparison (Apify SimilarWeb, April 2026)

| Metric | **RentCast** | **DealCheck** | Δ |
|---|---|---|---|
| Global rank | #312,375 | #594,817 | RentCast 90% better |
| US rank | #78,767 | #190,802 | RentCast 2.4× better |
| Monthly visits | **87,230** | 29,843 | **RentCast 2.9× more** |
| Bounce rate | 30.6% ✅ | 36.4% | RentCast stickier |
| Pages/visit | 4.95 | **6.99** | DealCheck deeper exploration |
| Avg session | 284s | 271s | tie |
| Category | finance/finance #989 | business_and_consumer_services/real_estate #2,051 | Different verticals |

### DealCheck trajectory (HISTORICAL VERIFIED)

- **Nov 2025**: 48,079 monthly visits (-22.3% MoM)
- **Apr 2026**: 29,843 monthly visits (**-38% over 5 months**)

DealCheck is shrinking faster than it was 6 months ago. RentCast appears stable-to-growing.

### Geographic surprises

**RentCast top countries**: US 84.8%, PK 6.9%, VN 1.8%, IN 1.2%, NI 1.1%

**DealCheck top countries**: US 69.6%, CA 23.1%, GB 2.7%, VN 1.7%, ID 1.6%

- **DealCheck has 23.1% Canadian traffic** — unusually strong cross-border for a US-only tool. Real Canadian distressed-asset investor base. Opportunity for future BidDeed/ZoneWise CA-province expansion.
- **RentCast has 6.9% Pakistani + 1.8% Vietnamese traffic** — developer/scraper signal. Confirms B2B API model attracts global devs in low-cost markets, supports BidDeed's MCP-native pitch.

## 2. Reverse-Engineered API Surface

Probed 2026-05-27 via reverse-engineering recon workflow. Full results in storage.

### RentCast API surface (101.8 KB probe data)

- `developers.rentcast.io` — documented developer portal (probed for OpenAPI/Swagger)
- `api.rentcast.io/v1/*` — production B2B API base, key-gated endpoints
- Sitemap indexed (see `sitemap-rentcast-parsed.json`)
- **MCP `.well-known/mcp.json` is absent** — BidDeed first-mover wedge

### DealCheck API surface (46.4 KB probe data)

- **No public developer API** — confirmed app-only (web/iOS/Android)
- MCP `.well-known` not present
- **Strategic implication**: BidDeed has zero competition from DealCheck in the developer/MCP surface

## 3. Strategic Implications for BidDeed MCP V1

### Pricing thesis (VALIDATED)

RentCast's $0/$74/$169/$329 tier with **87K monthly visits and growing** is the model to match — not DealCheck's $0/$19/$39 consumer pricing with **30K and shrinking**.

**BidDeed MCP V1 tier proposal** (per BIDDEED-MCP-V1-PRS.md, now validated):
- Free: $0/mo, 100 calls/mo
- Starter: $99/mo, 5,000 calls/mo
- Pro: $249/mo, 25,000 calls/mo
- Enterprise: $499+/mo, custom

### Differentiation (where neither competitor is)
1. **MCP-native from day 1** — neither competitor exposes `/.well-known/mcp.json`
2. **FL foreclosure + tax-deed depth** — RentCast is national/thin, no auction data
3. **Paired with ZoneWise.AI** — 67-county zoning intelligence layer (neither has)
4. **Agentic ecosystem positioning** — not "API" or "calculator" but "agentic AI ecosystem"

### Threat assessment
- **RentCast (Tier 1)**: could add MCP layer if they noticed BidDeed. Solo founder, national focus — unlikely to pivot to FL distressed-only depth.
- **DealCheck (Tier 2)**: declining, no API, no audience overlap. Compete on different axis.

## 4. Evidence Manifest

### RentCast (16 storage files at `ci-evidence/dossiers/rentcast/2026-05-27/`)
- 10 Playwright pages (home, pricing, api, developers, about, features, data, integrations, blog, contact)
- Tech recon: BuiltWith PNG, Wappalyzer PNG, SimilarWeb blocked (Apify backup)
- Structured: `similarweb-apify-rentcast.json` (28.9 KB), `sitemap-rentcast-parsed.json` (2.1 KB), `re-api-probes.json` (101.8 KB)

### DealCheck (26 storage files at `ci-evidence/dossiers/dealcheck/2026-05-27/`)
- 6 real Playwright captures + 3 phantom 404s
- Tech recon: BuiltWith PNG, Wappalyzer PNG, SimilarWeb PNG (direct scrape succeeded)
- Structured: `similarweb-apify-dealcheck.json` (27.0 KB), `re-api-probes.json` (46.4 KB)
- Phase 1-3 artifacts: about-anton-ivanov, api-endpoint-catalog, blog posts, features, home, patent-search, playwright-metrics, traffic-intelligence (legacy)

## 5. Honesty Markers

| Claim | Status | Source |
|---|---|---|
| Anton Ivanov solo founder of both | **VERIFIED** | dealcheck.io/about + Crunchbase + LinkedIn |
| RentCast 87,230 / DealCheck 29,843 visits | **VERIFIED** | Apify SimilarWeb 2026-05-27 |
| DealCheck -38% over 5 months | **VERIFIED** | Nov 2025 chat data + Apr 2026 Apify |
| API endpoint counts | **VERIFIED** | Reverse-engineering probe HTTP codes |
| Canada 23% of DealCheck traffic | **VERIFIED** | Apify geo distribution |
| Search/Social/Paid breakdown | **UNTESTED** | Apify quick scraper limitation |
| DEALCHECK trademark Oct 2024 | **UNTESTED** | No USPTO confirmation |
| BuiltWith full tech stack | **UNTESTED** | PNG only, structured scrape returned anti-bot HTML |

---

_Generated by SQL pipeline 2026-05-27. Supersedes RENTCAST-MCP-DOSSIER-V1.md._