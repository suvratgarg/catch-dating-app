/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable server-only provisioning audit created with approval consumption and readiness mutation. Hashes bind archive, exact readiness and independently audited external authority fence. No TTL or private message/contact content.
 */
export interface CatchWhatsappReadinessAuditDocument {
  schemaVersion: 1;
  auditId: string;
  approvalId: string;
  action: "create" | "revoke";
  projectId: string;
  actorUid: string;
  atMillis: number;
  provenanceSha256: string | null;
  recordSha256: string;
  readinessId: string;
  authorityFenceSha256: string;
}
