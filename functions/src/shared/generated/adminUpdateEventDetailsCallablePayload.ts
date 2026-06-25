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
      };
      activityDetails?: {
        [k: string]: unknown;
      };
    };
  };
}
