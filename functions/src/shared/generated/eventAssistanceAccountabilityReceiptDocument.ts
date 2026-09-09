/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceAccountabilityReceiptDocument {
  receiptId: string;
  guestId: string;
  requestHash: string;
  sourceGeneration: string;
  attendeeGeneration: string;
  checkInHash: string;
  episodeId: string | null;
  revision: number;
  disposition: "returned" | "departed" | "unresolved";
  createdAt: number;
  checkpoint?: {
    checkpointId: string;
    progressRevision: number;
    rosterId: string;
    rosterHash: string;
  };
}
