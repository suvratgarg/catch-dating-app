/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getOrganizerEntitlementCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_organizer_entitlement_payload.schema.json",
  "title": "GetOrganizerEntitlementCallablePayload",
  "description": "Requests the bounded entitlement projection (grants, meters, SKU catalog) for one managed organizer.",
  "type": "object",
  "additionalProperties": false,
  "x-owner": "Host organizer plan surface",
  "required": [
    "organizerId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
