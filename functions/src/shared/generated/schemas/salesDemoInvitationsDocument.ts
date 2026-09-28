/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesDemoInvitationsDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_demo_invitations.schema.json",
  "title": "SalesDemoInvitationDocument",
  "description": "Private digest-only invitation. Contact endpoint is retained only as a keyed digest.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "classification",
    "invitationId",
    "blueprintId",
    "blueprintRevision",
    "tokenDigest",
    "contactBinding",
    "expiresAt",
    "revoked",
    "revision",
    "sessionCap",
    "sessionCount",
    "startReceiptCount",
    "startWindowMinute",
    "startWindowCount",
    "currentSessionId",
    "issuedByUid",
    "issuedAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "invitationId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "blueprintId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "blueprintRevision": {
      "type": "integer",
      "minimum": 1
    },
    "tokenDigest": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "contactBinding": {
      "anyOf": [
        {
          "type": "null"
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "digest"
          ],
          "properties": {
            "kind": {
              "enum": [
                "email",
                "phone"
              ]
            },
            "digest": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            }
          }
        }
      ]
    },
    "expiresAt": {
      "type": "string",
      "format": "date-time"
    },
    "revoked": {
      "type": "boolean"
    },
    "revision": {
      "type": "integer",
      "minimum": 1
    },
    "sessionCap": {
      "type": "integer",
      "minimum": 1,
      "maximum": 3
    },
    "sessionCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 3
    },
    "startReceiptCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 12
    },
    "startWindowMinute": {
      "type": "integer",
      "minimum": 0
    },
    "startWindowCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 6
    },
    "currentSessionId": {
      "anyOf": [
        {
          "type": "null"
        },
        {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        }
      ]
    },
    "issuedByUid": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "issuedAt": {
      "type": "string",
      "format": "date-time"
    },
    "revokedByUid": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "revokedAt": {
      "type": "string",
      "format": "date-time"
    }
  },
  "definitions": {
    "id": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    }
  },
  "x-firestore-collection": "salesDemoInvitations",
  "x-firestore-path": "salesDemoInvitations/{invitationId}",
  "x-document-id-field": "invitationId",
  "x-owner": "sales demo admin and trial callables"
} as const;
