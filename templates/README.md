# ZoneWise Template Suite

> Fully formula-driven, cross-tab-linked spreadsheet templates for the BidDeed.AI / ZoneWise.AI distressed-asset workflow.

**Status**: v2 (May 2026) · 4 templates · 24,243 formulas · 105 named ranges · 0 errors

---

## What's in here

This folder ships four reusable Excel templates plus the Python build scripts that generate them. Each template is fully formula-driven — paste raw data, every analysis tab recalculates live.

| Template | Purpose | Tabs | Formulas | Named Ranges |
|---|---|---|---|---|
| `lot_cma/` | 3-method vacant-lot CMA reconciliation | 9 | 318 | 45 |
| `loi_campaign/` | Off-market acquisition outreach planner | 9 | 744 | 19 |
| `discovery_report/` | Active-lots ranking with 20%/25% gates | 8 | 3,086 | 15 |
| `distress_scoring/` | Live Shapira Triangle V4.0 scoring | 9 | 20,095 | 26 |

---

## Architecture (every template)

Each workbook follows the same pattern:

1. **README** — workflow + tab guide + color legend
2. **INPUTS** — All parameters as named ranges (yellow background = key assumption, blue text = edit me)
3. **DATA** — Paste raw query result here (the only place hardcoded values live)
4. **Analysis tabs** — Formula-driven views via `SUMIFS` / `COUNTIFS` / `AVERAGEIFS` / `INDEX` / `MATCH` / `LARGE`
5. **AUDIT** — Live self-tests (sums match, ranges valid, counts equal)

### Color coding (industry-standard financial-modeling convention)

- **Blue text** — User input (edit me)
- **Black text** — Formula in same sheet
- **Green italic** — Link from another sheet
- **Yellow background** — Key assumption needing review

### Cross-tab connectivity

All cross-sheet references go through 105 named ranges so formulas read like English:

```excel
=DATA!F6 * arv_mult                       # not =DATA!F6 * Sheet2!$C$10
=COUNTIF(SCORED!K6:K1505,"INTERNATIONAL") # named ranges ftw
```

---

## Quickstart

```bash
# 1. Install Python deps
pip install -r requirements.txt

# 2. Generate any of the 4 xlsx outputs
python loi_campaign/build.py
python discovery_report/build.py
python distress_scoring/build.py
# (lot_cma/ has its own README — see that folder)

# 3. Open the resulting xlsx, edit INPUTS tab, paste new DATA, all tabs recalc
```

---

## Use for new projects

To use any template for a fresh project:

1. Open the `INPUTS` tab — edit weights, thresholds, ARV multipliers (yellow cells)
2. Open the `DATA` tab — paste your `fl_parcels` query result (or whatever raw input the template expects)
3. All other tabs recalculate automatically

The build scripts ship with the 2827 SW 25th Ave Cape Coral worked example pre-populated so you can see exactly how each formula behaves.

---

## Worked-example outputs (from May 6, 2026 build)

- **Lot CMA**: 3-method reconciled value for 2827 SW 25th Ave = **$272,814**
- **Distress Scoring**: Ledwig Thomas (Germany, 55 yr held) → A=40, B=18, C=0 → Total **58 → T1**
- **Discovery Report**: 2827 SW 25th → **AGGRESSIVE LOI** (PASS-STRICT + STALE DOM)
- **LOI Campaign**: 1819 Dogwood Dr (Mihaichuk Trust, Canada) → score 65, Bid Cap **$200,133**

---

## IP / Patent reference

These templates implement portions of the Everest Capital USA / BidDeed.AI patent application Patent V3.1:

- **Claim 2** — Shapira Triangle V4.0 ensemble (Vertex A Owner + Vertex B Property + Vertex C Market)
- **Claim 5** — 20%/25% math-rule discovery gates
- **Claim 8** — Shapira Bid Cap formula (Bid Cap = ARV × bid_cap_pct × (1 − soft_cost_pct))
- **Claim 9** — Three-method lot CMA reconciliation (PSF / JV multiple / adjustment grid)

---

## Versioning

See `CHANGELOG.md` for the full version history. Templates are versioned as `v2` to distinguish from the original v1 hardcoded exports.

---

© 2026 Everest Capital USA · ZoneWise.AI · BidDeed.AI · Confidential
