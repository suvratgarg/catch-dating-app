/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Per-recipient send decision for a moment run; document id is {runId}_{recipientKey} so retries never double-send and every suppression carries its audited reason.
 */
export interface OrganizerMomentSendDocument {
  momentId: string;
  /**
   * Stable recipient idempotency key: household:|guest:|uid:|contact: prefixed.
   */
  recipientKey: string;
  decision: "sent" | "suppressed";
  /**
   * Suppression reason; null on sent.
   */
  reason?:
    | "noEndpoint"
    | "preferenceOff"
    | "noConsent"
    | "optedOut"
    | "endpointSuppressed"
    | "dailyCap"
    | null;
  /**
   * Scope-local calendar day (YYYY-MM-DD) for per-endpoint daily caps.
   */
  dayKey: string;
  createdAtMillis: number;
  /**
   * Run that produced this send; set on staffAttention sends so the attention projection can group recipients per run.
   */
  runId?: string | null;
  /**
   * Moment action kind; staffAttention rows feed the organizer attention projection.
   */
  actionKind?: "sendTemplate" | "push" | "staffAttention" | null;
  /**
   * Owning organizer for attention projection queries.
   */
  organizerId?: string | null;
  scopeKind?: "event" | "program" | null;
  scopeId?: string | null;
  /**
   * staffAttention: duty the alert targeted.
   */
  duty?: string | null;
  /**
   * staffAttention: alert severity.
   */
  severity?: "info" | "warning" | "urgent" | null;
  /**
   * staffAttention: rendered alert title.
   */
  title?: string | null;
}
