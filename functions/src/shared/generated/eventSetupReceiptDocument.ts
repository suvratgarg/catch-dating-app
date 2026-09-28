/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type EventSetupReceiptDocument = {
  operation:
    | "create"
    | "update"
    | "preferences"
    | "details"
    | "publish"
    | "unpublish";
  actorUid: string;
  organizerId: string;
  requestHash: string;
  eventId: string;
  appliedRevision?: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  outcome?: "discarded";
  expectedSetupRevision?: number;
} & (
  | {
      [k: string]: unknown;
    }
  | {
      operation?: "details";
      [k: string]: unknown;
    }
);
