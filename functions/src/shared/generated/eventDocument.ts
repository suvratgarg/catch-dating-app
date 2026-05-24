/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Canonical event document stored at events/{eventId}. The event id is the document id and is not stored in document data.
 */
export interface EventDocument {
  clubId: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  startTime: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  endTime: {
    _seconds: number;
    _nanoseconds: number;
  };
  meetingPoint: string;
  /**
   * Canonical meeting location selected from Google Places or a manually pinned map coordinate.
   */
  meetingLocation?: {
    name: string;
    address?: string | null;
    placeId?: string | null;
    latitude: number | null;
    longitude: number | null;
    notes?: string | null;
  };
  startingPointLat: number | null;
  startingPointLng: number | null;
  locationDetails: string | null;
  photoUrl?: string | null;
  distanceKm: number;
  eventFormat: {
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
  pace: "easy" | "moderate" | "fast" | "competitive";
  capacityLimit: number;
  description: string;
  priceInPaise: number;
  currency?: string;
  bookedCount: number;
  checkedInCount: number;
  waitlistedCount: number;
  status: "active" | "cancelled";
  cancelledAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  cancellationReason: string | null;
  constraints: {
    minAge: number;
    maxAge: number;
    maxMen: number | null;
    maxWomen: number | null;
  };
  eventPolicy?: {
    version: 1;
    admission: {
      format:
        | "open"
        | "inviteOnly"
        | "manualApproval"
        | "fixedCohortCaps"
        | "balancedRatio"
        | "membersOnly";
      capacityLimit: number;
      waitlistPolicy: {
        mode:
          | "disabled"
          | "rankedOffer"
          | "broadcastFirstComeFirstServed"
          | "manualReview";
        offerWindowMinutes: number;
      };
      inviteRequired: boolean;
      membershipRequired: boolean;
      manualApprovalRequired: boolean;
      privateAccessPolicy: {
        mode: "none" | "inviteCode";
        inviteCodeHint: string | null;
        privateLinkEnabled: boolean;
      };
      cohortCapacityLimits: {
        [k: string]: number;
      };
      balancedRatioPolicy: {
        leftCohortId: string;
        rightCohortId: string;
        maxSkew: number;
        openingBufferPerCohort: number;
        outOfRatioCohortPolicy:
          | "admitWithinGeneralCapacity"
          | "waitlist"
          | "manualReview"
          | "reject";
      } | null;
    };
    pricing: {
      basePriceInPaise: number;
      cohortAdjustmentsInPaise: {
        [k: string]: number;
      };
      /**
       * @maxItems 20
       */
      demandPricingRules: {
        pricedCohortId: string;
        balancingCohortId: string;
        stepAdjustmentInPaise: number;
        maxAdjustmentInPaise: number;
        freeSkew: number;
        demandStep: number;
      }[];
    };
    cancellation: {
      policyId: "flexible" | "standard" | "strict";
    };
    settlement: {
      hostPayoutTiming: "afterEventCompletion";
    };
  };
  genderCounts: {
    [k: string]: number;
  };
  cohortCounts: {
    [k: string]: number;
  };
  waitlistedCohortCounts: {
    [k: string]: number;
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
