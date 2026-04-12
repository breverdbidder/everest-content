---
layout: dono-v5
title: "Everest Content Engine"
dek: "The canonical content source for Everest Capital USA. Markdown in, multi-format out: HTML, PDF, video, social cuts. One source of truth, every format rendered."
permalink: /
eleventyExcludeFromCollections: true
---

## What this is

`everest-content` is the **single source of truth** for every piece of content Everest Capital produces — research intake, customer reports, investor deliverables, marketing pages, battle cards. Each piece lives as a markdown file with YAML frontmatter. On push, Eleventy renders it to HTML. GitHub Actions can render it to PDF via Playwright. Future pipelines (`everest-cinematic`) render it to video via Veo 3.

## Architecture

- **Content source:** `content/` — all markdown lives here
- **Design tokens:** [`design.md`](/design.md) — Stitch schema, navy + orange house brand
- **Layouts:** `_layouts/` — the canonical `dono-v5.njk` wrapper reads tokens from `design.md`
- **Output:** `_site/` — built by Eleventy, served by GitHub Pages at `content.zonewise.ai`

## Content types

- **[Research intake](/research/)** — transcripts, repos, articles evaluated against the Everest stack
- **Customer reports** — (coming) per-customer deliverables with tracking + PDF export
- **Investor materials** — (coming) battle cards, decks, one-pagers
- **Marketing** — (coming) landing page content pulled into zonewise-web at build time

## Related repos

- `breverdbidder/everest-media-gateway` — Gemini API abstraction (Veo 3, Nano Banana Pro, Imagen 4, TTS)
- `breverdbidder/everest-cinematic` — agentic video production pipeline
- `breverdbidder/everest-battle-cards` — competitive intel repo, will migrate here over time
