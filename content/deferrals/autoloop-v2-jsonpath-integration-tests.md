---
layout: deferral
title: "Integration tests for JsonPathEvolver against real DeepSeek / Claude APIs"
slug: autoloop-v2-jsonpath-integration-tests
priority: P2
status: pending
owner: claude
created: 2026-05-12
blocker: null
dependency: "cli-anything-biddeed#7474"
estimated_minutes: 60
tags: [autoloop-v2, jsonpath, testing, integration]
---

## What

Currently `evolution/tests/test_evolver_jsonpath.py` mocks every `httpx.post` call. That covers parsing, fallback logic, and the prompt-rendering contract — but doesn't prove:

1. DeepSeek V3.2 actually produces well-formed `{entries: [{field, new_value}]}` output for the new prompt
2. Claude Sonnet fallback path actually returns valid JSON when DeepSeek empty
3. The whitelist-aware prompt actually constrains the LLM (i.e., LLM doesn't suggest paths outside whitelist)
4. Cost tracking matches actual billed amounts within ±10%

Build a `evolution/tests/test_evolver_jsonpath_integration.py` (excluded from default pytest run via marker) that hits the real APIs:

```python
@pytest.mark.integration
@pytest.mark.skipif(not os.getenv("DEEPSEEK_API_KEY"), reason="needs real API key")
def test_real_deepseek_produces_whitelist_compliant_output():
    ...
```

Run via: `pytest -m integration evolution/tests/test_evolver_jsonpath_integration.py`

## Why

Mocked unit tests prove the code parses correctly — they don't prove the LLM follows the prompt. Three real-world failure modes the unit tests miss:

1. **Schema drift**: LLM might emit `{section, content}` (markdown shape) instead of `{field, new_value}` because that's what evolver.py uses and the LLM saw similar patterns in training data
2. **Whitelist ignoring**: LLM might suggest patches outside the whitelist (the patcher rejects them, but it's wasted tokens)
3. **Cost surprise**: DeepSeek V3.2 cost coefficient (`$0.28/1M`) may be stale — actual billed amount could be higher

## Why deferred (not done in this session)

Real API calls in tests cost money and require keys. Per Everest rules:
- `DEEPSEEK_API_KEY` is not yet in vault (no current usage outside this PR)
- `ANTHROPIC_API_KEY` could be used but each Sonnet call is ~$0.001 — adds up if tests run on every CI push
- Better: gate integration tests behind explicit local invocation; never run in CI

## Resume conditions

When resuming:
1. Verify `DEEPSEEK_API_KEY` exists in vault (or `ANTHROPIC_API_KEY` for Claude-only path)
2. Write 3 integration tests:
   - `test_real_deepseek_produces_whitelist_compliant_output` (1 call, ~$0.0003)
   - `test_real_claude_fallback_when_deepseek_empty` (force empty via degenerate prompt; ~$0.001)
   - `test_real_cost_tracking_within_10pct_of_billed` (measure 5 calls, compare to provider dashboard)
3. Add `pytest.ini` marker `integration` and document `pytest -m integration` in `docs/EVOLVER-JSONPATH.md`
4. NEVER run in default CI — gate behind manual workflow_dispatch only
5. Budget cap: integration test run total cost < $0.05/invocation

## Done when

- 3 integration tests exist behind `@pytest.mark.integration`
- Tests pass against real APIs at least once with documented cost
- `docs/EVOLVER-JSONPATH.md` documents the integration-test workflow
- A row in `extrep_evaluations.delivery_proof.integration_tests_run` records the first successful run

## Cross-references

- Unit tests (mocked, ship with PR): `evolution/tests/test_evolver_jsonpath.py`
- LLM providers being tested: DeepSeek V3.2 ($0.28/1M), Anthropic Sonnet 4.6 ($3 in / $15 out per 1M)
- Cost ceiling per Everest rule: $10/task (these tests are far under)
