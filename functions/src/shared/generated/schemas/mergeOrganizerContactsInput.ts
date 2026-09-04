/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const mergeOrganizerContactsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/merge_organizer_contacts_payload.schema.json",
  "title": "MergeOrganizerContactsCallablePayload",
  "description": "Manager-confirmed, revision-checked organizer contact merge.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "survivorContactId",
    "sourceContactId",
    "survivorRevision",
    "sourceRevision",
    "confirmConflicts",
    "idempotencyKey"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "survivorContactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "sourceContactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "survivorRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "sourceRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "confirmConflicts": {
      "type": "boolean"
    },
    "idempotencyKey": {
      "type": "string",
      "minLength": 8,
      "maxLength": 120
    }
  }
} as const;
