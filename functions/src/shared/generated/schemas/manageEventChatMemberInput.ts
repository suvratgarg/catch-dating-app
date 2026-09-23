/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const manageEventChatMemberCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/manage_event_chat_member_payload.schema.json",
  "title": "ManageEventChatMemberCallablePayload",
  "description": "Organizer manager removes, bans or explicitly reinstates a room member. Reinstatement never joins on the participant's behalf.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "targetUid",
    "action",
    "expectedRevision",
    "requestId",
    "expectedUid"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "targetUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "action": {
      "enum": [
        "remove",
        "ban",
        "reinstate"
      ]
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
