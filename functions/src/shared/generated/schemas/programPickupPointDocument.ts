/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programPickupPointDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/program_pickup_points.schema.json",
  "title": "ProgramPickupPointDocument",
  "description": "Server-owned program pickup station such as an airport terminal arrivals zone. Scopes greeter and dispatcher duties and transport grouping.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "programPickupPoints",
  "x-firestore-path": "programPickupPoints/{pickupPointId}",
  "x-document-id-field": "pickupPointId",
  "x-owner": "program resource setup callables",
  "required": [
    "programId",
    "organizerId",
    "kind",
    "label",
    "iataCode",
    "terminal",
    "meetingZone",
    "latitude",
    "longitude",
    "instructions",
    "active",
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
    "kind": {
      "type": "string",
      "enum": [
        "airport",
        "railway",
        "venue",
        "other"
      ]
    },
    "label": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140,
      "description": "Station label such as 'DEL T3 arrivals exit 4'."
    },
    "iataCode": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^[A-Z]{3}$"
        },
        {
          "type": "null"
        }
      ]
    },
    "terminal": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 40
    },
    "meetingZone": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 140
    },
    "latitude": {
      "type": [
        "number",
        "null"
      ],
      "minimum": -90,
      "maximum": 90
    },
    "longitude": {
      "type": [
        "number",
        "null"
      ],
      "minimum": -180,
      "maximum": 180
    },
    "instructions": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500,
      "description": "Guest-facing pickup instructions shown on travel confirmations."
    },
    "active": {
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
    }
  }
} as const;
