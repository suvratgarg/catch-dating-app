/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable idempotency and audit receipt for a dry-run or applied external-event publication/takedown action.
 */
export interface ExternalEventPublicationReceiptDocument {
  schemaVersion: 1;
  receiptId: string;
  idempotencyKey: string;
  inputHash: string;
  action: "publish" | "takedown";
  executionMode: "dry_run" | "apply";
  outcome: "would_publish" | "published" | "would_remove" | "removed";
  eventId: string;
  targetPath: string;
  sourceActionId: string | null;
  externalLinkCount: number;
  reviewNote: string;
  actorUid: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
