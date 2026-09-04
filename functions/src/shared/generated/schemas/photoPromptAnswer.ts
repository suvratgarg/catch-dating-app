/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const photoPromptAnswerSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/embedded/photo_prompt_answer.schema.json",
  "title": "PhotoPromptAnswer",
  "description": "One optional display prompt selected for a profile photo slot. The caption field is legacy-only and should no longer be written by clients.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "photoIndex",
    "promptId",
    "prompt"
  ],
  "properties": {
    "photoIndex": {
      "type": "integer",
      "minimum": 0,
      "maximum": 5
    },
    "promptId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80
    },
    "prompt": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140
    },
    "caption": {
      "type": "string",
      "maxLength": 140,
      "deprecated": true,
      "description": "Legacy user-entered caption retained for compatibility with older documents."
    }
  },
  "x-catch-catalog": "../catalogs/photo_prompts.json"
} as const;
