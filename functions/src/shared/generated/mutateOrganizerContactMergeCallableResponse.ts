/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable organizer contact merge or reversal receipt projection.
 */
export interface MutateOrganizerContactMergeCallableResponse {
  receiptId: string;
  operation: "merge" | "unmerge";
  survivorContactId: string;
  sourceContactId: string;
  movedEdgeCount: number;
  movedIdentityEvidenceCount: number;
  movedClaimCount: number;
  movedOriginCount: number;
  replayed: boolean;
}
