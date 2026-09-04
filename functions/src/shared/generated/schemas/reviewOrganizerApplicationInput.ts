/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const reviewOrganizerApplicationCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/review_organizer_application_payload.schema.json",
  "title": "ReviewOrganizerApplicationCallablePayload",
  "description": "Optimistic manager review mutation for one organizer application.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "applicationId",
    "expectedRevision",
    "reviewStatus",
    "reviewNote"
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
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
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
    "reviewNote": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 2000
    }
  }
} as const;
