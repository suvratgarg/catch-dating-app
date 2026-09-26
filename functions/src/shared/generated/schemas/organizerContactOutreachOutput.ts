/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerContactOutreachCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/organizer_contact_outreach_response.schema.json",
  "title": "OrganizerContactOutreachCallableResponse",
  "description": "Safe organizer contact outreach state returned after recording an attempt.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "contactId",
    "outreachId",
    "channel",
    "outcome",
    "note",
    "authorUid",
    "occurredAtMillis",
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
    "outreachId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "channel": {
      "type": "string",
      "enum": [
        "phoneCall",
        "whatsapp",
        "email",
        "sms",
        "inPerson",
        "other"
      ]
    },
    "outcome": {
      "type": "string",
      "enum": [
        "reached",
        "noAnswer",
        "leftMessage",
        "wrongContact",
        "attempted"
      ]
    },
    "note": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 500
    },
    "authorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "occurredAtMillis": {
      "type": "integer",
      "minimum": 0
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
