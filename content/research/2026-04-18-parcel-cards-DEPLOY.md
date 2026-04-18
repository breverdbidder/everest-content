# Parcel Cards — Phase 1 Deployment Runbook

SUMMIT `77c39794-79ac-4030-bde8-85a417c2ad3b`. Supersedes the runner's degraded first pass (Apr 18 07:35 UTC). This runbook is the single authoritative deployment doc; if this conflicts with earlier SUMMIT text, this wins.

---

## Status snapshot (as of this commit)

**VERIFIED** (done from chat, no runner involvement):
- `public.parcel_cards` table on Supabase `mocerqjnksmhcjzxrewo` with proper FK to `zw_parcels(id)` bigint, all 15 columns, 4 indexes, updated_at trigger.
- RLS: 5 policies (`parcel_cards_select_own`, `_select_public`, `_insert_owner`, `_update_owner`, `_delete_owner`).
- RPCs: `create_parcel_card(...)`, `increment_parcel_card_view(uuid)`, `increment_parcel_card_share(uuid)`.
- View: `public.parcel_cards_public` (denormalized join to `zw_parcels` for SEO renderer).
- Smoke test: real card created against Brevard parcel `1605 SWEETWOOD DR` (PIN `27 3708-02-*-42`), view_count incremented, referral_code generated.

**UNTESTED** (code shipped, not yet deployed):
- `app/parcel/[id]/page.tsx` — Next.js SSR page (targets `zonewise.ai/parcel/{id}`).
- `parcel-card-preview.html` — standalone visual preview (same data, same brand).

**INFERRED / needs Ariel decision**:
- Target web repo for the Next.js page. Default assumption: `breverdbidder/zonewise-web` or the monorepo that backs Vercel project `prj_EaXgEO6WDoSpCeLhuCemtbPr6e8E`. Confirm before copying `page.tsx` in.

---

## Deploy steps (in order)

### Step 1 — Vercel env vars (one-time, HITL)

On Vercel project `prj_EaXgEO6WDoSpCeLhuCemtbPr6e8E`:

```
NEXT_PUBLIC_SUPABASE_URL       = https://mocerqjnksmhcjzxrewo.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY  = <publishable key from Supabase dashboard>
```

Anon key only — **never** service_role on a public Next.js surface. The anon key is safe because `parcel_cards_public` is the only readable surface for anon (enforced by RLS + the view's WHERE `is_public = true` clause).

### Step 2 — Drop `page.tsx` into the web repo

File: `app/parcel/[id]/page.tsx` (Next.js 13+ app router). Requires `@supabase/supabase-js` already in deps — if not:

```
pnpm add @supabase/supabase-js
```

### Step 3 — Deploy to Vercel

Push to `main`, Vercel auto-deploys. Manual trigger via `vercel --prod` if preferred.

### Step 4 — Dify integration (this is the actual Hetzner-bound work)

On every completed chat turn, Dify must call:

```
POST https://mocerqjnksmhcjzxrewo.supabase.co/rest/v1/rpc/create_parcel_card
Headers:
  apikey: <service_role or anon>
  Authorization: Bearer <same>
  Content-Type: application/json
Body:
{
  "p_parcel_id": <bigint from zw_parcels lookup>,
  "p_user_id":   "<uuid of authenticated user>",
  "p_app":       "zonewise",
  "p_question":  "<user's question verbatim>",
  "p_answer":    { "summary": "...", "confidence": "VERIFIED", ... },
  "p_citations": [ { "source": "...", "section": "...", "url": "..." } ]
}
→ returns { card_id: "<uuid>" }
```

Dify then appends to its chat response:

```
📎 Share this answer: https://zonewise.ai/parcel/{card_id}
```

For BidDeed, same pattern — just pass `"p_app": "biddeed"` and the answer payload uses the buy-box schema instead of zoning.

### Step 5 — E2E verification

1. Open `chat.zonewise.ai`, ask a real parcel question.
2. Dify responds + includes the share URL.
3. Visit `https://zonewise.ai/parcel/{id}` in an incognito window → card renders, view_count increments.
4. Click "Copy link" → paste into another browser → second view increments.
5. Anon user clicks "Start free" → hits paywall after 2 queries → referral code `ref=<code>` attributed to original sharer on signup.

### Step 6 — Cache warmup (optional, high-volume parcels)

If a card goes viral, Vercel revalidation every 5 min keeps view_count fresh. For a specific card ID you want to hotload:

```
curl -X POST https://zonewise.ai/api/revalidate?path=/parcel/<id>&secret=<CRON_SECRET>
```

Add this API route if not already present.

---

## Rollback

If anything breaks:

```sql
-- nuclear: full rollback, zero data loss assuming < 24hr ship
DROP TABLE IF EXISTS public.parcel_cards CASCADE;
DROP VIEW  IF EXISTS public.parcel_cards_public;
DROP FUNCTION IF EXISTS public.create_parcel_card(bigint,uuid,text,text,jsonb,jsonb);
DROP FUNCTION IF EXISTS public.increment_parcel_card_view(uuid);
DROP FUNCTION IF EXISTS public.increment_parcel_card_share(uuid);
DROP FUNCTION IF EXISTS public.parcel_cards_touch_updated_at();
```

Next.js page rollback: revert the commit that adds `app/parcel/[id]/page.tsx`.

---

## What's explicitly NOT in Phase 1

- Workspace / firm collaboration UI (Phase 3).
- Referral reward distribution (Phase 2).
- OG image generation (Phase 2 — for now `og_image_url` is nullable; social unfurls use the default).
- Paywall gate itself (lives in Dify config, Phase 2).

These are flagged in the GTM brief at `content/research/2026-04-18-zw-bd-growth-loops.md`.

---

## Memory cites

`[mem:ZW_GTM]`, `[mem:PAIRING_RULE]`, `[mem:INFRA_SSOT]`, `[mem:BRAND]`, `[mem:EG14]`, `[mem:HONESTY_PROTOCOL]`, `[mem:K1_K4]`, `[mem:GHOST_SUCCESS_BANNED]`
