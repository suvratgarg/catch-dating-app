/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Only the authenticated respondent's reviewed answer labels and purpose-specific decisions; old grants remain withdrawable after mapping/source changes.
 */
export interface ListEventAssignmentFeatureChoicesCallableResponse {
  eventId: string;
  /**
   * @maxItems 1000
   */
  choices: {
    featureId: string;
    responseId: string;
    questionLabel: string | null;
    answerLabel: string | null;
    status: "notGranted" | "granted" | "withdrawn";
    revision: number;
    canGrant: boolean;
  }[];
}
