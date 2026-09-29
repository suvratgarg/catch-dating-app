/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Admin-authorized revocation of one existing entitlement grant. operationId makes the mutation idempotent across retries; revoke of an unknown or already-revoked grant fails closed.
 */
export interface AdminRevokeOrganizerEntitlementGrantCallablePayload {
  organizerId: string;
  operationId: string;
  grantId: string;
  reason: string;
}
