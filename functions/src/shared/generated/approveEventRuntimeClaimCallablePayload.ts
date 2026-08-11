/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Host decision for one pending Event Success runtime claim.
 */
export interface ApproveEventRuntimeClaimCallablePayload {
  eventId: string;
  uid: string;
  decision: "approve" | "reject";
  attendeeId?: string | null;
  reason?: string | null;
}
