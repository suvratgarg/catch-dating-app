/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const submitOrganizerFormResponseCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/submit_organizer_form_response_response.schema.json",
  "title": "SubmitOrganizerFormResponseCallableResponse",
  "description": "Stable form response receipt.",
  "allOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "responseId",
        "formId",
        "versionId",
        "status",
        "submittedAtMillis",
        "withdrawalToken",
        "completion"
      ],
      "properties": {
        "responseId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "formId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "versionId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "status": {
          "type": "string",
          "enum": [
            "submitted",
            "withdrawn"
          ]
        },
        "submittedAtMillis": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "withdrawalToken": {
          "type": [
            "string",
            "null"
          ],
          "pattern": "^[A-Za-z0-9_-]{32,160}$"
        },
        "completion": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "title",
            "message",
            "actionKind",
            "actionLabel",
            "actionUrl"
          ],
          "properties": {
            "title": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            },
            "message": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 1000
            },
            "actionKind": {
              "type": "string",
              "enum": [
                "none",
                "externalUrl",
                "event",
                "eventRuntime"
              ]
            },
            "actionLabel": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 80
            },
            "actionUrl": {
              "type": [
                "string",
                "null"
              ],
              "format": "uri",
              "maxLength": 500
            }
          }
        }
      }
    }
  ]
} as const;
