/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventRcsConsentReceiptDocumentSchema: Record<string, unknown> = {
  "oneOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "receiptId",
        "requestHash",
        "context",
        "attendeeId",
        "attendeeGeneration",
        "sourceGeneration",
        "actorUid",
        "senderId",
        "senderHash",
        "routeId",
        "recipientEndpointId",
        "source",
        "permissionHash",
        "appliedRevision",
        "createdAt",
        "decision",
        "copyVersion",
        "copyHash",
        "reviewHash",
        "reviewedStopHash"
      ],
      "properties": {
        "schemaVersion": {
          "type": "integer",
          "const": 1
        },
        "receiptId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "requestHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
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
        "actorUid": {
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
        "senderHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "routeId": {
          "type": "string",
          "const": "catchEventRcs"
        },
        "recipientEndpointId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "source": {
          "type": "string",
          "const": "verifiedParticipant"
        },
        "permissionHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "appliedRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "createdAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "decision": {
          "type": "string",
          "const": "grant"
        },
        "copyVersion": {
          "type": "string",
          "const": "catch-event-service-rcs-v1"
        },
        "copyHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "reviewHash": {
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
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "receiptId",
        "requestHash",
        "context",
        "attendeeId",
        "attendeeGeneration",
        "sourceGeneration",
        "actorUid",
        "senderId",
        "senderHash",
        "routeId",
        "recipientEndpointId",
        "source",
        "permissionHash",
        "appliedRevision",
        "createdAt",
        "decision",
        "copyVersion",
        "copyHash",
        "reviewHash",
        "reviewedStopHash"
      ],
      "properties": {
        "schemaVersion": {
          "type": "integer",
          "const": 1
        },
        "receiptId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "requestHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
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
        "actorUid": {
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
        "senderHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "routeId": {
          "type": "string",
          "const": "catchEventRcs"
        },
        "recipientEndpointId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "source": {
          "type": "string",
          "const": "verifiedParticipant"
        },
        "permissionHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "appliedRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "createdAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "decision": {
          "type": "string",
          "const": "revoke"
        },
        "copyVersion": {
          "type": "null"
        },
        "copyHash": {
          "type": "null"
        },
        "reviewHash": {
          "type": "null"
        },
        "reviewedStopHash": {
          "type": "null"
        }
      }
    }
  ],
  "title": "EventRcsConsentReceiptDocument",
  "x-firestore-collection": "eventAssistanceRcsConsentReceipts",
  "x-firestore-path": "eventAssistanceRcsConsentReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "verified participant event-service preferences"
} as const;
