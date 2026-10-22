/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private Host pilot review and operational activation evidence. No attendee identity or advertising permission.
 */
export interface HostPilotEventReviewDocument {
  schemaVersion: 1;
  classification: "sales_private";
  eventId: string;
  organizerId: string;
  realEvent: boolean;
  revision: number;
  reviewedAt: number;
  reviewedBy: string;
}
