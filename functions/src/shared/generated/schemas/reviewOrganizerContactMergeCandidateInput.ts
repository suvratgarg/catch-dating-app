/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const reviewOrganizerContactMergeCandidateCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/review_organizer_contact_merge_candidate_payload.schema.json",
  "title": "ReviewOrganizerContactMergeCandidateCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "candidateId",
    "contactIds",
    "decision",
    "expectedRevision"
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
    "contactIds": {
      "type": "array",
      "minItems": 2,
      "maxItems": 2,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    },
    "decision": {
      "type": "string",
      "enum": [
        "differentPeople",
        "reopen"
      ]
    },
    "expectedRevision": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
