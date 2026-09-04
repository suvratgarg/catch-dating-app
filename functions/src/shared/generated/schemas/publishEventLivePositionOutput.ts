/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const publishEventLivePositionCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/publish_event_live_position_response.schema.json",
  "title": "PublishEventLivePositionCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "sharing",
    "role",
    "serverTimeMillis",
    "staleAfterSeconds",
    "expiresAtMillis"
  ],
  "properties": {
    "sharing": {
      "type": "boolean"
    },
    "role": {
      "type": "string",
      "enum": [
        "host",
        "operator"
      ]
    },
    "serverTimeMillis": {
      "type": "integer",
      "minimum": 0
    },
    "staleAfterSeconds": {
      "type": "integer",
      "minimum": 30,
      "maximum": 600
    },
    "expiresAtMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0
    }
  }
} as const;
