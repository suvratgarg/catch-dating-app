/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const submitEventRehearsalGuestActionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/submit_event_rehearsal_guest_action_payload.schema.json",
  "title": "SubmitEventRehearsalGuestActionCallablePayload",
  "description": "Applies a bounded action from an anonymous rehearsal guest slot.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "publicRehearsalId",
    "slotToken",
    "clientActionId",
    "action"
  ],
  "properties": {
    "publicRehearsalId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{20,80}$"
    },
    "slotToken": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{20,180}$"
    },
    "clientActionId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{8,120}$"
    },
    "action": {
      "type": "string",
      "enum": [
        "checkIn",
        "confirmArrival",
        "optOut",
        "optIn",
        "askForHelp",
        "completePrompt"
      ]
    }
  }
} as const;
