---
layout: deferral
title: "Remotion license verification — is Everest Capital free-tier eligible?"
priority: P3
status: pending
owner: claude
created: 2026-04-12
blocker: null
dependency: null
estimated_minutes: 20
tags: [cinematic, licensing, due-diligence]
---

## What

Read the Remotion LICENSE file and commercial-use policy. Determine whether Everest Capital USA, as a solo-founder entity with Ariel as the only human developer, qualifies for the free tier, or whether commercial use requires a paid company license.

## Why this matters

`everest-cinematic` (scaffolded 2026-04-12) plans two composition backends:

1. **FFmpeg** (always free, always available, baseline quality)
2. **Remotion** (React-based programmatic video, higher ceiling, license-pending)

If Remotion is free for Everest, we use it for the `customer-report` pipeline and get spring animations, text overlays, and React-composed scenes. If it requires a paid license (typical threshold: companies with >3 employees), we stay on FFmpeg-only and lose the animation quality ceiling but keep zero-cost.

## What to verify

- [ ] Fetch `https://github.com/remotion-dev/remotion/blob/main/LICENSE.md` and read in full
- [ ] Check company-size threshold (current threshold as of 2026-04: ???)
- [ ] Check revenue-based thresholds if any
- [ ] Check per-render pricing vs per-seat licensing
- [ ] Document the verdict in `everest-cinematic/LICENSING.md`
- [ ] If paid, note the cheapest tier that would cover Everest + what it unlocks

## Done when

- `everest-cinematic/LICENSING.md` exists with verdict: FREE / PAID_REQUIRED / HYBRID
- If FREE: `tools/compose_remotion.py` stub is unblocked for implementation
- If PAID: `tools/compose_remotion.py` stub is marked `WONTFIX` and FFmpeg-only path is canonical

## Fallback if unclear

If the license text is ambiguous, default to **assume paid required** (conservative per Rule #24 LICENSE DISCIPLINE). FFmpeg-only is a perfectly acceptable quality ceiling for v1.
