/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminAssignSalesPartnerCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_assign_sales_partner_payload.schema.json",
  "title": "AdminAssignSalesPartnerCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "organizerId",
    "partnerUid",
    "expectedRevision",
    "nextAction",
    "reviewAt",
    "expiresAt",
    "reason",
    "originatorUid"
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
    "partnerUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 128
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0
    },
    "nextAction": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    },
    "reviewAt": {
      "type": "string",
      "format": "date-time"
    },
    "expiresAt": {
      "type": "string",
      "format": "date-time"
    },
    "reason": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    },
    "originatorUid": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 128
    }
  },
  "x-callable-aliases": [
    "adminAssignSalesPartner"
  ]
} as const;
