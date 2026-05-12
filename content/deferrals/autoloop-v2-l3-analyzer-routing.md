---
layout: deferral
title: "L3 analyzer routing: markdown vs jsonpath evolver per skill metadata"
slug: autoloop-v2-l3-analyzer-routing
priority: P1
status: pending
owner: claude
created: 2026-05-12
blocker: "PR #7474 must merge first; first jsonpath skill must exist to test against"
dependency: "cli-anything-biddeed#7474, autoloop-v2-jsonpath-whitelist-registry"
estimated_minutes: 120
tags: [autoloop-v2, l3, analyzer, routing, evolver]
---

## What

After L3 Post-Execution Analyzer (`scripts/l3_analyze.py`, already in repo since 2026-03-29) emits a `skill_analyses` row with `evolution_type` in `{fix, derived, captured}`, route the suggestion to the correct evolver:

- `target_skill` has `config_format='markdown'` (or unset) → `Evolver.generate()` → `EvolutionEntry` list → `skill_evolution_entries`
- `target_skill` has `config_format='jsonpath'` → `JsonPathEvolver.generate()` → `JsonPathEntry` list → `skill_evolution_jsonpath_entries`

Routing source of truth: a new `skill_lineage.config_format` column (or sidecar metadata file `.claude/skills/{skill}/skill.meta.json`).

## Why

L3 analyzer (specced 2026-03-29, migration applied 2026-05-12 this session) emits structured suggestions but has no downstream routing. Without this routing layer:

- Markdown skills get analyzer suggestions → routed to existing evolver.py → works
- Jsonpath skills get analyzer suggestions → no route → suggestions lost

The two evolvers (markdown + jsonpath) coexist but the routing logic to pick between them per skill doesn't exist yet.

## Why deferred (not done in this session)

Three reasons:

1. **No jsonpath skills exist yet.** Routing logic that always picks markdown is the same as no routing. First real jsonpath target needs to land first (depends on whitelist-registry deferral).
2. **The schema needs an additive column.** `skill_lineage.config_format text default 'markdown'` is a small migration but warrants explicit approval (per Everest rule on schema changes).
3. **Best engineered after first L3 analyzer run produces real data.** Routing on speculation invites hallucinated edge cases.

## Resume conditions

When resuming:
1. Verify at least 1 nightly L3 analyzer run completed (rows in `skill_analyses`)
2. Verify at least 1 jsonpath skill has a WhitelistConfig in the registry (per `autoloop-v2-jsonpath-whitelist-registry` deferral)
3. Add migration: `ALTER TABLE skill_lineage ADD COLUMN config_format TEXT NOT NULL DEFAULT 'markdown' CHECK (config_format IN ('markdown','jsonpath'))`
4. Update 5 seeded rows (zonewise-scraper, cost-discipline, honesty-protocol, brand-colors, ship-gate) — all should be `markdown`
5. Add the first `jsonpath` row (e.g., sentinel-thresholds) when its skill lands
6. Modify `scripts/l3_analyze.py` to read `config_format` and dispatch:
   ```python
   if lineage.config_format == 'jsonpath':
       entries = JsonPathEvolver(...).generate(signals, config=load_json(...), whitelist=REGISTRY[skill_name])
       persist_to(skill_evolution_jsonpath_entries, entries)
   else:
       entries = Evolver(...).generate(signals, skill_md_path=...)
       persist_to(skill_evolution_entries, entries)
   ```
7. Unit test the routing decision in isolation (mock both evolvers, verify correct one is called per config_format)

## Done when

- `skill_lineage.config_format` column exists with CHECK constraint
- `scripts/l3_analyze.py` routes correctly per column value
- Unit test in `evolution/tests/test_l3_routing.py` covers both branches with mocked evolvers
- One real jsonpath skill flows end-to-end: signal detected → analyzer → router → JsonPathEvolver → JsonPathPatcher → applied
- `skill_analyses` rows correctly tag their routing decision in `analyzed_by` (e.g., `gemini-flash+jsonpath_route`)

## Cross-references

- L3 spec: `specs/AUTOLOOP-L3-SPEC.md`
- L3 migration applied this session: `autoloop_l3_20260329`
- Analyzer script: `scripts/l3_analyze.py` (in repo since 2026-03-29)
- Routing target evolvers: `evolution/evolver.py` (existing) + `evolution/evolver_jsonpath.py` (PR #7474)
