/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Only the authenticated caller can resolve their own linked operational attendee. Ambiguity exposes no candidate identities and never selects a row.
 */
export interface EventAssistanceParticipantContextCallableResponse {
  eventId: string;
  subjectUid: string;
  serverTime: number;
  resolution:
    | {
        kind: "linked";
        organizerId: string;
        attendeeId: string;
        sourceHash: string;
      }
    | {
        kind: "unlinked" | "ambiguous";
      };
}
