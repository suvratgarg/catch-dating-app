/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programHotelInboundCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/program_hotel_inbound_response.schema.json",
  "title": "ProgramHotelInboundCallableResponse",
  "description": "Hotel-desk projection for one property: en-route trips and guests still expected. No phone numbers, flight internals or other hotels' data.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "hotelId",
    "hotelName",
    "generatedAtMillis",
    "trips",
    "expectedLegs",
    "accessExpiresAtMillis"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "hotelId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "hotelName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140
    },
    "generatedAtMillis": {
      "type": "integer",
      "minimum": 0
    },
    "trips": {
      "type": "array",
      "maxItems": 200,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "tripId",
          "plateDisplay",
          "vehicleClassId",
          "vendorName",
          "departedAtMillis",
          "estimatedArriveAtMillis",
          "passengerCount",
          "guestNames",
          "status",
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
          "plateDisplay": {
            "type": "string",
            "minLength": 4,
            "maxLength": 16
          },
          "vehicleClassId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 60
          },
          "vendorName": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 140
          },
          "departedAtMillis": {
            "type": "integer",
            "minimum": 0
          },
          "estimatedArriveAtMillis": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0,
            "description": "Route ETA once the Maps adapter ships; null until then."
          },
          "passengerCount": {
            "type": "integer",
            "minimum": 1,
            "maximum": 200
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
          "status": {
            "type": "string",
            "enum": [
              "enRoute",
              "arrived",
              "cancelled",
              "voided"
            ]
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
    "expectedLegs": {
      "type": "array",
      "maxItems": 500,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "legId",
          "guestDisplayName",
          "partyLabel",
          "passengers",
          "curbAtMillis",
          "readiness"
        ],
        "properties": {
          "legId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "guestDisplayName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 140
          },
          "partyLabel": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 140
          },
          "passengers": {
            "type": "integer",
            "minimum": 1,
            "maximum": 200
          },
          "curbAtMillis": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0
          },
          "readiness": {
            "type": "string",
            "enum": [
              "expected",
              "ready",
              "dispatched",
              "arrived",
              "disrupted",
              "noShow"
            ]
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
    }
  }
} as const;
