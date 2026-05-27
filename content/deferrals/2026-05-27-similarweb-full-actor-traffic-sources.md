# DEFERRED: SimilarWeb Search/Social/Paid traffic breakdown — needs full actor

**Created**: 2026-05-27 · **Status**: DEFERRED · **Priority**: P3 · **Est effort**: 15 min · **Cost**: ~$5/run vs $0.05/run currently

## Problem

Apify `mscraper~similarweb-quick-scraper` (used this session) returns ONLY Direct/Mail/Referrals traffic sources. Search/Social/Paid Referrals fields come back as null. This is a documented limitation of the quick scraper — the full scraper returns all 6 traffic sources but costs ~100× more.

## What we have (VERIFIED for both targets)

| Source | RentCast | DealCheck |
|---|---|---|
| Direct | 67.2% | 67.5% |
| Mail | 1.1% | 3.5% |
| Referrals | 1.2% | 1.3% |
| Search / Social / Paid | **null** | **null** |

## Strategic implication

Most of the ~30% unaccounted traffic for both targets is **search** (typical for SEO-driven SaaS) — but we cannot prove what share is organic vs paid without the full actor. This is the gap between "BidDeed needs SEO" vs "BidDeed needs PPC ($)".

## Recommendation

When BidDeed enters paid acquisition planning phase, run the full actor once per quarter ($5/run × 2 targets × 4/yr = $40/yr). Until then, the current `direct=67%/stickiness=4.5 min` signal is sufficient strategic ground truth.