/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listEventChatsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/list_event_chats_payload.schema.json",
  "title": "ListEventChatsCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "cursor",
    "limit"
  ],
  "properties": {
    "cursor": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "source",
            "after",
            "accountUid"
          ],
          "properties": {
            "source": {
              "type": "string",
              "enum": [
                "memberships",
                "participations",
                "attendees"
              ]
            },
            "after": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 1500,
                  "pattern": "^[^/]+$"
                },
                {
                  "type": "null"
                }
              ]
            },
            "accountUid": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 10
    }
  }
} as const;
