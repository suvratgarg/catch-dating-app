/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const commitOrganizerFormAdmissionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/commit_organizer_form_admission_payload.schema.json",
  "title": "CommitOrganizerFormAdmissionCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "eventId",
    "responseId",
    "contactId",
    "offerId",
    "expectedOfferRevision",
    "expectedOfferGeneration",
    "expectedLedgerRevision",
    "requestId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9_-]{1,180}$"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9_-]{1,180}$"
    },
    "responseId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9_-]{1,180}$"
    },
    "contactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9_-]{1,180}$"
    },
    "offerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9_-]{1,180}$"
    },
    "expectedOfferRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "expectedOfferGeneration": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "expectedLedgerRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 120,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{7,119}$"
    }
  }
} as const;
