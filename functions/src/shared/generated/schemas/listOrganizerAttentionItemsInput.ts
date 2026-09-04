/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listOrganizerAttentionItemsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/list_organizer_attention_items_payload.schema.json",
  "title": "ListOrganizerAttentionItemsCallablePayload",
  "description": "Requests a complete, read-through-reconciled Host Today attention projection for one managed organizer.",
  "type": "object",
  "additionalProperties": false,
  "x-owner": "Host Today",
  "required": [
    "organizerId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
