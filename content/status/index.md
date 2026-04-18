---
layout: dono-v5
title: "Autonomous Deploy Status"
dek: "Live operational status: 5-repo deploy queue, SUMMIT health, open HITL tasks, ghost-success honesty violations. Auto-refresh every 60 seconds."
permalink: /status/
eleventyExcludeFromCollections: true
---

{% raw %}
<style>
  :root {
    --dash-green: #10B981; --dash-red: #EF4444; --dash-amber: #F59E0B; --dash-violet: #8B5CF6;
    --dash-border: rgba(30,58,95,0.55); --dash-card: rgba(30,58,95,0.22); --dash-muted: #94A3B8; --dash-dim: #64748B;
  }
  .dash-refresh { font-size:12px; color:var(--dash-dim); display:flex; align-items:center; gap:6px; margin-bottom: 16px }
  .dash-pulse { width:8px; height:8px; background:var(--dash-green); border-radius:50%; animation:dash-pulse 2s infinite; display:inline-block }
  @keyframes dash-pulse { 0%,100%{opacity:1} 50%{opacity:.3} }

  .dash-kpi-row { display:grid; grid-template-columns: repeat(4, 1fr); gap:12px; margin-bottom:24px }
  .dash-kpi { background: var(--dash-card); border:1px solid var(--dash-border); border-radius:10px; padding:16px }
  .dash-kpi-label { font-size:11px; color:var(--dash-muted); text-transform:uppercase; letter-spacing:0.1em }
  .dash-kpi-value { font-size:28px; font-weight:700; margin-top:6px; letter-spacing:-0.02em }
  .dash-kpi-delta { font-size:11px; color:var(--dash-dim); margin-top:2px }

  .dash-grid { display:grid; grid-template-columns: repeat(auto-fit, minmax(340px, 1fr)); gap:20px; margin-bottom:24px }
  .dash-panel {
    background: linear-gradient(180deg, rgba(30,58,95,0.28) 0%, rgba(30,58,95,0.08) 100%);
    border:1px solid var(--dash-border); border-radius:12px; padding:20px 22px;
    min-height: 120px;
  }
  .dash-panel-title { font-size:11px; font-weight:600; color:var(--dash-muted); text-transform:uppercase; letter-spacing:0.12em; margin-bottom:14px; display:flex; justify-content:space-between; align-items:center }
  .dash-panel-count { font-size:10px; background:#1E3A5F; color:#F1F5F9; padding:2px 8px; border-radius:999px; letter-spacing:0.02em }

  .dash-table { width:100%; border-collapse:collapse; font-size:13px }
  .dash-table th { text-align:left; font-weight:500; color:var(--dash-dim); font-size:11px; text-transform:uppercase; letter-spacing:0.08em; padding:6px 10px 10px; border-bottom:1px solid var(--dash-border) }
  .dash-table td { padding:10px; border-bottom:1px solid rgba(30,58,95,0.2); vertical-align:top }
  .dash-table tr:last-child td { border-bottom:none }
  .dash-repo-slug { font-weight:600 }
  .dash-repo-meta { font-size:11px; color:var(--dash-muted); margin-top:2px }
  .dash-kind-badge { display:inline-block; font-size:10px; padding:2px 7px; border-radius:4px; background:rgba(139,92,246,0.2); color:var(--dash-violet); text-transform:uppercase; letter-spacing:0.04em; font-weight:600 }
  .dash-score-cell { font-variant-numeric: tabular-nums; font-weight:600 }
  .dash-score-high { color:var(--dash-green) } .dash-score-mid { color:var(--dash-amber) } .dash-score-low { color:var(--dash-red) }

  .dash-pill { display:inline-block; font-size:10px; padding:3px 10px; border-radius:999px; font-weight:700; letter-spacing:0.04em; text-transform:uppercase }
  .dash-pill-verified { background:var(--dash-green); color:#020617 }
  .dash-pill-queued   { background:var(--dash-amber); color:#020617 }
  .dash-pill-running  { background:var(--dash-violet); color:#020617 }
  .dash-pill-failed   { background:var(--dash-red); color:#020617 }
  .dash-pill-closed   { background:rgba(148,163,184,0.3); border:1px solid var(--dash-border) }

  .dash-task-row { padding:12px 0; border-bottom:1px solid rgba(30,58,95,0.2); display:flex; gap:14px; align-items:flex-start }
  .dash-task-row:last-child { border-bottom:none }
  .dash-task-id { font-size:10px; font-weight:700; color:#F59E0B; background:rgba(245,158,11,0.1); padding:3px 7px; border-radius:4px; letter-spacing:0.04em; flex-shrink:0; font-family: ui-monospace,monospace }
  .dash-task-title { font-weight:600; font-size:14px }
  .dash-task-desc { font-size:12px; color:var(--dash-muted); margin-top:3px; line-height:1.5 }
  .dash-task-meta { font-size:11px; color:var(--dash-dim); margin-top:6px; display:flex; gap:14px; flex-wrap:wrap }
  .dash-task-meta a { color:#F59E0B; text-decoration:none }
  .dash-task-meta a:hover { text-decoration:underline }

  .dash-loading { color:var(--dash-dim); padding:24px; text-align:center; font-size:13px }
  @media (max-width:780px) { .dash-kpi-row { grid-template-columns: repeat(2,1fr) } }
</style>

<div class="dash-refresh"><span class="dash-pulse"></span><span id="dash-last-refresh">loading…</span></div>

<div class="dash-kpi-row">
  <div class="dash-kpi"><div class="dash-kpi-label">Open HITL</div><div class="dash-kpi-value" id="kpi-hitl">—</div><div class="dash-kpi-delta" id="kpi-hitl-delta">tasks pending</div></div>
  <div class="dash-kpi"><div class="dash-kpi-label">5-Repo verified</div><div class="dash-kpi-value" id="kpi-deploys">—</div><div class="dash-kpi-delta">of 5</div></div>
  <div class="dash-kpi"><div class="dash-kpi-label">Open SUMMITs</div><div class="dash-kpi-value" id="kpi-summits">—</div><div class="dash-kpi-delta">queued/running</div></div>
  <div class="dash-kpi"><div class="dash-kpi-label">Violations 24h</div><div class="dash-kpi-value" id="kpi-violations">—</div><div class="dash-kpi-delta" id="kpi-violations-delta">ghost-success blocks</div></div>
</div>

<div class="dash-grid">
  <div class="dash-panel" style="grid-column:1/-1">
    <div class="dash-panel-title">5-Repo Deploy Queue <span class="dash-panel-count" id="cnt-deploys">—</span></div>
    <table class="dash-table">
      <thead><tr><th>Repo</th><th>RepoEval</th><th>State</th><th>EG14</th><th>Note</th></tr></thead>
      <tbody id="deploys-body"><tr><td colspan="5" class="dash-loading">loading…</td></tr></tbody>
    </table>
  </div>

  <div class="dash-panel" style="grid-column:1/-1">
    <div class="dash-panel-title">Open HITL Tasks <span class="dash-panel-count" id="cnt-hitl">—</span></div>
    <div id="hitl-body"><div class="dash-loading">loading…</div></div>
  </div>

  <div class="dash-panel">
    <div class="dash-panel-title">SUMMITs last 7 days <span class="dash-panel-count" id="cnt-summits">—</span></div>
    <table class="dash-table">
      <thead><tr><th>Day</th><th>State</th><th>N</th><th>EG14+</th></tr></thead>
      <tbody id="summits-body"><tr><td colspan="4" class="dash-loading">loading…</td></tr></tbody>
    </table>
  </div>

  <div class="dash-panel">
    <div class="dash-panel-title">Honesty Violations — summit_dispatch <span class="dash-panel-count" id="cnt-violations">—</span></div>
    <table class="dash-table">
      <thead><tr><th>Day</th><th>Severity</th><th>Tag</th><th>N</th></tr></thead>
      <tbody id="violations-body"><tr><td colspan="4" class="dash-loading">loading…</td></tr></tbody>
    </table>
  </div>
</div>

<script>
(() => {
  const SUPABASE_URL = 'https://mocerqjnksmhcjzxrewo.supabase.co';
  const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vY2VycWpua3NtaGNqenhyZXdvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1MzI1MjYsImV4cCI6MjA4MDEwODUyNn0.rG8pHWQjAyKnJBNsVBeqJnK0mxPKqMVRVq6T9-klKQDw';
  const H = { apikey: SUPABASE_ANON_KEY, Authorization: 'Bearer ' + SUPABASE_ANON_KEY, Accept: 'application/json' };
  const fetchView = async (name, params = '') => {
    const r = await fetch(`${SUPABASE_URL}/rest/v1/${name}${params ? '?' + params : ''}`, { headers: H });
    if (!r.ok) throw new Error(`${name}: HTTP ${r.status}`);
    return r.json();
  };
  const esc = s => (s ?? '').toString().replace(/[&<>"']/g, c => ({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;' }[c]));
  const scoreClass = n => n >= 85 ? 'dash-score-high' : n >= 60 ? 'dash-score-mid' : 'dash-score-low';
  const stateClass = s => `dash-pill dash-pill-${s || 'queued'}`;

  async function render() {
    try {
      const [deploys, hitl, summits, violations] = await Promise.all([
        fetchView('v_five_repo_deploy_status'),
        fetchView('v_open_hitl_tasks'),
        fetchView('v_summit_health', 'select=day,state,n,eg14_passed&order=day.desc'),
        fetchView('v_honesty_violations_summit_daily')
      ]);

      document.getElementById('cnt-deploys').textContent = `${deploys.length} total`;
      document.getElementById('kpi-deploys').textContent = deploys.filter(r => r.state === 'verified').length;
      document.getElementById('deploys-body').innerHTML = deploys.map(r => `
        <tr>
          <td><div class="dash-repo-slug">${esc(r.repo_slug)}</div><div class="dash-repo-meta"><span class="dash-kind-badge">${esc(r.integration_kind)}</span> → ${esc(r.target_host_repo)}</div></td>
          <td class="dash-score-cell ${scoreClass(r.repoeval_score)}">${r.repoeval_score}</td>
          <td><span class="${stateClass(r.state)}">${esc(r.state)}</span></td>
          <td class="dash-score-cell">${r.eg14_score ?? '—'}</td>
          <td style="color:var(--dash-muted); font-size:12px">${esc(r.last_action_note || '')}</td>
        </tr>`).join('');

      document.getElementById('cnt-hitl').textContent = `${hitl.length} open`;
      document.getElementById('kpi-hitl').textContent = hitl.length;
      document.getElementById('kpi-hitl-delta').textContent = hitl.filter(r => r.priority === 'p0').length + ' p0 · ' + hitl.filter(r => r.priority === 'p1').length + ' p1';
      document.getElementById('hitl-body').innerHTML = hitl.map(r => `
        <div class="dash-task-row">
          <div class="dash-task-id">${esc(r.task_id)}</div>
          <div style="flex:1">
            <div class="dash-task-title">${esc(r.title)}</div>
            <div class="dash-task-desc">${esc(r.description)}</div>
            <div class="dash-task-meta"><span><span class="${stateClass(r.priority === 'p0' ? 'failed' : r.priority === 'p1' ? 'queued' : 'running')}">${esc(r.priority)}</span></span><span>~${esc(r.eta)}</span>${r.link ? `<a href="${esc(r.link)}" target="_blank" rel="noopener">open →</a>` : ''}</div>
          </div>
        </div>`).join('');

      document.getElementById('cnt-summits').textContent = `${summits.length} slices`;
      const open = summits.filter(r => ['queued','running','dispatched','issue_created'].includes(r.state)).reduce((a, r) => a + r.n, 0);
      document.getElementById('kpi-summits').textContent = open;
      document.getElementById('summits-body').innerHTML = summits.slice(0, 10).map(r => `
        <tr>
          <td style="font-variant-numeric:tabular-nums">${new Date(r.day).toLocaleDateString('en-US', { month:'short', day:'2-digit' })}</td>
          <td><span class="${stateClass(r.state)}">${esc(r.state)}</span></td>
          <td class="dash-score-cell">${r.n}</td>
          <td class="dash-score-cell">${r.eg14_passed || 0}</td>
        </tr>`).join('');

      document.getElementById('cnt-violations').textContent = `${violations.length} slices`;
      const recent = violations.filter(r => (Date.now() - new Date(r.day).getTime()) < 86400000 * 1.5).reduce((a, r) => a + r.n, 0);
      document.getElementById('kpi-violations').textContent = recent;
      document.getElementById('kpi-violations-delta').textContent = violations.reduce((a, r) => a + r.n, 0) + ' lifetime';
      document.getElementById('violations-body').innerHTML = violations.slice(0, 10).map(r => `
        <tr>
          <td style="font-variant-numeric:tabular-nums">${new Date(r.day).toLocaleDateString('en-US', { month:'short', day:'2-digit' })}</td>
          <td><span class="${stateClass(r.severity === 'CRITICAL' ? 'failed' : r.severity === 'HIGH' ? 'queued' : r.severity === 'AUDIT' ? 'closed' : 'running')}">${esc(r.severity)}</span></td>
          <td style="font-size:12px; color:var(--dash-muted)">${esc(r.tag_used)}</td>
          <td class="dash-score-cell">${r.n}</td>
        </tr>`).join('');

      document.getElementById('dash-last-refresh').textContent = `live · ${new Date().toLocaleTimeString('en-US', { hour12: false })}`;
    } catch (e) {
      document.getElementById('dash-last-refresh').textContent = `err · ${e.message}`;
    }
  }

  render();
  setInterval(render, 60000);
})();
</script>
{% endraw %}

## About this page

Pulls from 4 Supabase views via read-only `anon` role (RLS-enforced):

- **`v_five_repo_deploy_status`** — V7 autonomous 5-repo deploy queue
- **`v_open_hitl_tasks`** — tasks that genuinely require human action
- **`v_summit_health`** — 7-day rolling SUMMIT dispatch health
- **`v_honesty_violations_summit_daily`** — ghost-success guardrail trend

The ghost-success guardrail (`trg_prevent_ghost_success`) blocks any `summit_chat_dispatch` state transition into `verified` that lacks evidence keys (`hard_verification`, `github_commits`, `eg14_summary`, `smoke_test`, `supabase_artifacts`, `supabase_migrations`). Blocked attempts log with `CRITICAL` severity.
