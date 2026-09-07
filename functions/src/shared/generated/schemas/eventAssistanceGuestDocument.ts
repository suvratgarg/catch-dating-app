/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceGuestDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "guestId",
    "context",
    "attendeeId",
    "attendeeGeneration",
    "episodeId",
    "revision",
    "lifecycle",
    "intention",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "guestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
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
    "attendeeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "attendeeGeneration": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "episodeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "revision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "lifecycle": {
      "enum": [
        "active",
        "closed"
      ]
    },
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
    "createdAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "updatedAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  },
  "title": "EventAssistanceGuestDocument",
  "x-firestore-collection": "eventAssistanceGuests",
  "x-firestore-path": "eventAssistanceGuests/{guestId}",
  "x-document-id-field": "guestId",
  "x-owner": "trusted event-assistance guest boundary"
} as const;
