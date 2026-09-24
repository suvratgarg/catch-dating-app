/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface QueryOrganizerFormResponsesCallablePayload {
  organizerId: string;
  formId: string;
  versionId: string;
  /**
   * @minItems 1
   * @maxItems 2
   */
  statuses: ("submitted" | "withdrawn")[];
  /**
   * Published-version-aware compiler validates ALL/ANY tree, operators, value types, sensitive exclusion, depth 3 and maximum 20 leaves before any response scan.
   */
  predicate: {
    [k: string]: unknown;
  } | null;
  sort: {
    questionId: string | null;
    direction: "asc" | "desc";
    nulls: "first" | "last";
  };
  limit: number;
  cursor: string | null;
}
