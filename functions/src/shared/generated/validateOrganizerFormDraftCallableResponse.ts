/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Publish-readiness result from the canonical form validator.
 */
export interface ValidateOrganizerFormDraftCallableResponse {
  valid: boolean;
  /**
   * @maxItems 250
   */
  issues: {
    code: string;
    path: string;
    message: string;
    severity: "error" | "warning";
  }[];
}
