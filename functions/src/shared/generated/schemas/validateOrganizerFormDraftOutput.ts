/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const validateOrganizerFormDraftCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/validate_organizer_form_draft_response.schema.json",
  "title": "ValidateOrganizerFormDraftCallableResponse",
  "description": "Publish-readiness result from the canonical form validator.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "valid",
    "issues"
  ],
  "properties": {
    "valid": {
      "type": "boolean"
    },
    "issues": {
      "type": "array",
      "maxItems": 250,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "code",
          "path",
          "message",
          "severity"
        ],
        "properties": {
          "code": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "path": {
            "type": "string",
            "minLength": 1,
            "maxLength": 300
          },
          "message": {
            "type": "string",
            "minLength": 1,
            "maxLength": 500
          },
          "severity": {
            "type": "string",
            "enum": [
              "error",
              "warning"
            ]
          }
        }
      }
    }
  }
} as const;
