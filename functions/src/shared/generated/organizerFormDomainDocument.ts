/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned exact hostname lease and verified form binding. Client reads and writes are forbidden.
 */
export interface OrganizerFormDomainDocument {
  hostname: string;
  organizerId: string;
  formId: string;
  publicFormId: string;
  ownershipChallenge: string;
  expectedCname: string;
  status: "pending" | "verified" | "active" | "revoked";
  certificateStatus: "pending" | "ready" | "failed";
  verifiedAtMillis: number | null;
  generation: number;
  reservedAtMillis: number;
  pendingExpiresAtMillis: number;
}
