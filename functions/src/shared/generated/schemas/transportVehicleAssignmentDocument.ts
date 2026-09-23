/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const transportVehicleAssignmentDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/transport_vehicle_assignments.schema.json",
  "title": "TransportVehicleAssignmentDocument",
  "description": "Server-owned organizer-wide occupancy of a normalized vehicle plate. Dispatch reserves the vehicle atomically with its passenger assignments. Arrival or void releases only the matching trip; active reservations never expire by age.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "transportVehicleAssignments",
  "x-firestore-path": "transportVehicleAssignments/{assignmentId}",
  "x-document-id-field": "assignmentId",
  "x-owner": "program dispatch transaction",
  "required": [
    "organizerId",
    "plateNormalized",
    "programId",
    "tripId",
    "status",
    "assignedAt",
    "releasedAt",
    "revision"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "tripId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "released"
      ]
    },
    "assignedAt": {
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
    "releasedAt": {
      "anyOf": [
        {
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
        {
          "type": "null"
        }
      ]
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "plateNormalized": {
      "type": "string",
      "pattern": "^[A-Z0-9]{4,16}$"
    }
  }
} as const;
