/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Host projection of a rehearsal session, synthetic actors, and bounded action history.
 */
export interface EventRehearsalBootstrapCallableResponse {
  session: {
    id: string;
    organizerId: string;
    sourceEventId: string | null;
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
    virtualNowMillis: number;
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
    expiresAtMillis: number;
  };
  /**
   * @maxItems 50
   */
  actors: {
    actorId: string;
    displayName: string;
    persona: string;
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
    keepApartActorIds: string[];
    helpRequested: boolean;
    promptCompleted: boolean;
    layoutUnitId: string | null;
    confirmedLayoutUnitId: string | null;
  }[];
  /**
   * @maxItems 500
   */
  actions: {
    clientActionId: string;
    actorId: string | null;
    kind: string;
    name: string;
    runtimeRevision: number;
    virtualNowMillis: number;
  }[];
  guestUrl: string;
  canUseInternalFaults: boolean;
}
