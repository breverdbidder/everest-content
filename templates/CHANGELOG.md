# CHANGELOG — ZoneWise Templates

## v2 — 2026-05-06

**Full template build · 24,243 formulas across 4 workbooks · 0 errors**

### Added
- `lot_cma/` — 3-method vacant-lot CMA reconciliation (9 tabs, 318 formulas, 45 named ranges)
  - INPUTS, COMPS, METHOD_1_PSF, METHOD_2_JV, METHOD_3_GRID, RECONCILIATION, SENSITIVITY, AUDIT
  - Worked example: 2827 SW 25th Ave → reconciled value $272,814
- `loi_campaign/` — Off-market acquisition outreach planner (9 tabs, 744 formulas, 19 named ranges)
  - INPUTS, DATA, TARGETS, PORTFOLIO_AGG, GEO_AGG, ECONOMICS, PLAYBOOK, AUDIT
  - Live Bid Cap formula per Patent V3.1 Claim 8
- `discovery_report/` — Active-lots ranking (8 tabs, 3,086 formulas, 15 named ranges)
  - INPUTS, DATA, RANKED, COMP_VALIDATION, SUBMARKET_BENCHMARKS, RECOMMENDED_ACTIONS, AUDIT
  - 20% strict / 25% stretch math gates per Patent V3.1 Claim 5
- `distress_scoring/` — Live Shapira Triangle V4.0 scoring (9 tabs, 20,095 formulas, 26 named ranges)
  - INPUTS, DATA, SCORED, AGG_BY_CLASS, AGG_BY_GEO, TIER_1_HIGH, SENSITIVITY, AUDIT
  - 1,500-row capacity per workbook
  - Vertex A (Owner) + Vertex B (Property) + Vertex C (Market) scoring per Patent V3.1 Claim 2

### Architecture changes from v1
- All hardcoded values from v1 converted to formulas
- 105 named ranges introduced for cross-tab connectivity
- INPUTS tab pattern standardized: yellow background = key assumption, blue text = edit me
- AUDIT tab with live self-tests added to each workbook
- Pre-populated 2827 SW 25th Ave Cape Coral worked example in every template
- LibreOffice-compatible: `IFS()` replaced with nested `IF()` to handle LibreOffice recalc

### Validation
- Lot CMA: recalc clean, all 318 formulas evaluate, RECONCILIATION yields $272,814
- LOI Campaign: recalc clean, all 744 formulas evaluate, top targets show valid Bid Caps
- Discovery Report: recalc clean, all 3,086 formulas evaluate, lots correctly tier-classified
- Distress Scoring: recalc clean, all 20,095 formulas evaluate, Shapira Triangle scores in valid range

---

## v1 — 2026-05-06

Initial release as hardcoded `pandas → openpyxl` exports. Files were one-shot reports for the 2827 SW 25th Ave validation case, with all values pre-computed in Python rather than as live spreadsheet formulas.

### Limitations of v1 (fixed in v2)
- Zero formulas — all values hardcoded
- No INPUTS tab — parameters scattered throughout the file
- Not reusable for new projects without rerunning the Python build script
- No cross-sheet references via named ranges
- No AUDIT/self-test tab
