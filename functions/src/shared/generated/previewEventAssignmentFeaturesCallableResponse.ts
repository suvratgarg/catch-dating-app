/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * No answer values or participant identities: current roster coverage for an unsaved mapping.
 */
export interface PreviewEventAssignmentFeaturesCallableResponse {
  eventId: string;
  revision: number;
  rosterCount: number;
  coverageBasis: "currentEventRoster";
  /**
   * @maxItems 8
   */
  sources: {
    formId: string;
    formTitle: string;
    versionId: string;
    isActiveVersion: boolean;
    /**
     * @maxItems 100
     */
    questions: {
      questionId: string;
      label: string;
      kind: "singleChoice" | "multiChoice" | "number";
      /**
       * @maxItems 40
       */
      options: {
        optionId: string;
        label: string;
      }[];
    }[];
  }[];
  /**
   * @maxItems 8
   */
  rows: {
    featureId: string;
    kind: "category" | "set" | "number" | "ordinal";
    mode: "preferSimilar" | "preferDifferent" | "balanceAcrossGroups";
    weight: number;
    grantedCount: number;
    missingCount: number;
  }[];
}
