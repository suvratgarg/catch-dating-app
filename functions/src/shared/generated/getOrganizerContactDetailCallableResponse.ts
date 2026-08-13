/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-only contact facts and bounded event timeline. Private feedback and Event Success inputs are excluded.
 */
export interface GetOrganizerContactDetailCallableResponse {
  organizerId: string;
  contactId: string;
  displayName: string;
  sourceDisplayName: string;
  displayNameOverride: string | null;
  phoneE164: string | null;
  email: string | null;
  linkedAccount: boolean;
  identityState: "unlinked" | "verified" | "ambiguous";
  identityConfidence: "eventOnly" | "proposed" | "verified";
  /**
   * @maxItems 20
   */
  ambiguousCandidateContactIds: string[];
  whatsappAdminSuppressed: boolean;
  traits: {
    expectedEventCount: number;
    attendedEventCount: number;
    cancelledEventCount: number;
    noShowCount: number;
    importedEventCount: number;
    attendanceRate: number | null;
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
      | "advocate"
      | "high_impact_advocate"
      | "whatsapp_reachable"
      | "sms_reachable"
    )[];
    whatsappStatus: "unknown" | "optedIn" | "optedOut";
    smsStatus: "unknown" | "optedIn" | "optedOut";
    sourceCoverage: "exact" | "partial" | "insufficientData";
  };
  revenue: {
    coverage: "exact" | "partial" | "unavailable";
    /**
     * @maxItems 8
     */
    amounts: {
      currency: string;
      amountMinor: number;
      paidOrderCount: number;
    }[];
  };
  /**
   * @maxItems 100
   */
  events: {
    eventId: string;
    attendeeId: string;
    displayName: string;
    source:
      | "catchBooking"
      | "hostImport"
      | "hostManual"
      | "webOtp"
      | "providerSync";
    status: "invited" | "registered" | "waitlisted" | "checkedIn" | "cancelled";
    expected: boolean;
    registered: boolean;
    cancelled: boolean;
    checkedIn: boolean;
    eventStartAtMillis: number | null;
    eventEndAtMillis: number | null;
    registeredAtMillis: number | null;
    cancelledAtMillis: number | null;
    checkedInAtMillis: number | null;
  }[];
  eventsTruncated: boolean;
  revision: number;
}
