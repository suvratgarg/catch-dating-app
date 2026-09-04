/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventRuntimeAccessSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/embedded/event_runtime_access.schema.json",
  "title": "EventRuntimeAccess",
  "description": "Server-owned public join configuration for the no-download Event Success runtime.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "enabled",
    "publicRuntimeId",
    "walkInPolicy",
    "termsVersion"
  ],
  "properties": {
    "enabled": {
      "type": "boolean"
    },
    "publicRuntimeId": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[A-Za-z0-9_-]{20,80}$"
    },
    "walkInPolicy": {
      "type": "string",
      "enum": [
        "deny",
        "hostApproval",
        "autoCreate"
      ]
    },
    "termsVersion": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80
    }
  }
} as const;
