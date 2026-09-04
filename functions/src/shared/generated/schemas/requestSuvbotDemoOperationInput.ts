/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const requestSuvbotDemoOperationCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/request_suvbot_demo_operation_payload.schema.json",
  "title": "RequestSuvbotDemoOperationCallablePayload",
  "description": "Callable payload accepted by requestSuvbotDemoOperation. Demo-only operations triggered from the Suvbot conversation surface.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "action"
  ],
  "properties": {
    "action": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "text": {
      "type": "string",
      "maxLength": 2000
    }
  }
} as const;
