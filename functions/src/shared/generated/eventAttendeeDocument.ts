/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private event-scoped operational attendee stored at eventAttendees/{attendeeId}.
 */
export interface EventAttendeeDocument {
  eventId: string;
  clubId: string;
  organizerId: string;
  displayName: string;
  searchName: string;
  source: "catchBooking" | "hostImport" | "hostManual" | "webOtp";
  status: "invited" | "registered" | "waitlisted" | "checkedIn" | "cancelled";
  linkedUid: string | null;
  phoneE164: string | null;
  email: string | null;
  externalReference: string | null;
  ticketType: string | null;
  importId: string | null;
  sourceRowId: string | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  registeredAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  waitlistedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  checkedInAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  cancelledAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  checkedInBy: string | null;
  linkedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * First eligible opaque invitation link preserved on this operational attendee.
   */
  inviteLinkId?: string | null;
  inviteCapturedAt?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
