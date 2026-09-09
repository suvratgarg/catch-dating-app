/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceDepartureRosterDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "rosterId",
    "context",
    "groupId",
    "progressId",
    "progressRevision",
    "sourceHash",
    "confirmedBy",
    "confirmedAt",
    "members"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "rosterId": {
      "type": "string",
      "pattern": "^departure-roster:[a-f0-9]{64}$"
    },
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
    "progressId": {
      "type": "string",
      "pattern": "^progress:[a-f0-9]{64}$"
    },
    "progressRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "sourceHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "confirmedBy": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000
    },
    "confirmedAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "members": {
      "type": "array",
      "maxItems": 1000,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "attendeeId",
          "sourceGeneration",
          "attendeeGeneration",
          "checkInHash",
          "episodeId",
          "membershipHash"
        ],
        "properties": {
          "attendeeId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "sourceGeneration": {
            "type": "string",
            "pattern": "^[a-f0-9]{64}$"
          },
          "attendeeGeneration": {
            "type": "string",
            "pattern": "^[a-f0-9]{64}$"
          },
          "checkInHash": {
            "type": "string",
            "pattern": "^[a-f0-9]{64}$"
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
          "membershipHash": {
            "anyOf": [
              {
                "type": "string",
                "pattern": "^[a-f0-9]{64}$"
              },
              {
                "type": "null"
              }
            ]
          }
        }
      }
    },
    "destination": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "placeId",
            "lateEntry"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "fixedPlace"
            },
            "placeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "lateEntry": {
              "type": "string",
              "enum": [
                "allowed",
                "hostDecision",
                "closed"
              ]
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "itineraryId",
            "stopId"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "itineraryStop"
            },
            "itineraryId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            },
            "stopId": {
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
            "kind",
            "routeId",
            "groupId",
            "checkpointId"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "groupCheckpoint"
            },
            "routeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            },
            "groupId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "checkpointId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            }
          }
        }
      ]
    },
    "checkpointRequest": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "responsibleOperatorId",
        "dueAt"
      ],
      "properties": {
        "responsibleOperatorId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 128,
          "pattern": "^[^/]+$"
        },
        "dueAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        }
      }
    }
  },
  "title": "EventAssistanceDepartureRosterDocument",
  "x-firestore-collection": "eventAssistanceDepartureRosters",
  "x-firestore-path": "eventAssistanceDepartureRosters/{rosterId}",
  "x-document-id-field": "rosterId",
  "x-owner": "event-assistance departure command"
} as const;
