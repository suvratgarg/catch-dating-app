/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned isolated Host rehearsal session stored at eventRehearsals/{sessionId}.
 */
export interface EventRehearsalDocument {
  organizerId: string;
  clubId: string;
  ownerUid: string;
  sourceEventId: string | null;
  sourceEventRevision: string | null;
  publicRehearsalId: string;
  viewerTokenHash: string;
  scenarioId:
    | "smoothRun"
    | "lateAndNoShow"
    | "earlyExitAndReturn"
    | "rosterAndCapacity"
    | "walkInAndAmbiguousClaim"
    | "privacyAndKeepApart"
    | "lowConnectivity"
    | "concurrentHosts"
    | "revealInterrupted"
    | "externalProfiles"
    | "accountabilitySweep";
  seed: number;
  actorCount: number;
  actionCount: number;
  status: "draft" | "ready" | "running" | "paused" | "complete" | "expired";
  setup: {
    title: string;
    locationName: string;
    durationMinutes: number;
    hostGoal: string;
    attendeePrompt: string;
    /**
     * @minItems 1
     * @maxItems 8
     */
    moduleIds: (
      | "arrival"
      | "firstHello"
      | "pods"
      | "rotations"
      | "conversationCues"
      | "reveal"
      | "afterglow"
      | "accountability"
    )[];
  };
  setupRevision: number;
  runtimeRevision: number;
  activeStepIndex: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  virtualStartedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  virtualNow: {
    _seconds: number;
    _nanoseconds: number;
  };
  faultId:
    | "none"
    | "latency"
    | "oneShotFailure"
    | "listenerDisconnect"
    | "staleRevision"
    | "duplicateDelivery"
    | "legacyFixture"
    | "reducedMotion"
    | "lowBandwidth";
  faultConsumed: boolean;
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
   * Serialized Firestore Timestamp fixture shape.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  completedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
