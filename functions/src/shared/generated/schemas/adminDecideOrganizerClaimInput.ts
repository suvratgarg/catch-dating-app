/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminDecideOrganizerClaimCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_decide_organizer_claim_payload.schema.json",
  "title": "AdminDecideOrganizerClaimCallablePayload",
  "description": "Callable payload accepted by adminDecideOrganizerClaim.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "decision"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "decision": {
      "type": "string",
      "enum": [
        "approve",
        "reject"
      ]
    },
    "decisionReason": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    }
  }
} as const;
