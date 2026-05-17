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
  hostGoal: string;
  privateCrushEnabled: boolean;
  contextualOpenersEnabled: boolean;
  activeStepIndex: number;
  status: "setup" | "live" | "complete";
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
