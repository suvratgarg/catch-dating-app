/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Withdraw exactly one sender’s WhatsApp permission using the reviewed receipt. Never grants consent.
 */
export interface WithdrawParticipantMessagingPermissionCallablePayload {
  scope: "catch" | "organizer";
  organizerId: string | null;
  /**
   * Omit for sender-wide withdrawal. Scope one purpose without changing the other.
   */
  purpose?: "eventOperations" | "marketing";
  expectedReceiptId: string | null;
  requestId: string;
}
