/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createOrganizerFormShareLinkCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_organizer_form_share_link_payload.schema.json",
  "title": "CreateOrganizerFormShareLinkCallablePayload",
  "description": "Creates an idempotent source-attributed link for a published form.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "label",
    "source",
    "requestId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "formId": {
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
    "requestId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{16,120}$"
    }
  }
} as const;
