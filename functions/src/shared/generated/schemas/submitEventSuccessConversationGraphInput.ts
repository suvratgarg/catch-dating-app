/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const submitEventSuccessConversationGraphCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/submit_event_success_conversation_graph_payload.schema.json",
  "title": "SubmitEventSuccessConversationGraphCallablePayload",
  "description": "Authenticated attendee submission for the end-of-event conversation graph.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "selectedUids",
    "skipped"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "selectedUids": {
      "type": "array",
      "uniqueItems": true,
      "maxItems": 1000,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    },
    "skipped": {
      "type": "boolean"
    }
  }
} as const;
