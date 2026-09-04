/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const sendCrossPathsInvitationCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/send_cross_paths_invitation_response.schema.json",
  "title": "SendCrossPathsInvitationCallableResponse",
  "description": "Sanitized invitation receipt returned after a successful send.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "invitationId",
    "status",
    "eventId",
    "recipientUid",
    "expiresAt"
  ],
  "properties": {
    "invitationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "status": {
      "type": "string",
      "const": "pending"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "recipientUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expiresAt": {
      "type": "string",
      "format": "date-time"
    }
  }
} as const;
