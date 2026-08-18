/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Completed reviewed conversion receipt.
 */
export interface ConvertOrganizerFormResponseCallableResponse {
  receiptId: string;
  organizerId: string;
  formId: string;
  responseId: string;
  kind: "crmContact" | "application" | "eventAttendeeProposal" | "followUp";
  status: "pending" | "completed" | "failed";
  /**
   * @maxItems 100
   */
  fields: {
    destinationField: string;
    label: string;
    value: string | number | boolean | null;
    origin: "verifiedIdentity" | "formAnswer" | "hostOverride";
    conflict: string | null;
  }[];
  resultId: string | null;
  undoStatus: "notAvailable" | "available" | "used" | "expired";
  completedAtMillis: number | null;
}
