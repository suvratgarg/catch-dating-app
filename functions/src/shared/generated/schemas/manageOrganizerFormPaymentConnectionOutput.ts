/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const manageOrganizerFormPaymentConnectionCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/manage_organizer_form_payment_connection_response.schema.json",
  "title": "ManageOrganizerFormPaymentConnectionCallableResponse",
  "description": "Safe connection status and one-use OAuth link. No merchant credentials.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "available",
    "authorizationUrl",
    "connectionId",
    "expiresAtMillis",
    "connections"
  ],
  "properties": {
    "available": {
      "type": "boolean"
    },
    "authorizationUrl": {
      "anyOf": [
        {
          "type": "string",
          "format": "uri",
          "maxLength": 4000
        },
        {
          "type": "null"
        }
      ]
    },
    "connectionId": {
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
    },
    "expiresAtMillis": {
      "anyOf": [
        {
          "type": "integer",
          "minimum": 0
        },
        {
          "type": "null"
        }
      ]
    },
    "connections": {
      "type": "array",
      "maxItems": 100,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "connectionId",
          "status",
          "mode",
          "accountId",
          "webhookVerified",
          "lastErrorCode"
        ],
        "properties": {
          "connectionId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "status": {
            "type": "string",
            "enum": [
              "connecting",
              "ready",
              "needsAttention",
              "disconnected"
            ]
          },
          "mode": {
            "type": "string",
            "enum": [
              "test",
              "live"
            ]
          },
          "accountId": {
            "anyOf": [
              {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              },
              {
                "type": "null"
              }
            ]
          },
          "webhookVerified": {
            "type": "boolean"
          },
          "lastErrorCode": {
            "anyOf": [
              {
                "type": "string",
                "minLength": 1,
                "maxLength": 80
              },
              {
                "type": "null"
              }
            ]
          }
        }
      }
    }
  }
} as const;
