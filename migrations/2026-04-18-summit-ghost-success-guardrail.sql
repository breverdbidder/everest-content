-- Migration: summit_ghost_success_guardrail
-- Applied: 2026-04-18 via Supabase MCP (project mocerqjnksmhcjzxrewo)
-- Purpose: Block SUMMIT state→'verified' transitions lacking real delivery evidence
-- Trigger: BEFORE UPDATE OF state ON public.summit_chat_dispatch
--
-- Rationale
-- ---------
-- SUMMIT 77c39794 (Apr 18) flipped to 'verified' in 4 minutes with 0 commits to
-- the target repo and null EG14 score. The `delivery_proof` contained only
-- dispatch markers (phase1_sent_at, issue_created_at, phase*_request_id) — not
-- evidence of completed work. Historical pattern: every one of the last 10
-- SUMMITs showed eg14_passed=null, confirming the "runner reports success
-- without producing deliverables" pattern flagged in memory as
-- GHOST_SUCCESS_BANNED.
--
-- This trigger makes ghost-success structurally impossible at the database
-- level. The runner can still claim success, but Postgres will block it and
-- log to honesty_violations with CRITICAL severity (3x penalty per protocol).
--
-- Evidence keys (one required)
-- ----------------------------
--   hard_verification   — explicit verification contract (smoke test exits, query results)
--   github_commits      — real file SHAs landed in target repo
--   eg14_summary        — EG14 14-pt gate was actually run
--   smoke_test          — E2E test output captured
--   supabase_artifacts  — schema objects created
--   supabase_migrations — named migrations applied
--
-- Dispatch markers (NOT accepted as evidence)
-- -------------------------------------------
--   phase1_sent_at, issue_created_at, phase1_request_id,
--   phase2_dispatch_request_id, workflow_run_id, workflow_run_url,
--   issue_created_at — these prove dispatch, not delivery.
--
-- Grandfathering
-- --------------
-- Trigger only fires on transitions INTO 'verified' from a non-verified state.
-- Existing verified rows (34+ as of apply date) are unaffected.
--
-- Escape hatch
-- ------------
-- If a SUMMIT legitimately has no work to verify (e.g., an eval-only spike),
-- mark it 'closed' rather than 'verified'. 'closed' is unguarded.
--
-- Audit query
-- -----------
--   SELECT id, claim, severity, corrective_action, created_at
--   FROM honesty_violations
--   WHERE domain = 'summit_dispatch'
--   ORDER BY created_at DESC;
--
-- Rollback
-- --------
--   DROP TRIGGER IF EXISTS trg_prevent_ghost_success ON public.summit_chat_dispatch;
--   DROP FUNCTION IF EXISTS public.prevent_summit_ghost_success();

CREATE OR REPLACE FUNCTION public.prevent_summit_ghost_success()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_has_evidence boolean;
  v_keys text[];
BEGIN
  IF NEW.state <> 'verified' OR OLD.state = 'verified' THEN
    RETURN NEW;
  END IF;

  IF NEW.delivery_proof IS NULL OR NEW.delivery_proof = '{}'::jsonb THEN
    INSERT INTO public.honesty_violations(
      domain, claim, tag_used, actual_truth, severity, session_source, corrective_action
    ) VALUES (
      'summit_dispatch',
      format('SUMMIT %s claimed state=verified', NEW.id),
      'VERIFIED',
      'delivery_proof is null or empty',
      'CRITICAL',
      coalesce(NEW.chat_session_id, 'runner'),
      'Populate delivery_proof with one of: hard_verification, github_commits, eg14_summary, smoke_test, supabase_artifacts, supabase_migrations'
    );
    RAISE EXCEPTION 'ghost-success blocked for SUMMIT %: delivery_proof is null/empty', NEW.id
      USING ERRCODE = '23514',
            HINT    = 'Populate delivery_proof with real evidence.';
  END IF;

  v_has_evidence := (
       NEW.delivery_proof ? 'hard_verification'
    OR NEW.delivery_proof ? 'github_commits'
    OR NEW.delivery_proof ? 'eg14_summary'
    OR NEW.delivery_proof ? 'smoke_test'
    OR NEW.delivery_proof ? 'supabase_artifacts'
    OR NEW.delivery_proof ? 'supabase_migrations'
  );

  IF NOT v_has_evidence THEN
    SELECT array_agg(k) INTO v_keys FROM jsonb_object_keys(NEW.delivery_proof) k;
    INSERT INTO public.honesty_violations(
      domain, claim, tag_used, actual_truth, severity, session_source, corrective_action
    ) VALUES (
      'summit_dispatch',
      format('SUMMIT %s claimed state=verified with delivery_proof keys: %s', NEW.id, v_keys::text),
      'VERIFIED',
      'delivery_proof contains only dispatch markers, not delivery evidence',
      'CRITICAL',
      coalesce(NEW.chat_session_id, 'runner'),
      'Add one of: hard_verification, github_commits, eg14_summary, smoke_test, supabase_artifacts, supabase_migrations'
    );
    RAISE EXCEPTION
      'ghost-success blocked for SUMMIT %: delivery_proof has no evidence keys (found: %)',
      NEW.id, coalesce(v_keys::text, 'none')
      USING ERRCODE = '23514',
            HINT    = 'delivery_proof needs one of: hard_verification, github_commits, eg14_summary, smoke_test, supabase_artifacts, supabase_migrations';
  END IF;

  RETURN NEW;
END $$;

COMMENT ON FUNCTION public.prevent_summit_ghost_success IS
  'Blocks SUMMIT state→verified transitions lacking real delivery evidence. Logs to honesty_violations with CRITICAL severity (3x penalty).';

DROP TRIGGER IF EXISTS trg_prevent_ghost_success ON public.summit_chat_dispatch;
CREATE TRIGGER trg_prevent_ghost_success
  BEFORE UPDATE OF state ON public.summit_chat_dispatch
  FOR EACH ROW
  EXECUTE FUNCTION public.prevent_summit_ghost_success();

REVOKE ALL ON FUNCTION public.prevent_summit_ghost_success FROM PUBLIC;
