/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Read-only filters for the durable Supply Intake operations inventory. This callable never requests or executes a run.
 */
export type AdminListIntakeOperationsCallablePayload = {
  [k: string]: unknown;
} & {
  workflowId?: "supply-intake";
  runId?: string | null;
  primaryStage?: "incoming" | "verify" | "resolve" | "ready" | null;
  entityKind?:
    | "event"
    | "organizer"
    | "source_result"
    | "source_profile"
    | null;
  lifecycleStatus?:
    | "queued"
    | "in_progress"
    | "waiting"
    | "ready"
    | "published"
    | "terminal"
    | null;
  runStatus?:
    | "planned"
    | "queued"
    | "running"
    | "paused"
    | "completed"
    | "failed"
    | "cancelled"
    | null;
  /**
   * When true, returns only work items carrying the canonical human_review_required task flag.
   */
  humanReviewRequired?: boolean;
  runLimit?: number;
  workItemLimit?: number;
  runCursor?: string | null;
  workItemCursor?: string | null;
};
