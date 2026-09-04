/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const grantEventStaffCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/grant_event_staff_payload.schema.json",
  "title": "GrantEventStaffCallablePayload",
  "description": "Organizer-manager request to grant an existing phone-auth account expiring event-operator access.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "phoneNumber",
    "expiresAtMillis"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "phoneNumber": {
      "type": "string",
      "minLength": 8,
      "maxLength": 32
    },
    "expiresAtMillis": {
      "type": "integer",
      "minimum": 0
    }
  }
} as const;
