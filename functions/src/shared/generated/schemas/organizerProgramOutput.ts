/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerProgramCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/organizer_program_response.schema.json",
  "title": "OrganizerProgramCallableResponse",
  "description": "Manager-facing program detail: settings, resources and coverage counts. No guest rows.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "program",
    "functions",
    "pickupPoints",
    "hotels",
    "counts"
  ],
  "properties": {
    "program": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "programId",
        "kind",
        "title",
        "timezone",
        "status",
        "startsAtMillis",
        "endsAtMillis",
        "capabilities",
        "transportSettings",
        "revision"
      ],
      "properties": {
        "programId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
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
        "status": {
          "type": "string",
          "enum": [
            "draft",
            "active",
            "completed",
            "archived"
          ]
        },
        "startsAtMillis": {
          "type": "integer",
          "minimum": 0
        },
        "endsAtMillis": {
          "type": "integer",
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
        },
        "revision": {
          "type": "integer",
          "minimum": 1
        }
      }
    },
    "functions": {
      "type": "array",
      "maxItems": 40,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "functionId",
          "name",
          "startsAtMillis",
          "endsAtMillis",
          "venueName",
          "status"
        ],
        "properties": {
          "functionId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "name": {
            "type": "string",
            "minLength": 1,
            "maxLength": 140
          },
          "startsAtMillis": {
            "type": "integer",
            "minimum": 0
          },
          "endsAtMillis": {
            "type": "integer",
            "minimum": 0
          },
          "venueName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "status": {
            "type": "string",
            "enum": [
              "scheduled",
              "completed",
              "cancelled"
            ]
          }
        }
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
          "kind",
          "label",
          "active",
          "revision"
        ],
        "properties": {
          "pickupPointId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
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
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 140
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
          },
          "meetingZone": {
            "type": [
              "string",
              "null"
            ]
          },
          "instructions": {
            "type": [
              "string",
              "null"
            ]
          },
          "active": {
            "type": "boolean"
          },
          "revision": {
            "type": "integer",
            "minimum": 1
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
          "name",
          "address",
          "active",
          "revision"
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
          },
          "address": {
            "type": "string",
            "minLength": 1,
            "maxLength": 300
          },
          "receptionContact": {
            "type": [
              "string",
              "null"
            ]
          },
          "active": {
            "type": "boolean"
          },
          "revision": {
            "type": "integer",
            "minimum": 1
          }
        }
      }
    },
    "counts": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "guests",
        "households",
        "inboundLegs",
        "activeStaff"
      ],
      "properties": {
        "guests": {
          "type": "integer",
          "minimum": 0
        },
        "households": {
          "type": "integer",
          "minimum": 0
        },
        "inboundLegs": {
          "type": "integer",
          "minimum": 0
        },
        "activeStaff": {
          "type": "integer",
          "minimum": 0
        }
      }
    }
  }
} as const;
