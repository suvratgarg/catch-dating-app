/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const transferClubOwnershipCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/transfer_club_ownership_payload.schema.json",
  "title": "TransferClubOwnershipCallablePayload",
  "description": "Callable payload accepted by transferClubOwnership.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId",
    "uid"
  ],
  "properties": {
    "clubId": {
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
