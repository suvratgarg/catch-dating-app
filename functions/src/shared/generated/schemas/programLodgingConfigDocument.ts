/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programLodgingConfigDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/program_lodging_configs.schema.json",
  "title": "ProgramLodgingConfigDocument",
  "description": "Private event lodging setup referencing canonical program guest/group/hotel/room-block IDs. Contains explicit demand and sharing choices, exact or provisional inventory, and verified layered 2D facts; no copied contact records or public hotel catalog.",
  "x-firestore-collection": "programLodgingConfigs",
  "x-firestore-path": "programLodgingConfigs/{programId}",
  "x-document-id-field": "programId",
  "x-owner": "program lodging coordinator configuration",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "organizerId",
    "revision",
    "demand",
    "parties",
    "groupParents",
    "rooms",
    "inventory",
    "labels"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991,
      "x-catch-ownership": "server-only"
    },
    "demand": {
      "type": "array",
      "maxItems": 500,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "guestId",
          "startsAtMillis",
          "endsAtMillis",
          "beds",
          "requiredFeatures"
        ],
        "properties": {
          "guestId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180,
            "x-catch-ownership": "server-only"
          },
          "startsAtMillis": {
            "type": "integer",
            "minimum": 0,
            "maximum": 8640000000000000
          },
          "endsAtMillis": {
            "type": "integer",
            "minimum": 0,
            "maximum": 8640000000000000
          },
          "beds": {
            "type": "integer",
            "minimum": 1,
            "maximum": 100
          },
          "requiredFeatures": {
            "type": "array",
            "maxItems": 30,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 80
            },
            "uniqueItems": true
          }
        }
      },
      "x-catch-ownership": "server-only"
    },
    "parties": {
      "type": "array",
      "maxItems": 500,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "guestIds",
          "confirmed",
          "priority",
          "requiredRoomType",
          "pin"
        ],
        "properties": {
          "id": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180,
            "x-catch-ownership": "server-only"
          },
          "guestIds": {
            "type": "array",
            "maxItems": 100,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180,
              "x-catch-ownership": "server-only"
            },
            "minItems": 1,
            "uniqueItems": true
          },
          "confirmed": {
            "type": "boolean"
          },
          "priority": {
            "type": "integer",
            "minimum": 0,
            "maximum": 1000000
          },
          "requiredRoomType": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 1,
            "maxLength": 80
          },
          "pin": {
            "anyOf": [
              {
                "type": "object",
                "additionalProperties": false,
                "required": [],
                "properties": {
                  "inventoryId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180,
                    "x-catch-ownership": "server-only"
                  },
                  "hotelId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180,
                    "x-catch-ownership": "server-only"
                  },
                  "zoneId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180,
                    "x-catch-ownership": "server-only"
                  }
                }
              },
              {
                "type": "null"
              }
            ]
          }
        }
      },
      "x-catch-ownership": "server-only"
    },
    "groupParents": {
      "type": "array",
      "maxItems": 500,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "parentIds"
        ],
        "properties": {
          "id": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180,
            "x-catch-ownership": "server-only"
          },
          "parentIds": {
            "type": "array",
            "maxItems": 20,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180,
              "x-catch-ownership": "server-only"
            },
            "uniqueItems": true
          }
        }
      },
      "x-catch-ownership": "server-only"
    },
    "rooms": {
      "type": "array",
      "maxItems": 500,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "hotelId",
          "zoneId",
          "building",
          "floor",
          "wing",
          "roomType",
          "beds",
          "maxOccupants",
          "verifiedFeatures",
          "resourceIds",
          "position"
        ],
        "properties": {
          "id": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180,
            "x-catch-ownership": "server-only"
          },
          "hotelId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180,
            "x-catch-ownership": "server-only"
          },
          "zoneId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180,
            "x-catch-ownership": "server-only"
          },
          "building": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 1,
            "maxLength": 80
          },
          "floor": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 1,
            "maxLength": 80
          },
          "wing": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 1,
            "maxLength": 80
          },
          "roomType": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "beds": {
            "type": "integer",
            "minimum": 1,
            "maximum": 100
          },
          "maxOccupants": {
            "type": "integer",
            "minimum": 1,
            "maximum": 100
          },
          "verifiedFeatures": {
            "type": "array",
            "maxItems": 30,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 80
            },
            "uniqueItems": true
          },
          "resourceIds": {
            "type": "array",
            "maxItems": 100,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180,
              "x-catch-ownership": "server-only"
            },
            "minItems": 1,
            "uniqueItems": true
          },
          "position": {
            "anyOf": [
              {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "x",
                  "y"
                ],
                "properties": {
                  "x": {
                    "type": "number",
                    "minimum": 0,
                    "maximum": 1
                  },
                  "y": {
                    "type": "number",
                    "minimum": 0,
                    "maximum": 1
                  }
                }
              },
              {
                "type": "null"
              }
            ]
          }
        }
      },
      "x-catch-ownership": "server-only"
    },
    "inventory": {
      "type": "array",
      "maxItems": 500,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "contractId",
          "physicalRoomId",
          "provisional",
          "availability"
        ],
        "properties": {
          "id": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180,
            "x-catch-ownership": "server-only"
          },
          "contractId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180,
            "x-catch-ownership": "server-only"
          },
          "physicalRoomId": {
            "anyOf": [
              {
                "type": "string",
                "minLength": 1,
                "maxLength": 180,
                "x-catch-ownership": "server-only"
              },
              {
                "type": "null"
              }
            ]
          },
          "provisional": {
            "anyOf": [
              {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "hotelId",
                  "zoneId",
                  "building",
                  "floor",
                  "wing",
                  "roomType",
                  "beds",
                  "maxOccupants",
                  "verifiedFeatures"
                ],
                "properties": {
                  "hotelId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180,
                    "x-catch-ownership": "server-only"
                  },
                  "zoneId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180,
                    "x-catch-ownership": "server-only"
                  },
                  "building": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "minLength": 1,
                    "maxLength": 80
                  },
                  "floor": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "minLength": 1,
                    "maxLength": 80
                  },
                  "wing": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "minLength": 1,
                    "maxLength": 80
                  },
                  "roomType": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 80
                  },
                  "beds": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 100
                  },
                  "maxOccupants": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 100
                  },
                  "verifiedFeatures": {
                    "type": "array",
                    "maxItems": 30,
                    "items": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 80
                    },
                    "uniqueItems": true
                  }
                }
              },
              {
                "type": "null"
              }
            ]
          },
          "availability": {
            "type": "array",
            "maxItems": 30,
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "arrival",
                "departure"
              ],
              "properties": {
                "arrival": {
                  "type": "string",
                  "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
                },
                "departure": {
                  "type": "string",
                  "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
                }
              }
            },
            "minItems": 1
          }
        }
      },
      "x-catch-ownership": "server-only"
    },
    "labels": {
      "type": "array",
      "maxItems": 500,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "inventoryId",
          "roomLabel"
        ],
        "properties": {
          "inventoryId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180,
            "x-catch-ownership": "server-only"
          },
          "roomLabel": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 1,
            "maxLength": 40
          }
        }
      },
      "x-catch-ownership": "server-only"
    }
  }
} as const;
