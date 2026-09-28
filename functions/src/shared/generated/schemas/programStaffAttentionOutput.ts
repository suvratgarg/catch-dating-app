/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programStaffAttentionCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/program_staff_attention_response.schema.json",
  "title": "ProgramStaffAttentionCallableResponse",
  "description": "Program staff attention feed: staffAttention moment sends raised for this program, filtered to the caller's active duties. Coordinators and managers receive every duty's alerts. Send fanout is deduplicated per run and duty.",
  "type": "object",
  "additionalProperties": false,
  "x-callable-aliases": [
    "listProgramStaffAttention"
  ],
  "required": [
    "programId",
    "items",
    "truncated"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "items": {
      "type": "array",
      "maxItems": 100,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "itemId",
          "runId",
          "momentId",
          "duty",
          "severity",
          "title",
          "createdAtMillis"
        ],
        "properties": {
          "itemId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          },
          "runId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "momentId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "duty": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "severity": {
            "type": "string",
            "enum": [
              "info",
              "warning",
              "urgent"
            ]
          },
          "title": {
            "type": "string",
            "minLength": 1,
            "maxLength": 300
          },
          "createdAtMillis": {
            "type": "integer",
            "minimum": 0
          }
        }
      }
    },
    "truncated": {
      "type": "boolean"
    }
  }
} as const;
