/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Sanitized event and caller state for the no-download runtime.
 */
export interface GetEventRuntimeBootstrapCallableResponse {
  event: {
    eventId: string;
    publicRuntimeId: string;
    title: string;
    startTimeMillis: number;
    endTimeMillis: number;
    locationName: string;
    checkedInCount: number;
    runtimeTermsVersion: string;
    /**
     * @maxItems 24
     */
    moduleIds: string[];
    interactionModel:
      | "pacePods"
      | "pairedRotations"
      | "teamRotations"
      | "seatedTable"
      | "freeFormMixer"
      | "hostLedProgram"
      | "openFormat";
    layout: null | {
      layoutId: string;
      label: string;
      /**
       * @minItems 1
       * @maxItems 200
       */
      units: {
        id: string;
        label: string;
        shape: "round" | "rect" | "row" | "court" | "zone";
        capacity: number;
        gridX: number;
        gridY: number;
        order: number;
      }[];
    };
    /**
     * Fields that must be completed before event mode opens: display name plus at most one server-selected pre-event payload. Optional preference fields are never required for entry.
     *
     * @maxItems 10
     */
    requiredFieldIds: (
      | "displayName"
      | "gender"
      | "interestedInGenders"
      | "relationshipGoal"
      | "dateOfBirth"
      | "paceBand"
      | "skillBand"
      | "dietaryAndSeatingNotes"
      | "questionnaireAnswerIds"
      | "teamName"
    )[];
    /**
     * Plan-derived event-only answers the guest may provide to improve preference-aware suggestions. Guests may skip them and receive neutral assignments.
     *
     * @maxItems 10
     */
    optionalFieldIds: (
      | "displayName"
      | "gender"
      | "interestedInGenders"
      | "relationshipGoal"
      | "dateOfBirth"
      | "paceBand"
      | "skillBand"
      | "dietaryAndSeatingNotes"
      | "questionnaireAnswerIds"
      | "teamName"
    )[];
    questionnaireConfig: null | {
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
  };
  participant: null | {
    accessStatus:
      | "needsClaim"
      | "pendingApproval"
      | "needsInput"
      | "ready"
      | "optedOut"
      | "revoked";
    attendanceStatus:
      | "invited"
      | "registered"
      | "waitlisted"
      | "checkedIn"
      | "cancelled"
      | null;
    eventId: string;
    clubId: string;
    organizerId: string;
    /**
     * @maxItems 10
     */
    requiredFieldIds: string[];
    /**
     * @maxItems 10
     */
    completedFieldIds: string[];
    runtimeProfile: {
      displayName: string;
      gender: "man" | "woman" | "nonBinary" | "other" | null;
      interestedInGenders: ("man" | "woman" | "nonBinary" | "other")[];
      relationshipGoal:
        | "relationship"
        | "casual"
        | "marriage"
        | "friendship"
        | "unsure"
        | null;
      dateOfBirthMillis: number | null;
      paceBand: "competitive" | "fast" | "moderate" | "easy" | null;
      skillBand: "beginner" | "intermediate" | "advanced" | null;
      dietaryAndSeatingNotes: string | null;
      /**
       * @maxItems 8
       */
      questionnaireAnswerIds: string[];
      teamName: string | null;
    };
  };
}
