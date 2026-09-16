/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceGroupStaffCallableResponseSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "outcome",
    "operationRevision",
    "view"
  ],
  "properties": {
    "outcome": {
      "enum": [
        "read",
        "applied",
        "replayed"
      ]
    },
    "operationRevision": {
      "anyOf": [
        {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        {
          "type": "null"
        }
      ]
    },
    "view": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "context",
        "groupId",
        "sourceHash",
        "serverTime",
        "uid",
        "displayName",
        "phoneLastFour",
        "revision",
        "status",
        "duty",
        "operatorExpiresAtMillis",
        "canAssign",
        "availableDuties"
      ],
      "properties": {
        "context": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "mode",
            "eventId",
            "organizerId"
          ],
          "properties": {
            "mode": {
              "type": "string",
              "const": "live"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "organizerId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            }
          }
        },
        "groupId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "sourceHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "serverTime": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
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
        "phoneLastFour": {
          "type": "string",
          "pattern": "^[0-9]{4}$"
        },
        "revision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "status": {
          "enum": [
            "none",
            "assigned",
            "expired",
            "revoked",
            "sourceChanged"
          ]
        },
        "duty": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "groupId",
                "duty",
                "expiresAtMillis",
                "sourceHash",
                "grantedBy",
                "grantedAtMillis"
              ],
              "properties": {
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "duty": {
                  "enum": [
                    "lead",
                    "pacer",
                    "sweep"
                  ]
                },
                "expiresAtMillis": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "sourceHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "grantedBy": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "grantedAtMillis": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                }
              }
            },
            {
              "type": "null"
            }
          ]
        },
        "operatorExpiresAtMillis": {
          "anyOf": [
            {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            {
              "type": "null"
            }
          ]
        },
        "canAssign": {
          "type": "boolean"
        },
        "availableDuties": {
          "type": "array",
          "maxItems": 3,
          "uniqueItems": true,
          "items": {
            "enum": [
              "lead",
              "pacer",
              "sweep"
            ]
          }
        }
      }
    }
  },
  "title": "EventAssistanceGroupStaffCallableResponse"
} as const;
