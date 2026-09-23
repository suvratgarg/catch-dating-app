/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const updateEventChatAccessCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/update_event_chat_access_response.schema.json",
  "title": "UpdateEventChatAccessCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "revision",
    "replayed"
  ],
  "properties": {
    "revision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
