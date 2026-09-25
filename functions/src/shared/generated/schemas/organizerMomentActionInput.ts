/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerMomentActionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/organizer_moment_action_payload.schema.json",
  "title": "OrganizerMomentActionCallablePayload",
  "description": "Lifecycle transition on one moment: arm (approve the rule once), pause, or resume. Scope must match the stored moment.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "scope",
    "momentId"
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
    }
  }
} as const;
