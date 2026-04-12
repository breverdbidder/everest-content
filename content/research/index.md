---
layout: dono-v5
title: "Research Intake"
dek: "Transcripts, repos, articles, and threads evaluated against the Everest stack. Each one gets a verdict — ADOPT, CONFIRM, DELTA, or REJECT — with concrete deltas, not vibes."
permalink: /research/
eleventyExcludeFromCollections: true
---

## Latest intake

{% for entry in collections.research %}
- **[{{ entry.data.title }}]({{ entry.url }})** — *{{ entry.data.date | readableDate }}* · **{{ entry.data.verdict }}** {% if entry.data.repoeval_score %}· REPOEVAL {{ entry.data.repoeval_score }}{% endif %}
  {% if entry.data.dek %}{{ entry.data.dek | truncate(200) }}{% endif %}
{% endfor %}

## How the funnel works

1. **Ingest** — drop a URL: transcript, repo, article, or thread. Auto-routed to the right subtree.
2. **Extract** — Supadata for video. REPOEVAL for code. Structured insights pulled under HONESTY PROTOCOL.
3. **Verdict** — ADOPT / CONFIRM / DELTA / REJECT against the current Everest stack. No vibes, only deltas.
4. **Cross-pollinate** — deltas ship as SUMMIT tasks. Confirmations get logged. Rejections archived with reason.

Content lives as markdown in `content/research/` and is rendered to HTML by Eleventy using the canonical `dono-v5` layout, which reads all brand tokens from [`/design.md`](/design.md).
