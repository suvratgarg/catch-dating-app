/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminRevokeOrganizerEntitlementGrantCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_revoke_organizer_entitlement_grant_payload.schema.json",
  "title": "AdminRevokeOrganizerEntitlementGrantCallablePayload",
  "description": "Admin-authorized revocation of one existing entitlement grant. operationId makes the mutation idempotent across retries; revoke of an unknown or already-revoked grant fails closed.",
  "type": "object",
  "additionalProperties": false,
  "x-owner": "Admin console finance ops",
  "required": [
    "organizerId",
    "operationId",
    "grantId",
    "reason"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "operationId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{16,120}$"
    },
    "grantId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "reason": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    }
  }
} as const;
