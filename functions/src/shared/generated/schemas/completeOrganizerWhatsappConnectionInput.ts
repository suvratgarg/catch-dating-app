/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const completeOrganizerWhatsappConnectionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/complete_organizer_whatsapp_connection_payload.schema.json",
  "title": "CompleteOrganizerWhatsappConnectionCallablePayload",
  "description": "Server-side completion of Meta Embedded Signup using the short-lived authorization code returned to the Host surface.",
  "x-callable-aliases": [
    "completeOrganizerWhatsappConnection"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "authorizationCode",
    "wabaId",
    "phoneNumberId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "authorizationCode": {
      "type": "string",
      "minLength": 20,
      "maxLength": 2048
    },
    "wabaId": {
      "type": "string",
      "pattern": "^[0-9]{5,40}$"
    },
    "phoneNumberId": {
      "type": "string",
      "pattern": "^[0-9]{5,40}$"
    },
    "businessId": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[0-9]{5,40}$"
    }
  }
} as const;
