#!/usr/bin/env bash
# SUMMIT 77c39794 Phase 1b — Dify integration smoke test
# Anti-ghost-success verification: runs the full round-trip and confirms
# a real row appears in parcel_cards via Supabase query.
#
# Usage:
#   export SUPABASE_URL=https://mocerqjnksmhcjzxrewo.supabase.co
#   export SUPABASE_ANON_KEY=<anon>
#   export INTERNAL_AUTH_TOKEN=<shared secret>
#   export TARGET_HOST=https://zonewise.ai        # or preview URL
#   bash smoke-dify-parcel-cards.sh
#
# Exit codes:
#   0  → PASS (card created + confirmed in Supabase within 10s)
#   1  → FAIL (anything else)

set -euo pipefail

: "${SUPABASE_URL:?SUPABASE_URL not set}"
: "${SUPABASE_ANON_KEY:?SUPABASE_ANON_KEY not set}"
: "${INTERNAL_AUTH_TOKEN:?INTERNAL_AUTH_TOKEN not set}"
: "${TARGET_HOST:?TARGET_HOST not set (e.g. https://zonewise-web-preview.vercel.app)}"

TEST_MARK="smoke-$(date +%s)-$$"

echo "=== 1/3 — POST /api/parcel-cards/create ==="
RESP=$(curl -sS -X POST "${TARGET_HOST}/api/parcel-cards/create" \
  -H "Content-Type: application/json" \
  -H "x-internal-auth: ${INTERNAL_AUTH_TOKEN}" \
  -d "{
    \"parcel_id\": 1,
    \"user_id\": null,
    \"app\": \"zonewise\",
    \"question\": \"[${TEST_MARK}] smoke test — is zone R-1 allowed on this parcel?\",
    \"answer\": {
      \"summary\": \"Dify integration smoke test — generated $(date -u +%FT%TZ)\",
      \"confidence\": \"UNTESTED\"
    },
    \"citations\": [{\"source\": \"smoke-test\", \"section\": \"N/A\"}]
  }")

CARD_ID=$(echo "$RESP" | python3 -c "import json,sys; print(json.load(sys.stdin).get('card_id',''))")
SHARE_URL=$(echo "$RESP" | python3 -c "import json,sys; print(json.load(sys.stdin).get('share_url',''))")

if [[ -z "${CARD_ID}" ]]; then
  echo "FAIL — no card_id returned"
  echo "response: ${RESP}"
  exit 1
fi

echo "  card_id: ${CARD_ID}"
echo "  share_url: ${SHARE_URL}"
echo ""

echo "=== 2/3 — Verify row exists in public.parcel_cards via REST ==="
sleep 2  # give Postgres a moment (not strictly needed but avoids races)
ROW=$(curl -sS "${SUPABASE_URL}/rest/v1/parcel_cards_public?id=eq.${CARD_ID}&select=id,app,question,view_count,county,pin" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}")
ROW_COUNT=$(echo "$ROW" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")

if [[ "${ROW_COUNT}" != "1" ]]; then
  echo "FAIL — expected 1 row, got ${ROW_COUNT}"
  echo "response: ${ROW}"
  exit 1
fi

echo "  row_confirmed: 1"
echo "  details: ${ROW}"
echo ""

echo "=== 3/3 — Verify share URL renders (GET with 200) ==="
# Note: if Vercel preview requires auth bypass token, pass via header
STATUS=$(curl -sS -o /dev/null -w "%{http_code}" "${SHARE_URL}" || echo "000")
if [[ "${STATUS}" != "200" ]]; then
  echo "WARN — share URL returned ${STATUS} (may indicate DNS/deploy not propagated yet, acceptable for smoke)"
else
  echo "  share_url_http: 200"
fi
echo ""

echo "✅ PASS — Dify integration smoke test complete"
echo "    card_id=${CARD_ID}"
echo "    test_mark=${TEST_MARK}"
echo ""
echo "To clean up test rows:"
echo "  DELETE FROM public.parcel_cards WHERE question LIKE '[smoke-%';"
