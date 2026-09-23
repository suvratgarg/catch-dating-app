/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programTransportPlanCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/program_transport_plan_response.schema.json",
  "title": "ProgramTransportPlanCallableResponse",
  "description": "Deterministic grouping suggestions from the transport policy, recomputed per request. Suggestions are not reservations; dispatch is a separate command.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "pickupPointId",
    "generatedAtMillis",
    "groups",
    "unassigned",
    "accessExpiresAtMillis"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "pickupPointId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "generatedAtMillis": {
      "type": "integer",
      "minimum": 0
    },
    "groups": {
      "type": "array",
      "maxItems": 200,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "legIds",
          "partyIds",
          "destinationHotelId",
          "destinationLabel",
          "readiness",
          "vehicleClassId",
          "vehicleClassLabel",
          "passengers",
          "luggageUnits",
          "earliestCurbAtMillis",
          "latestCurbAtMillis",
          "dispatchByMillis",
          "waitOverdue"
        ],
        "properties": {
          "legIds": {
            "type": "array",
            "minItems": 1,
            "maxItems": 50,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            }
          },
          "partyIds": {
            "type": "array",
            "maxItems": 50,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            }
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
          "readiness": {
            "type": "string",
            "enum": [
              "expected",
              "ready"
            ]
          },
          "vehicleClassId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 60
          },
          "vehicleClassLabel": {
            "type": "string",
            "minLength": 1,
            "maxLength": 60
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
          "earliestCurbAtMillis": {
            "type": "integer",
            "minimum": 0
          },
          "latestCurbAtMillis": {
            "type": "integer",
            "minimum": 0
          },
          "dispatchByMillis": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0
          },
          "waitOverdue": {
            "type": "boolean"
          }
        }
      }
    },
    "unassigned": {
      "type": "array",
      "maxItems": 500,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "legId",
          "reason"
        ],
        "properties": {
          "legId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "reason": {
            "type": "string",
            "enum": [
              "missingTime",
              "noSuitableVehicle",
              "missingScope"
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
