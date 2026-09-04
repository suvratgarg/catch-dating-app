/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const approveEventRuntimeClaimCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/approve_event_runtime_claim_response.schema.json",
  "title": "ApproveEventRuntimeClaimCallableResponse",
  "description": "Host runtime-claim decision receipt.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "status"
  ],
  "properties": {
    "status": {
      "type": "string",
      "enum": [
        "approved",
        "rejected"
      ]
    }
  }
} as const;
