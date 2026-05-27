# DEFERRED: Output gate flip from warn to blocking

**Created**: 2026-05-27 · **Status**: SCHEDULED · **Priority**: P1 · **Target date**: 2026-05-28 · **Est effort**: 5 min

## Background

SUMMIT-G output gate (`5539ded1-d781-45c5-9903-0aa255a53de6`, closed earlier session) deployed `.github/workflows/_ci-output-gate.yml` (commit `c9fe4ae8`) and wired it into `summit-rentcast-dossier.yml` (commit `b80280a6`) with **`gate_mode=warn`** for a 24-hour observation period.

## What the gate validates (4 checks)

1. Phase completion in `ci_v65_dossier_phases`
2. Classification populated in `ci_dossiers`
3. Legacy `rich_data` field non-empty (V6.5 backward compat)
4. Storage file count ≥ `min_storage_files` input (default 8)

Logs verdict to `ghost_success_audit` table with `verdict`, `failures`, `checks_performed`, `gate_mode`.

## Why warn first

Validated by ghost-test: caught RentCast at P11_BUNDLE with 0 files, recorded `verdict=fail`. Working as designed. Warn mode for 24h to ensure no false positives on legitimate runs before making it production-blocking.

## Flip procedure (target: 2026-05-28)

1. `apply_migration` or `str_replace` on `summit-rentcast-dossier.yml`: change `gate_mode: warn` → `gate_mode: blocking`
2. Push to main
3. Confirm next legitimate run passes
4. Backport to ~6 other summit-* workflows (deferral #6 below)

## Acceptance criteria

`ghost_success_audit` has zero `verdict=fail` rows from legitimate non-ghost runs in the 24h observation window (currently ~0 expected since dispatch flow is well-tested).