/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createOrganizerFormShareLinkCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/create_organizer_form_share_link_response.schema.json",
  "title": "CreateOrganizerFormShareLinkCallableResponse",
  "description": "Source-attributed public form URL.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "linkId",
    "label",
    "source",
    "url",
    "sourceToken"
  ],
  "properties": {
    "linkId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "label": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "source": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120
    },
    "url": {
      "type": "string",
      "format": "uri",
      "maxLength": 2000
    },
    "sourceToken": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{20,160}$"
    }
  }
} as const;
