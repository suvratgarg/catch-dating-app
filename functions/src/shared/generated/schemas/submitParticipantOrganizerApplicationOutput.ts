/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const submitParticipantOrganizerApplicationCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/submit_participant_organizer_application_response.schema.json",
  "title": "SubmitParticipantOrganizerApplicationCallableResponse",
  "description": "Identity and exact grant receipt for a native participant application.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "applicationId",
    "responseId",
    "grantId",
    "reviewStatus",
    "intakeProfileRevision",
    "replayed"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "applicationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "responseId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "grantId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "reviewStatus": {
      "const": "submitted"
    },
    "intakeProfileRevision": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
