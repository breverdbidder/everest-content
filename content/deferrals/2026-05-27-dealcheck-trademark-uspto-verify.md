# DEFERRED: DEALCHECK trademark verification (Oct 2024 claim) — needs USPTO access

**Created**: 2026-05-27 · **Status**: UNTESTED (Honesty V3) · **Priority**: P3 · **Est effort**: 30 min · **Cost**: free

## Problem

AgentRemote bot crawl earlier in CI cycle claimed DEALCHECK trademark was filed October 2024 by Fortnoff Financial LLC (Anton Ivanov's entity). This claim has been carried forward in prior dossier drafts as UNTESTED — no successful USPTO/Justia/Trademarkia confirmation this session via web search.

## Verification options

1. **USPTO TSDR API** (free, public) — `https://tsdr.uspto.gov/ts/cd/casestatus/sn{serial_number}/info.xml`. Need to first find the serial number via tmsearch.uspto.gov
2. **Justia trademark search** — `https://trademarks.justia.com/owners/fortnoff-financial-llc/` (verify entity registration)
3. **Trademarkia search** — `trademarkia.com/trademarks-search.aspx?tn=DEALCHECK`
4. **PTAB direct query** for trademark opposition history

## Why this matters for BidDeed

If DEALCHECK is a registered TM, the name "BidDeed" is sufficiently distant (different industry classification — auction software vs investor calculator) but worth confirming there is no overlap with Anton's portfolio. Low priority because BidDeed and DealCheck operate in non-overlapping classifications and trade dress.

## Acceptance criteria

Either: (a) USPTO record located + status verified + registration class noted, OR (b) confirmed no registration exists and AgentRemote bot was wrong.