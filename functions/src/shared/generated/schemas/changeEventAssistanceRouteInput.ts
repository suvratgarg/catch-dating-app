/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const changeEventAssistanceRouteCallablePayloadSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "command"
  ],
  "properties": {
    "command": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "context",
        "eventId",
        "operationId",
        "payload"
      ],
      "properties": {
        "kind": {
          "type": "string",
          "const": "changeRoute"
        },
        "context": {
          "anyOf": [
            {
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
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "rehearsalId",
                "virtualEventId",
                "clockId"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "rehearsal"
                },
                "rehearsalId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "virtualEventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "clockId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                }
              }
            }
          ]
        },
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "operationId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "payload": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "routeRevision",
            "groupId",
            "expectedSourceHash",
            "alternativeId",
            "decisionId"
          ],
          "properties": {
            "routeRevision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991,
              "description": "Nonnegative safe integer revision."
            },
            "groupId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "expectedSourceHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "alternativeId": {
              "type": "string",
              "pattern": "^alternative:[a-f0-9]{64}$"
            },
            "decisionId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          }
        }
      }
    }
  },
  "allOf": [
    {
      "properties": {
        "command": {
          "properties": {
            "kind": {
              "const": "changeRoute"
            },
            "context": {
              "properties": {
                "mode": {
                  "const": "live"
                }
              }
            }
          }
        }
      }
    }
  ],
  "title": "ChangeEventAssistanceRouteCallablePayload"
} as const;
