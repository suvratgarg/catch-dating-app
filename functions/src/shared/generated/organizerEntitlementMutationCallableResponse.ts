/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Result of an admin entitlement grant or revoke mutation, including idempotent replay marker.
 */
export interface OrganizerEntitlementMutationCallableResponse {
  schemaVersion: 1;
  organizerId: string;
  revision: number;
  grantId: string;
  replayed: boolean;
}
