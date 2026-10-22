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
        },
        "hostLead": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "eventId",
            "isNew"
          ],
          "properties": {
            "eventId": {
              "type": "string",
              "pattern": "^host_lead_[0-9]{13}_[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$"
            },
            "isNew": {
              "type": "boolean"
            }
          }
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
