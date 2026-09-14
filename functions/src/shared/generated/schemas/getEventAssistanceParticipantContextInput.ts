/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getEventAssistanceParticipantContextCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_event_assistance_participant_context_payload.schema.json",
  "title": "GetEventAssistanceParticipantContextCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    }
  }
} as const;
