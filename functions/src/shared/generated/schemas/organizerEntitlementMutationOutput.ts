/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerEntitlementMutationCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/organizer_entitlement_mutation_response.schema.json",
  "title": "OrganizerEntitlementMutationCallableResponse",
  "description": "Result of an admin entitlement grant or revoke mutation, including idempotent replay marker.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "organizerId",
    "revision",
    "grantId",
    "replayed"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "grantId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
