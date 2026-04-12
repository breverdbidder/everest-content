---
layout: dono-v5
title: "Ship Status"
dek: "Live dashboard of what shipped, what's in flight, and what's deferred across the Everest ecosystem. Auto-refreshed every 30 minutes via GitHub Actions."
permalink: /ship/
eleventyExcludeFromCollections: true
---

<div style="padding: 14px 20px; background: var(--bg-card); border: 1px solid var(--border); border-radius: 6px; margin-bottom: 32px; font-family: 'JetBrains Mono', monospace; font-size: 12px; color: var(--text-dim);">
  Generated: <code>{{ ship.generated_at }}</code> · Refreshes on every Pages build + every 30 min via scheduled workflow · Auth: ambient <code>GITHUB_TOKEN</code>
</div>

## Live services

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 12px; margin-bottom: 40px;">
{% for u in ship.live_urls %}
  <a href="{{ u.url }}" target="_blank" rel="noopener" style="display:block; padding: 16px; background: var(--bg-card); border: 1px solid var(--border); border-left: 3px solid var(--green); border-radius: 6px; text-decoration: none;">
    <div style="font-size: 11px; color: var(--text-faint); text-transform: uppercase; letter-spacing: 0.1em; font-family: 'JetBrains Mono', monospace; margin-bottom: 4px;">LIVE</div>
    <div style="font-size: 14px; font-weight: 600; color: var(--text); margin-bottom: 4px;">{{ u.label }}</div>
    <div style="font-size: 12px; color: var(--text-dim); word-break: break-all;">{{ u.url }}</div>
  </a>
{% endfor %}
</div>

## SUMMIT dispatches in flight

{% if ship.summit_runs.length > 0 %}
<table>
  <thead>
    <tr><th>Run</th><th>Status</th><th>Conclusion</th><th>Event</th><th>When</th><th>Link</th></tr>
  </thead>
  <tbody>
  {% for run in ship.summit_runs %}
    <tr>
      <td><code>#{{ run.run_number }}</code></td>
      <td>
        {% if run.status == "in_progress" %}<span style="color: var(--orange);">● in_progress</span>
        {% elif run.status == "queued" %}<span style="color: var(--yellow);">● queued</span>
        {% elif run.status == "completed" and run.conclusion == "success" %}<span style="color: var(--green);">● completed</span>
        {% elif run.status == "completed" and run.conclusion == "failure" %}<span style="color: var(--red);">● failed</span>
        {% else %}<span style="color: var(--text-dim);">● {{ run.status }}</span>
        {% endif %}
      </td>
      <td>{{ run.conclusion or "—" }}</td>
      <td>{{ run.event }}</td>
      <td><code>{{ run.created_at | isoDate }}</code></td>
      <td><a href="{{ run.url }}" target="_blank">view →</a></td>
    </tr>
  {% endfor %}
  </tbody>
</table>
{% else %}
<p><em>No recent SUMMIT runs found (GitHub API may be rate-limited during build).</em></p>
{% endif %}

## Open SUMMIT issues

{% if ship.open_summits.length > 0 %}
<ul>
{% for s in ship.open_summits %}
  <li><strong>#{{ s.number }}</strong> — <a href="{{ s.url }}" target="_blank">{{ s.title }}</a>
    <br><span style="font-size: 11px; color: var(--text-faint); font-family: 'JetBrains Mono', monospace;">
    {% for l in s.labels %}{{ l }} · {% endfor %}created {{ s.created_at | isoDate }}
    </span>
  </li>
{% endfor %}
</ul>
{% else %}
<p><em>No open SUMMIT-labeled issues.</em></p>
{% endif %}

## Deferred work

Items that were deferred during Claude sessions and are tracked here instead of disappearing into chat history. Every deferral is a markdown file under `content/deferrals/` — add, update, or resolve by committing a change.

{% if collections.deferrals %}
<table>
  <thead>
    <tr><th>Priority</th><th>Status</th><th>Title</th><th>Blocker</th><th>~Time</th></tr>
  </thead>
  <tbody>
  {% for d in collections.deferrals %}
    <tr>
      <td><code>{{ d.data.priority }}</code></td>
      <td>
        {% if d.data.status == "done" %}<span style="color: var(--green);">● done</span>
        {% elif d.data.status == "blocked" %}<span style="color: var(--yellow);">● blocked</span>
        {% elif d.data.status == "in-progress" %}<span style="color: var(--orange);">● in-progress</span>
        {% else %}<span style="color: var(--text-dim);">● {{ d.data.status }}</span>
        {% endif %}
      </td>
      <td><a href="{{ d.url }}">{{ d.data.title }}</a></td>
      <td style="font-size: 12px; color: var(--text-dim);">{{ d.data.blocker or d.data.dependency or "—" }}</td>
      <td>{{ d.data.estimated_minutes or "?" }}min</td>
    </tr>
  {% endfor %}
  </tbody>
</table>
{% endif %}

## Recent activity (cross-repo commit stream)

Last 30 commits across all Everest repos, sorted by timestamp.

{% if ship.recent_commits.length > 0 %}
<table>
  <thead>
    <tr><th>When</th><th>Repo</th><th>Message</th><th>Commit</th></tr>
  </thead>
  <tbody>
  {% for c in ship.recent_commits %}
    <tr>
      <td style="white-space: nowrap; font-size: 12px;"><code>{{ c.date | isoDate }}</code></td>
      <td><code>{{ c.repo }}</code></td>
      <td style="font-size: 13px;">{{ c.message }}</td>
      <td><a href="{{ c.url }}" target="_blank"><code>{{ c.sha }}</code></a></td>
    </tr>
  {% endfor %}
  </tbody>
</table>
{% else %}
<p><em>No recent commits (GitHub API rate limit during build — will populate on next refresh).</em></p>
{% endif %}

## How this page works

This dashboard is generated by Eleventy at build time from two sources:

1. **GitHub REST API** — commits, workflow runs, and open issues are fetched via `_data/ship.js` using the ambient `GITHUB_TOKEN` provided by GitHub Actions during the Pages build. Zero secrets required.
2. **Local deferrals** — the `## Deferred work` table reads from `content/deferrals/*.md` via an Eleventy collection. Adding a deferral = committing a markdown file with a YAML frontmatter block.

The page auto-refreshes via a scheduled workflow (`.github/workflows/refresh-ship.yml`) that re-triggers the build every 30 minutes, plus on every push to any content path.

**To add a deferral from a Claude session:** create a new markdown file under `content/deferrals/` with frontmatter (`priority`, `status`, `owner`, `blocker`, `dependency`, `estimated_minutes`) and commit. The file is the source of truth. No Supabase, no Nexus task ledger — just Git.

**To mark one done:** edit the frontmatter `status: done` and commit. The dashboard reflects it on next rebuild.

**Why this over Telegram/email:** zero push notification load. You pull when you want to check. Full audit trail in `git log`. Any Claude instance in any future session can read + append by cloning the repo.
