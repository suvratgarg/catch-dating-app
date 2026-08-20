/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Rebuildable organizer-person-event fact edge projected from the canonical operational attendee.
 */
export interface OrganizerContactEventEdgeDocument {
  organizerId: string;
  contactId: string;
  originContactId: string;
  eventId: string;
  attendeeId: string;
  displayName: string;
  eventDisplayName?: string | null;
  eventOriginMode?: "catchNative" | "externalCompanion" | null;
  eventProvider?:
    | "catch"
    | "generic"
    | "luma"
    | "eventbrite"
    | "partiful"
    | "posh"
    | "bookmyshow"
    | "district"
    | "sortmyscene"
    | "airbnb"
    | null;
  linkedUid: string | null;
  phoneE164: string | null;
  email: string | null;
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
  eventStartAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  eventEndAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  registeredAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  cancelledAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  checkedInAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  revenueAmountMinor?: number | null;
  revenueCurrency?: string | null;
  revenueSource?: "hostImport" | "hostEstimate" | "providerOrder" | null;
  revenueAllocation?: "perAttendee" | "sharedOrder" | null;
  revenueOrderReference?: string | null;
  inviteLinkId?: string | null;
  inviteCapturedAt?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  sourceCreatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  sourceUpdatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  revision: number;
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
}
