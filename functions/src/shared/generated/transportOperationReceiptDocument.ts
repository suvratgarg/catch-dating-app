/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned idempotency receipt for offline-replayed transport mutations. An exact retry returns the original result; a conflicting reuse of the client operation id fails closed.
 */
export interface TransportOperationReceiptDocument {
  programId: string;
  operationKind:
    | "markReady"
    | "claim"
    | "unclaim"
    | "markDisrupted"
    | "dispatch"
    | "markArrived"
    | "voidTrip";
  clientOperationId: string;
  actorUid: string;
  /**
   * Stable hash of the mutation payload; a same-id different-payload replay is rejected.
   */
  requestHash: string;
  tripId: string | null;
  legId: string | null;
  /**
   * Committed entity revision returned to a replayed caller.
   */
  resultRevision: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Receipt retention horizon for cleanup sweeps.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
