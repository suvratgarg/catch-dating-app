/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const respondCrossPathsInvitationCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/respond_cross_paths_invitation_response.schema.json",
  "title": "RespondCrossPathsInvitationCallableResponse",
  "description": "Sanitized terminal response after accepting or declining an invitation.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "invitationId",
    "status",
    "conversationId",
    "pairHoldId"
  ],
  "properties": {
    "invitationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "status": {
      "type": "string",
      "enum": [
        "accepted",
        "declined"
      ]
    },
    "conversationId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "pairHoldId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    }
  }
} as const;
