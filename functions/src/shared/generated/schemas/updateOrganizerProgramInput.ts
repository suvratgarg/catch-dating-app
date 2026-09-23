/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const updateOrganizerProgramCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/update_organizer_program_payload.schema.json",
  "title": "UpdateOrganizerProgramCallablePayload",
  "description": "Patch program fields. Omitted fields are unchanged; expectedRevision fences concurrent edits.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "expectedRevision"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "title": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140
    },
    "timezone": {
      "type": "string",
      "minLength": 1,
      "maxLength": 60
    },
    "startsAtMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "endsAtMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "status": {
      "type": "string",
      "enum": [
        "draft",
        "active",
        "completed",
        "archived"
      ]
    },
    "capabilities": {
      "type": "array",
      "maxItems": 8,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "arrivalsTransport",
          "accommodation",
          "forms",
          "messaging"
        ]
      }
    },
    "transportSettings": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "bandWindowMillis",
        "maxReadyWaitMillis",
        "domesticExitLagMillis",
        "internationalExitLagMillis",
        "vehicleClasses"
      ],
      "properties": {
        "bandWindowMillis": {
          "type": "integer",
          "minimum": 300000,
          "maximum": 7200000,
          "description": "Anchored curb-time window used by grouping suggestions. Default 30 minutes."
        },
        "maxReadyWaitMillis": {
          "type": "integer",
          "minimum": 60000,
          "maximum": 3600000,
          "description": "Ceiling on how long a physically ready party waits before a group is flagged overdue. Default 10 minutes for premium events."
        },
        "domesticExitLagMillis": {
          "type": "integer",
          "minimum": 0,
          "maximum": 7200000,
          "description": "Default landing-to-curb lag for domestic arrivals."
        },
        "internationalExitLagMillis": {
          "type": "integer",
          "minimum": 0,
          "maximum": 14400000,
          "description": "Default landing-to-curb lag for international arrivals."
        },
        "vehicleClasses": {
          "type": "array",
          "maxItems": 16,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "id",
              "label",
              "passengerCapacity",
              "luggageCapacity",
              "capabilities",
              "sortOrder"
            ],
            "properties": {
              "id": {
                "type": "string",
                "minLength": 1,
                "maxLength": 60,
                "pattern": "^[a-z0-9][a-z0-9_-]{0,59}$"
              },
              "label": {
                "type": "string",
                "minLength": 1,
                "maxLength": 60
              },
              "passengerCapacity": {
                "type": "integer",
                "minimum": 1,
                "maximum": 200
              },
              "luggageCapacity": {
                "type": "integer",
                "minimum": 0,
                "maximum": 500
              },
              "capabilities": {
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
              "sortOrder": {
                "type": "integer",
                "minimum": 0,
                "maximum": 1000
              }
            }
          },
          "description": "Program-scoped vehicle catalog consumed by grouping suggestions; ids are unique per program."
        }
      }
    }
  }
} as const;
