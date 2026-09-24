/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Organizer maps reviewed versioned form questions to bounded soft assignment features; it does not grant answer use.
 */
export interface ConfigureEventAssignmentFeaturesCallablePayload {
  eventId: string;
  expectedRevision: number;
  requestId: string;
  /**
   * @maxItems 8
   */
  rules: {
    featureId: string;
    formId: string;
    versionId: string;
    questionId: string;
    transformVersion: number;
    kind: "category" | "set" | "number" | "ordinal";
    mode: "preferSimilar" | "preferDifferent" | "balanceAcrossGroups";
    weight: number;
    /**
     * @maxItems 40
     */
    optionIds?: string[];
    scoreByOptionId?: {
      [k: string]: number;
    };
    minimum?: number;
    maximum?: number;
  }[];
}
