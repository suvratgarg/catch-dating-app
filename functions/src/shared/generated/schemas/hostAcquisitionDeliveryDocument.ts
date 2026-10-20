/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const hostAcquisitionDeliveryDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/host_acquisition_deliveries.schema.json",
  "title": "HostAcquisitionDeliveryDocument",
  "description": "Private, bounded Meta Lead delivery. Current consent and the original Sales intent are rechecked before dispatch. Contact data and form answers are excluded.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "hostAcquisitionDeliveries",
  "x-firestore-path": "hostAcquisitionDeliveries/{eventId}",
  "x-document-id-field": "eventId",
  "x-owner": "joinWaitlist and Host acquisition delivery worker",
  "required": [
    "schemaVersion",
    "classification",
    "eventId",
    "intentId",
    "consentId",
    "acceptedAt",
    "status",
    "attempts",
    "nextAttemptAt",
    "attemptId",
    "lastAttemptAt",
    "expiresAt",
    "context"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "eventId": {
      "type": "string",
      "pattern": "^host_lead_[0-9]{13}_[a-f0-9]{8}(-[a-f0-9]{4}){3}-[a-f0-9]{12}$"
    },
    "intentId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9_-]+$"
    },
    "consentId": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "acceptedAt": {
      "type": "integer",
      "minimum": 1
    },
    "status": {
      "enum": [
        "pending",
        "sending",
        "accepted",
        "unknown",
        "stopped"
      ]
    },
    "attempts": {
      "type": "integer",
      "minimum": 0,
      "maximum": 5
    },
    "nextAttemptAt": {
      "type": "integer",
      "minimum": 1
    },
    "attemptId": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[a-f0-9-]{36}$"
    },
    "lastAttemptAt": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1
    },
    "expiresAt": {
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
    "context": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "clientId",
            "userAgent"
          ],
          "properties": {
            "clientId": {
              "type": "string",
              "pattern": "^[0-9]{1,10}\\.[0-9]{10}$"
            },
            "userAgent": {
              "type": "string",
              "minLength": 1,
              "maxLength": 512,
              "pattern": "^[^\\u0000-\\u001f\\u007f]+$"
            },
            "fbclid": {
              "type": "string",
              "pattern": "^[A-Za-z0-9_-]{10,512}$"
            },
            "clickCapturedAt": {
              "type": "integer",
              "minimum": 1
            }
          }
        },
        {
          "type": "null"
        }
      ]
    }
  }
} as const;
