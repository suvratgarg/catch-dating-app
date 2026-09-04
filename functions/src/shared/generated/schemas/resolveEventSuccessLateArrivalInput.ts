/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const resolveEventSuccessLateArrivalCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/resolve_event_success_late_arrival_payload.schema.json",
  "title": "ResolveEventSuccessLateArrivalCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "uid",
    "expectedRevision",
    "confirmed"
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
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "confirmed": {
      "type": "boolean",
      "const": true
    }
  }
} as const;
