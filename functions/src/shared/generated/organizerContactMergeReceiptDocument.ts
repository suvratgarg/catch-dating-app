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
  /**
   * @maxItems 400
   */
  movedEdgeIds: string[];
  /**
   * @maxItems 400
   */
  movedIdentityEvidenceIds: string[];
  /**
   * @maxItems 400
   */
  movedClaimIds: string[];
  /**
   * @maxItems 400
   */
  movedOriginIds: string[];
  movedEdgeCount: number;
  movedIdentityEvidenceCount: number;
  movedClaimCount: number;
  movedOriginCount: number;
  idempotencyKey: string;
  reversalOfReceiptId: string | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * @maxItems 200
   */
  seatMoves?: {
    eventId: string;
    aliasId: string;
    kind: "contact" | "contactOrigin";
    valueHash: string;
    before: {
      canonicalKey: string;
      identityRevision: number;
      migrationRevision: number;
      state: "ready";
    } | null;
    after: {
      canonicalKey: string;
      identityRevision: number;
      migrationRevision: number;
      state: "ready";
    };
  }[];
  /**
   * @maxItems 100
   */
  seatEventGuards?: {
    eventId: string;
    ledgerRevision: number;
    migrationRevision: number;
    sourceReservation: {
      canonicalKey: string;
      identityRevision: number;
      revision: number;
      active: boolean;
    } | null;
    survivorReservation: {
      canonicalKey: string;
      identityRevision: number;
      revision: number;
      active: boolean;
    } | null;
    /**
     * @maxItems 200
     */
    aliasIdsBefore: string[];
    sourceAlias: {
      canonicalKey: string;
      identityRevision: number;
      migrationRevision: number;
      state: "ready";
    } | null;
    survivorAlias: {
      canonicalKey: string;
      identityRevision: number;
      migrationRevision: number;
      state: "ready";
    } | null;
  }[];
  /**
   * @maxItems 200
   */
  seatAdmissionGuards?: {
    eventId: string;
    responseId: string;
    ownershipId: string;
    receiptId: string | null;
  }[];
  /**
   * @maxItems 400
   */
  survivorOriginIdsBefore?: string[];
  /**
   * @maxItems 200
   */
  sourceOriginAliasIdsBefore?: string[];
}
