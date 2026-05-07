# Lot CMA Template

> Vacant-lot Comparative Market Analysis — 3-method reconciled

**Status**: v2 (May 2026) · 9 tabs · 318 formulas · 45 named ranges · Patent V3.1 Claim 9

---

## What this template does

Computes a reconciled fair-value estimate for a vacant lot using three independent methods, then reconciles them with user-set weights. All math is formula-driven.

### The three methods

1. **METHOD 1 — Lot $/SF**: Average comparable-sale $/SF × subject lot SF
2. **METHOD 2 — JV Multiple**: (Comp Sale Price / Comp Just Value) × Subject Just Value
3. **METHOD 3 — Comp Adjustment Grid**: Each comp adjusted for size, frontage, waterfront type, corner premium, then averaged

### Reconciliation

Final value = (Method 1 × w1) + (Method 2 × w2) + (Method 3 × w3), where weights sum to 100% and are user-editable on INPUTS tab.

---

## Tabs

1. README (this page)
2. INPUTS — subject parcel data, reconciliation weights, adjustment factors
3. COMPS — up to 15 comparable vacant-lot sales (formula-driven $/SF and JV multiple per comp)
4. METHOD_1_PSF — Lot $/SF method
5. METHOD_2_JV — Just-Value multiple method
6. METHOD_3_GRID — Comp adjustment grid (157 formulas — most computational tab)
7. RECONCILIATION — weighted average across methods
8. SENSITIVITY — 2-way data table on weights
9. AUDIT — formula audit log + self-tests

---

## Worked example — 2827 SW 25th Ave Cape Coral

The template ships pre-populated with this case. Live computed values:

| Method | Value |
|---|---|
| Method 1 (Lot $/SF) | $82,223 |
| Method 2 (JV Multiple) | $111,601 |
| Method 3 (Comp Grid) | $78,990 |

Reconciled value depends on user-set weights (default 30/35/35).

---

## Build script status

The v2 Lot CMA build script (`build_lot_cma_v2.py`) is maintained in the BidDeed.AI workspace; the canonical xlsx output `ZoneWise_LotCMA_Template_v2.xlsx` is shipped to the chat-output channel. The build script source will be published here once stabilized.

---

## Use for new lots

1. Open `INPUTS` tab. Replace the BLUE cells with the new lot data
2. Open `COMPS` tab. Replace comp rows with recent comparable sales
3. Adjust reconciliation weights on INPUTS tab as appropriate for this lot
4. Read RECONCILIATION tab for final weighted value
5. Stress-test on SENSITIVITY tab

---

© 2026 Everest Capital USA · ZoneWise.AI · Confidential
