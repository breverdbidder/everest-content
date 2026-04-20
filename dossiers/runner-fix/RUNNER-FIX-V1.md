# RUNNER-FIX-V1 — Ghost-Success Elimination

**Status:** Verified diagnosis, awaiting direct pg_net push deployment.
**Date:** 2026-04-19
**Honesty violation corrected:** `0eeeac5d-a0c8-4b44-a02c-57f8d2f7f762` — VERIFIED tagging without verification. All 5 defects subsequently confirmed against actual code.
**Dispatch reference:** `7cd357a8-2b4c-437b-828c-41d36ecf938a` — ghost-successed at T+22m52s, meta-proving the pattern it was meant to fix.

---

## Executive finding

On 2026-04-19, nine consecutive SUMMIT dispatches against `breverdbidder/cli-anything-biddeed` reported GitHub Actions green while writing zero meaningful state to Supabase. Root cause: five defects in `.github/workflows/claude-code-direct.yml` and `scripts/claude-runner.sh`. All five VERIFIED against commits `c9e988851643dca6227b42aff2457a3453bc7b0e` (yml) and `48e00ded059a8d208ea168275c0cfe917b856227` (sh) via `pg_net.http_get` requests 161 and 162.

The runner-fix dispatch ITSELF ghost-successed, providing dispositive evidence that the defects are real and self-reinforcing.

## Verified defects

### Defect 1 — No auth-validity probe (VERIFIED)
`git ls-remote` pattern absent from validate-input step. Expired/invalid PAT passes validation because only env var presence is checked. Checkout then fails with exit 128, but the workflow reports success because failure happens before the summit body runs.

**Fix:** Replace presence-only check with live `git ls-remote` probe. Redact PAT from error output.

### Defect 2 — `set -euo pipefail` missing from ALL shell blocks (VERIFIED)
Zero occurrences across 6 `run:` blocks in YAML + zero in runner script. Bash defaults to continue-on-error.

**Fix:** Every `run:` block gets `shell: bash` + `set -euo pipefail` as first line.

### Defect 3 — 4 instances of `||true` swallowing exit codes (VERIFIED)
Four occurrences of `||true` in YAML. Each defeats subsequent error checks.

**Fix:** Delete all `||true` occurrences. Non-fatal intent uses explicit `if-then-else` with WARN log.

### Defect 4 — No `write_failed` trap in runner (VERIFIED)
`trap ... ERR` absent. `write_failed` function absent. If runner dies before summit body starts, `state` stays `running` indefinitely.

**Fix:** Add `write_failed()` + `trap write_failed ERR EXIT` at top. Clear trap on clean exit with `trap - ERR EXIT` then `PUSHED commit:<sha>` marker.

### Defect 5 — No pre-flight repeat-failure guard (VERIFIED)
No guard pattern in runner. Runner accepts any dispatch even when last 3 against same repo all failed with identical errors.

**Fix:** Pre-flight query of last 3 dispatches for `target_repo`. If all 3 `state=failed` AND share `last_error` substring, refuse with `state='quarantined'`.

## Verification plan

V1: failing dispatch `target_repo=breverdbidder/does-not-exist` → expect `state=failed`, `last_error` contains `git auth probe failed` OR `runner_exit_1_at`.

V2: succeeding dispatch `summit_body="echo HELLO_RUNNER_OK"` → expect `state=verified`, `workflow_run_id != null`.

## Output markers

On success: `PUSHED commit:<sha>` (exact literal).
On failure: `ERROR:<reason>` (exact literal).

## Dispatch history

`7cd357a8-2b4c-437b-828c-41d36ecf938a` created 2026-04-19 23:52:57 UTC. Ghost-successed at T+22m52s. `workflow_run_id=null`. Quarantined with reason `ghost_success_9x_same_pattern_21min_no_workflow_run_id`.

## Pattern compliance (post-violation)

Per honesty violation `0eeeac5d`:

- Original spec tagged VERIFIED without verification. Fetch-then-verify skipped.
- Corrected: all 5 defects VERIFIED via `pg_net.http_get` (reqs 161, 162) against specific commit SHAs.
- Original dispatch inlined the spec in `summit_body` rather than committing dossier first.
- Corrected: this dossier is the committed artifact.
- Direct pg_net push was proposed as fallback rather than primary per Rule #1.
- Corrected: dispatch `7cd357a8` ghost-successed as predicted. Direct pg_net push is the default path forward.

---

*Committed 2026-04-19 as corrective action for honesty violation `0eeeac5d`. Parent everest-content HEAD: `7d6f0f01bb578e0f18f9183332ae52eef479e1bf`.*
