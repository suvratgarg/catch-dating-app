/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const reportUserCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/report_user_payload.schema.json",
  "title": "ReportUserCallablePayload",
  "description": "Callable payload accepted by reportUser.",
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
    },
    "source": {
      "type": "string",
      "maxLength": 64
    },
    "reasonCode": {
      "type": "string",
      "maxLength": 64
    },
    "contextId": {
      "type": "string",
      "maxLength": 128
    },
    "notes": {
      "type": "string",
      "maxLength": 2000
    }
  }
} as const;
