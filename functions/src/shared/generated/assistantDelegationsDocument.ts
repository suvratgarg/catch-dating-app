/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private expiring action and entity grant from an employee to one registered assistant client.
 */
export interface AssistantDelegationsDocument {
  schemaVersion: 1;
  classification: "sales_private";
  delegationId: string;
  actorUid: string;
  clientId: string;
  /**
   * @minItems 1
   * @maxItems 20
   */
  allowedActions: (
    | "hosts.search"
    | "hosts.get"
    | "tasks.list"
    | "opportunities.list"
    | "fields.list"
    | "receipts.get"
    | "activities.log"
    | "tasks.upsert"
    | "opportunities.upsert"
    | "fields.create"
    | "fields.setValue"
    | "evidence.propose"
  )[];
  /**
   * @minItems 1
   * @maxItems 30
   */
  organizerIds: string[];
  /**
   * @maxItems 50
   */
  fieldIds: string[];
  expiresAt: string;
  maxRequestsPerMinute: number;
  maxRequestsPerDay: number;
  revoked: boolean;
  revision: number;
  issuedByUid: string;
  issuedAt: string;
  revokedByUid?: string;
  revokedAt?: string;
}
