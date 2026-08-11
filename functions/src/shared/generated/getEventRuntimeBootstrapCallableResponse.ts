/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Sanitized event and caller state for the no-download runtime.
 */
export interface GetEventRuntimeBootstrapCallableResponse {
  event: {
    publicRuntimeId: string;
    title: string;
    startTimeMillis: number;
    endTimeMillis: number;
    locationName: string;
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
