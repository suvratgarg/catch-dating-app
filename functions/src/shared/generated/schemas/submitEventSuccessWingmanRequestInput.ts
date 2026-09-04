/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const submitEventSuccessWingmanRequestCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/submit_event_success_wingman_request_payload.schema.json",
  "title": "SubmitEventSuccessWingmanRequestCallablePayload",
  "description": "Callable payload accepted by submitEventSuccessWingmanRequest.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "targetUid"
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
    "note": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240
    }
  }
} as const;
