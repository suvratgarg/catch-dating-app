/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getParticipantFormPhotoCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "additionalProperties": false,
  "$id": "https://catch.app/contracts/callables/get_participant_form_photo_payload.schema.json",
  "title": "GetParticipantFormPhotoCallablePayload",
  "description": "Preview one image from the verified participant’s designated form-profile question.",
  "required": [
    "responseId",
    "questionId",
    "assetId"
  ],
  "properties": {
    "responseId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "questionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "assetId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
