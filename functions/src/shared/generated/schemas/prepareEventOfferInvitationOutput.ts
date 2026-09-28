/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const prepareEventOfferInvitationCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/prepare_event_offer_invitation_response.schema.json",
  "title": "PrepareEventOfferInvitationCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "url",
    "expiresAtMillis"
  ],
  "properties": {
    "url": {
      "type": "string",
      "format": "uri",
      "pattern": "^https://",
      "maxLength": 2048
    },
    "expiresAtMillis": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
