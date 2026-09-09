/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventRcsPermissionDocumentSchema: Record<string, unknown> = {
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
        "sourceGeneration",
        "subjectUid",
        "senderId",
        "sender",
        "routeId",
        "purpose",
        "phoneE164",
        "recipientEndpointId",
        "currentReceiptId",
        "expiresAt",
        "updatedAt",
        "status",
        "evidence",
        "subscriptionId"
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
        "sourceGeneration": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "subjectUid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "senderId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "sender": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "agentId",
            "displayName"
          ],
          "properties": {
            "agentId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 512,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._@-]*$"
            },
            "displayName": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            }
          }
        },
        "routeId": {
          "type": "string",
          "const": "catchEventRcs"
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
        "currentReceiptId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
            "reviewHash",
            "senderHash",
            "reviewedStopHash"
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
              "const": "catch-event-service-rcs-v1"
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
            "reviewHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "senderHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "reviewedStopHash": {
              "anyOf": [
                {
                  "type": "null"
                },
                {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                }
              ]
            }
          }
        },
        "subscriptionId": {
          "type": "string",
          "pattern": "^rcs-subscription:[a-f0-9]{64}$",
          "description": "Derived agent and phone conversation key for bounded STOP discovery; covered by the immutable permission receipt."
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
        "sourceGeneration",
        "subjectUid",
        "senderId",
        "sender",
        "routeId",
        "purpose",
        "phoneE164",
        "recipientEndpointId",
        "currentReceiptId",
        "expiresAt",
        "updatedAt",
        "status",
        "evidence",
        "subscriptionId"
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
        "sourceGeneration": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "subjectUid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "senderId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "sender": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "agentId",
            "displayName"
          ],
          "properties": {
            "agentId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 512,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._@-]*$"
            },
            "displayName": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            }
          }
        },
        "routeId": {
          "type": "string",
          "const": "catchEventRcs"
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
        "currentReceiptId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
                "reviewHash",
                "senderHash",
                "reviewedStopHash"
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
                  "const": "catch-event-service-rcs-v1"
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
                "reviewHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "senderHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "reviewedStopHash": {
                  "anyOf": [
                    {
                      "type": "null"
                    },
                    {
                      "type": "string",
                      "pattern": "^[a-f0-9]{64}$"
                    }
                  ]
                }
              }
            }
          ]
        },
        "subscriptionId": {
          "type": "string",
          "pattern": "^rcs-subscription:[a-f0-9]{64}$",
          "description": "Derived agent and phone conversation key for bounded STOP discovery; covered by the immutable permission receipt."
        }
      }
    }
  ],
  "title": "EventRcsPermissionDocument",
  "x-firestore-collection": "eventAssistanceRcsPermissions",
  "x-firestore-path": "eventAssistanceRcsPermissions/{permissionId}",
  "x-document-id-field": "permissionId",
  "x-owner": "verified participant event-service preferences"
} as const;
