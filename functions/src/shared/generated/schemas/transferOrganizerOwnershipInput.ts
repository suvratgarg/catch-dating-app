/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const transferOrganizerOwnershipCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/transfer_organizer_ownership_payload.schema.json",
  "title": "TransferOrganizerOwnershipCallablePayload",
  "description": "Callable payload accepted by transferOrganizerOwnership.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "uid"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
