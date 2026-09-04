/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerCommunicationPermissionReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_communication_permission_receipts.schema.json",
  "title": "OrganizerCommunicationPermissionReceiptDocument",
  "description": "Immutable participant-controlled grant or withdrawal evidence for one organizer and channel. Current preference projections reference these receipts but never replace their history.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerCommunicationPermissionReceipts",
  "x-firestore-path": "organizerCommunicationPermissionReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "participant registration, self-service preference, unsubscribe, and inbound STOP handlers",
  "required": [
    "organizerId",
    "uid",
    "channel",
    "decision",
    "evidenceStatus",
    "termsVersion",
    "consentCopyHash",
    "source",
    "sourceEventId",
    "sourceFormId",
    "sourceResponseId",
    "sourceProviderEventId",
    "actorClass",
    "actorUid",
    "identityStrength",
    "grantedAt",
    "revokedAt",
    "supersedesReceiptId",
    "createdAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "channel": {
      "type": "string",
      "enum": [
        "whatsapp",
        "sms"
      ]
    },
    "decision": {
      "type": "string",
      "enum": [
        "optedIn",
        "optedOut"
      ]
    },
    "evidenceStatus": {
      "type": "string",
      "enum": [
        "complete",
        "incomplete"
      ]
    },
    "termsVersion": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80
    },
    "consentCopyHash": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[a-f0-9]{64}$"
    },
    "source": {
      "type": "string",
      "enum": [
        "publicEventRegistration",
        "hostFormResponse",
        "participantSettings",
        "unsubscribeLink",
        "inboundStop",
        "providerWebhook",
        "legacyIncomplete"
      ]
    },
    "sourceEventId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "sourceFormId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "sourceResponseId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "sourceProviderEventId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 240
    },
    "actorClass": {
      "type": "string",
      "enum": [
        "participant",
        "provider",
        "system"
      ]
    },
    "actorUid": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "identityStrength": {
      "type": "string",
      "enum": [
        "unknown",
        "emailVerified",
        "phoneVerified",
        "catchAccount"
      ]
    },
    "grantedAt": {
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
    "revokedAt": {
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
    "supersedesReceiptId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
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
    }
  },
  "allOf": [
    {
      "if": {
        "properties": {
          "decision": {
            "const": "optedIn"
          },
          "evidenceStatus": {
            "const": "complete"
          }
        },
        "required": [
          "decision",
          "evidenceStatus"
        ]
      },
      "then": {
        "properties": {
          "termsVersion": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "consentCopyHash": {
            "type": "string",
            "pattern": "^[a-f0-9]{64}$"
          },
          "grantedAt": {
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
          "revokedAt": {
            "type": "null"
          }
        }
      }
    },
    {
      "if": {
        "properties": {
          "decision": {
            "const": "optedOut"
          },
          "evidenceStatus": {
            "const": "complete"
          }
        },
        "required": [
          "decision",
          "evidenceStatus"
        ]
      },
      "then": {
        "properties": {
          "grantedAt": {
            "type": "null"
          },
          "revokedAt": {
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
      }
    }
  ]
} as const;
