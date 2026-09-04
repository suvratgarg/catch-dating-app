/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerMessagingSetupCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/organizer_messaging_setup_response.schema.json",
  "title": "OrganizerMessagingSetupCallableResponse",
  "description": "Safe organizer messaging connection and approved-template inventory.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "providerConfigured",
    "embeddedSignup",
    "connection",
    "templates"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "providerConfigured": {
      "type": "boolean"
    },
    "embeddedSignup": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "appId",
        "configId",
        "graphVersion"
      ],
      "properties": {
        "appId": {
          "type": [
            "string",
            "null"
          ]
        },
        "configId": {
          "type": [
            "string",
            "null"
          ]
        },
        "graphVersion": {
          "type": [
            "string",
            "null"
          ]
        }
      }
    },
    "connection": {
      "type": [
        "object",
        "null"
      ],
      "additionalProperties": false,
      "required": [
        "connectionId",
        "status",
        "displayPhoneNumber",
        "verifiedName",
        "qualityRating",
        "messagingLimitTier",
        "templateSyncStatus",
        "webhookStatus",
        "testStatus",
        "revision"
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
            "pending",
            "testing",
            "active",
            "degraded",
            "blocked",
            "tokenRevoked",
            "disconnected"
          ]
        },
        "displayPhoneNumber": {
          "type": [
            "string",
            "null"
          ]
        },
        "verifiedName": {
          "type": [
            "string",
            "null"
          ]
        },
        "qualityRating": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            null,
            "GREEN",
            "YELLOW",
            "RED",
            "UNKNOWN"
          ]
        },
        "messagingLimitTier": {
          "type": [
            "string",
            "null"
          ]
        },
        "templateSyncStatus": {
          "type": "string",
          "enum": [
            "notStarted",
            "current",
            "stale",
            "failed"
          ]
        },
        "webhookStatus": {
          "type": "string",
          "enum": [
            "notSubscribed",
            "subscribed",
            "degraded"
          ]
        },
        "testStatus": {
          "type": "string",
          "enum": [
            "notSent",
            "pending",
            "delivered",
            "failed"
          ]
        },
        "revision": {
          "type": "integer",
          "minimum": 1
        }
      }
    },
    "templates": {
      "type": "array",
      "maxItems": 200,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "templateId",
          "name",
          "language",
          "category",
          "status",
          "variableNames",
          "hasMediaHeader",
          "buttonKinds"
        ],
        "properties": {
          "templateId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "name": {
            "type": "string"
          },
          "language": {
            "type": "string"
          },
          "category": {
            "type": "string",
            "enum": [
              "MARKETING",
              "UTILITY",
              "AUTHENTICATION",
              "UNKNOWN"
            ]
          },
          "status": {
            "type": "string",
            "enum": [
              "APPROVED",
              "PENDING",
              "REJECTED",
              "PAUSED",
              "DISABLED",
              "DELETED",
              "UNKNOWN"
            ]
          },
          "variableNames": {
            "type": "array",
            "items": {
              "type": "string"
            }
          },
          "hasMediaHeader": {
            "type": "boolean"
          },
          "buttonKinds": {
            "type": "array",
            "items": {
              "type": "string"
            }
          }
        }
      }
    }
  }
} as const;
