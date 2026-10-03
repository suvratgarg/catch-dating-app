/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getEventViewerStateCallablePayloadSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "inviteCode": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        {
          "type": "null"
        }
      ]
    },
    "publicPaymentId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    }
  },
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_event_viewer_state_payload.schema.json",
  "title": "GetEventViewerStateCallablePayload",
  "description": "Read current account-scoped event facts using an Auth-derived subject; never reserve or grant admission.",
  "x-callable-aliases": [
    "getEventViewerState"
  ]
} as const;
