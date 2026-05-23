/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Canonical safety block edge stored at blocks/{blockId}.
 */
export interface BlockDocument {
  blockerUserId: string;
  blockedUserId: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  source: "profile" | "chat" | "match" | "support";
  reasonCode?: string;
}
