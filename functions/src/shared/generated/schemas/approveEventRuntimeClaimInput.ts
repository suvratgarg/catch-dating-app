/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const approveEventRuntimeClaimCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/approve_event_runtime_claim_payload.schema.json",
  "title": "ApproveEventRuntimeClaimCallablePayload",
  "description": "Host decision for one pending Event Success runtime claim.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "uid",
    "decision"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "uid": {
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
    "attendeeId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "reason": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240
    }
  }
} as const;
