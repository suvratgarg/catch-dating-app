/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listOrganizerWhatsappThreadsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/list_organizer_whatsapp_threads_response.schema.json",
  "title": "ListOrganizerWhatsappThreadsCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "threads",
    "nextCursor"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "threads": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "threadId",
          "contactId",
          "displayName",
          "eventIds",
          "lastMessageBody",
          "lastMessageDirection",
          "lastMessageAtMillis",
          "lastInboundAtMillis",
          "serviceWindowExpiresAtMillis",
          "serviceWindowOpen"
        ],
        "properties": {
          "threadId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "contactId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "displayName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "eventIds": {
            "type": "array",
            "maxItems": 50,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            }
          },
          "lastMessageBody": {
            "type": "string",
            "minLength": 1,
            "maxLength": 4096
          },
          "lastMessageDirection": {
            "type": "string",
            "enum": [
              "inbound",
              "outbound"
            ]
          },
          "lastMessageAtMillis": {
            "type": "integer",
            "minimum": 0
          },
          "lastInboundAtMillis": {
            "type": "integer",
            "minimum": 0
          },
          "serviceWindowExpiresAtMillis": {
            "type": "integer",
            "minimum": 0
          },
          "serviceWindowOpen": {
            "type": "boolean"
          }
        }
      }
    },
    "nextCursor": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 512
    }
  },
  "definitions": {
    "thread": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "threadId",
        "contactId",
        "displayName",
        "eventIds",
        "lastMessageBody",
        "lastMessageDirection",
        "lastMessageAtMillis",
        "lastInboundAtMillis",
        "serviceWindowExpiresAtMillis",
        "serviceWindowOpen"
      ],
      "properties": {
        "threadId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "contactId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "displayName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "eventIds": {
          "type": "array",
          "maxItems": 50,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          }
        },
        "lastMessageBody": {
          "type": "string",
          "minLength": 1,
          "maxLength": 4096
        },
        "lastMessageDirection": {
          "type": "string",
          "enum": [
            "inbound",
            "outbound"
          ]
        },
        "lastMessageAtMillis": {
          "type": "integer",
          "minimum": 0
        },
        "lastInboundAtMillis": {
          "type": "integer",
          "minimum": 0
        },
        "serviceWindowExpiresAtMillis": {
          "type": "integer",
          "minimum": 0
        },
        "serviceWindowOpen": {
          "type": "boolean"
        }
      }
    }
  }
} as const;
