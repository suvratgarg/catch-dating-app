/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceDepartureRostersCallableResponseSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "context",
    "groupId",
    "actorUid",
    "validUntil",
    "serverTime",
    "progressRevision",
    "coverage",
    "rosters",
    "nextBeforeRevision"
  ],
  "properties": {
    "context": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "mode",
        "eventId",
        "organizerId"
      ],
      "properties": {
        "mode": {
          "type": "string",
          "const": "live"
        },
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "organizerId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000
        }
      }
    },
    "groupId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 128
    },
    "validUntil": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "serverTime": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "progressRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "coverage": {
      "const": "page"
    },
    "rosters": {
      "type": "array",
      "maxItems": 10,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "progressRevision",
          "confirmedAt",
          "destination",
          "label",
          "sourceState",
          "rosterSize",
          "checkpoint"
        ],
        "properties": {
          "progressRevision": {
            "type": "integer",
            "minimum": 1,
            "maximum": 9007199254740991
          },
          "confirmedAt": {
            "type": "integer",
            "minimum": 0,
            "maximum": 9007199254740991
          },
          "destination": {
            "anyOf": [
              {
                "anyOf": [
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind",
                      "placeId",
                      "lateEntry"
                    ],
                    "properties": {
                      "kind": {
                        "type": "string",
                        "const": "fixedPlace"
                      },
                      "placeId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160,
                        "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                      },
                      "lateEntry": {
                        "type": "string",
                        "enum": [
                          "allowed",
                          "hostDecision",
                          "closed"
                        ]
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind",
                      "itineraryId",
                      "stopId"
                    ],
                    "properties": {
                      "kind": {
                        "type": "string",
                        "const": "itineraryStop"
                      },
                      "itineraryId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 2000
                      },
                      "stopId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 2000
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind",
                      "routeId",
                      "groupId",
                      "checkpointId"
                    ],
                    "properties": {
                      "kind": {
                        "type": "string",
                        "const": "groupCheckpoint"
                      },
                      "routeId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 2000
                      },
                      "groupId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160,
                        "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                      },
                      "checkpointId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 2000
                      }
                    }
                  }
                ]
              },
              {
                "type": "null"
              }
            ]
          },
          "label": {
            "anyOf": [
              {
                "type": "string",
                "minLength": 1,
                "maxLength": 240
              },
              {
                "type": "null"
              }
            ]
          },
          "sourceState": {
            "enum": [
              "current",
              "setupChanged",
              "destinationNotRecorded"
            ]
          },
          "rosterSize": {
            "type": "integer",
            "minimum": 0,
            "maximum": 1000
          },
          "checkpoint": {
            "anyOf": [
              {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "checkpointId",
                  "reportStatus",
                  "reportRevision",
                  "accountedForCount",
                  "originalRequestedDueAt"
                ],
                "properties": {
                  "checkpointId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 160,
                    "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                  },
                  "reportStatus": {
                    "enum": [
                      "unreported",
                      "partial",
                      "complete"
                    ]
                  },
                  "reportRevision": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 9007199254740991
                  },
                  "accountedForCount": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 1000
                  },
                  "originalRequestedDueAt": {
                    "anyOf": [
                      {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      {
                        "type": "null"
                      }
                    ]
                  }
                }
              },
              {
                "type": "null"
              }
            ]
          }
        }
      }
    },
    "nextBeforeRevision": {
      "anyOf": [
        {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        {
          "type": "null"
        }
      ]
    }
  },
  "title": "EventAssistanceDepartureRostersCallableResponse"
} as const;
