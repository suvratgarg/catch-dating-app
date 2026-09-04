/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const overrideEventSuccessGroupsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/override_event_success_groups_payload.schema.json",
  "title": "OverrideEventSuccessGroupsCallablePayload",
  "description": "Callable payload accepted by overrideEventSuccessGroups.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "rounds"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
          "groups"
        ],
        "properties": {
          "roundIndex": {
            "type": "integer",
            "minimum": 0,
            "maximum": 31
          },
          "groups": {
            "type": "array",
            "minItems": 1,
            "maxItems": 100,
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "label",
                "participantUids"
              ],
              "properties": {
                "label": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 80
                },
                "participantUids": {
                  "type": "array",
                  "minItems": 1,
                  "maxItems": 24,
                  "items": {
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
  }
} as const;
