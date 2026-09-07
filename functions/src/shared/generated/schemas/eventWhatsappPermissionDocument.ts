/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventWhatsappPermissionDocumentSchema: Record<string, unknown> = {
  "oneOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "permissionId",
        "revision",
        "context",
        "attendeeId",
        "attendeeGeneration",
        "senderId",
        "routeId",
        "purpose",
        "phoneE164",
        "recipientEndpointId",
        "status",
        "evidence",
        "expiresAt",
        "updatedAt",
        "currentReceiptId",
        "sender"
      ],
      "properties": {
        "schemaVersion": {
          "type": "integer",
          "const": 1
        },
        "permissionId": {
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
        "context": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "mode",
            "organizerId",
            "eventId"
          ],
          "properties": {
            "mode": {
              "type": "string",
              "const": "live"
            },
            "organizerId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
        "senderId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "routeId": {
          "type": "string",
          "const": "organizerEventWhatsapp"
        },
        "purpose": {
          "type": "string",
          "const": "eventService"
        },
        "phoneE164": {
          "type": "string",
          "pattern": "^\\+[1-9][0-9]{7,14}$"
        },
        "recipientEndpointId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "status": {
          "type": "string",
          "const": "granted"
        },
        "evidence": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "receiptId",
            "copyVersion",
            "acceptedAt",
            "phoneVerifiedAt",
            "subjectUid",
            "senderHash"
          ],
          "properties": {
            "receiptId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "copyVersion": {
              "type": "string",
              "const": "catch-event-service-whatsapp-v1"
            },
            "acceptedAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "phoneVerifiedAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "subjectUid": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "senderHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            }
          }
        },
        "expiresAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "updatedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "currentReceiptId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "sender": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "providerAccountId",
            "providerPhoneNumberId",
            "displayName",
            "displayPhoneNumber"
          ],
          "properties": {
            "providerAccountId": {
              "type": "string",
              "pattern": "^[0-9]{5,40}$"
            },
            "providerPhoneNumberId": {
              "type": "string",
              "pattern": "^[0-9]{5,40}$"
            },
            "displayName": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            },
            "displayPhoneNumber": {
              "type": "string",
              "minLength": 7,
              "maxLength": 32
            }
          }
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "permissionId",
        "revision",
        "context",
        "attendeeId",
        "attendeeGeneration",
        "senderId",
        "routeId",
        "purpose",
        "phoneE164",
        "recipientEndpointId",
        "status",
        "evidence",
        "expiresAt",
        "updatedAt",
        "currentReceiptId",
        "sender"
      ],
      "properties": {
        "schemaVersion": {
          "type": "integer",
          "const": 1
        },
        "permissionId": {
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
        "context": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "mode",
            "organizerId",
            "eventId"
          ],
          "properties": {
            "mode": {
              "type": "string",
              "const": "live"
            },
            "organizerId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
        "senderId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "routeId": {
          "type": "string",
          "const": "organizerEventWhatsapp"
        },
        "purpose": {
          "type": "string",
          "const": "eventService"
        },
        "phoneE164": {
          "type": "string",
          "pattern": "^\\+[1-9][0-9]{7,14}$"
        },
        "recipientEndpointId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "status": {
          "type": "string",
          "const": "revoked"
        },
        "evidence": {
          "anyOf": [
            {
              "type": "null"
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "receiptId",
                "copyVersion",
                "acceptedAt",
                "phoneVerifiedAt",
                "subjectUid",
                "senderHash"
              ],
              "properties": {
                "receiptId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "copyVersion": {
                  "type": "string",
                  "const": "catch-event-service-whatsapp-v1"
                },
                "acceptedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "phoneVerifiedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "subjectUid": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "senderHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                }
              }
            }
          ]
        },
        "expiresAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "updatedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "currentReceiptId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "sender": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "providerAccountId",
            "providerPhoneNumberId",
            "displayName",
            "displayPhoneNumber"
          ],
          "properties": {
            "providerAccountId": {
              "type": "string",
              "pattern": "^[0-9]{5,40}$"
            },
            "providerPhoneNumberId": {
              "type": "string",
              "pattern": "^[0-9]{5,40}$"
            },
            "displayName": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            },
            "displayPhoneNumber": {
              "type": "string",
              "minLength": 7,
              "maxLength": 32
            }
          }
        }
      }
    }
  ],
  "title": "EventWhatsappPermissionDocument",
  "x-firestore-collection": "eventAssistanceWhatsappPermissions",
  "x-firestore-path": "eventAssistanceWhatsappPermissions/{permissionId}",
  "x-document-id-field": "permissionId",
  "x-owner": "verified participant event-service preferences"
} as const;
