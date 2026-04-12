---
layout: deferral
title: "PostHog drop-in for Dono v5 layout — per-page behavior tracking"
priority: P2
status: pending
owner: claude
created: 2026-04-12
blocker: null
dependency: "Decision on PostHog project split: internal vs customer-deliverables"
estimated_minutes: 60
tags: [content-engine, analytics, behavior]
---

## What

Add PostHog snippet to `_layouts/dono-v5.njk` behind a frontmatter toggle:

```yaml
# In any content markdown frontmatter:
tracking: true         # default: false
tracking_project: "customer-deliverables"  # or "internal-research"
```

The layout reads the toggle and, if `true`, injects the PostHog snippet with the right project key. Events written to PostHog, then mirrored to Supabase `content_events` table via the existing Supabase CLI pattern (Rule #27: data sovereignty).

## Why

Right now every page on `content.zonewise.ai` is a black hole. We have no idea which research entries are read, how far readers scroll, or which customer reports get forwarded. The Karpathy entry could have 50 reads or 0 — identical signal.

This is the prerequisite for the entire behavior-loop conversation from earlier tonight. Without PostHog in the layout, "readers/scanners/forwarders" segmentation is a hypothesis we can't measure.

## Decision needed before execution

**Two PostHog projects or one?**

- **Two projects** — `everest-internal` for research/admin content, `everest-customer` for customer-facing reports. Clean separation, lets us apply different consent/privacy rules per project. More setup time.
- **One project** — single source, tag events with `content_type` property, filter downstream. Faster setup, but mixes signal types.

Recommendation: **Two projects.** Internal research has no consent obligations (it's our own content we read). Customer reports eventually need consent banners and GDPR-safe routing. Mixing them creates a migration headache later.

## Implementation steps (post-decision)

1. Create two PostHog projects (or verify existing)
2. Add project keys as secrets: `POSTHOG_KEY_INTERNAL`, `POSTHOG_KEY_CUSTOMER`
3. Add `{% if page.tracking %}...{% endif %}` block to `_layouts/dono-v5.njk`
4. Update `design.md` with a new section `analytics:` describing the tracking conventions
5. Test: browse to one page, verify event appears in PostHog within 60 seconds
6. Add nightly cron SUMMIT that syncs `content_events` from PostHog → Supabase

## Done when

- Toggle works (tracking: true enables, tracking: false disables)
- Events reach PostHog
- Nightly sync writes to Supabase `content_events` table
- First 24 hours of data shows at least one complete session

## Scope guardrails

- NOT in scope: server-side analytics (Plausible, etc.)
- NOT in scope: A/B testing infrastructure
- NOT in scope: email open tracking (separate system)
