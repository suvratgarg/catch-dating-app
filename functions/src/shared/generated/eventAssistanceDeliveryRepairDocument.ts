/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceDeliveryRepairDocument {
  receiptId: string;
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  messageId: string;
  intentHash: string;
  requestHash: string;
  actorUid: string;
  operationId: string;
  messageRevision: number;
  createdAt: number;
}
