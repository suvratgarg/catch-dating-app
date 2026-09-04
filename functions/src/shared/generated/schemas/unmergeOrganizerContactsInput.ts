/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const unmergeOrganizerContactsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/unmerge_organizer_contacts_payload.schema.json",
  "title": "UnmergeOrganizerContactsCallablePayload",
  "description": "Manager request to reverse one organizer contact merge receipt.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "mergeReceiptId",
    "idempotencyKey"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "mergeReceiptId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "idempotencyKey": {
      "type": "string",
      "minLength": 8,
      "maxLength": 120
    }
  }
} as const;
