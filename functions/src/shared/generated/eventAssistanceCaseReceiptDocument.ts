/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceCaseReceiptDocument {
  receiptId: string;
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  caseId: string;
  caseBindingHash: string;
  requestHash: string;
  revision: number;
  actorUid: string;
  outcome: "resolved" | "declined" | "transferred";
  createdAt: number;
}
