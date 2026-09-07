/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceGroupProgressDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "progressId",
    "context",
    "groupId",
    "revision",
    "destination",
    "sourceHash",
    "confirmedBy",
    "confirmedAt",
    "operationId",
    "requestHash",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "progressId": {
      "type": "string",
      "pattern": "^progress:[a-f0-9]{64}$"
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
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
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
    "operationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "requestHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "createdAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "updatedAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  },
  "title": "EventAssistanceGroupProgressDocument",
  "x-firestore-collection": "eventAssistanceGroupProgress",
  "x-firestore-path": "eventAssistanceGroupProgress/{progressId}",
  "x-document-id-field": "progressId",
  "x-owner": "event-assistance departure command"
} as const;
