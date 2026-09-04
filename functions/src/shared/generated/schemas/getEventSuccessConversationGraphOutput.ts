/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getEventSuccessConversationGraphCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/get_event_success_conversation_graph_response.schema.json",
  "title": "GetEventSuccessConversationGraphCallableResponse",
  "description": "Attendee-only end-of-event conversation graph form projection.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "consentMode",
    "prompt",
    "candidates",
    "selectedUids",
    "submissionStatus"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "consentMode": {
      "type": "string",
      "enum": [
        "optIn",
        "optOut"
      ]
    },
    "prompt": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "candidates": {
      "type": "array",
      "maxItems": 1000,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "uid",
          "displayName",
          "assigned"
        ],
        "properties": {
          "uid": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "displayName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "assigned": {
            "type": "boolean"
          }
        }
      }
    },
    "selectedUids": {
      "type": "array",
      "uniqueItems": true,
      "maxItems": 1000,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    },
    "submissionStatus": {
      "type": "string",
      "enum": [
        "unsubmitted",
        "submitted",
        "skipped"
      ]
    }
  }
} as const;
