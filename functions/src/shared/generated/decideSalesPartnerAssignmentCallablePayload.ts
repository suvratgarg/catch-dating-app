/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface DecideSalesPartnerAssignmentCallablePayload {
  requestId: string;
  organizerId: string;
  expectedRevision: number;
  decision: "accept" | "decline";
  relationshipContext: string | null;
  channel: "email" | "whatsapp" | "other" | null;
}
