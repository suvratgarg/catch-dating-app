/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const cancelCrossPathsInvitationOrPlanCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/cancel_cross_paths_invitation_or_plan_payload.schema.json",
  "title": "CancelCrossPathsInvitationOrPlanCallablePayload",
  "description": "Participant cancellation accepted by cancelCrossPathsInvitationOrPlan.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "invitationId"
  ],
  "properties": {
    "invitationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
