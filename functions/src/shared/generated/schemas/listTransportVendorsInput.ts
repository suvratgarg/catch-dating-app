/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listTransportVendorsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/list_transport_vendors_payload.schema.json",
  "title": "ListTransportVendorsCallablePayload",
  "description": "List organizer vendors, optionally narrowed to those bound to a program.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "programId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
