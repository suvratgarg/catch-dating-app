/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getOrganizerProviderSetupCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_organizer_provider_setup_payload.schema.json",
  "title": "GetOrganizerProviderSetupCallablePayload",
  "description": "Manager request for safe provider capabilities and one event mapping.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "eventId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
