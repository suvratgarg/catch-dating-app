/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Precomputed form/version funnel or privacy-aware question aggregate.
 */
export interface OrganizerFormAggregateDocument {
  organizerId: string;
  formId: string;
  versionId: string;
  scope: "version" | "question";
  questionId: string | null;
  questionLabel: string | null;
  questionKind:
    | (
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
        | "signature"
      )
    | null;
  privacyClass: null | "contact" | "profile" | "sensitive" | "organizerCustom";
  opens: number;
  starts: number;
  submissions: number;
  withdrawals: number;
  completionMillisTotal: number;
  /**
   * @maxItems 12
   */
  completionBuckets: {
    upperBoundMillis: number;
    count: number;
  }[];
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
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
