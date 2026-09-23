/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getEventChatProfileSharingCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_event_chat_profile_sharing_payload.schema.json",
  "title": "GetEventChatProfileSharingCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "expectedUid"
  ],
  "properties": {
    "eventId": {
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
