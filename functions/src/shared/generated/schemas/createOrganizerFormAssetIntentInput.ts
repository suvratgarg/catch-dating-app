/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createOrganizerFormAssetIntentCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_organizer_form_asset_intent_payload.schema.json",
  "title": "CreateOrganizerFormAssetIntentCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "draftId",
    "draftToken",
    "questionId",
    "requestId",
    "originalFileName",
    "contentType",
    "sizeBytes",
    "sha256"
  ],
  "properties": {
    "draftId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "draftToken": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[A-Za-z0-9_-]{32,160}$"
    },
    "questionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{8,160}$"
    },
    "originalFileName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 255
    },
    "contentType": {
      "type": "string",
      "enum": [
        "image/jpeg",
        "image/png",
        "image/webp",
        "application/pdf"
      ]
    },
    "sizeBytes": {
      "type": "integer",
      "minimum": 1,
      "maximum": 26214400
    },
    "sha256": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    }
  }
} as const;
