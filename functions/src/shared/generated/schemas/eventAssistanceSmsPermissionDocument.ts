/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceSmsPermissionDocumentSchema: Record<string, unknown> = {
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
        "currentReceiptId"
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
          "const": "catchEventSms"
        },
        "purpose": {
          "type": "string",
          "const": "eventService"
        },
        "phoneE164": {
          "type": "string",
          "pattern": "^\\+91[6-9][0-9]{9}$"
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
            "subjectUid"
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
              "const": "catch-event-service-sms-v1"
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
        "currentReceiptId"
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
          "const": "catchEventSms"
        },
        "purpose": {
          "type": "string",
          "const": "eventService"
        },
        "phoneE164": {
          "type": "string",
          "pattern": "^\\+91[6-9][0-9]{9}$"
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
                "subjectUid"
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
                  "const": "catch-event-service-sms-v1"
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
        }
      }
    }
  ],
  "title": "EventAssistanceSmsPermissionDocument",
  "x-firestore-collection": "eventAssistanceSmsPermissions",
  "x-firestore-path": "eventAssistanceSmsPermissions/{permissionId}",
  "x-document-id-field": "permissionId",
  "x-owner": "trusted event-assistance SMS worker"
} as const;
