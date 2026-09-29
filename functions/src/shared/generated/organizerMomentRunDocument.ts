/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned planned/fired run for a moment. Time-based runId encodes moment + anchor revision + nominal due time; mutable travel wake and deferrals are separate. Triggered/manual identities retain subject/requestKey.
 */
export interface OrganizerMomentRunDocument {
  runId: string;
  momentId: string;
  dueAtMillis: number;
  /**
   * Scheduled occurrence time (anchor plus offsets), the identity axis behind runId; dueAtMillis is the mutable next-wake time and may differ for deferrals.
   */
  nominalDueAtMillis?: number;
  /**
   * Hard stop on firing this run; a deferred run past expiry skips instead of sending late.
   */
  expiresAtMillis?: number;
  occurrenceVersion?: 2;
  plannedWakeAtMillis?: number;
  travelPlanHash?: string;
  anchorRevision: number;
  status:
    | "planned"
    | "resolving"
    | "dispatched"
    | "skipped"
    | "superseded"
    | "failed";
  targetFunctionId?: string | null;
  /**
   * Triggered runs: the fact's subject (e.g. travel leg id).
   */
  subjectId?: string | null;
  /**
   * Skip/failure reason written at run transition.
   */
  reason?: string | null;
  recipients?: number | null;
  sent?: number | null;
  /**
   * Suppression reason -> recipient count rollup.
   */
  suppressed?: {
    [k: string]: number;
  } | null;
  suppressedNoEndpoint?: number | null;
  /**
   * Occurrence binding for form-automation sends. Present only on runs materialized by the automation handoff; delivery evidence lives in automationDeliveryMessages.
   */
  automation?: {
    ruleId: string;
    ruleRevision: number;
    actionId: string;
    eventKind:
      | "submitted"
      | "withdrawn"
      | "applicationAccepted"
      | "eventAttended";
    sourceId: string;
    occurredAtMillis: number;
    /**
     * Business-delay horizon computed by the automation engine at handoff; the delivery claim re-derives it from live facts.
     */
    dueAtMillis: number;
    /**
     * Contact identity resolved at handoff; claim re-derives the live identity so merges follow the send.
     */
    contactId: string;
    /**
     * Durable intent record this run executes; the outbox owns the actual attempt history.
     */
    deliveryMessageId: string;
  } | null;
}
