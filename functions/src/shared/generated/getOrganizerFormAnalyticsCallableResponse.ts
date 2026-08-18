/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Privacy-aware precomputed form funnel and compatible question aggregates.
 */
export interface GetOrganizerFormAnalyticsCallableResponse {
  organizerId: string;
  formId: string;
  versionId: string;
  version: number;
  opens: number;
  starts: number;
  submissions: number;
  withdrawals: number;
  completionRate: number;
  medianCompletionMillis: number | null;
  /**
   * @maxItems 200
   */
  questions: {
    questionId: string;
    label: string;
    kind:
      | "shortText"
      | "longText"
      | "singleChoice"
      | "multiChoice"
      | "date"
      | "phone"
      | "email"
      | "url"
      | "number"
      | "boolean"
      | "file"
      | "acknowledgement"
      | "signature";
    privacyClass: "contact" | "profile" | "sensitive" | "organizerCustom";
    responseCount: number;
    /**
     * @maxItems 100
     */
    choiceCounts: {
      value: string | boolean;
      label: string;
      count: number;
    }[];
    numericCount: number;
    numericSum: number;
    numericMin: number | null;
    numericMax: number | null;
  }[];
  /**
   * @maxItems 200
   */
  sources: {
    sourceLinkId: string | null;
    label: string;
    opens: number;
    starts: number;
    submissions: number;
  }[];
  privacyThreshold: number;
}
