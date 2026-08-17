/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Loads one published organizer application form and private, review-required suggestions for the authenticated participant.
 */
export interface GetParticipantOrganizerApplicationFormCallablePayload {
  organizerId: string;
  formId: string;
  targetKind: "organizer" | "event" | "campaign";
  targetId: string | null;
}
