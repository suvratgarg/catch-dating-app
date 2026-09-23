/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programHotelDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/program_hotels.schema.json",
  "title": "ProgramHotelDocument",
  "description": "Server-owned program accommodation property. Scopes hotel-desk duties, guest stays and transport destinations.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "programHotels",
  "x-firestore-path": "programHotels/{hotelId}",
  "x-document-id-field": "hotelId",
  "x-owner": "program resource setup callables",
  "required": [
    "programId",
    "organizerId",
    "name",
    "address",
    "latitude",
    "longitude",
    "receptionContact",
    "notes",
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
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140
    },
    "address": {
      "type": "string",
      "minLength": 1,
      "maxLength": 300
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
    "receptionContact": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 140
    },
    "notes": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500
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
