# Spec B — FL Clerk Direct Adapter v1

**Status:** VERIFIED design. Phase 2 — post-Spec-A.
**Timeline:** 8-12 weeks.
**Dependencies:** Spec A shipped first. Runner fix landed.

---

## Goal

True SSOT independence. Direct L1 integration with 67 FL Clerks of Court. Captures pre-auction docket events (lis pendens, judgment, motion practice) 10-20 days before RealAuction publishes.

---

## Why L1 matters

| Event | L2 (RealAuction) | L1 (Clerk Direct) | Edge |
|---|---|---|---|
| Sale scheduled | 1-3 days before | 10-20 days before | 10-20× earlier |
| Lis Pendens | not exposed | real-time | ∞ |
| Final Judgment | not exposed | real-time | ∞ |
| Plaintiff counsel | hidden | visible | ∞ |
| Bankruptcy stay | hidden | real-time | ∞ |

This cannot be reproduced by any L2 aggregator. Structural moat against PO, RealAuction, CoreLogic.

---

## FL standardization (the lever)

- **UCN** (Uniform Case Number): 20-char format mandated by Fla. R. Jud. Admin. 2.245(b). `{CC}{YYYY}{DIV}{NNNNNN}{QUALIFIER}`. Foreclosures = CA division.
- **UCR v1.4.2** (Uniform Case Reporting): XML schema all clerks submit to state. Standardized event types.
- **Standards for Access Sept 2024**: Access Level A for foreclosure dockets. Legal mandate.
- **AOSC 16-14 + 18-16**: public images of filed documents legally available.

67 adapters collapse to 3 platform templates:
- **Odyssey / Enterprise Case Manager** (Tyler Technologies) — ~40 FL counties inc. Miami-Dade, Pinellas, Pasco
- **Benchmark CaseSearch** (ImageSoft) — ~15-20 counties inc. Bay, Leon
- **Custom / Legacy** — ~7-10 outlier counties

---

## Pydantic schema (abbreviated)

```python
class ClerkJudgment(BaseModel):
    ucn: str = Field(pattern=r"^\d{2}\d{4}(CA|CC|DR|CP|CF|MM|TR)\d{6}[A-Z]*$")
    ucn_county_code: int
    ucn_year: int
    ucn_division: Literal["CA","CC","DR","CP","CF","MM","TR"]
    case_initiated_date: date
    case_type_code: str
    case_status: Literal["active","closed","disposed","reopened","transferred"]
    primary_judge: Optional[str]
    plaintiff: str
    plaintiff_counsel_name: Optional[str]
    plaintiff_counsel_bar_number: Optional[str]
    defendant: list[str]
    property_address: str
    parcel_id: Optional[str]
    lis_pendens_date: Optional[date]
    final_judgment_date: Optional[date]
    final_judgment_amount: Optional[Decimal]
    scheduled_sale_date: Optional[date]
    docket_events: list[DocketEvent]
    bankruptcy_stay_filed: Optional[date]
    clerk_county: str
    clerk_platform: Literal["odyssey","benchmark","custom_cf","custom_asp","legacy"]
```

---

## Template adapters

1. **Odyssey** — `https://{clerk_domain}/Public/CaseSearch/CaseSearch.aspx`, ASP.NET ViewState postbacks, `tyler-pubapp-*` CSS classes
2. **Benchmark** — `https://{clerk_domain}/cvweb/cgi-bin/*`, ColdFusion server-rendered
3. **Custom** — per-county LangStruct extractor with 10 seed examples each

---

## Deployment plan

- Weeks 3-4: Odyssey adapter. Validate on Miami-Dade + Pinellas. ~40 counties covered.
- Weeks 5-6: Benchmark adapter. Validate on Bay + Leon. ~60 counties total.
- Weeks 7-10: Custom adapters for 7-10 outliers.
- Weeks 11-12: Reconciliation vs RealAuction + PO historical. SSOT independence achieved.

---

*Pairs with Spec A. Together: Phase 1a (Spec A, L2) + Phase 1b (10-day title pipeline) + Phase 2 (Spec B, L1) = full lifecycle ownership by Week 20.*
