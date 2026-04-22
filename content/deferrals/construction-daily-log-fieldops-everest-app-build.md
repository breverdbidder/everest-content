# Deferral: fieldops-everest App Build

**Slug:** `construction-daily-log-fieldops-everest-app-build`
**Created:** 2026-04-22
**Session:** extreps-construction-daily-log-2026-04-22
**Domain:** ZONEWISE / KENSTREKT (field ops)
**Priority:** P2
**Status:** DEFERRED

## What's deferred

The fieldops-everest fork is seeded with the contract (37-field daily-log JSON Schema + DELTA features) and a README that explains the plan. The actual app — Supabase schema, RLS policies, React form components, photo upload pipeline, Workbox PWA, weather auto-pull integration — is not built.

## Estimated effort

~16h dev work, equivalent to one SUMMIT dispatch:

- 4h — Supabase migrations (projects, daily_logs, photos, sub_tokens, audit table) + RLS
- 3h — capability-URL pattern for subcontractors (fix_token-style, no account creation)
- 2h — AJV runtime validation wired to JSON Schema contract
- 2h — Workbox PWA + offline cache (cache-first for shell, network-first for API)
- 2h — Supabase Storage integration for photos with EXIF preservation
- 2h — National Weather Service auto-pull on entry create
- 1h — README updates + first-run quickstart

## Why deferred

Today's session scope was EXTREPS evaluation + fork creation + distillation publishing. App build is a distinct piece of work that:

1. Belongs in its own dispatched session for proper EG14 traceability
2. Should be sequenced after at least one of the 3 distillations is read by whoever (or whatever) writes the actual code
3. Will benefit from the open-summit count having been verified clean (zero open right now per honesty correction)

## Resume conditions

When resuming, the resumer should:

1. `git clone https://github.com/breverdbidder/fieldops-everest`
2. Read `README.md` + `schemas/daily-log.schema.json`
3. Read all 3 distillations under `breverdbidder/everest-vault/200-references/external-knowledge/`
4. Apply Supabase migrations to `mocerqjnksmhcjzxrewo`
5. Implement components in dependency order: schema validator → form renderer → photo upload → sync → PWA shell

## Cross-references

- EXTREPS rows: `extrep_evaluations` where `chat_session_id = 'extreps-construction-daily-log-2026-04-22'`
- Fork commit: 501b221308e71cf574f72463f4b30b9c11bdf44e
- Distillation commit: fa370dacdd3a1adae432de8829ea7c1a858cbab7
- Honesty violation logged this session: id=25f01dc9-86ef-470b-a594-6962e30f4084
- Real-world driver: Property360 / Kenstrekt jobsite ops, including 625 Ocean Street (FDEP CCCL, June 25, 2026 permit deadline)

## Honesty markers

- [VERIFIED] schema validates per Draft 2020-12
- [VERIFIED] fork exists, parent linkage intact
- [VERIFIED] distillations meet all 4 EXTREPS constraints
- [UNTESTED] daily log workflow end-to-end on a real jobsite (no UI yet)
- [UNKNOWN] which Mariam-side staff will pilot the app first (625 Ocean? Bliss8?)
