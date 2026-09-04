/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminDecideSafetyTriageItemCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_decide_safety_triage_item_payload.schema.json",
  "title": "Admin Decide Safety Triage Item Callable Payload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "targetPath",
    "decision",
    "note"
  ],
  "properties": {
    "targetPath": {
      "type": "string",
      "maxLength": 260,
      "pattern": "^(reports|moderationFlags|eventSafetyReports)/[^/]+$"
    },
    "decision": {
      "type": "string",
      "enum": [
        "review",
        "dismiss"
      ]
    },
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    }
  },
  "definitions": {
    "targetPath": {
      "type": "string",
      "maxLength": 260,
      "pattern": "^(reports|moderationFlags|eventSafetyReports)/[^/]+$"
    }
  }
} as const;
