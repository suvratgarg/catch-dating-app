/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programTravelLegDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/program_travel_legs.schema.json",
  "title": "ProgramTravelLegDocument",
  "description": "Server-owned per-guest travel leg. Carries itinerary facts, flight status snapshots, readiness/claim state and reviewed manual overrides. Provider facts are linked, never copied over manual observations.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "programTravelLegs",
  "x-firestore-path": "programTravelLegs/{legId}",
  "x-document-id-field": "legId",
  "x-owner": "program travel and dispatch callables",
  "required": [
    "programId",
    "organizerId",
    "guestId",
    "partyId",
    "kind",
    "flightNumber",
    "carrierCode",
    "originIata",
    "destinationIata",
    "scheduledArrivalAt",
    "estimatedArrivalAt",
    "actualArrivalAt",
    "flightStatus",
    "flightInstanceId",
    "pickupPointId",
    "destinationHotelId",
    "destinationLabel",
    "readiness",
    "readyAt",
    "claimedByUid",
    "claimedAt",
    "manualCurbAt",
    "manualCurbNote",
    "passengers",
    "luggageUnits",
    "requiredCapabilities",
    "dedicatedVehicle",
    "source",
    "createdAt",
    "updatedAt",
    "revision",
    "arrivalTerminal",
    "flightRefreshedAt",
    "flightNextRefreshAt"
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
    "guestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "description": "Exactly one guest per leg; companions get their own legs sharing a party."
    },
    "partyId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "description": "Optional ride-together travel party; null means this leg travels as a singleton."
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
    "scheduledArrivalAt": {
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
    "estimatedArrivalAt": {
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
    "actualArrivalAt": {
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
    "flightStatus": {
      "type": "string",
      "enum": [
        "scheduled",
        "enroute",
        "landed",
        "delayed",
        "cancelled",
        "diverted",
        "unknown"
      ]
    },
    "flightInstanceId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "description": "Resolved provider flight instance once flight tracking ships; null for manual entries."
    },
    "international": {
      "type": [
        "boolean",
        "null"
      ],
      "description": "True for international sectors; selects the program's international exit lag. Null/false uses the domestic lag."
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
      "maxLength": 140,
      "description": "Free-text destination when the drop is not a configured hotel."
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
    },
    "readyAt": {
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
      ],
      "description": "Observed curb-ready timestamp; outranks every estimate."
    },
    "claimedByUid": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "claimedAt": {
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
    "manualCurbAt": {
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
      ],
      "description": "Reviewed manual curb estimate; outranks flight-derived timing."
    },
    "manualCurbNote": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 280
    },
    "passengers": {
      "type": "integer",
      "minimum": 1,
      "maximum": 200,
      "description": "Seats this leg consumes, including children without their own guest record."
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
      "type": "boolean",
      "description": "VIP/private transfers never share a suggested vehicle."
    },
    "source": {
      "type": "string",
      "enum": [
        "manual",
        "import",
        "formResponse",
        "planner"
      ]
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
    },
    "arrivalTerminal": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 8,
      "description": "Provider-reported arrival terminal (e.g. T3). Staff display only; pickup point authority stays with pickupPointId."
    },
    "flightRefreshedAt": {
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
      ],
      "description": "Last successful provider refresh; null when the leg has never been enriched."
    },
    "flightNextRefreshAt": {
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
      ],
      "description": "Scheduler cursor: refresh once this passes. Null for non-flight or terminal-state legs."
    }
  }
} as const;
