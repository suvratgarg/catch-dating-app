/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const findOrganizerFormPaymentCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/find_organizer_form_payment_payload.schema.json",
  "title": "FindOrganizerFormPaymentCallablePayload",
  "description": "Find the signed-in respondent's most recent payment for a public form without browser-local identifiers.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "publicFormId"
  ],
  "properties": {
    "publicFormId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{20,80}$"
    }
  }
} as const;
