/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listOrganizerMomentsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/list_organizer_moments_payload.schema.json",
  "title": "ListOrganizerMomentsCallablePayload",
  "description": "List all moments for one event or program scope.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "scope"
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
    }
  }
} as const;
