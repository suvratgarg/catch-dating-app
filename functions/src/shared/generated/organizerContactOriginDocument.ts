/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned provenance for one organizer contact source. Source facts are immutable; only currentContactId moves during a receipt-backed merge or unmerge.
 */
export interface OrganizerContactOriginDocument {
  organizerId: string;
  currentContactId: string;
  originContactId: string;
  sourceKind:
    | "catchBooking"
    | "hostImport"
    | "hostManual"
    | "webOtp"
    | "providerSync"
    | "hostForm";
  sourceEntityKind:
    | "eventAttendee"
    | "manualEntry"
    | "hostFormResponse"
    | "providerRecord"
    | "importBatch"
    | "webRegistration";
  sourceEntityId: string;
  eventId: string | null;
  formId: string | null;
  responseId: string | null;
  actorClass: "participant" | "organizerManager" | "provider" | "system";
  actorUid: string | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  observedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  originVersion: 1;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
