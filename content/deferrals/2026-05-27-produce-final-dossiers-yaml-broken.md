# DEFERRED: produce-final-dossiers.yml broken (YAML validation failed)

**Created**: 2026-05-27 · **Session**: CI V6.5 final dossier delivery · **Status**: DEFERRED · **Priority**: P3 · **Est effort**: 30 min

## Problem

Workflow `.github/workflows/produce-final-dossiers.yml` (commit `efee5afd`) failed GitHub Actions YAML validation. Run `26542152308` registered as `completed/failure` with **0 jobs scheduled** — the file never reached job-execution phase.

## Resolution this session

Pivoted to pure SQL pipeline (CTEs building markdown via `||` concatenation + `gh_push_files_handler`). Successfully delivered all 3 final markdown files:
- `everest-vault/600-Research/battle-cards/rentcast-v6-FINAL.md` (`8249dd45`)
- `everest-vault/600-Research/battle-cards/dealcheck-v6-FINAL.md` (`ab70eab7`)
- `everest-content/dossiers/competitive-intel/RENTCAST-DEALCHECK-CI-V65-FINAL.md` (`2c7d9192`)

Broken file DELETED from cli-anything-biddeed this session.

## Root cause hypothesis (not investigated)

Likely culprit: nested f-string conditional expressions (`{"A" if x else "B"}`) inside Python triple-quoted f-strings, combined with literal Markdown blocks containing `${{` patterns or unicode special chars (`→`, `·`) in step names. GHA pre-parses `${{ ... }}` expressions before YAML scheduling — any malformed expression there kills the workflow.

## Recommended approach (if rebuilding workflow path)

1. Move markdown templates to separate `.md.tmpl` files in repo
2. Workflow reads templates, does only simple `.format(**data)` substitution
3. Avoid unicode in step names
4. Pre-validate via `actionlint` before push

## Why this is P3

SQL pipeline works and is simpler. No urgent need to rebuild the workflow path unless we want scheduled/cron dossier refresh later.