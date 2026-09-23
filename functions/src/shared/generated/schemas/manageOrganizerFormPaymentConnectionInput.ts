/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const manageOrganizerFormPaymentConnectionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/manage_organizer_form_payment_connection_payload.schema.json",
  "title": "ManageOrganizerFormPaymentConnectionCallablePayload",
  "description": "Manager-only merchant connection setup, safe listing, credential refresh, and local disconnection.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "action",
    "connectionId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "action": {
      "type": "string",
      "enum": [
        "begin",
        "list",
        "disconnect",
        "refresh"
      ]
    },
    "connectionId": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^rpc_[a-f0-9]{32}$"
        },
        {
          "type": "null"
        }
      ]
    }
  }
} as const;
