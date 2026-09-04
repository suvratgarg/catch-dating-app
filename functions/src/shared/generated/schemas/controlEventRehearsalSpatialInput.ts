/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const controlEventRehearsalSpatialCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/control_event_rehearsal_spatial_payload.schema.json",
  "title": "ControlEventRehearsalSpatialCallablePayload",
  "description": "Previews or persists one synthetic actor placement inside an isolated dress rehearsal.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "sessionId",
    "expectedRevision",
    "clientActionId",
    "actorId",
    "action",
    "destinationUnitId",
    "scope"
  ],
  "properties": {
    "sessionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "clientActionId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{8,120}$"
    },
    "actorId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "action": {
      "type": "string",
      "enum": [
        "reassign",
        "confirmPosition",
        "releasePinned"
      ]
    },
    "destinationUnitId": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^table-[1-9][0-9]*$",
          "maxLength": 40
        },
        {
          "type": "null"
        }
      ]
    },
    "scope": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "thisRound",
        "pinned",
        null
      ]
    }
  }
} as const;
