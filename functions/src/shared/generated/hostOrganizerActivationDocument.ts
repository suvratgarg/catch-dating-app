/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private Host pilot review and operational activation evidence. No attendee identity or advertising permission.
 */
export interface HostOrganizerActivationDocument {
  schemaVersion: 1;
  classification: "sales_private";
  organizerId: string;
  eventId: string;
  receiptId: string;
  activatedAt: number;
  recordedAt: number;
  reviewRevision: number;
}
