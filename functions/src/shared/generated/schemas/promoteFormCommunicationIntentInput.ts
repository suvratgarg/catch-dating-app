/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const promoteFormCommunicationIntentCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/promote_form_communication_intent_payload.schema.json",
  "title": "PromoteFormCommunicationIntentCallablePayload",
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
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
