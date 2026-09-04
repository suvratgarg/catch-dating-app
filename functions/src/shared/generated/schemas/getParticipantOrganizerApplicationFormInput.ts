/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getParticipantOrganizerApplicationFormCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_participant_organizer_application_form_payload.schema.json",
  "title": "GetParticipantOrganizerApplicationFormCallablePayload",
  "description": "Loads one published organizer application form and private, review-required suggestions for the authenticated participant.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "targetKind",
    "targetId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "formId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "targetKind": {
      "type": "string",
      "enum": [
        "organizer",
        "event",
        "campaign"
      ]
    },
    "targetId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
