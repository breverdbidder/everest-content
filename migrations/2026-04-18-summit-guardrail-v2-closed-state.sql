-- Migration: summit_guardrail_v2_closed_state_plus_views
-- Applied: 2026-04-18 via Supabase MCP (project mocerqjnksmhcjzxrewo)
-- Supersedes: 2026-04-18-summit-ghost-success-guardrail.sql (v1)
--
-- Changes from v1
-- ---------------
-- 1. Function `prevent_summit_ghost_success()` now guards transitions into BOTH
--    `verified` (strict — requires evidence keys, CRITICAL severity) AND
--    `closed` (weak — requires any non-empty delivery_proof, HIGH severity).
-- 2. Adds two analytics views:
--    - `v_honesty_violations_summit_daily` — for Grafana panel
--    - `v_summit_health`                   — 30-day rolling dispatch health metrics
--
-- Why extend to 'closed'?
-- -----------------------
-- `closed` is weaker than `verified` — it means "done, not strongly verified."
-- But a closed SUMMIT with NO delivery_proof at all = no audit trail for what
-- happened. The weak gate forces the runner (or human) to at least state WHY
-- it's being closed (runner_note, eval_findings, cancellation_reason, etc.).
--
-- Legit closed flows (each satisfies the weak bar):
--   SET state='closed', delivery_proof = jsonb_build_object('runner_note', 'superseded by X')
--   SET state='closed', delivery_proof = jsonb_build_object('eval_findings', '...')
--   SET state='closed', delivery_proof = jsonb_build_object('cancellation_reason', 'pivoted')
--
-- Grandfathered
-- -------------
-- Trigger only fires on OLD.state <> NEW.state. 3 existing closed null-proof
-- rows were backfilled to honesty_violations (severity=AUDIT) on this date —
-- those rows themselves were not modified, just documented.
--
-- Rollback to v1
-- --------------
-- Re-apply 2026-04-18-summit-ghost-success-guardrail.sql.
--
-- Full rollback
-- -------------
--   DROP TRIGGER IF EXISTS trg_prevent_ghost_success ON public.summit_chat_dispatch;
--   DROP FUNCTION IF EXISTS public.prevent_summit_ghost_success();
--   DROP VIEW IF EXISTS public.v_honesty_violations_summit_daily;
--   DROP VIEW IF EXISTS public.v_summit_health;

CREATE OR REPLACE FUNCTION public.prevent_summit_ghost_success()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_has_evidence boolean;
  v_keys text[];
  v_guarding_state text;
BEGIN
  IF NEW.state NOT IN ('verified','closed') OR OLD.state = NEW.state THEN
    RETURN NEW;
  END IF;

  v_guarding_state := NEW.state;

  IF v_guarding_state = 'verified' THEN
    IF NEW.delivery_proof IS NULL OR NEW.delivery_proof = '{}'::jsonb THEN
      INSERT INTO public.honesty_violations(domain, claim, tag_used, actual_truth, severity, session_source, corrective_action)
      VALUES ('summit_dispatch', format('SUMMIT %s claimed verified', NEW.id), 'VERIFIED',
              'delivery_proof is null/empty', 'CRITICAL',
              coalesce(NEW.chat_session_id,'runner'),
              'Add one of: hard_verification, github_commits, eg14_summary, smoke_test, supabase_artifacts, supabase_migrations');
      RAISE EXCEPTION 'ghost-success blocked for SUMMIT %: verified requires delivery_proof', NEW.id
        USING ERRCODE='23514';
    END IF;

    v_has_evidence := NEW.delivery_proof ? 'hard_verification'
                   OR NEW.delivery_proof ? 'github_commits'
                   OR NEW.delivery_proof ? 'eg14_summary'
                   OR NEW.delivery_proof ? 'smoke_test'
                   OR NEW.delivery_proof ? 'supabase_artifacts'
                   OR NEW.delivery_proof ? 'supabase_migrations';

    IF NOT v_has_evidence THEN
      SELECT array_agg(k) INTO v_keys FROM jsonb_object_keys(NEW.delivery_proof) k;
      INSERT INTO public.honesty_violations(domain, claim, tag_used, actual_truth, severity, session_source, corrective_action)
      VALUES ('summit_dispatch',
              format('SUMMIT %s verified with keys %s', NEW.id, v_keys::text),
              'VERIFIED',
              'delivery_proof contains only dispatch markers',
              'CRITICAL',
              coalesce(NEW.chat_session_id,'runner'),
              'Add an evidence key, not just dispatch markers');
      RAISE EXCEPTION 'ghost-success blocked for SUMMIT %: verified needs evidence keys (found: %)', NEW.id, coalesce(v_keys::text,'none')
        USING ERRCODE='23514';
    END IF;

  ELSIF v_guarding_state = 'closed' THEN
    IF NEW.delivery_proof IS NULL OR NEW.delivery_proof = '{}'::jsonb THEN
      INSERT INTO public.honesty_violations(domain, claim, tag_used, actual_truth, severity, session_source, corrective_action)
      VALUES ('summit_dispatch',
              format('SUMMIT %s claimed closed with null/empty delivery_proof', NEW.id),
              'CLOSED',
              'closed state with no delivery_proof — cannot audit what happened',
              'HIGH',
              coalesce(NEW.chat_session_id,'runner'),
              'Add delivery_proof with runner_note, eval_findings, cancellation_reason, or similar minimal artifact');
      RAISE EXCEPTION 'closed-without-proof blocked for SUMMIT %: even closed state needs a delivery_proof artifact', NEW.id
        USING ERRCODE='23514',
              HINT='For manual closures, set delivery_proof = jsonb_build_object(''runner_note'', ''<why>''). For eval spikes, include findings.';
    END IF;
  END IF;

  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_prevent_ghost_success ON public.summit_chat_dispatch;
CREATE TRIGGER trg_prevent_ghost_success
  BEFORE UPDATE OF state ON public.summit_chat_dispatch
  FOR EACH ROW
  EXECUTE FUNCTION public.prevent_summit_ghost_success();

COMMENT ON FUNCTION public.prevent_summit_ghost_success IS
  'v2 — Blocks ghost-success on verified (strict: needs evidence keys) and closed (weak: needs any delivery_proof). Logs to honesty_violations with CRITICAL / HIGH severity respectively.';

CREATE OR REPLACE VIEW public.v_honesty_violations_summit_daily AS
SELECT
  date_trunc('day', created_at) AS day,
  severity,
  tag_used,
  count(*) AS n
FROM public.honesty_violations
WHERE domain = 'summit_dispatch'
GROUP BY 1, 2, 3
ORDER BY 1 DESC;

CREATE OR REPLACE VIEW public.v_summit_health AS
SELECT
  date_trunc('day', created_at) AS day,
  state,
  priority,
  count(*) AS n,
  count(*) FILTER (WHERE eg14_passed) AS eg14_passed,
  count(*) FILTER (WHERE delivery_proof IS NOT NULL AND delivery_proof != '{}'::jsonb) AS has_proof,
  count(*) FILTER (WHERE workflow_run_url IS NOT NULL) AS had_workflow,
  round(avg(extract(epoch FROM (completed_at - created_at)))/60)::int AS median_minutes
FROM public.summit_chat_dispatch
WHERE created_at > now() - interval '30 days'
GROUP BY 1, 2, 3
ORDER BY 1 DESC, 2;

GRANT SELECT ON public.v_honesty_violations_summit_daily TO authenticated, service_role;
GRANT SELECT ON public.v_summit_health                   TO authenticated, service_role;
