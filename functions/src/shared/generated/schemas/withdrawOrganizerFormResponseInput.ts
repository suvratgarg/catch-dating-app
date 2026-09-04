/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const withdrawOrganizerFormResponseCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/withdraw_organizer_form_response_payload.schema.json",
  "title": "WithdrawOrganizerFormResponseCallablePayload",
  "description": "Idempotently withdraws one submitted response under respondent authority.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "responseId",
    "withdrawalToken",
    "requestId"
  ],
  "properties": {
    "responseId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "withdrawalToken": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[A-Za-z0-9_-]{32,160}$"
    },
    "requestId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{16,120}$"
    }
  }
} as const;
