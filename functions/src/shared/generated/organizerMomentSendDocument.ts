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
}
