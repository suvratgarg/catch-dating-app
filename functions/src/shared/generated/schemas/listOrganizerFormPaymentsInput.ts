/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listOrganizerFormPaymentsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/list_organizer_form_payments_payload.schema.json",
  "title": "ListOrganizerFormPaymentsCallablePayload",
  "description": "Manager-only bounded fee ledger for one owned form, independent of the response inbox.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "statuses",
    "cursor",
    "limit"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "formId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "statuses": {
      "type": "array",
      "uniqueItems": true,
      "maxItems": 11,
      "items": {
        "enum": [
          "creatingOrder",
          "orderUnknown",
          "checkoutReady",
          "verifying",
          "captured",
          "submitted",
          "failed",
          "expired",
          "refundPending",
          "refunded",
          "reviewRequired"
        ],
        "type": "string"
      }
    },
    "cursor": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 50
    }
  }
} as const;
