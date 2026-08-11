/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Submits the minimum event-scoped profile required by enabled Event Success modules.
 */
export interface SubmitEventRuntimeProfileCallablePayload {
  publicRuntimeId: string;
  runtimeTermsVersion: string;
  sensitiveDataTermsVersion?: string | null;
  saveAsCatchPrefill: boolean;
  fields: {
    displayName?: string;
    gender?: "man" | "woman" | "nonBinary" | "other" | null;
    /**
     * @maxItems 4
     */
    interestedInGenders?: ("man" | "woman" | "nonBinary" | "other")[];
    relationshipGoal?:
      | "relationship"
      | "casual"
      | "marriage"
      | "friendship"
      | "unsure"
      | null;
    dateOfBirthMillis?: number | null;
  };
}
