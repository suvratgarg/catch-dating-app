/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface QueryOrganizerFormResponsesCallableResponse {
  form: {
    formId: string;
    title: string;
    versionId: string;
    version: number;
  };
  fieldCatalog: {
    questionId: string;
    label: string;
    kind: string;
    operators: string[];
    sortable: boolean;
    options: {
      value: string;
      label: string;
    }[];
  }[];
  /**
   * @maxItems 100
   */
  items: {
    responseId: string;
    formId: string;
    formTitle: string;
    versionId: string;
    version: number;
    status: "submitted" | "withdrawn";
    identityKind:
      | "anonymous"
      | "emailVerified"
      | "phoneVerified"
      | "catchAccount";
    identity: {
      displayName: string | null;
      email: string | null;
      phoneE164: string | null;
      origin: "anonymous" | "respondentGranted" | "organizerAcquired";
    };
    sourceLinkId: string | null;
    submittedAtMillis: number;
    withdrawnAtMillis: number | null;
  }[];
  total: number;
  nextCursor: string | null;
  /**
   * @maxItems 5000
   */
  selectedIds: string[];
  queryHash: string;
  resultHash: string;
}
