/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Fire a manual moment immediately. The caller-supplied requestKey scopes idempotency: retries and double-submits with the same key resolve to the same run.
 */
export interface RunOrganizerMomentCallablePayload {
  scope: {
    kind: "event" | "program";
    /**
     * Required when kind=event; must be null otherwise.
     */
    eventId?: string | null;
    /**
     * Required when kind=program; must be null otherwise.
     */
    programId?: string | null;
  };
  momentId: string;
  requestKey: string;
}
