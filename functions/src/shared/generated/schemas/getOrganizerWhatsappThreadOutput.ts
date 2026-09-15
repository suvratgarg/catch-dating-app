/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getOrganizerWhatsappThreadCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/get_organizer_whatsapp_thread_response.schema.json",
  "title": "GetOrganizerWhatsappThreadCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "threadId",
    "contactId",
    "displayName",
    "lastInboundAtMillis",
    "serviceWindowExpiresAtMillis",
    "serviceWindowOpen",
    "messages",
    "messagesTruncated"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
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
    "linkedUid": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 128,
      "description": "Verified current account identity for this organizer contact; absent on older servers and null for unresolved, merged, hidden or deleted identities."
    },
    "displayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
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
    },
    "messages": {
      "type": "array",
      "maxItems": 200,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "messageId",
          "direction",
          "body",
          "occurredAtMillis"
        ],
        "properties": {
          "messageId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "direction": {
            "type": "string",
            "enum": [
              "inbound",
              "outbound"
            ]
          },
          "body": {
            "type": "string",
            "minLength": 1,
            "maxLength": 4096
          },
          "occurredAtMillis": {
            "type": "integer",
            "minimum": 0
          }
        }
      }
    },
    "messagesTruncated": {
      "type": "boolean"
    }
  },
  "definitions": {
    "message": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "messageId",
        "direction",
        "body",
        "occurredAtMillis"
      ],
      "properties": {
        "messageId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "direction": {
          "type": "string",
          "enum": [
            "inbound",
            "outbound"
          ]
        },
        "body": {
          "type": "string",
          "minLength": 1,
          "maxLength": 4096
        },
        "occurredAtMillis": {
          "type": "integer",
          "minimum": 0
        }
      }
    }
  }
} as const;
