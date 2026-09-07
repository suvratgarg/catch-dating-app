/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const resolveEventAssistanceAccountabilityCallablePayloadSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "groupId",
    "command",
    "expectedSourceHash"
  ],
  "properties": {
    "groupId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
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
          "const": "resolveAccountability"
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
            "attendeeId",
            "episodeId",
            "disposition"
          ],
          "properties": {
            "attendeeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "episodeId": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                {
                  "type": "null"
                }
              ],
              "description": "Current assistance episode, or explicit absence. The command adapter separately fences the canonical physical check-in."
            },
            "disposition": {
              "type": "string",
              "enum": [
                "returned",
                "departed",
                "unresolved"
              ]
            }
          }
        }
      }
    },
    "expectedSourceHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    }
  },
  "allOf": [
    {
      "properties": {
        "command": {
          "properties": {
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
  "title": "ResolveEventAssistanceAccountabilityCallablePayload"
} as const;
