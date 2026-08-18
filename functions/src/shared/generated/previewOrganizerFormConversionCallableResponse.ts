/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Exact reviewed fields, conflicts, and permission boundary before conversion.
 */
export interface PreviewOrganizerFormConversionCallableResponse {
  organizerId: string;
  formId: string;
  responseId: string;
  kind: "crmContact" | "application" | "eventAttendeeProposal" | "followUp";
  eventId: string | null;
  allowed: boolean;
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
  /**
   * @maxItems 20
   */
  warnings: string[];
  existingResultId: string | null;
}
