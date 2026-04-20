# VERIFIER-FIX-V1 — remove invalid --auto-flip --telegram flags

**Status:** [VERIFIED] — landed on main, empirically proven in 16s run
**Date:** 2026-04-20
**Merge commit:** `40715933402ddd992784065c1a8b49b22c2842c7`
**Direct commit:** `db164c61e2c644a4942e2d2235aea50d70711972`
**Parent:** `f74b23cdb5ca22e4b8451e08246b81be9deafa1f` (V2 runner state-model merge)
**Target file:** `.github/workflows/supabase-summit-verifier.yml` (in cli-anything-biddeed)

---

## Executive summary

`supabase-summit-verifier.yml` was passing two CLI flags to `scripts/supabase_summit_verifier.py` that the script did not recognize: `--auto-flip` and `--telegram`. argparse rejected them with exit code 2 before any verification work could run. Every verifier GHA run since at least 2026-04-19T23:44Z had been failing in 8–14 seconds for this reason. Because `auto_dispatch_awaiting_verification()` relies on this workflow to produce `summit_verifier_runs` rows, **all awaiting_verification → verified promotions across the system were silently blocked** until this fix landed.

The fix is trivial and the argparse error message is unambiguous:

```
supabase_summit_verifier.py: error: unrecognized arguments: --auto-flip --telegram
```

Removed ` --auto-flip --telegram` (leading space included) from the 4 `Run verifier *` step `run:` lines that had them. The 5th step (`retro-verify-today`) already did not have these flags.

---

## Why these flags existed (diagnosis)

The script uses opt-out semantics: `--no-auto-flip` to disable auto-flip, `--no-eg14` to disable EG14. Auto-flip-to-failed behavior is therefore on by default. Someone authoring the workflow presumably wanted to be explicit about opting-in and added `--auto-flip` as a mirror of `--no-auto-flip`, but that flag was never added to the script. Same for `--telegram`: Telegram notification is configured via `BIDDEED_BOT_TOKEN` + `BIDDEED_BOT_CHAT_ID` env vars, not a CLI flag.

Both flags have been dead since the workflow added them. The fact that the workflow argparse-failed silently for ~1.5 hours without being noticed suggests either: (a) no awaiting_verification dispatches had been created during that window, or (b) the downstream consequence (nothing gets promoted to verified) was tolerated without alarm. The SUMMIT Verifier cron running every 5 minutes was failing silently at schedule runs 23:44, 00:24 (and likely earlier).

---

## The fix (single line, 4 occurrences removed)

Global textual substitution: ` --auto-flip --telegram` → `` (empty string)

Targeted lines (before):

- `run: python scripts/supabase_summit_verifier.py --auto-patrol --auto-flip --telegram`
- `run: python scripts/supabase_summit_verifier.py --all-verified-today --auto-flip --telegram`
- `run: python scripts/supabase_summit_verifier.py --session "${{ inputs.session_id }}" --auto-flip --telegram`
- `run: python scripts/supabase_summit_verifier.py --summit-id "${{ inputs.summit_id }}" --auto-flip --telegram`

Delta:

- Original yml: 2,977 bytes
- V1 yml: 2,885 bytes
- Net removed: 92 bytes (4 × 23 chars including leading space)
- yml SHA before: `4531e3c23a62485bdd374fbbbce7a75bca0ce75b`
- yml SHA after: `e5ecda8a17ffb648ca75518adb009b7794c4bf22`

---

## Empirical proof

### Pre-fix failure (representative)

- GHA run 24643711594
- event: workflow_dispatch (manually triggered by dispatch_summit_verifier_scan)
- duration: 13 seconds
- step 6 "Run verifier (auto-patrol)" conclusion: failure
- stderr: `supabase_summit_verifier.py: error: unrecognized arguments: --auto-flip --telegram`
- exit code: 2

Pattern held across earlier runs: 24642831498 (14s failure), 24642044437 (8s failure), and presumably older.

### Post-fix success

- GHA run 24643829666
- event: workflow_dispatch
- head_sha: `40715933` (this merge)
- duration: 16 seconds
- conclusion: success
- summit_verifier_runs row produced: `044c1fa7-b7cd-426e-b174-cbf2dbf3f2cc` (first clean verifier row this session)

The ~2-second runtime delta between pre-fix and post-fix (13s → 16s) is consistent with the script actually doing its verification work in post-fix rather than argparse-exiting in pre-fix.

---

## Downstream — dual-gate trigger now unblocked

`trg_require_dual_gate` (BEFORE UPDATE on `summit_chat_dispatch`) refuses `state="verified"` unless a recent `summit_verifier_runs` row for the summit exists with `overall_verdict="PASS"` (within 2 hours). Pre-fix: zero PASS rows could exist, because the verifier never completed its work. Post-fix: rows are being produced, dual-gate is satisfied for passing dispatches.

This fix does NOT by itself promote any specific dispatch to `verified`. It restores the ability of the verifier to produce PASS/FAIL verdicts. For a dispatch to be promoted, its summit_body must contain verifiable claims the verifier can parse and find evidence for on main.

---

## Known caveat — NOOP dispatches don't promote

The V2 empirical test dispatch `f40c705e-e1e8-4bfe-8d54-3ce8a61fd00c` was a pure NOOP ("print this marker line and exit"). Its post-fix verifier row (`044c1fa7`) returned:

- overall_verdict: DISPATCHED-ONLY (not PASS)
- dual_gate_verdict: INSUFFICIENT_EVIDENCE
- claims_total: 0
- per_claim_verdicts: []

This is correct verifier behavior. The summit_body had no claims to parse because it was deliberately minimal. A production dispatch with a real mandate (e.g., "create file X at path Y with sections Z") will yield non-zero claims and should reach PASS if the work is actually done. The NOOP can remain at awaiting_verification indefinitely as a sentinel or can be manually closed via bypass.

---

## Artifacts

- Pre-fix failing run log: https://github.com/breverdbidder/cli-anything-biddeed/actions/runs/24643711594
- Post-fix passing run log: https://github.com/breverdbidder/cli-anything-biddeed/actions/runs/24643829666
- Commit: https://github.com/breverdbidder/cli-anything-biddeed/commit/db164c61e2c644a4942e2d2235aea50d70711972
- Merge: https://github.com/breverdbidder/cli-anything-biddeed/commit/40715933402ddd992784065c1a8b49b22c2842c7
- First clean summit_verifier_runs row: `044c1fa7-b7cd-426e-b174-cbf2dbf3f2cc`

---

## Honesty tags

- [VERIFIED] Pre-fix runs failing on argparse `unrecognized arguments` — confirmed by fetching step 6 log directly from Azure blob
- [VERIFIED] Post-fix run 24643829666 succeeded in 16s and produced a `summit_verifier_runs` row
- [VERIFIED] yml on main now matches patched content (SHA `e5ecda8a`)
- [INFERRED] Telegram notifications are handled via env vars rather than CLI flag — based on presence of `BIDDEED_BOT_*` secrets in workflow env and absence of argparse support for `--telegram`. Not observed firing in this session.
- [UNTESTED] A real-claim dispatch (not NOOP) reaches `overall_verdict=PASS` and promotes to `state=verified`. Next session via Brevard ROD recon or similar.

---

*Paired with `RUNNER-FIX-V2.md` (merge `a506530757ea7a3da609f548cf75d24926e6d80e`). Runner V2 made the dispatch lifecycle state-model correct; Verifier V1 made the downstream verifier pipeline functional. Together they unblock the full promotion path.*
