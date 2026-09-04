/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const overrideEventSuccessRotationsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/override_event_success_rotations_payload.schema.json",
  "title": "OverrideEventSuccessRotationsCallablePayload",
  "description": "Callable payload accepted by overrideEventSuccessRotations.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "expectedRevision",
    "rounds"
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
    "rounds": {
      "type": "array",
      "minItems": 1,
      "maxItems": 32,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "roundIndex",
          "pairings"
        ],
        "properties": {
          "roundIndex": {
            "type": "integer",
            "minimum": 0,
            "maximum": 31
          },
          "pairings": {
            "type": "array",
            "minItems": 0,
            "maxItems": 100,
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "uidA",
                "uidB"
              ],
              "properties": {
                "uidA": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "uidB": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                }
              }
            }
          }
        }
      }
    }
  }
} as const;
