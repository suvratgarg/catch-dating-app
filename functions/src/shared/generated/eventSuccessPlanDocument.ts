/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

/**
 * Host-owned live event-success setup stored at eventSuccessPlans/{eventId}. The event id is the document id and is also stored for cheap validation and reads.
 */
export interface EventSuccessPlanDocument {
  eventId: string;
  clubId: string;
  playbookId: string;
  /**
   * @maxItems 24
   */
  selectedModuleIds: string[];
  targetAttendeeCount: number;
  structureConfig?: {
    unitKind: "wholeGroup" | "pods" | "pairs" | "teams" | "tables";
    unitSize: number;
    unitCount?: number | null;
    rotationIntervalMinutes?: number | null;
    revealCountdownSeconds: number;
  };
  hostGoal: string;
  wingmanRequestsEnabled: boolean;
  contextualOpenersEnabled: boolean;
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
  activeStepIndex: number;
  status: "setup" | "live" | "complete";
  revealStatus?: "idle" | "countingDown" | "revealed";
  activeRevealRoundIndex?: number;
  revealStartedAt?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  revealEndsAt?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  attendeePrompt?: string | null;
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
  frozenAt?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  completedAt?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
