/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getOrganizerContactDetailCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_organizer_contact_detail_payload.schema.json",
  "title": "GetOrganizerContactDetailCallablePayload",
  "description": "Manager-authorized organizer contact detail request.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "contactId"
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
    "includeHistory": {
      "type": "boolean",
      "default": true,
      "description": "False loads overview facts without send, reply, form-response timeline, or merge-history reads. Omission preserves the full response for existing clients."
    }
  }
} as const;
