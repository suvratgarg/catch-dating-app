/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminAddSalesEvidenceCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_sales_evidence_add_payload.schema.json",
  "title": "Sales evidence.add callable payload",
  "description": "Private bounded Sales callable request. Server authorization and transaction policy are enforced separately.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "requestId",
    "claimKey",
    "sourceType",
    "sourceRef",
    "observedAt",
    "confidence"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "contactId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        {
          "type": "null"
        }
      ]
    },
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "claimKey": {
      "enum": [
        "identity",
        "recurrence",
        "operation",
        "stack",
        "other"
      ]
    },
    "signalId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "sourceType": {
      "enum": [
        "first_party",
        "public_web",
        "human_note",
        "import_artifact"
      ]
    },
    "sourceRef": {
      "type": "string",
      "minLength": 1,
      "maxLength": 320
    },
    "observedAt": {
      "type": "string",
      "format": "date-time"
    },
    "validThrough": {
      "anyOf": [
        {
          "type": "string",
          "format": "date-time"
        },
        {
          "type": "null"
        }
      ]
    },
    "confidence": {
      "enum": [
        "high",
        "medium",
        "low"
      ]
    },
    "normalizedValue": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500
    },
    "excerpt": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500
    }
  }
} as const;
