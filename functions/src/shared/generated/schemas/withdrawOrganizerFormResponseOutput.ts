/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const withdrawOrganizerFormResponseCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/withdraw_organizer_form_response_response.schema.json",
  "title": "WithdrawOrganizerFormResponseCallableResponse",
  "description": "Withdrawn response state.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "responseId",
    "status",
    "withdrawnAtMillis"
  ],
  "properties": {
    "responseId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "status": {
      "type": "string",
      "const": "withdrawn"
    },
    "withdrawnAtMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  }
} as const;
