/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesHostSettlementAttestationsDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_host_settlement_attestations.schema.json",
  "title": "SalesHostSettlementAttestationsDocument",
  "description": "Owner-attested first-party host subscription collection; provider unconfirmed and separate from guest payments.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "salesHostSettlementAttestations",
  "x-firestore-path": "salesHostSettlementAttestations/{attestationId}",
  "x-owner": "private Sales commercial service",
  "required": [
    "schemaVersion",
    "classification",
    "revision",
    "attestationId",
    "organizerId",
    "opportunityId",
    "quoteId",
    "termVersion",
    "termsHash",
    "amountMinor",
    "currency",
    "purpose",
    "receivedAt",
    "settlementMethod",
    "settlementReference",
    "recipientAccountScope",
    "settlementIdentityHash",
    "servicePeriod",
    "evidence",
    "status",
    "providerConfirmed",
    "actorUid",
    "attestedAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "revision": {
      "const": 1
    },
    "attestationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "opportunityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "quoteId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "termVersion": {
      "type": "integer",
      "minimum": 1
    },
    "termsHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "amountMinor": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000000000
    },
    "currency": {
      "type": "string",
      "pattern": "^[A-Z]{3}$"
    },
    "purpose": {
      "const": "host_subscription"
    },
    "receivedAt": {
      "type": "string",
      "format": "date-time",
      "maxLength": 48
    },
    "settlementMethod": {
      "enum": [
        "bank_transfer",
        "cash",
        "other_external"
      ]
    },
    "settlementReference": {
      "type": "string",
      "minLength": 6,
      "maxLength": 120,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9 ./_-]*$"
    },
    "recipientAccountScope": {
      "type": "string",
      "minLength": 3,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9 ./_-]*$"
    },
    "settlementIdentityHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "servicePeriod": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "startsAt",
            "endsAt"
          ],
          "properties": {
            "startsAt": {
              "type": "string",
              "format": "date-time",
              "maxLength": 48
            },
            "endsAt": {
              "type": "string",
              "format": "date-time",
              "maxLength": 48
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "evidence": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "evidenceId",
        "sourceRef",
        "contentHash",
        "observedAt"
      ],
      "properties": {
        "evidenceId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "sourceRef": {
          "type": "string",
          "minLength": 1,
          "maxLength": 512
        },
        "contentHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "observedAt": {
          "type": "string",
          "format": "date-time",
          "maxLength": 48
        }
      }
    },
    "status": {
      "const": "manual_attested_collected"
    },
    "providerConfirmed": {
      "const": false
    },
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "attestedAt": {
      "type": "string",
      "format": "date-time",
      "maxLength": 48
    }
  },
  "x-document-id-field": "attestationId"
} as const;
