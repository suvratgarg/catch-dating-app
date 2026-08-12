/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Bounded details and handoff for a valid opaque event invitation.
 */
export interface ResolveEventInviteLandingCallableResponse {
  eventId: string;
  title: string;
  startTimeMillis: number;
  endTimeMillis: number;
  locationName: string;
  destinationKind:
    | "catchEvent"
    | "eventRuntime"
    | "externalBooking"
    | "marketingLanding";
  destinationUrl: string | null;
  sourceLabel: string;
}
