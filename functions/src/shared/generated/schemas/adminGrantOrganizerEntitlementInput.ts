/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminGrantOrganizerEntitlementCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_grant_organizer_entitlement_payload.schema.json",
  "title": "AdminGrantOrganizerEntitlementCallablePayload",
  "description": "Admin-authorized grant of one entitlement SKU to an organizer. operationId makes the mutation idempotent across retries; server stamps grantedAt and grantedBy.",
  "type": "object",
  "additionalProperties": false,
  "x-owner": "Admin console finance ops",
  "required": [
    "organizerId",
    "operationId",
    "sku",
    "unit",
    "quantityTotal",
    "source"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "operationId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{16,120}$"
    },
    "sku": {
      "type": "string",
      "enum": [
        "wedding_essentials",
        "wedding_pro",
        "wedding_signature",
        "wedding_transport_addon",
        "planner_annual"
      ]
    },
    "unit": {
      "type": "string",
      "enum": [
        "program",
        "organizerYear"
      ]
    },
    "quantityTotal": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000
    },
    "validFromMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "validUntilMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "source": {
      "type": "string",
      "enum": [
        "manualInvoice",
        "checkout",
        "promo"
      ]
    },
    "receiptRef": {
      "type": "string",
      "maxLength": 180
    },
    "note": {
      "type": "string",
      "maxLength": 500
    }
  }
} as const;
