/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned organizer listing claim request stored at clubClaimRequests/{requestId}.
 */
export interface ClubClaimRequestDocument {
  requestId: string;
  clubId: string;
  requesterUid: string;
  requesterName: string;
  requesterRole:
    | "owner"
    | "founder"
    | "manager"
    | "marketer"
    | "venueManager"
    | "other";
  businessEmail: string | null;
  businessPhone: string | null;
  /**
   * @maxItems 8
   */
  proofUrls: string[];
  message: string | null;
  status: "pending" | "approved" | "rejected" | "withdrawn" | "superseded";
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
  decidedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  decidedByUid: string | null;
  decisionReason: string | null;
  previousRequestId: string | null;
}
