/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Safe manager-only organizer contact rows and opaque pagination state.
 */
export interface ListOrganizerContactsCallableResponse {
  organizerId: string;
  /**
   * @maxItems 100
   */
  contacts: {
    contactId: string;
    displayName: string;
    phoneE164: string | null;
    email: string | null;
    identityState: "unlinked" | "verified" | "ambiguous";
    identityConfidence: "eventOnly" | "proposed" | "verified";
    ambiguousCandidateCount: number;
    attendedEventCount: number;
    expectedEventCount: number;
    lastAttendedAtMillis: number | null;
    /**
     * @maxItems 16
     */
    segmentIds: (
      | "new_to_organizer"
      | "first_time_attendee"
      | "repeat_attendee"
      | "regular"
      | "lapsed_regular"
      | "reliable_attendee"
      | "needs_confirmation"
      | "whatsapp_reachable"
      | "sms_reachable"
    )[];
    whatsappStatus: "unknown" | "optedIn" | "optedOut";
    smsStatus: "unknown" | "optedIn" | "optedOut";
    sourceCoverage: "exact" | "partial" | "insufficientData";
    revision: number;
  }[];
  nextCursor: string | null;
  sourceCoverage: "exact" | "partial";
  projectionVersion: number;
}
