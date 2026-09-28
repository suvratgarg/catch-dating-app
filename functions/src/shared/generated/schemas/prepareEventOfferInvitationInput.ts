/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const prepareEventOfferInvitationCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/prepare_event_offer_invitation_payload.schema.json",
  "title": "PrepareEventOfferInvitationCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "eventId",
    "offerId",
    "responseId",
    "expectedOfferGeneration",
    "expectedOfferRevision"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9_:-]+$"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9_:-]+$"
    },
    "offerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9_:-]+$"
    },
    "responseId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9_:-]+$"
    },
    "expectedOfferGeneration": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "expectedOfferRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
