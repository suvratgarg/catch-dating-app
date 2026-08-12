/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager request to reverse one organizer contact merge receipt.
 */
export interface UnmergeOrganizerContactsCallablePayload {
  organizerId: string;
  mergeReceiptId: string;
  idempotencyKey: string;
}
