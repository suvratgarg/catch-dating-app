/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventRehearsalRouteDecisionDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "sessionId",
    "clockId",
    "groupId",
    "progressRevision",
    "previousRevision",
    "departureRevision",
    "sourceHash",
    "alternativeId",
    "destination",
    "decisionId",
    "operationId",
    "decidedBy",
    "decidedAt"
  ],
  "properties": {
    "sessionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "clockId": {
      "type": "string",
      "pattern": "^clock:[a-f0-9]{64}$"
    },
    "groupId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "progressRevision": {
      "type": "integer",
      "minimum": 2,
      "maximum": 500
    },
    "previousRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 499
    },
    "departureRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 499
    },
    "sourceHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "alternativeId": {
      "type": "string",
      "pattern": "^alternative:[a-f0-9]{64}$"
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
    "decisionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "operationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "decidedBy": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "decidedAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  },
  "title": "EventRehearsalRouteDecisionDocument",
  "description": "An immutable synthetic route override layered on a recorded rehearsal departure.",
  "x-firestore-collection": "eventRehearsalRouteDecisions",
  "x-firestore-path": "eventRehearsalRouteDecisions/{decisionDocumentId}",
  "x-document-id-field": "id",
  "x-owner": "event rehearsal callables"
} as const;
