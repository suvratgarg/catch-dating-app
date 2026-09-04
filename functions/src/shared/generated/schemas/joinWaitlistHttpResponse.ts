/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const joinWaitlistHTTPResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/http/join_waitlist_response.schema.json",
  "title": "Join Waitlist HTTP Response",
  "description": "Version 1 JSON response returned by the member waitlist and Host operating-application endpoint.",
  "oneOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "ok",
        "alreadyJoined"
      ],
      "properties": {
        "ok": {
          "const": true
        },
        "alreadyJoined": {
          "type": "boolean"
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "error"
      ],
      "properties": {
        "error": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        }
      }
    }
  ]
} as const;
