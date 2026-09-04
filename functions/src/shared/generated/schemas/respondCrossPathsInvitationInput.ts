/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const respondCrossPathsInvitationCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/respond_cross_paths_invitation_payload.schema.json",
  "title": "RespondCrossPathsInvitationCallablePayload",
  "description": "Recipient-only response accepted by respondCrossPathsInvitation.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "invitationId",
    "decision"
  ],
  "properties": {
    "invitationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "decision": {
      "type": "string",
      "enum": [
        "accept",
        "decline"
      ]
    }
  }
} as const;
