/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned isolated Host rehearsal session stored at eventRehearsals/{sessionId}.
 */
export interface EventRehearsalDocument {
  guestSource?: "simulated" | "event";
  /**
   * Private frozen roster names and attendance only. No production identity or contact fields.
   *
   * @minItems 2
   * @maxItems 50
   */
  rosterSnapshot?: {
    displayName: string;
    status: "expected" | "present";
  }[];
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
    eventFormat?: {
      version: 1;
      activityKind:
        | "socialRun"
        | "running"
        | "walking"
        | "pickleball"
        | "padel"
        | "tennis"
        | "badminton"
        | "cycling"
        | "spinClass"
        | "yoga"
        | "strengthTraining"
        | "pubQuiz"
        | "barCrawl"
        | "dinner"
        | "singlesMixer"
        | "openActivity";
      interactionModel:
        | "pacePods"
        | "pairedRotations"
        | "teamRotations"
        | "seatedTable"
        | "freeFormMixer"
        | "hostLedProgram"
        | "openFormat";
      customActivityLabel?: string;
      defaultPlaybookId?: string;
      /**
       * @maxItems 30
       */
      defaultModuleIds?: string[];
      /**
       * Optional event-success behavior primitives for custom or unsupported activity formats. These fields translate a saved event format into the small set of primitives event success can reason about.
       */
      eventSuccessPrimitives?: {
        phoneAvailability?:
          | "continuous"
          | "plannedPauses"
          | "arrivalAndPostEventOnly"
          | "hostOnlyLive"
          | "noneDuringActivity";
        rotationSuitability?: "none" | "plannedBreaks" | "continuousRounds";
        assignmentAlgorithm?:
          | "none"
          | "pacePods"
          | "socialPods"
          | "pairRotations"
          | "teamBalancer"
          | "tableSeating";
        compatibilityPolicy?:
          | "none"
          | "socialCohortBalance"
          | "mutualInterestOnly"
          | "questionnaireClueOnly";
        matchingObjective?:
          | "coverage"
          | "romantic"
          | "affinity"
          | "novelty"
          | "balance"
          | "spread";
        unitOutcome?: "none" | "completion" | "score" | "rank";
        accountability?: "none" | "rollCall" | "sweep";
        durationShape?: "continuous" | "rounds" | "courses" | "segments";
      };
      activityDetails?: {
        /**
         * Composable operations for an event that moves through a route. Activity kind remains the broader format authority.
         */
        routePlan?: {
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
        [k: string]: unknown;
      };
    };
    successDefaults?: {
      enabled?: boolean;
      layoutId?: string | null;
      playbookId?: string;
      /**
       * @maxItems 24
       */
      selectedModuleIds?: string[];
      moduleSelectionConfigured?: boolean;
      structureConfig?: {
        [k: string]: unknown;
      };
      hostGoal?: string;
      wingmanRequestsEnabled?: boolean;
      contextualOpenersEnabled?: boolean;
      compatibilityAffectsRanking?: boolean;
      questionnaireConfig?: {
        templateId: string;
        customTitle?: string | null;
        /**
         * @maxItems 8
         */
        customQuestions?: {
          id: string;
          prompt: string;
          /**
           * @minItems 2
           * @maxItems 5
           */
          options: {
            id: string;
            label: string;
          }[];
        }[];
      };
      attendeePrompt?: string | null;
    };
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
