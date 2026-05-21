/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

/**
 * Server-owned live guidance assignment stored at eventSuccessAssignments/{eventId_moduleId_uid}.
 */
export interface EventSuccessAssignmentDocument {
  eventId: string;
  clubId: string;
  uid: string;
  moduleId: "micro_pods" | "guided_rotations";
  label: string;
  displayTitle: string;
  displaySubtitle?: string | null;
  /**
   * @maxItems 20
   */
  peerUids: string[];
  /**
   * @maxItems 24
   */
  rotationSlots?: {
    roundIndex: number;
    label: string;
    /**
     * Serialized Firestore Timestamp fixture shape.
     */
    startsAt: {
      _seconds: number;
      _nanoseconds: number;
    };
    /**
     * Serialized Firestore Timestamp fixture shape.
     */
    endsAt: {
      _seconds: number;
      _nanoseconds: number;
    };
    peerUid: string;
    compatibility:
      | "mutual_interest"
      | "one_way_interest"
      | "questionnaire_match"
      | "social"
      | "host_override";
  }[];
  source: "server_v1" | "host_override_v1" | "server";
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
  /**
   * Internal demo seed marker used for cleanup and diagnostics.
   */
  synthetic?: boolean;
  /**
   * Internal demo seed prefix used for cleanup and diagnostics.
   */
  seedPrefix?: string;
  /**
   * Internal demo seed scenario name used for cleanup and diagnostics.
   */
  scenario?: string;
  /**
   * Internal demo-operations marker used for cleanup and diagnostics.
   */
  demoOps?: boolean;
  /**
   * Internal demo-operations id used for cleanup and diagnostics.
   */
  demoOpsId?: string;
  /**
   * Internal demo-operations command name used for cleanup and diagnostics.
   */
  demoOpsCommand?: string;
}
