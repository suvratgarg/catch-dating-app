/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programAccessCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/program_access_response.schema.json",
  "title": "ProgramAccessCallableResponse",
  "description": "Work-shell bootstrap: the caller's role, duties, station scopes and labeled program resources. Staff receive only operational fields.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "organizerId",
    "title",
    "kind",
    "timezone",
    "status",
    "actorRole",
    "duties",
    "grantExpiresAtMillis",
    "capabilities",
    "pickupPoints",
    "hotels",
    "vehicleClasses"
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
    "title": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140
    },
    "kind": {
      "type": "string",
      "enum": [
        "wedding",
        "corporate",
        "social",
        "other"
      ]
    },
    "timezone": {
      "type": "string",
      "minLength": 1,
      "maxLength": 60
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
    "actorRole": {
      "type": "string",
      "enum": [
        "manager",
        "staff"
      ]
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
              "guestRelations",
              "communications",
              "functionCheckIn",
              "functionLead",
              "airportGreeter",
              "hotelDesk",
              "transportDispatcher",
              "reconciliationViewer",
              "stakeholderViewer"
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
          "functionIds": {
            "type": "array",
            "maxItems": 64,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "description": "Function restriction for functionCheckIn and functionLead duties; absent or empty means all program functions. Optional on documents written before function-scoped duties existed."
          },
          "expiresAtMillis": {
            "type": "integer",
            "minimum": 1,
            "maximum": 9007199254740991,
            "description": "Exclusive expiry of this exact duty and resource scope. Independent of other assignments."
          }
        }
      },
      "description": "Managers receive an empty list meaning unrestricted; staff receive their granted duties."
    },
    "grantExpiresAtMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0
    },
    "capabilities": {
      "type": "array",
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
    "pickupPoints": {
      "type": "array",
      "maxItems": 32,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "pickupPointId",
          "label",
          "kind",
          "iataCode",
          "terminal"
        ],
        "properties": {
          "pickupPointId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 140
          },
          "kind": {
            "type": "string",
            "enum": [
              "airport",
              "railway",
              "venue",
              "other"
            ]
          },
          "iataCode": {
            "type": [
              "string",
              "null"
            ]
          },
          "terminal": {
            "type": [
              "string",
              "null"
            ]
          }
        }
      }
    },
    "hotels": {
      "type": "array",
      "maxItems": 64,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "hotelId",
          "name"
        ],
        "properties": {
          "hotelId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "name": {
            "type": "string",
            "minLength": 1,
            "maxLength": 140
          }
        }
      }
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
      }
    }
  }
} as const;
