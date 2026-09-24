/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned person-level wedding/corporate guest record. One document per invited person; household membership and optional CRM contact links are explicit. A shared phone number never merges two guests.
 */
export interface ProgramGuestDocument {
  programId: string;
  organizerId: string;
  displayName: string;
  householdId: string | null;
  /**
   * Optional link to organizerContacts. Absence never blocks guest operations.
   */
  contactId: string | null;
  /**
   * Optional reachable phone for this person. Shared family phones do not merge identities.
   */
  phoneE164: string | null;
  email: string | null;
  /**
   * Planner-side reference such as a spreadsheet id or invitation code.
   */
  externalReference: string | null;
  invitationStatus: "notInvited" | "invited" | "delivered" | "responded";
  /**
   * Derived program-wide rollup maintained by the server from programFunctionGuests rows (any attending -> attending, else strongest other response). Per-function truth lives only on programFunctionGuests; writers never set this directly.
   */
  rsvpStatus: "pending" | "attending" | "declined" | "maybe";
  source: "manual" | "import" | "formResponse";
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
  revision: number;
}
