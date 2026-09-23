/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getParticipantFormPhotoCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "additionalProperties": false,
  "$id": "https://catch.app/contracts/callable_responses/get_participant_form_photo_response.schema.json",
  "title": "GetParticipantFormPhotoCallableResponse",
  "description": "Bounded metadata-free JPEG bytes for private in-memory review; never an original upload URL.",
  "required": [
    "contentType",
    "previewBase64",
    "width",
    "height"
  ],
  "properties": {
    "contentType": {
      "type": "string",
      "const": "image/jpeg"
    },
    "previewBase64": {
      "type": "string",
      "minLength": 4,
      "maxLength": 349528,
      "pattern": "^[A-Za-z0-9+/]+={0,2}$"
    },
    "width": {
      "type": "integer",
      "minimum": 1,
      "maximum": 640
    },
    "height": {
      "type": "integer",
      "minimum": 1,
      "maximum": 640
    }
  }
} as const;
