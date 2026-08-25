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
      /**
       * Frozen, synthetic-only movement truth used by dress rehearsal. It never reads or writes a real person's live position.
       */
      movementSimulation?: {
        /**
         * @maxItems 40
         */
        itinerary: {
          id: string;
          kind:
            | "gather"
            | "activity"
            | "stop"
            | "break"
            | "transition"
            | "finish";
          offsetMinutes: number;
          durationMinutes?: number | null;
          title: string;
          description?: string | null;
          location?: {
            name: string;
            address?: string | null;
            placeId?: string | null;
            latitude: number;
            longitude: number;
            notes?: string | null;
          } | null;
          routeDistanceMeters?: number | null;
        }[];
        routePlan: null | {
          version: 1 | 2;
          movementMode: "run" | "walk" | "ride" | "mixed";
          routeShape: "loop" | "outAndBack" | "pointToPoint";
          groupStrategy: "together" | "paceGroups" | "selfDirected";
          stopCadence: "continuous" | "flexibleStops" | "hostedStops";
          /**
           * @minItems 1
           * @maxItems 7
           */
          stopKinds: (
            | "water"
            | "regroup"
            | "venue"
            | "photoSpot"
            | "viewpoint"
            | "hazard"
            | "turnaround"
          )[];
          /**
           * @minItems 1
           * @maxItems 6
           */
          roleKinds: (
            | "routeLead"
            | "sweep"
            | "pacer"
            | "stopHost"
            | "marshal"
            | "photographer"
          )[];
          /**
           * @minItems 2
           * @maxItems 500
           */
          path?: {
            latitude: number;
            longitude: number;
          }[];
          /**
           * @maxItems 12
           */
          paceGroups?: {
            id: string;
            label: string;
            targetPaceSecondsPerKm?: number | null;
            sortOrder: number;
          }[];
          liveTrackingPolicy?: {
            mode: "disabled" | "hostOnly" | "authorizedOperators";
            staleAfterSeconds: number;
            retentionMinutes: number;
          };
        };
        /**
         * @maxItems 2
         */
        livePositions: {
          role: "host" | "operator";
          latitude: number;
          longitude: number;
          recordedOffsetMinutes: number;
        }[];
        lateArrivalGuidance: string | null;
      };
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
