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
  /**
   * Current canonical social membership truth. Host selections update it through upsertProgramGuest; imported group labels append source-labelled suggestions without changing this projection.
   *
   * @maxItems 20
   */
  groupIds: string[];
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
  /**
   * Identity/free-text scrub marker set by the archive retention sweep; null until anonymized.
   */
  anonymizedAt?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Current values are a projection of these exact immutable same-program assertions. Absent fields have unknown acquisition provenance.
   */
  fieldSelections?: {
    displayName?: string;
    phoneE164?: string;
    email?: string;
  };
  /**
   * Imported conflicting assertions awaiting explicit host field choice. All historical assertions remain in their scoped ledger.
   */
  fieldConflicts?: {
    /**
     * @maxItems 20
     */
    displayName?: string[];
    /**
     * @maxItems 20
     */
    phoneE164?: string[];
    /**
     * @maxItems 20
     */
    email?: string[];
  };
  /**
   * Exact immutable host membership choices; includes and excludes survive every import.
   *
   * @maxItems 100
   */
  membershipSelections?: {
    groupId: string;
    assertionId: string;
  }[];
  /**
   * Source-labelled unapproved membership assertions. Never add canonical groupIds without a host choice.
   *
   * @maxItems 100
   */
  membershipSuggestions?: {
    groupId: string;
    assertionId: string;
  }[];
}
