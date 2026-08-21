/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Bounded idempotency and reproduction record for rehearsal actions.
 */
export interface EventRehearsalActionDocument {
  sessionId: string;
  clientActionId: string;
  actorUid: string | null;
  actorId: string | null;
  kind: "control" | "behavior" | "spatial" | "guest" | "setup" | "system";
  name: string;
  runtimeRevision: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  virtualNow: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
