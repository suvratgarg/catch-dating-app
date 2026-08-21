/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Synthetic participant state stored only for an isolated rehearsal.
 */
export interface EventRehearsalActorDocument {
  sessionId: string;
  actorId: string;
  displayName: string;
  persona:
    | "firstTimer"
    | "regular"
    | "quiet"
    | "connector"
    | "external"
    | "sparseProfile"
    | "accessibilityNeeds"
    | "walkIn";
  status:
    | "expected"
    | "present"
    | "late"
    | "noShow"
    | "departed"
    | "returned"
    | "disconnected"
    | "walkIn"
    | "ambiguousClaim";
  guestMoment:
    | "welcome"
    | "checkIn"
    | "firstHello"
    | "assignment"
    | "rotation"
    | "pause"
    | "reveal"
    | "afterglow"
    | "complete";
  optedOut: boolean;
  /**
   * @maxItems 10
   */
  keepApartActorIds: string[];
  helpRequested: boolean;
  promptCompleted: boolean;
  layoutUnitId: string | null;
  confirmedLayoutUnitId: string | null;
  lastActionAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
