/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Idempotent reviewed downstream conversion and safe-undo boundary.
 */
export interface OrganizerFormConversionReceiptDocument {
  organizerId: string;
  formId: string;
  responseId: string;
  kind: "crmContact" | "application" | "eventAttendeeProposal" | "followUp";
  requestId: string;
  actorUid: string;
  status: "pending" | "completed" | "failed";
  /**
   * @maxItems 100
   */
  fields: {
    destinationField: string;
    label: string;
    value: string | number | boolean | null;
    origin: "verifiedIdentity" | "formAnswer" | "hostOverride";
    conflict: string | null;
  }[];
  resultId: string | null;
  undoStatus: "notAvailable" | "available" | "used" | "expired";
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
  completedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
