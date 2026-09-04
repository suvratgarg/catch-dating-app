/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const archiveOrganizerCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/archive_organizer_payload.schema.json",
  "title": "ArchiveOrganizerCallablePayload",
  "description": "Callable payload accepted by archiveOrganizer.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "reason": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500
    }
  }
} as const;
