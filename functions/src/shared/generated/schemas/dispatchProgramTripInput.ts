/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const dispatchProgramTripCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/dispatch_program_trip_payload.schema.json",
  "title": "DispatchProgramTripCallablePayload",
  "description": "Dispatch a vehicle: snapshot plate, vendor, class and manifest in one transaction that also writes per-leg active assignments and an idempotency receipt.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "pickupPointId",
    "vehicleClassId",
    "plateDisplay",
    "legIds",
    "clientOperationId",
    "expectedLegRevisions"
  ],
  "properties": {
    "programId": {
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
    "expectedLegRevisions": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "legId",
          "revision"
        ],
        "properties": {
          "legId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "revision": {
            "type": "integer",
            "minimum": 1,
            "maximum": 9007199254740991
          }
        }
      },
      "description": "Exactly one revision fence for every selected leg; missing, duplicate, extraneous or stale fences abort dispatch.",
      "minItems": 1,
      "uniqueItems": true
    },
    "departedAtMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 253402300799999,
      "description": "Explicit departure timestamp for late offline sync; defaults to server now."
    },
    "notes": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 280
    },
    "clientOperationId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 120
    }
  }
} as const;
