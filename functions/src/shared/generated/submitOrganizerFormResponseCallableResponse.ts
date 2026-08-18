/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Stable form response receipt.
 */
export type SubmitOrganizerFormResponseCallableResponse = {
  responseId: string;
  formId: string;
  versionId: string;
  status: "submitted" | "withdrawn";
  submittedAtMillis: number;
  withdrawalToken: string | null;
  completion: {
    title: string;
    message: string | null;
    actionKind: "none" | "externalUrl" | "event" | "eventRuntime";
    actionLabel: string | null;
    actionUrl: string | null;
  };
};
