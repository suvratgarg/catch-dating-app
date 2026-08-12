/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable evidence for a manager-confirmed organizer contact merge or its reversal.
 */
export interface OrganizerContactMergeReceiptDocument {
  organizerId: string;
  operation: "merge" | "unmerge";
  survivorContactId: string;
  sourceContactId: string;
  /**
   * @maxItems 20
   */
  evidence: (
    | "sameVerifiedUid"
    | "sameVerifiedPhone"
    | "sameImportedPhone"
    | "sameEmail"
    | "managerConfirmed"
  )[];
  /**
   * @maxItems 20
   */
  conflicts: string[];
  actorUid: string;
  survivorRevision: number;
  sourceRevision: number;
  reversalOfReceiptId: string | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
