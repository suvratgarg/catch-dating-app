/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const claimProgramStaffInviteCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/claim_program_staff_invite_payload.schema.json",
  "title": "ClaimProgramStaffInviteCallablePayload",
  "description": "Redeem a staff invite. The caller must be signed in with a verified phone number matching the invite's bound phone; on success a programStaffGrants document is written and the invite is consumed.",
  "type": "object",
  "additionalProperties": false,
  "x-callable-aliases": [
    "claimProgramStaffInvite"
  ],
  "required": [
    "inviteId"
  ],
  "properties": {
    "inviteId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 180
    }
  }
} as const;
