/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const reviewOrganizerApplicationCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/review_organizer_application_response.schema.json",
  "title": "ReviewOrganizerApplicationCallableResponse",
  "description": "Updated organizer application review identity and revision.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "applicationId",
    "reviewStatus",
    "reviewedAtMillis",
    "revision"
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
    "reviewStatus": {
      "type": "string",
      "enum": [
        "inReview",
        "approved",
        "waitlisted",
        "declined"
      ]
    },
    "reviewedAtMillis": {
      "type": "integer",
      "minimum": 0
    },
    "revision": {
      "type": "integer",
      "minimum": 2,
      "maximum": 9007199254740991
    },
    "contactId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
