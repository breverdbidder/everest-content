---
layout: deferral
title: "agentic-video-maker activation: ElevenLabs + fal.ai + VOICE_ID HITL gates"
slug: agentic-video-maker-activation-hitl
priority: P3
status: blocked
owner: ariel
created: 2026-05-12
blocker: "Requires Ariel: account creation + 2FA + $5-10 starter credit + key paste"
dependency: null
estimated_minutes: 10
tags: [video-maker, hitl, vault, gtm, deferred-hitl]
---

## What

The `breverdbidder/agentic-video-maker` fork is fully lifted and CI-green, but cannot generate a real video until 3 secrets are populated:

```yaml
required_vault_entries:
  - name: elevenlabs_api_key
    cost: Free tier OK for testing; Creator $22/mo for Music API + commercial use
    where: https://elevenlabs.io → Profile → API Keys
  - name: fal_api_key
    cost: pay-as-you-go; ~$5-10 starter credit covers ~10 cheap or ~3 premium runs
    where: https://fal.ai → Dashboard → API Keys
  - name: elevenlabs_voice_id_default
    cost: free (browse + copy)
    where: https://elevenlabs.io/app/voice-library — pick multilingual voice for Hebrew
```

Then mirror vault → GHA secrets:

```bash
gh secret set GEMINI_API_KEY      -R breverdbidder/agentic-video-maker -b "$GEMINI"
gh secret set ELEVENLABS_API_KEY  -R breverdbidder/agentic-video-maker -b "$ELEVEN"
gh secret set FAL_KEY             -R breverdbidder/agentic-video-maker -b "$FAL"
gh secret set VOICE_ID            -R breverdbidder/agentic-video-maker -b "$VOICE"
```

## Why

Per Everest rules:
- "ALWAYS Ask Permission For: New third-party service integrations (first time only)"
- "ALWAYS Ask Permission For: Spend >$10"

ElevenLabs and fal.ai are both first-time integrations + require billing setup. Cannot be agent-delegated. Account creation involves 2FA + email verification, which only Ariel can complete.

## Why deferred (not done in this session)

The original ask was a REPOEVAL + lift, both of which are complete. Activation is a separate Ariel-blocking concern that surfaced AS A FINDING during the lift, not as part of the lift itself.

## Why this is P3, not P1

Strategic fit (per session REPOEVAL): video GTM is **off-thesis** for BidDeed/ZoneWise through Sprint 1 + Futures cycle (end Aug 2026). Tip of spear is zonewise.ai choropleth + Stripe lead magnet. Video tooling is a nice-to-have for marketing content later, not a critical path.

Cost forecast if activated:
```yaml
expected_volume:
  smoke_tests: 2-3 runs (~$3 total)
  production_runs: 4-8/mo, mostly medium tier (~$2.50 avg)
  monthly_estimate: $20-30/mo
```

Within $100/mo API budget per Everest cost-discipline rule.

## Resume conditions (when Ariel decides to activate)

1. Sign up ElevenLabs + fal.ai (5min total)
2. Run the 4 `gh secret set` commands above
3. Smoke test:
   ```bash
   gh workflow run "Everest Video Dispatch" \
     -R breverdbidder/agentic-video-maker \
     -f brief="5-second test card with HELLO on black background" \
     -f length=5 -f quality=cheap -f max_cost=1
   ```
4. Verify mp4 artifact uploaded
5. Update this deferral status to `verified`

## Done when

- All 3 vault entries populated
- All 4 GHA secrets set
- Smoke test produces valid mp4 artifact under $1 cost
- One real GTM use case identified (ZoneWise zoning explainer? BidDeed market report?) and produced
- Hebrew voice quality clears subjective bar OR strategic decision to stick to English-only

## Cross-references

- Fork: https://github.com/breverdbidder/agentic-video-maker
- Integration guide: `breverdbidder/agentic-video-maker/EVEREST_INTEGRATION.md`
- HITL gates table: `breverdbidder/agentic-video-maker/CLAUDE.md`
- REPOEVAL row: `extrep_evaluations` id 6d403944-9c6a-4cb3-8392-3a6a33f8cf61
- Existing vault entry: `gemini_api_key` (already present, length 39)
