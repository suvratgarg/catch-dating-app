/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned account-deletion tombstone stored at deletedUsers/{uid}.
 */
export interface DeletedUserTombstoneDocument {
  uid: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  deletedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  retainedFor?: string[];
}
