---
layout: deferral
title: "Wire JsonPathEvolver into autoloop.yml workflow for structured-config skills"
slug: autoloop-v2-jsonpath-autoloop-yml-wiring
priority: P1
status: pending
owner: claude
created: 2026-05-12
blocker: "PRs #7473 + #7474 must merge first"
dependency: "cli-anything-biddeed#7473, cli-anything-biddeed#7474"
estimated_minutes: 120
tags: [autoloop-v2, jsonpath, workflow, github-actions]
---

## What

After PRs #7473 (`JsonPathPatcher`) and #7474 (`JsonPathEvolver`) merge, wire the new path into `.github/workflows/autoloop.yml` so nightly runs autonomously tune structured-config skills, not just SKILL.md prose skills.

Specifically:
1. Add a `skill_config_format` matrix dimension (`markdown` | `jsonpath`) to autoloop.yml
2. For `markdown` targets: existing `Evolver.generate()` flow (no change)
3. For `jsonpath` targets: new flow — `JsonPathEvolver.generate()` → `JsonPathPatcher.apply()` → commit mutated JSON
4. Maintain K3 surgical-changes gate with appropriate metric (entry-count for jsonpath, line-growth for markdown)
5. Wire callback to `skill_evolution_jsonpath_entries` table (depends on `autoloop-v2-jsonpath-migration` deferral landing first)

## Why

The two merged PRs give us a working module pair (`JsonPathEvolver` + `JsonPathPatcher`) but nothing currently invokes them in nightly runs. Without autoloop.yml wiring, the capability sits unused.

## Why deferred (not done in this session)

1. PRs not yet merged — wiring on an unmerged base is fragile
2. The first real consumer (Sentinel thresholds vs Shapira weights vs scraper config) hasn't been picked
3. Better to land the underlying capability cleanly, gather one week of L3 analyzer data, THEN pick a first wire-up target with evidence

## Resume conditions

When resuming:
1. Verify #7473 + #7474 merged to main
2. Verify `autoloop-v2-jsonpath-migration` deferral landed (table exists in production)
3. Pick FIRST wire-up target (recommend Sentinel thresholds — smallest blast radius, easiest rollback)
4. Add target to autoloop.yml matrix
5. Add WhitelistConfig for that target under `evolution/whitelists/sentinel_thresholds.py`
6. Smoke-run nightly twice; verify entries flowing into `skill_evolution_jsonpath_entries`
7. Manually approve first 3 patches before flipping `applied=true` autonomy switch

## Done when

- autoloop.yml runs nightly with at least one `jsonpath` target
- 3 consecutive nights produce well-formed entries (LLM emit → patcher apply → git commit)
- Zero ghost-success events (per V2 schema-level guardrail)
- Sentinel `r5_queued_no_pickup_60s` count for `jsonpath` skills = 0 over 7 days
