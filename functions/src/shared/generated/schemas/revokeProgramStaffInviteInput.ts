/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const revokeProgramStaffInviteCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/revoke_program_staff_invite_payload.schema.json",
  "title": "RevokeProgramStaffInviteCallablePayload",
  "description": "Revoke a pending program staff invite so the link can no longer be claimed. Manager-only; claimed invites are unaffected (revoke the grant instead).",
  "type": "object",
  "additionalProperties": false,
  "x-callable-aliases": [
    "revokeProgramStaffInvite"
  ],
  "required": [
    "programId",
    "inviteId"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "inviteId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 180
    }
  }
} as const;
