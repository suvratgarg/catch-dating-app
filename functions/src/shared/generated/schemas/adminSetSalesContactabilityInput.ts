/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminSetSalesContactabilityCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_sales_contacts_set_contactability_payload.schema.json",
  "title": "Sales contacts.setContactability callable payload",
  "description": "Private bounded Sales callable request. Server authorization and transaction policy are enforced separately.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "contactId",
    "requestId",
    "expectedRevision",
    "status",
    "reason"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "contactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000000
    },
    "status": {
      "enum": [
        "unknown",
        "draft_reviewed",
        "held",
        "suppressed"
      ]
    },
    "reason": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000
    },
    "evidenceId": {
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
    }
  }
} as const;
