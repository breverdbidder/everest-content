---
layout: deferral
title: "OG image generation SUMMIT — Nano Banana Pro per-page social cards"
priority: P2
status: blocked
owner: claude
created: 2026-04-12
blocker: "Blocked on SUMMIT #464 (everest-media-gateway first render)"
dependency: "cli-anything-biddeed#464"
estimated_minutes: 45
tags: [content-engine, media-gateway, social]
---

## What

Add `.github/workflows/og-generate.yml` to `everest-content` that:

1. On every push to `content/**`, enumerates changed markdown files
2. For each page, calls `everest-media-gateway` with a prompt derived from the page title + dek
3. Prepends the `design.md` style injection (navy + orange + Inter + dark bg)
4. Saves the 1200×630 PNG to `assets/og/{slug}.png`
5. The Dono v5 layout reads `page.og_image` frontmatter, falls back to the generated path

## Why

Right now LinkedIn / Slack / Twitter link unfurls for `content.zonewise.ai/...` URLs show a default GitHub Pages card. Every forwarded link is a lost branding moment. Nano Banana Pro generates a 1200×630 in ~4 seconds at ~$0.002/image on Gemini Business tier.

## Dependency chain

This SUMMIT is useless until **SUMMIT #464** (`everest-media-gateway` first render) successfully ships a working Nano Banana Pro API route. The deferral auto-unblocks when:

- `breverdbidder/everest-content/assets/test-generation.png` exists (proof SUMMIT A landed)
- `breverdbidder/everest-media-gateway` has a callable `/api/gemini/generate` route

The ship dashboard checks both conditions on every refresh. When both green, status flips from `blocked` → `ready-to-dispatch`.

## Done when

- `og-generate.yml` workflow exists and has run at least once successfully
- At least 3 pages have committed `assets/og/*.png` files
- Opening any content URL in LinkedIn's post composer shows the branded card

## Scope guardrails (K2 simplicity)

- NOT in scope: video OG cards (Twitter player tag)
- NOT in scope: dynamic per-viewer personalization
- NOT in scope: Figma integration
- One workflow, one model (Nano Banana Pro), one output format
