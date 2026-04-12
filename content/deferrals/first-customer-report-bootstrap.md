---
layout: deferral
title: "First customer-report content type — bootstrap the deliverables path"
priority: P2
status: blocked
owner: claude
created: 2026-04-12
blocker: "Blocked on SUMMIT #464 (media gateway) + SUMMIT #466 (cinematic skeleton)"
dependency: "cli-anything-biddeed#464,cli-anything-biddeed#466"
estimated_minutes: 90
tags: [content-engine, reports, customer-deliverables, tracking]
---

## What

Create `everest-content/content/reports/` content type with:

1. Frontmatter schema (customer_id, report_type, subject, expires_at, access_token, generate_video, tracking)
2. A `reports-layout.njk` layout that differs from `dono-v5` only in access-gate logic
3. A token-based routing mechanism: `/reports/{token}/` returns the report, expired tokens return 404
4. The first real customer report, using a live deal from the pipeline

## Why

This is the highest-ROI content type on the whole roadmap per earlier conversation tonight:

> "When a customer opens their report and reads the 'recommended offer' section for 4 minutes, that's a closing signal. That's not true for any of the other three content types. And it doesn't need SEO, doesn't need consent banners (private link), doesn't fight with zonewise-web."

This deferral is where the business value of the whole content engine is validated.

## Why it's blocked

Two dependencies must land first:

- **SUMMIT #464** — everest-media-gateway needs to be callable so the report can auto-generate hero images per section
- **SUMMIT #466** — everest-cinematic skeleton needs stage skills so the `generate_video: true` frontmatter flag actually triggers a video render

Without both, we ship a tracked-but-static report. Acceptable for v1, but the goal is full multi-format (HTML + PDF + video) from one markdown file.

## Implementation plan (post-unblock)

1. Create `content/reports/_schema.yaml` defining frontmatter contract
2. Create `_layouts/reports-layout.njk` with access-gate logic
3. Add `_data/reports.js` that generates unique slugs at build time
4. Pick one live deal from the BidDeed pipeline (needs Ariel input on which)
5. Generate the first report markdown by hand
6. Ship it to a real customer
7. Watch PostHog for the first session (assuming deferral #4 lands first)

## Done when

- First customer report ships to a real customer
- The customer opens it at least once
- Telemetry data lands in `content_events` table
- The 9 AM digest tomorrow shows first view + duration

## Scope guardrails (K2)

- NOT in scope: multi-customer at once
- NOT in scope: report template library
- NOT in scope: payment integration
- NOT in scope: e-signature
- ONE report to ONE real customer first. Iterate from there.
