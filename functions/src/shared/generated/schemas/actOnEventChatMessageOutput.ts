/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const actOnEventChatMessageCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/act_on_event_chat_message_response.schema.json",
  "title": "ActOnEventChatMessageCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "applied",
    "replayed"
  ],
  "properties": {
    "applied": {
      "const": true,
      "type": "boolean"
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
