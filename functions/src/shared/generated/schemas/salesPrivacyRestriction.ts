/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesPrivacyRestrictionSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_privacy_restrictions.schema.json",
  "title": "SalesPrivacyRestriction",
  "description": "Permanent organizer-scoped private Sales reintroduction fence. Existence blocks reads, writes and receipt replay.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "classification",
    "organizerId",
    "status",
    "revision",
    "reason",
    "requestId",
    "materialHash",
    "restrictedByUid",
    "restrictedAt",
    "activePlanId"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "organizerId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{0,179}$"
    },
    "status": {
      "enum": [
        "restricted",
        "processing",
        "internal_processed_with_unresolved"
      ]
    },
    "revision": {
      "type": "integer",
      "minimum": 1
    },
    "reason": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    },
    "requestId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$"
    },
    "materialHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "restrictedByUid": {
      "type": "string",
      "minLength": 1
    },
    "restrictedAt": {
      "type": "string",
      "format": "date-time"
    },
    "activePlanId": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^privacy-[a-f0-9]{40}$"
        },
        {
          "type": "null"
        }
      ]
    }
  },
  "x-firestore-collection": "salesPrivacyRestrictions",
  "x-firestore-path": "salesPrivacyRestrictions/{id}",
  "x-owner": "Private Sales privacy lifecycle"
} as const;
