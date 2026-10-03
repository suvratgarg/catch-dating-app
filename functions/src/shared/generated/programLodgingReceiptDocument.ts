/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable private operation receipt bound to program, actor and exact request. Replay rechecks current authority and returns current workflow; it never restores a prior approval.
 */
export interface ProgramLodgingReceiptDocument {
  programId: string;
  organizerId: string;
  receipt: {
    operationId: string;
    requestHash: string;
    actorUid: string;
    resultingRevision: number;
  };
}
