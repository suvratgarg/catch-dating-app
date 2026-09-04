/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminDecideAccessApplicationCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_decide_access_application_payload.schema.json",
  "title": "Admin Decide Access Application Callable Payload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "applicationUid",
    "decision",
    "note"
  ],
  "properties": {
    "applicationUid": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "decision": {
      "type": "string",
      "enum": [
        "approve",
        "deny"
      ]
    },
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    },
    "cohortId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        {
          "type": "null"
        }
      ]
    }
  }
} as const;
