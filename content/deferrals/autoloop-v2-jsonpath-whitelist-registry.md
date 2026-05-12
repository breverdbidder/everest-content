---
layout: deferral
title: "Per-target WhitelistConfig registry under evolution/whitelists/"
slug: autoloop-v2-jsonpath-whitelist-registry
priority: P2
status: pending
owner: claude
created: 2026-05-12
blocker: "Needs first real consumer to make sensible whitelist decisions"
dependency: "cli-anything-biddeed#7473, autoloop-v2-jsonpath-autoloop-yml-wiring"
estimated_minutes: 90
tags: [autoloop-v2, jsonpath, whitelist, registry, defense-in-depth]
---

## What

Create `evolution/whitelists/` package with one `WhitelistConfig` per autoloop-managed structured-config target. Each whitelist declares:

- Which dotted paths are patchable (regex)
- Type expectations (int / float / bool / string / enum)
- Numeric bounds (min, max)
- Enum allowed values
- `auto_create_roots` (top-level keys that materialize on demand)

Example structure:

```
evolution/whitelists/
├── __init__.py              # registry: NAME → WhitelistConfig
├── sentinel_thresholds.py   # first target (smallest blast radius)
├── shapira_weights.py
├── zonewise_county_config.py
├── llm_router_rules.py
└── marketing_os_tenants.py
```

Each module exposes a module-level `WHITELIST: WhitelistConfig`. The `__init__.py` collects them into a `REGISTRY: dict[str, WhitelistConfig]` indexed by `target` name.

## Why

The patcher (#7473) and evolver (#7474) are generic. Both ship with permissive defaults for drop-in patch-plan.cjs compatibility, but production use needs target-specific whitelists or the LLM can patch anything that parses.

Defense in depth has TWO layers:
1. The LLM sees the whitelist in its prompt (declarative — best effort)
2. The patcher enforces it at apply time (mandatory — guaranteed)

Both need the same WhitelistConfig instance. A registry makes that single source of truth easy to share.

## Why deferred

Building a whitelist registry without a first real consumer is speculative. Each target has domain-specific bounds (what's a reasonable `alert_threshold` for Sentinel? what's a reasonable `xgboost_lr` for Shapira?). Picking those numbers without evidence is hallucination.

Better: land the capability empty, observe the first 2 weeks of L3 analyzer suggestions, THEN write whitelists with evidence of what the LLM actually tries to patch.

## Resume conditions

When resuming:
1. Pick FIRST target (recommend Sentinel thresholds — already proposed in test fixtures)
2. Read the current config file's schema; document every field
3. Decide which fields are "tunable" (numeric thresholds, weights, sample rates) vs "structural" (table names, foreign keys)
4. Write `evolution/whitelists/sentinel_thresholds.py` with regex + bounds for tunable fields only
5. Add module-level imports to `evolution/whitelists/__init__.py` registry dict
6. Wire `autoloop.yml` to look up `REGISTRY[target_name]` before calling `JsonPathEvolver`
7. Repeat for each subsequent target as it comes online

## Done when

- At least 1 target's WhitelistConfig is in production use
- Registry `REGISTRY: dict[str, WhitelistConfig]` is the single source of truth (no inline whitelists in autoloop.yml)
- A `skip_reason="path not whitelisted"` count in `skill_evolution_jsonpath_entries` is non-zero (proves the whitelist is actually rejecting things, not just rubber-stamping)
- Documentation in `docs/EVOLVER-JSONPATH.md` updated with the registry pattern

## Cross-references

- Pattern source: `WhitelistConfig` class in `evolution/jsonpath_schema.py` (PR #7473)
- Example whitelist: see `evolution/tests/test_jsonpath_patcher.py::TestSentinelThresholdsUseCase` for a working Sentinel example
