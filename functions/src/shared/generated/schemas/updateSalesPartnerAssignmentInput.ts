/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const updateSalesPartnerAssignmentCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/update_sales_partner_assignment_payload.schema.json",
  "title": "UpdateSalesPartnerAssignmentCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "organizerId",
    "expectedRevision",
    "relationshipContext",
    "channel",
    "nextAction",
    "reviewAt"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 128
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 128
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0
    },
    "relationshipContext": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 1000
    },
    "channel": {
      "type": "string",
      "enum": [
        "email",
        "whatsapp",
        "other"
      ]
    },
    "nextAction": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    },
    "reviewAt": {
      "type": "string",
      "format": "date-time"
    }
  },
  "x-callable-aliases": [
    "updateSalesPartnerAssignment"
  ]
} as const;
