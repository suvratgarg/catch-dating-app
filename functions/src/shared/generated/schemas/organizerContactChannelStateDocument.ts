/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerContactChannelStateDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_contact_channel_states.schema.json",
  "title": "OrganizerContactChannelStateDocument",
  "description": "Organizer-contact channel frequency and suppression state rechecked immediately before delivery.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerContactChannelStates",
  "x-firestore-path": "organizerContactChannelStates/{stateId}",
  "x-document-id-field": "stateId",
  "x-owner": "campaign delivery and unsubscribe webhooks",
  "required": [
    "organizerId",
    "contactId",
    "channel",
    "endpointHash",
    "suppressionStatus",
    "suppressionSource",
    "campaignAcceptedCount",
    "lastCampaignAcceptedAt",
    "lastInboundAt",
    "lastReplyAt",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "contactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "channel": {
      "const": "whatsapp"
    },
    "endpointHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "suppressionStatus": {
      "type": "string",
      "enum": [
        "none",
        "optedOut",
        "providerBlocked",
        "invalidEndpoint",
        "adminSuppressed"
      ]
    },
    "suppressionSource": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        null,
        "preference",
        "inboundStop",
        "provider",
        "admin"
      ]
    },
    "adminSuppressed": {
      "type": "boolean",
      "description": "Independent organizer pause. It never replaces a person opt-out or provider suppression."
    },
    "campaignAcceptedCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000
    },
    "lastCampaignAcceptedAt": {
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
    "lastInboundAt": {
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
    "lastReplyAt": {
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
    }
  }
} as const;
