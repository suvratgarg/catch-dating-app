/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Read current account-scoped event facts using an Auth-derived subject; never reserve or grant admission.
 */
export interface GetEventViewerStateCallablePayload {
  eventId: string;
  inviteCode?: string | null;
  publicPaymentId?: string | null;
}
