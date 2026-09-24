/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const submitProgramHouseholdRsvpCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/submit_program_household_rsvp_payload.schema.json",
  "title": "SubmitProgramHouseholdRsvpCallablePayload",
  "description": "Token-authenticated household RSVP submit. Responses are limited to guests in the token's household and apply atomically. messagingConsent records the explicit checkbox state; it is never implied by submitting.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "token",
    "responses",
    "messagingConsent"
  ],
  "properties": {
    "token": {
      "type": "string",
      "minLength": 16,
      "maxLength": 1024
    },
    "responses": {
      "type": "array",
      "maxItems": 2000,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "guestId",
          "functionId",
          "rsvpStatus"
        ],
        "properties": {
          "guestId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "functionId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "rsvpStatus": {
            "type": "string",
            "enum": [
              "pending",
              "attending",
              "declined",
              "maybe"
            ]
          },
          "partySize": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 1,
            "maximum": 20
          },
          "responseNote": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 500
          }
        }
      }
    },
    "messagingConsent": {
      "type": "boolean",
      "description": "The explicit household messaging-consent checkbox; recorded exactly as ticked."
    }
  }
} as const;
