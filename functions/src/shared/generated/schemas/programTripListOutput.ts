/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programTripListCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/program_trip_list_response.schema.json",
  "title": "ProgramTripListCallableResponse",
  "description": "Manager/dispatcher/reconciliation trip ledger: the dispatch record that drives vendor reconciliation.",
  "type": "object",
  "additionalProperties": false,
  "x-callable-aliases": [
    "listProgramTrips"
  ],
  "required": [
    "programId",
    "trips",
    "accessExpiresAtMillis",
    "nextCursor"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "trips": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "tripId",
          "pickupPointId",
          "destinationHotelId",
          "destinationLabel",
          "vehicleClassId",
          "plateDisplay",
          "vendorId",
          "kind",
          "status",
          "passengerCount",
          "departedAtMillis",
          "arrivedAtMillis",
          "voidReason",
          "guestNames",
          "revision",
          "manifestSource",
          "vehicleClassLabel"
        ],
        "properties": {
          "tripId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
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
            "maxLength": 180
          },
          "destinationLabel": {
            "type": "string",
            "minLength": 1,
            "maxLength": 140
          },
          "vehicleClassId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 60
          },
          "plateDisplay": {
            "type": "string",
            "minLength": 4,
            "maxLength": 16
          },
          "vendorId": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 180
          },
          "vendorName": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 140
          },
          "kind": {
            "type": "string",
            "enum": [
              "guestTransfer",
              "repositioning"
            ]
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
          "passengerCount": {
            "type": "integer",
            "minimum": 1,
            "maximum": 200
          },
          "departedAtMillis": {
            "type": "integer",
            "minimum": 0
          },
          "arrivedAtMillis": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0
          },
          "voidReason": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 280
          },
          "guestNames": {
            "type": "array",
            "maxItems": 50,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 140
            }
          },
          "revision": {
            "type": "integer",
            "minimum": 1
          },
          "manifestSource": {
            "type": "string",
            "enum": [
              "dispatchSnapshot",
              "currentRecords"
            ],
            "description": "Whether displayed guest names were captured with dispatch or resolved from current records for a legacy trip."
          },
          "vehicleClassLabel": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 1,
            "maxLength": 60,
            "description": "Vehicle-class label recorded with dispatch. Null when the legacy trip has no snapshot."
          }
        }
      }
    },
    "accessExpiresAtMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1,
      "maximum": 9007199254740991,
      "description": "Exclusive deadline for retaining this scoped projection. Earliest contributing duty expiry; null only for organizer managers. Refresh after expiry even if another narrower duty remains active."
    },
    "nextCursor": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
