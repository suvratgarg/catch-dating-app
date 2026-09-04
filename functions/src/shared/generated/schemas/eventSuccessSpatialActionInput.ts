/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventSuccessSpatialActionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/event_success_spatial_action_payload.schema.json",
  "title": "EventSuccessSpatialActionCallablePayload",
  "description": "Revision-fenced Host spatial-control action.",
  "x-callable-aliases": [
    "controlEventSuccessSpatial"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "expectedRevision",
    "action",
    "moduleId",
    "uid"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "action": {
      "type": "string",
      "enum": [
        "previewReassignment",
        "reassign",
        "confirmPosition",
        "releasePinned"
      ]
    },
    "moduleId": {
      "type": "string",
      "enum": [
        "micro_pods",
        "guided_rotations"
      ]
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "destinationUnitId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,79}$"
    },
    "scope": {
      "type": "string",
      "enum": [
        "thisRound",
        "pinned"
      ]
    }
  }
} as const;
