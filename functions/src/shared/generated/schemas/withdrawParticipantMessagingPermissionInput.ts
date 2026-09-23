/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const withdrawParticipantMessagingPermissionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/withdraw_participant_messaging_permission_payload.schema.json",
  "title": "WithdrawParticipantMessagingPermissionCallablePayload",
  "description": "Withdraw exactly one sender’s WhatsApp permission using the reviewed receipt. Never grants consent.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "scope",
    "organizerId",
    "expectedReceiptId",
    "requestId"
  ],
  "properties": {
    "scope": {
      "type": "string",
      "enum": [
        "catch",
        "organizer"
      ]
    },
    "organizerId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "expectedReceiptId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
