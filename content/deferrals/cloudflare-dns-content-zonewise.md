---
layout: deferral
title: "Point Cloudflare DNS at GitHub Pages"
priority: P2
status: pending
owner: ariel
created: 2026-04-12
blocker: "Browser-only dashboard action (Cloudflare DNS) — legit HITL escalation per Rule #1"
dependency: null
estimated_minutes: 2
tags: [infra, dns, content-engine]
---

## What

Add a CNAME record in the `zonewise.ai` Cloudflare zone:

```
Type:    CNAME
Name:    content
Target:  breverdbidder.github.io
Proxy:   DNS only (grey cloud)
TTL:     Auto
```

## Why

The `CNAME` file is already committed in `everest-content` pointing at `content.zonewise.ai`, and GitHub Pages is serving the site at `https://breverdbidder.github.io/everest-content/`. Once Cloudflare DNS resolves, GitHub Pages will automatically provision the SSL cert and serve at `https://content.zonewise.ai/`.

## Why this is on Ariel, not Claude

Cloudflare DNS edits require dashboard auth (not API-token-addressable from the Hetzner runner). This is one of the three legit escalation cases per Rule #1: OAuth browser flow.

**Alternative path if you want me to handle it:** give me the `CF_API_TOKEN` with DNS:Edit scope on zonewise.ai and I'll push the record via the Cloudflare API. Current `CF_API_TOKEN` in `cli-anything-biddeed` secrets may already have that scope — needs verification.

## Done when

`curl -I https://content.zonewise.ai/` returns `200` with GitHub Pages headers.
