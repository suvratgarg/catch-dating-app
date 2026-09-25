/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const runOrganizerMomentCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/run_organizer_moment_payload.schema.json",
  "title": "RunOrganizerMomentCallablePayload",
  "description": "Fire a manual moment immediately. The caller-supplied requestKey scopes idempotency: retries and double-submits with the same key resolve to the same run.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "scope",
    "momentId",
    "requestKey"
  ],
  "properties": {
    "scope": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind"
      ],
      "properties": {
        "kind": {
          "type": "string",
          "enum": [
            "event",
            "program"
          ]
        },
        "eventId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 180,
          "description": "Required when kind=event; must be null otherwise."
        },
        "programId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 180,
          "description": "Required when kind=program; must be null otherwise."
        }
      }
    },
    "momentId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestKey": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
