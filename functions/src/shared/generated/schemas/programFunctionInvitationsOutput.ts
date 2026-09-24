/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programFunctionInvitationsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/program_function_invitations_response.schema.json",
  "title": "ProgramFunctionInvitationsCallableResponse",
  "description": "Acknowledgement for an invitation-list apply: the committed function revision plus the row diff that landed.",
  "type": "object",
  "additionalProperties": false,
  "x-callable-aliases": [
    "applyProgramFunctionInvitations"
  ],
  "required": [
    "entityId",
    "revision",
    "createdCount",
    "revokedCount",
    "keptCount",
    "alreadyApplied"
  ],
  "properties": {
    "entityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "description": "The function document id."
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "createdCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "revokedCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "keptCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "alreadyApplied": {
      "type": "boolean",
      "description": "True when an exact replay returned the original result."
    }
  }
} as const;
