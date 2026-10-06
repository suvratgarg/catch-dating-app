/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const catchWhatsappIngressEvidenceDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/catch_whatsapp_ingress_evidence.schema.json",
  "title": "CatchWhatsappIngressEvidenceDocument",
  "description": "Body-free durable semantic collision fence captured only after authenticated exact-sender ingress. Hashes never establish source completeness, consent or STOP absence. Blocked events cannot be reactivated; no TTL.",
  "x-firestore-collection": "catchWhatsappIngressEvidence",
  "x-firestore-path": "catchWhatsappIngressEvidence/{eventId}",
  "x-document-id-field": "eventId",
  "x-owner": "Catch signed webhook ingress",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "eventId",
    "wabaId",
    "phoneNumberId",
    "endpointHash",
    "materialSha256",
    "eventKind",
    "classification",
    "ambiguity",
    "state",
    "receivedAtMillis"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "eventId": {
      "type": "string",
      "pattern": "^cwhe_[a-f0-9]{64}$"
    },
    "wabaId": {
      "type": "string",
      "pattern": "^[0-9]{1,32}$"
    },
    "phoneNumberId": {
      "type": "string",
      "pattern": "^[0-9]{1,32}$"
    },
    "endpointHash": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        {
          "type": "null"
        }
      ]
    },
    "materialSha256": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "eventKind": {
      "type": "string",
      "enum": [
        "inbound",
        "status"
      ]
    },
    "classification": {
      "type": "string",
      "enum": [
        "text",
        "stop",
        "status",
        "ambiguous"
      ]
    },
    "ambiguity": {
      "anyOf": [
        {
          "type": "string",
          "enum": [
            "unresolved-endpoint",
            "truncated-text",
            "unsupported-message",
            "missing-text",
            "invalid-status-errors"
          ]
        },
        {
          "type": "null"
        }
      ]
    },
    "state": {
      "type": "string",
      "enum": [
        "accepted",
        "blocked"
      ]
    },
    "receivedAtMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  }
} as const;
