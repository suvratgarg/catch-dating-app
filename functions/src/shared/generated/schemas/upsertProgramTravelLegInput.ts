/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const upsertProgramTravelLegCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/upsert_program_travel_leg_payload.schema.json",
  "title": "UpsertProgramTravelLegCallablePayload",
  "description": "Create or update one guest journey. Guest and journey kind are immutable; party membership is owned by upsertProgramTravelParty.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "guestId",
    "kind",
    "passengers",
    "luggageUnits",
    "requiredCapabilities",
    "dedicatedVehicle"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "legId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "guestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "kind": {
      "type": "string",
      "enum": [
        "inbound",
        "outbound",
        "ground"
      ]
    },
    "flightNumber": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^[A-Z0-9]{2,3}-?[0-9]{1,4}[A-Z]?$"
        },
        {
          "type": "null"
        }
      ]
    },
    "carrierCode": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 3
    },
    "originIata": {
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
    "destinationIata": {
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
    "scheduledArrivalAtMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 253402300799999
    },
    "international": {
      "type": [
        "boolean",
        "null"
      ],
      "description": "True for international sectors; selects the program's international exit lag."
    },
    "pickupPointId": {
      "type": [
        "string",
        "null"
      ],
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
    "passengers": {
      "type": "integer",
      "minimum": 1,
      "maximum": 200
    },
    "luggageUnits": {
      "type": "integer",
      "minimum": 0,
      "maximum": 500
    },
    "requiredCapabilities": {
      "type": "array",
      "maxItems": 12,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "wheelchairAccessible",
          "extraLuggage",
          "childSeat"
        ]
      }
    },
    "dedicatedVehicle": {
      "type": "boolean"
    }
  },
  "allOf": [
    {
      "if": {
        "required": [
          "legId"
        ]
      },
      "then": {
        "required": [
          "expectedRevision"
        ]
      }
    }
  ]
} as const;
