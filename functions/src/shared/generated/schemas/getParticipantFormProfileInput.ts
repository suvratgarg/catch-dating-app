/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getParticipantFormProfileCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_participant_form_profile_payload.schema.json",
  "title": "GetParticipantFormProfileCallablePayload",
  "description": "Read exact owned prepared form data for profile review.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "responseId"
  ],
  "properties": {
    "responseId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
