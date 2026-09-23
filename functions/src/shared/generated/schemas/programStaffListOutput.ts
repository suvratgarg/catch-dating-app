/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programStaffListCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/program_staff_list_response.schema.json",
  "title": "ProgramStaffListCallableResponse",
  "description": "Manager's view of program staff grants.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "members"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "members": {
      "type": "array",
      "maxItems": 100,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "uid",
          "displayName",
          "phoneLastFour",
          "duties",
          "status",
          "expiresAtMillis",
          "revision"
        ],
        "properties": {
          "uid": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "displayName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "phoneLastFour": {
            "type": "string",
            "pattern": "^[0-9]{4}$"
          },
          "duties": {
            "type": "array",
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "duty",
                "pickupPointIds",
                "hotelIds",
                "expiresAtMillis"
              ],
              "properties": {
                "duty": {
                  "type": "string",
                  "enum": [
                    "programCoordinator",
                    "airportGreeter",
                    "hotelDesk",
                    "transportDispatcher",
                    "reconciliationViewer"
                  ]
                },
                "pickupPointIds": {
                  "type": "array",
                  "maxItems": 32,
                  "uniqueItems": true,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "description": "Pickup restriction; empty means all program pickup points. Both resource restrictions must be met by the same assignment."
                },
                "hotelIds": {
                  "type": "array",
                  "maxItems": 64,
                  "uniqueItems": true,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "description": "Destination restriction; empty means all program hotels. Restrictions from different assignments never combine into new routes."
                },
                "expiresAtMillis": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991,
                  "description": "Exclusive expiry of this exact duty and resource scope. Independent of other assignments."
                }
              }
            }
          },
          "status": {
            "type": "string",
            "enum": [
              "active",
              "expired",
              "revoked"
            ]
          },
          "expiresAtMillis": {
            "type": "integer",
            "minimum": 0
          },
          "revision": {
            "type": "integer",
            "minimum": 1
          }
        }
      }
    }
  }
} as const;
