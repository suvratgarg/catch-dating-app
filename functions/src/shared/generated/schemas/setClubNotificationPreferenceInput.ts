/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const setClubNotificationPreferenceCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/set_club_notification_preference_payload.schema.json",
  "title": "SetClubNotificationPreferenceCallablePayload",
  "description": "Callable payload accepted by setClubNotificationPreference.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId",
    "enabled"
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "enabled": {
      "type": "boolean"
    }
  }
} as const;
