// _data/ship.js — build-time data fetch for the /ship/ dashboard
// Pulls recent commits + workflow runs + open SUMMIT issues across Everest repos.
// Uses GITHUB_TOKEN automatically provided by GHA during Pages build.
// Zero secrets needed — ambient Actions auth.

const REPOS = [
  "everest-content",
  "everest-media-gateway",
  "everest-cinematic",
  "cli-anything-biddeed",
  "everest-battle-cards",
  "everest-nexus",
  "everest-vault",
  "everest-seo",
  "hermes-agent",
];

async function ghFetch(url) {
  const token = process.env.GITHUB_TOKEN || process.env.GH_TOKEN || "";
  const headers = {
    "Accept": "application/vnd.github+json",
    "User-Agent": "everest-content-ship-dashboard",
  };
  if (token) headers["Authorization"] = `token ${token}`;
  try {
    const r = await fetch(url, { headers });
    if (!r.ok) {
      console.warn(`[ship.js] ${r.status} ${url}`);
      return null;
    }
    return await r.json();
  } catch (e) {
    console.warn(`[ship.js] fetch failed ${url}: ${e.message}`);
    return null;
  }
}

export default async function () {
  const now = new Date().toISOString();

  // 1. Recent commits per repo (last 5 each)
  const commitPromises = REPOS.map(async (repo) => {
    const commits = await ghFetch(
      `https://api.github.com/repos/breverdbidder/${repo}/commits?per_page=5`
    );
    if (!commits || !Array.isArray(commits)) return { repo, commits: [] };
    return {
      repo,
      commits: commits.map((c) => ({
        sha: c.sha.slice(0, 8),
        message: (c.commit.message || "").split("\n")[0].slice(0, 100),
        author: c.commit.author?.name || "unknown",
        date: c.commit.author?.date,
        url: c.html_url,
      })),
    };
  });

  // 2. Latest SUMMIT runs from cli-anything-biddeed
  const runs = await ghFetch(
    "https://api.github.com/repos/breverdbidder/cli-anything-biddeed/actions/workflows/claude-code-direct.yml/runs?per_page=10"
  );
  const summitRuns = runs?.workflow_runs?.map((r) => ({
    run_number: r.run_number,
    name: r.name,
    status: r.status,
    conclusion: r.conclusion,
    created_at: r.created_at,
    url: r.html_url,
    head_branch: r.head_branch,
    event: r.event,
  })) || [];

  // 3. Open summit-labeled issues on cli-anything-biddeed
  const issues = await ghFetch(
    "https://api.github.com/repos/breverdbidder/cli-anything-biddeed/issues?state=open&labels=summit&per_page=15"
  );
  const openSummits = (Array.isArray(issues) ? issues : [])
    .filter((i) => !i.pull_request)
    .map((i) => ({
      number: i.number,
      title: i.title,
      url: i.html_url,
      labels: (i.labels || []).map((l) => l.name),
      created_at: i.created_at,
    }));

  // 4. Flattened recent-activity list (all commits, sorted by date)
  const allCommits = (await Promise.all(commitPromises)).flatMap((entry) =>
    entry.commits.map((c) => ({ ...c, repo: entry.repo }))
  );
  allCommits.sort(
    (a, b) => new Date(b.date || 0) - new Date(a.date || 0)
  );

  // 5. Live URL probes (static list — a live-probe would require server-side)
  const liveUrls = [
    { url: "https://breverdbidder.github.io/everest-content/", label: "Content hub" },
    { url: "https://breverdbidder.github.io/everest-content/research/", label: "Research intake" },
    { url: "https://breverdbidder.github.io/everest-content/design.md", label: "Design tokens" },
    { url: "https://breverdbidder.github.io/everest-battle-cards/", label: "Battle cards" },
    { url: "https://breverdbidder.github.io/everest-battle-cards/research/", label: "Legacy research" },
  ];

  return {
    generated_at: now,
    recent_commits: allCommits.slice(0, 30),
    summit_runs: summitRuns,
    open_summits: openSummits,
    live_urls: liveUrls,
  };
}
