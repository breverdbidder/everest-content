# DEFERRED: BuiltWith structured JSON — needs API key

**Created**: 2026-05-27 · **Status**: DEFERRED · **Priority**: P2 · **Est effort**: 1h (incl. signup) · **Cost**: $295–$595/yr or scrape free

## Problem

Reverse-engineering recon workflow (`run 26541870526`) captured BuiltWith.com PNG screenshots (240 KB each for both targets) but the HTML scrape via BeautifulSoup returned empty `tech_categories` dict. Likely cause: BuiltWith serves anti-bot HTML to unauthenticated UAs — the visible-in-browser tech stack list is loaded via authenticated API or JS later.

## What landed

- `ci-evidence/dossiers/rentcast/2026-05-27/recon-builtwith.png` (241.7 KB)
- `ci-evidence/dossiers/dealcheck/2026-05-27/recon-builtwith.png` (240.8 KB)
- Marked **UNTESTED** in v6 battle cards

## What did not land

- `builtwith-rentcast-structured.json` (planned, empty)
- `builtwith-dealcheck-structured.json` (planned, empty)

## Options to unblock

1. **BuiltWith Pro API** ($295/yr basic, $595/yr pro) — direct JSON access for any domain
2. **Wappalyzer Pro API** ($150/yr) — alternative, comparable depth
3. **Free scrape with Playwright + auth cookie** — register free BuiltWith account, save session, scrape as logged-in user (cheaper but fragile)
4. **Use Apify BuiltWith scraper actor** — same pattern as SimilarWeb path that worked this session

## Recommendation

Option 4 (Apify BuiltWith actor) — reuses proven pattern from `mscraper/similarweb-quick-scraper`, costs ~$0.05/run, same vault token (`apify_api_token`).