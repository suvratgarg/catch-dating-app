/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const manageEventChatMemberCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/manage_event_chat_member_response.schema.json",
  "title": "ManageEventChatMemberCallableResponse",
  "description": "Revisioned manager moderation receipt, not a current access grant.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "revision",
    "replayed"
  ],
  "properties": {
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
