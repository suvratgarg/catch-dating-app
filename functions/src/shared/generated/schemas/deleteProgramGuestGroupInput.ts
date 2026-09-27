/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const deleteProgramGuestGroupCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/delete_program_guest_group_payload.schema.json",
  "title": "DeleteProgramGuestGroupCallablePayload",
  "description": "Delete a program guest group and scrub its id from member programGuests.groupIds in bounded batches.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "groupId"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "groupId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
