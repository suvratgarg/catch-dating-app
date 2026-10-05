/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface UpdateSalesPartnerAssignmentCallablePayload {
  requestId: string;
  organizerId: string;
  expectedRevision: number;
  relationshipContext: string | null;
  channel: "email" | "whatsapp" | "other";
  nextAction: string;
  reviewAt: string;
}
