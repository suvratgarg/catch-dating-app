/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const reviewOrganizerContactMergeCandidateCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/review_organizer_contact_merge_candidate_response.schema.json",
  "title": "ReviewOrganizerContactMergeCandidateCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "candidateId",
    "decisionState",
    "revision"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "candidateId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "decisionState": {
      "type": "string",
      "enum": [
        "differentPeople",
        "reopened"
      ]
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
