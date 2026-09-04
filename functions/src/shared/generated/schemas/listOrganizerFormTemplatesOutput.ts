/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listOrganizerFormTemplatesCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/list_organizer_form_templates_response.schema.json",
  "title": "ListOrganizerFormTemplatesCallableResponse",
  "description": "Versioned template summaries for the Host form gallery.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "templates"
  ],
  "properties": {
    "templates": {
      "type": "array",
      "minItems": 1,
      "maxItems": 100,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "templateId",
          "version",
          "title",
          "description",
          "purpose",
          "identityPolicy",
          "sectionCount",
          "questionCount"
        ],
        "properties": {
          "templateId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "version": {
            "type": "integer",
            "minimum": 1,
            "maximum": 1000000
          },
          "title": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160
          },
          "description": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 1000
          },
          "purpose": {
            "type": "string",
            "enum": [
              "application",
              "registration",
              "intake",
              "waiver",
              "feedback",
              "survey"
            ]
          },
          "identityPolicy": {
            "type": "string",
            "enum": [
              "anonymous",
              "emailVerified",
              "phoneVerified",
              "emailOrPhoneVerified",
              "catchAccount"
            ]
          },
          "sectionCount": {
            "type": "integer",
            "minimum": 1,
            "maximum": 40
          },
          "questionCount": {
            "type": "integer",
            "minimum": 0,
            "maximum": 4000
          }
        }
      }
    }
  }
} as const;
