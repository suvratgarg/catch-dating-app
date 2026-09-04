/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const unblockUserCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/unblock_user_payload.schema.json",
  "title": "UnblockUserCallablePayload",
  "description": "Callable payload accepted by unblockUser.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "targetUserId"
  ],
  "properties": {
    "targetUserId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
