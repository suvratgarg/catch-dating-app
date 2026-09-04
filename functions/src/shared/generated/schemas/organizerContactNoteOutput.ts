/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerContactNoteCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/organizer_contact_note_response.schema.json",
  "title": "OrganizerContactNoteCallableResponse",
  "description": "Safe organizer contact note state returned after a create or edit.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "contactId",
    "noteId",
    "body",
    "authorUid",
    "createdAtMillis",
    "updatedAtMillis",
    "revision"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "contactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "noteId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "body": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000
    },
    "authorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "createdAtMillis": {
      "type": "integer",
      "minimum": 0
    },
    "updatedAtMillis": {
      "type": "integer",
      "minimum": 0
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
