/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const upsertProgramTravelPartyCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/upsert_program_travel_party_payload.schema.json",
  "title": "UpsertProgramTravelPartyCallablePayload",
  "description": "Create or update a ride-together travel party.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "memberGuestIds",
    "dedicatedVehicle"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "partyId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "label": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 140
    },
    "memberGuestIds": {
      "type": "array",
      "minItems": 1,
      "maxItems": 50,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      },
      "description": "One to fifty people traveling together. A one-person party supports private transfers and staged manifest imports."
    },
    "dedicatedVehicle": {
      "type": "boolean"
    }
  }
} as const;
