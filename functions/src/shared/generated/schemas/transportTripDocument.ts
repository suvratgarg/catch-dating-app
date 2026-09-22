/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const transportTripDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/transport_trips.schema.json",
  "title": "TransportTripDocument",
  "description": "Server-owned dispatched vehicle record. The dispatch act is the reconciliation atom: plate, vendor, class and manifest are snapshotted at departure. Airport, hotel and finance surfaces read field-redacted projections.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "transportTrips",
  "x-firestore-path": "transportTrips/{tripId}",
  "x-document-id-field": "tripId",
  "x-owner": "program dispatch and arrival callables",
  "required": [
    "programId",
    "organizerId",
    "kind",
    "pickupPointId",
    "destinationHotelId",
    "destinationLabel",
    "vehicleClassId",
    "vendorId",
    "vendorNameSnapshot",
    "plateNormalized",
    "plateDisplay",
    "partyIds",
    "legIds",
    "passengerCount",
    "status",
    "departedAt",
    "departedByUid",
    "voidedByUid",
    "voidReason",
    "arrivedAt",
    "arrivedByUid",
    "rateSnapshot",
    "clientOperationId",
    "notes",
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
        "guestTransfer",
        "repositioning"
      ]
    },
    "pickupPointId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "destinationHotelId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "destinationLabel": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 140
    },
    "vehicleClassId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 60,
      "description": "Program vehicle-class catalog id snapshotted at dispatch."
    },
    "vendorId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "vendorNameSnapshot": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 140
    },
    "plateNormalized": {
      "type": "string",
      "minLength": 4,
      "maxLength": 16,
      "description": "Uppercased plate with separators stripped; the reconciliation join key."
    },
    "plateDisplay": {
      "type": "string",
      "minLength": 4,
      "maxLength": 16
    },
    "partyIds": {
      "type": "array",
      "maxItems": 50,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    },
    "legIds": {
      "type": "array",
      "minItems": 1,
      "maxItems": 50,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    },
    "passengerCount": {
      "type": "integer",
      "minimum": 1,
      "maximum": 200
    },
    "status": {
      "type": "string",
      "enum": [
        "enRoute",
        "arrived",
        "cancelled",
        "voided"
      ]
    },
    "departedAt": {
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
    "departedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "arrivedAt": {
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
    "voidedByUid": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "description": "Dispatcher/manager who voided the trip."
    },
    "voidReason": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 280,
      "description": "Required reason recorded when a dispatch is voided; reviewed in reconciliation."
    },
    "arrivedByUid": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "rateSnapshot": {
      "type": [
        "object",
        "null"
      ],
      "additionalProperties": false,
      "required": [
        "currency",
        "amountMinor",
        "pricingKind"
      ],
      "properties": {
        "currency": {
          "type": "string",
          "pattern": "^[A-Z]{3}$"
        },
        "amountMinor": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "pricingKind": {
          "type": "string",
          "enum": [
            "perTrip",
            "perVehicleDay",
            "custom"
          ]
        }
      },
      "description": "Optional agreed rate frozen at dispatch; commercial terms ship with the reconciliation slice."
    },
    "clientOperationId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 120,
      "description": "Idempotent dispatch key; a replay returns the original trip."
    },
    "notes": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 280
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
