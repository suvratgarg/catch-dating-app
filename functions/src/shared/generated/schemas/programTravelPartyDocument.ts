/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programTravelPartyDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/program_travel_parties.schema.json",
  "title": "ProgramTravelPartyDocument",
  "description": "Server-owned ride-together membership for specific travel legs. This is independent of invitation households and does not apply to a guest's other journeys.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "programTravelParties",
  "x-firestore-path": "programTravelParties/{partyId}",
  "x-document-id-field": "partyId",
  "x-owner": "program travel callables",
  "required": [
    "programId",
    "organizerId",
    "label",
    "legIds",
    "dedicatedVehicle",
    "createdAt",
    "updatedAt",
    "revision"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "label": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 140
    },
    "dedicatedVehicle": {
      "type": "boolean"
    },
    "createdAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    },
    "updatedAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "legIds": {
      "type": "array",
      "minItems": 0,
      "maxItems": 50,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      },
      "description": "Explicit travel legs in this ride-together party. Guest identities are derived from those legs. An existing un-dispatched party may be emptied to release its members."
    }
  }
} as const;
