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
     * Fields that must be completed before event mode opens. Sensitive preference fields are never required for entry.
     *
     * @maxItems 5
     */
    requiredFieldIds: (
      | "displayName"
      | "gender"
      | "interestedInGenders"
      | "relationshipGoal"
      | "dateOfBirth"
    )[];
    /**
     * Plan-derived event-only answers the guest may provide to improve preference-aware suggestions. Guests may skip them and receive neutral assignments.
     *
     * @maxItems 5
     */
    optionalFieldIds: (
      | "displayName"
      | "gender"
      | "interestedInGenders"
      | "relationshipGoal"
      | "dateOfBirth"
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
     * @maxItems 5
     */
    requiredFieldIds: string[];
    /**
     * @maxItems 5
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
    };
  };
}
