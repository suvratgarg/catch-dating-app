/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Idempotently applies one reviewed response conversion.
 */
export interface ConvertOrganizerFormResponseCallablePayload {
  organizerId: string;
  responseId: string;
  kind: "crmContact" | "application" | "eventAttendeeProposal" | "followUp";
  eventId: string | null;
  overrides: {
    [k: string]: string | number | boolean | null;
  };
  requestId: string;
}
