/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Bounded own completed-demo proof for private claim review delay. Contains references and hashes, never grant tokens or synthetic guest data. Every resume rechecks current identity, scope and real manager authority before Forms materialization.
 */
export interface SalesDemoContinuationDocument {
  schemaVersion: 1;
  classification: "sales_private";
  continuationId: string;
  actorUid: string;
  organizerId: string;
  invitationId: string;
  invitationRevision: number;
  invitationExpiresAt: string;
  blueprintId: string;
  blueprintRevision: number;
  sessionId: string;
  sessionRevision: number;
  setupHash: string;
  completedAt: string;
  createdAt: string;
  expiresAt: string;
}
