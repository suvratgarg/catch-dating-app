/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const saveOrganizerFormResponseDraftCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/save_organizer_form_response_draft_payload.schema.json",
  "title": "SaveOrganizerFormResponseDraftCallablePayload",
  "description": "Optimistically saves respondent answers without file bytes.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "draftId",
    "draftToken",
    "expectedRevision",
    "answers",
    "consentAccepted"
  ],
  "properties": {
    "draftId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "draftToken": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[A-Za-z0-9_-]{32,160}$"
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "answers": {
      "type": "object",
      "maxProperties": 4000,
      "propertyNames": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      },
      "additionalProperties": {
        "anyOf": [
          {
            "type": "string",
            "maxLength": 10000
          },
          {
            "type": "number",
            "minimum": -1000000000,
            "maximum": 1000000000
          },
          {
            "type": "boolean"
          },
          {
            "type": "null"
          },
          {
            "type": "array",
            "maxItems": 100,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "maxLength": 500
            }
          }
        ]
      }
    },
    "consentAccepted": {
      "type": "boolean"
    }
  }
} as const;
