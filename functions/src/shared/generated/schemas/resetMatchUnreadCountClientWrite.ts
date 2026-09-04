/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const resetMatchUnreadCountClientWriteSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/client_writes/reset_match_unread_count.schema.json",
  "title": "ResetMatchUnreadCountClientWrite",
  "description": "Client-owned Firestore update operation for a participant resetting only their own unread counter on matches/{matchId}.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "path",
    "data"
  ],
  "properties": {
    "path": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "matchId"
      ],
      "properties": {
        "matchId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    },
    "data": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "unreadCounts"
      ],
      "properties": {
        "unreadCounts": {
          "type": "object",
          "additionalProperties": {
            "type": "integer",
            "minimum": 0
          },
          "minProperties": 1,
          "maxProperties": 1
        }
      }
    }
  },
  "x-firestore-operation": "update",
  "x-firestore-path": "matches/{matchId}",
  "x-owner": "active match participant direct unread reset"
} as const;
