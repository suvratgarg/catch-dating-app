/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminDecideAccessApplicationCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_decide_access_application_response.schema.json",
  "title": "Admin Decide Access Application Callable Response",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "applicationUid",
    "decision",
    "status"
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
    "status": {
      "type": "string",
      "enum": [
        "approvedForProfile",
        "notSelectedYet"
      ]
    }
  }
} as const;
