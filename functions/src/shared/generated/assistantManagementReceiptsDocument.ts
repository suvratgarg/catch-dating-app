/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable server-side result of one owner management request; keyed by issuer and request id hash.
 */
export interface AssistantManagementReceiptsDocument {
  schemaVersion: 1;
  classification: "sales_private";
  receiptId: string;
  issuerUid: string;
  requestId: string;
  action:
    | "assistant.clients.set"
    | "assistant.delegations.issue"
    | "assistant.delegations.revoke";
  targetId: string;
  materialHash: string;
  result: {
    clientId?: string;
    authUid?: string;
    active?: boolean;
    delegationId?: string;
    actorUid?: string;
    allowedActions?: string[];
    organizerIds?: string[];
    fieldIds?: string[];
    expiresAt?: string;
    revoked?: boolean;
    revokedByUid?: string;
    revokedAt?: string;
    revision?: number;
    updatedAt?: string;
    issuedAt?: string;
  };
  createdAt: string;
}
