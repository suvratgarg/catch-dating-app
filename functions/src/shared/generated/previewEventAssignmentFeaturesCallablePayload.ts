/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-only aggregate coverage preview for unsaved event-local structured matching rules.
 */
export interface PreviewEventAssignmentFeaturesCallablePayload {
  eventId: string;
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
  /**
   * @maxItems 4
   */
  sourceFormIds?: string[];
}
