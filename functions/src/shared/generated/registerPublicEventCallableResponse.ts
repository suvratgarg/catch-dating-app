/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Registration receipt returned to the phone-authenticated website visitor.
 */
export interface RegisterPublicEventCallableResponse {
  eventId: string;
  attendeeId: string;
  status: "registered" | "waitlisted" | "alreadyRegistered";
}
