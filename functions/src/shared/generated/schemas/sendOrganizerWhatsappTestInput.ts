/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const sendOrganizerWhatsappTestCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/send_organizer_whatsapp_test_payload.schema.json",
  "title": "SendOrganizerWhatsappTestCallablePayload",
  "description": "Sends one manager-authorized template message to verify an organizer-owned WhatsApp sender.",
  "x-callable-aliases": [
    "sendOrganizerWhatsappTest"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "connectionId",
    "templateId",
    "toE164",
    "templateVariables"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "connectionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "templateId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "toE164": {
      "type": "string",
      "pattern": "^\\+[1-9][0-9]{7,14}$"
    },
    "templateVariables": {
      "type": "object",
      "maxProperties": 20,
      "propertyNames": {
        "pattern": "^[A-Za-z][A-Za-z0-9_]{0,63}$"
      },
      "additionalProperties": {
        "type": "string",
        "minLength": 1,
        "maxLength": 240
      }
    }
  }
} as const;
