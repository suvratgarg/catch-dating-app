/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const sendCrossPathsInvitationCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/send_cross_paths_invitation_payload.schema.json",
  "title": "SendCrossPathsInvitationCallablePayload",
  "description": "Typed, message-free invitation intent accepted by sendCrossPathsInvitation.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "recipientUid",
    "suggestionToken"
  ],
  "properties": {
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
    "suggestionToken": {
      "type": "string",
      "minLength": 40,
      "maxLength": 4096
    }
  }
} as const;
