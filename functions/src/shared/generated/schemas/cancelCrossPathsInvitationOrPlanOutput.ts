/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const cancelCrossPathsInvitationOrPlanCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/cancel_cross_paths_invitation_or_plan_response.schema.json",
  "title": "CancelCrossPathsInvitationOrPlanCallableResponse",
  "description": "Sanitized cancellation receipt for a pending invitation or accepted plan.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "invitationId",
    "status"
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
        "cancelled",
        "invalidated"
      ]
    }
  }
} as const;
