/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const prepareEventSuccessRotationDraftCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/prepare_event_success_rotation_draft_payload.schema.json",
  "title": "PrepareEventSuccessRotationDraftCallablePayload",
  "description": "Revision-fenced payload accepted by generateEventSuccessRotations when preparing the next host-only round.",
  "x-callable-aliases": [
    "generateEventSuccessRotations"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "expectedRevision"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    }
  }
} as const;
