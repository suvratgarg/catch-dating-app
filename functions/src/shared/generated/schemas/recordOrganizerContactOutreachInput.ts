/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const recordOrganizerContactOutreachCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/record_organizer_contact_outreach_payload.schema.json",
  "title": "RecordOrganizerContactOutreachCallablePayload",
  "description": "Manager-authorized request to log one outreach attempt on an organizer contact. An omitted occurredAtMillis records the attempt at server receipt; explicit times may not be in the future.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "contactId",
    "channel",
    "outcome"
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
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    },
    "occurredAtMillis": {
      "type": "integer",
      "minimum": 0
    }
  }
} as const;
