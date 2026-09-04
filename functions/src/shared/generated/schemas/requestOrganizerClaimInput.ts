/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const requestOrganizerClaimCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/request_organizer_claim_payload.schema.json",
  "title": "RequestOrganizerClaimCallablePayload",
  "description": "Callable payload accepted by requestOrganizerClaim.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "requesterName",
    "requesterRole"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requesterName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "requesterRole": {
      "type": "string",
      "enum": [
        "owner",
        "founder",
        "manager",
        "marketer",
        "venueManager",
        "other"
      ]
    },
    "businessEmail": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 320
    },
    "businessPhone": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 32
    },
    "proofUrls": {
      "type": "array",
      "maxItems": 8,
      "items": {
        "type": "string",
        "format": "uri",
        "maxLength": 2048
      },
      "uniqueItems": true
    },
    "message": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    }
  }
} as const;
