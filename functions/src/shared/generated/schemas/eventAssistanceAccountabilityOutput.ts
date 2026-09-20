/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceAccountabilityCallableResponseSchema: Record<string, unknown> = {
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
        "attendeeId",
        "serverTime",
        "sourceHash",
        "revision",
        "episodeId",
        "disposition",
        "availability"
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
        "attendeeId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "serverTime": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "sourceHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "revision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
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
          ]
        },
        "disposition": {
          "enum": [
            "returned",
            "departed",
            "unresolved"
          ]
        },
        "availability": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind"
              ],
              "properties": {
                "kind": {
                  "const": "ready"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "reason"
              ],
              "properties": {
                "kind": {
                  "const": "unavailable"
                },
                "reason": {
                  "enum": [
                    "notApplicable",
                    "notCheckedIn",
                    "departureNotRecorded",
                    "notOnDeparture",
                    "visitChanged",
                    "setupChanged",
                    "differentCheckpoint",
                    "destinationNotRecorded",
                    "notCheckpoint"
                  ]
                }
              }
            }
          ]
        },
        "checkpoint": {
          "description": "An explicitly recorded departure at a named checkpoint; it never infers a roster or changes event-wide sweep configuration.",
          "type": "object",
          "additionalProperties": false,
          "required": [
            "checkpointId",
            "progressRevision"
          ],
          "properties": {
            "checkpointId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            },
            "progressRevision": {
              "type": "integer",
              "minimum": 1,
              "maximum": 9007199254740991
            }
          }
        }
      }
    }
  },
  "title": "EventAssistanceAccountabilityCallableResponse"
} as const;
