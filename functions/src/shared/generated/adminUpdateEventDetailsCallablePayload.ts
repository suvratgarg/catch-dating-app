/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by adminUpdateEventDetails. This edits low-risk app-facing canonical event fields through an audited admin callable.
 */
export interface AdminUpdateEventDetailsCallablePayload {
  eventId: string;
  reviewNote?: string | null;
  fields: {
    description?: string;
    photoUrl?: string | null;
    distanceKm?: number;
    pace?: "easy" | "moderate" | "fast" | "competitive";
    crossPathsDiscoveryEnabled?: boolean;
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
          version: 1;
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
        };
        [k: string]: unknown;
      };
    };
  };
}
