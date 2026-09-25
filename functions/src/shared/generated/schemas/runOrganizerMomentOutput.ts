/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const runOrganizerMomentCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/run_organizer_moment_response.schema.json",
  "title": "RunOrganizerMomentCallableResponse",
  "description": "Result of a manual moment fire: the deterministic run id.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "runId"
  ],
  "properties": {
    "runId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 300
    }
  }
} as const;
