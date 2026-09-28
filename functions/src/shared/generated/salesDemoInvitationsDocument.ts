/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private digest-only invitation. Contact endpoint is retained only as a keyed digest.
 */
export interface SalesDemoInvitationsDocument {
  schemaVersion: 1;
  classification: "sales_private";
  invitationId: string;
  blueprintId: string;
  blueprintRevision: number;
  tokenDigest: string;
  contactBinding: null | {
    kind: "email" | "phone";
    digest: string;
  };
  expiresAt: string;
  revoked: boolean;
  revision: number;
  sessionCap: number;
  sessionCount: number;
  startReceiptCount: number;
  startWindowMinute: number;
  startWindowCount: number;
  currentSessionId: null | string;
  issuedByUid: string;
  issuedAt: string;
  revokedByUid?: string;
  revokedAt?: string;
}
