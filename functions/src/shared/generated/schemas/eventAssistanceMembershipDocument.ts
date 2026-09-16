/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceMembershipDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "membershipId",
    "context",
    "attendeeId",
    "sourceGeneration",
    "attendeeGeneration",
    "episodeId",
    "revision",
    "accepted",
    "transfer",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "membershipId": {
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
    "sourceGeneration": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
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
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "accepted": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "groupId",
            "groupSourceHash",
            "responsibleOperatorId",
            "acceptedAt"
          ],
          "properties": {
            "groupId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "groupSourceHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "responsibleOperatorId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "acceptedAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "transfer": {
      "anyOf": [
        {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "transferId",
                "from",
                "to",
                "targetSourceHash",
                "receivingOperatorId",
                "requestedBy",
                "requestedAt",
                "expiresAt",
                "status",
                "resolvedAt",
                "resolvedBy"
              ],
              "properties": {
                "transferId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "from": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "to": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "targetSourceHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "receivingOperatorId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "requestedBy": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "requestedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "expiresAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "status": {
                  "const": "pending"
                },
                "resolvedAt": {
                  "type": "null"
                },
                "resolvedBy": {
                  "type": "null"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "transferId",
                "from",
                "to",
                "targetSourceHash",
                "receivingOperatorId",
                "requestedBy",
                "requestedAt",
                "expiresAt",
                "status",
                "resolvedAt",
                "resolvedBy"
              ],
              "properties": {
                "transferId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "from": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "to": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "targetSourceHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "receivingOperatorId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "requestedBy": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "requestedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "expiresAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "status": {
                  "enum": [
                    "accepted",
                    "rejected",
                    "cancelled"
                  ]
                },
                "resolvedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "resolvedBy": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
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
  "title": "EventAssistanceMembershipDocument",
  "x-firestore-collection": "eventAssistanceMemberships",
  "x-firestore-path": "eventAssistanceMemberships/{membershipId}",
  "x-document-id-field": "membershipId",
  "x-owner": "event group membership"
} as const;
