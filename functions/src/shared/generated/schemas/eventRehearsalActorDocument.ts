/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventRehearsalActorDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_rehearsal_actors.schema.json",
  "title": "EventRehearsalActorDocument",
  "description": "Synthetic participant state stored only for an isolated rehearsal.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventRehearsalActors",
  "x-firestore-path": "eventRehearsalActors/{actorDocumentId}",
  "x-document-id-field": "id",
  "x-owner": "event rehearsal callables",
  "required": [
    "sessionId",
    "actorId",
    "displayName",
    "persona",
    "status",
    "guestMoment",
    "optedOut",
    "keepApartActorIds",
    "helpRequested",
    "promptCompleted",
    "layoutUnitId",
    "confirmedLayoutUnitId",
    "lastActionAt",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "sessionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "actorId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "displayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "x-catch-ownership": "callable-owned"
    },
    "persona": {
      "type": "string",
      "enum": [
        "firstTimer",
        "regular",
        "quiet",
        "connector",
        "external",
        "sparseProfile",
        "accessibilityNeeds",
        "walkIn"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "status": {
      "type": "string",
      "enum": [
        "expected",
        "present",
        "late",
        "noShow",
        "departed",
        "returned",
        "disconnected",
        "walkIn",
        "ambiguousClaim"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "connectionState": {
      "type": "string",
      "enum": [
        "connected",
        "disconnected"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "guestMoment": {
      "type": "string",
      "enum": [
        "welcome",
        "checkIn",
        "firstHello",
        "assignment",
        "rotation",
        "pause",
        "reveal",
        "afterglow",
        "complete"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "optedOut": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "keepApartActorIds": {
      "type": "array",
      "maxItems": 10,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      },
      "x-catch-ownership": "callable-owned"
    },
    "helpRequested": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "promptCompleted": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "layoutUnitId": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^table-[1-9][0-9]*$",
          "maxLength": 40
        },
        {
          "type": "null"
        }
      ],
      "x-catch-ownership": "callable-owned"
    },
    "confirmedLayoutUnitId": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^table-[1-9][0-9]*$",
          "maxLength": 40
        },
        {
          "type": "null"
        }
      ],
      "x-catch-ownership": "callable-owned"
    },
    "lastActionAt": {
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
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
    },
    "assistance": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "intention",
        "latestMessageId"
      ],
      "properties": {
        "intention": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unknown"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "claimedEta"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "onMyWay"
                },
                "claimedEta": {
                  "anyOf": [
                    {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "UTC milliseconds."
                    },
                    {
                      "type": "null",
                      "const": null
                    }
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "target"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "joinLater"
                },
                "target": {
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
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "notComing"
                }
              }
            }
          ]
        },
        "latestMessageId": {
          "anyOf": [
            {
              "type": "string",
              "pattern": "^outbox:[a-f0-9]{64}$"
            },
            {
              "type": "null"
            }
          ]
        }
      },
      "x-catch-ownership": "callable-owned"
    }
  }
} as const;
