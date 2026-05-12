---
layout: deferral
title: "Apply skill_evolution_jsonpath_entries table migration"
slug: autoloop-v2-jsonpath-migration
priority: P1
status: pending
owner: claude
created: 2026-05-12
blocker: "PR #7473 must merge first (DDL constant ships in jsonpath_schema.py)"
dependency: "cli-anything-biddeed#7473"
estimated_minutes: 15
tags: [autoloop-v2, jsonpath, supabase, migration]
---

## What

Apply the DDL constant `SQL_SKILL_EVOLUTION_JSONPATH_ENTRIES` from `evolution/jsonpath_schema.py` (PR #7473) to production Supabase as a real migration.

The DDL is already written:

```sql
CREATE TABLE IF NOT EXISTS skill_evolution_jsonpath_entries (
    id                  UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    skill_name          TEXT NOT NULL,
    source_signal_id    UUID REFERENCES skill_evolution_signals(id),
    target              TEXT NOT NULL,
    field               TEXT NOT NULL,
    new_value           JSONB NOT NULL,
    action              TEXT NOT NULL DEFAULT 'update' CHECK (action IN ('add','update','delete','skip')),
    skip_reason         TEXT,
    merge_target        TEXT,
    applied             BOOLEAN DEFAULT FALSE,
    eval_score_before   FLOAT,
    eval_score_after    FLOAT,
    llm_model_used      TEXT,
    token_cost          FLOAT,
    fingerprint         TEXT NOT NULL,
    created_at          TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(fingerprint)
);
CREATE INDEX IF NOT EXISTS idx_jsonpath_entries_skill   ON skill_evolution_jsonpath_entries(skill_name);
CREATE INDEX IF NOT EXISTS idx_jsonpath_entries_target  ON skill_evolution_jsonpath_entries(target);
CREATE INDEX IF NOT EXISTS idx_jsonpath_entries_applied ON skill_evolution_jsonpath_entries(applied) WHERE applied = FALSE;
```

Drop into `migrations/20260513_jsonpath_entries.sql` (or next available date), then apply via `Supabase:apply_migration` tool.

## Why

`JsonPathEvolver.generate()` returns `list[JsonPathEntry]` instances. To persist these to Supabase (mirroring how `EvolutionEntry` flows to `skill_evolution_entries`), the destination table must exist.

Without this table, autoloop runs produce in-memory entries that vanish when the workflow ends.

## Why deferred (not done in this session)

Per Everest rules: "ALWAYS Ask Permission For: Schema changes to production tables." The `skill_analyses` / `skill_lineage` migration applied this session was a different case — it had been specced, approved, written 6 weeks ago, and the file existed in-repo (Ariel-approved). This new table is freshly proposed by today's session work and warrants explicit approval.

The L3 migration precedent: when Ariel explicitly approves a session's design proposal (this session: "A and B"), the migration may be applied as part of the approved work. This deferral exists because the new table emerged AFTER the original approval, as a follow-up to #7473's DDL.

## Resume conditions

When resuming:
1. Verify #7473 merged to main
2. Drop `SQL_SKILL_EVOLUTION_JSONPATH_ENTRIES` constant (from `evolution/jsonpath_schema.py`) into a real migration file
3. Apply via `Supabase:apply_migration` (project `mocerqjnksmhcjzxrewo`)
4. Verify with `SELECT count(*) FROM skill_evolution_jsonpath_entries` (expect 0)
5. Update `extrep_evaluations` row 6d403944 `delivery_proof` with migration_applied timestamp

## Done when

- Table `skill_evolution_jsonpath_entries` exists in production
- Three indexes present (skill, target, applied-partial)
- `INSERT ... ON CONFLICT (fingerprint) DO NOTHING` works (idempotent writes)
- `JsonPathEvolver.generate()` outputs round-trip cleanly to the table via service.py / store.py once wired

## Cross-references

- PR with DDL ready: cli-anything-biddeed#7473
- Existing pattern: `migrations/20260329_autoloop_l3.sql` (applied this session)
- Foreign key target: `skill_evolution_signals(id)` — verify this table exists before applying
