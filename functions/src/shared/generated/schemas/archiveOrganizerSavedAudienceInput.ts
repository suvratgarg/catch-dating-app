/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const archiveOrganizerSavedAudienceCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/archive_organizer_saved_audience_payload.schema.json",
  "title": "ArchiveOrganizerSavedAudienceCallablePayload",
  "description": "Archives one reusable CRM audience with optimistic revision control.",
  "x-callable-aliases": [
    "archiveOrganizerSavedAudience"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "audienceId",
    "expectedRevision"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "audienceId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
