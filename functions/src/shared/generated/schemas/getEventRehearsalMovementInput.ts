/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getEventRehearsalMovementCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_event_rehearsal_movement_payload.schema.json",
  "title": "GetEventRehearsalMovementCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "sessionId",
    "expectedSetupRevision",
    "scope"
  ],
  "properties": {
    "sessionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedSetupRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "scope": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "groupId"
      ],
      "properties": {
        "groupId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "progressRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 500
        },
        "beforeRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 501
        }
      }
    }
  }
} as const;
