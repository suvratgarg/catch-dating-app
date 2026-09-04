/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getOrganizerFormAnalyticsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/get_organizer_form_analytics_response.schema.json",
  "title": "GetOrganizerFormAnalyticsCallableResponse",
  "description": "Privacy-aware precomputed form funnel and compatible question aggregates.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "versionId",
    "version",
    "opens",
    "starts",
    "submissions",
    "withdrawals",
    "completionRate",
    "medianCompletionMillis",
    "questions",
    "sources",
    "privacyThreshold"
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
    "versionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "version": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000
    },
    "opens": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000000
    },
    "starts": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000000
    },
    "submissions": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000000
    },
    "withdrawals": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000000
    },
    "completionRate": {
      "type": "number",
      "minimum": 0,
      "maximum": 1
    },
    "medianCompletionMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 604800000
    },
    "questions": {
      "type": "array",
      "maxItems": 200,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "questionId",
          "label",
          "kind",
          "privacyClass",
          "responseCount",
          "choiceCounts",
          "numericCount",
          "numericSum",
          "numericMin",
          "numericMax"
        ],
        "properties": {
          "questionId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          },
          "kind": {
            "type": "string",
            "enum": [
              "shortText",
              "longText",
              "singleChoice",
              "multiChoice",
              "date",
              "phone",
              "email",
              "url",
              "number",
              "boolean",
              "file",
              "acknowledgement",
              "signature"
            ]
          },
          "privacyClass": {
            "type": "string",
            "enum": [
              "contact",
              "profile",
              "sensitive",
              "organizerCustom"
            ]
          },
          "responseCount": {
            "type": "integer",
            "minimum": 0,
            "maximum": 1000000000
          },
          "choiceCounts": {
            "type": "array",
            "maxItems": 100,
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "value",
                "label",
                "count"
              ],
              "properties": {
                "value": {
                  "type": [
                    "string",
                    "boolean"
                  ],
                  "maxLength": 160
                },
                "label": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160
                },
                "count": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 1000000000
                }
              }
            }
          },
          "numericCount": {
            "type": "integer",
            "minimum": 0,
            "maximum": 1000000000
          },
          "numericSum": {
            "type": "number",
            "minimum": -1000000000000000000,
            "maximum": 1000000000000000000
          },
          "numericMin": {
            "type": [
              "number",
              "null"
            ]
          },
          "numericMax": {
            "type": [
              "number",
              "null"
            ]
          }
        }
      }
    },
    "sources": {
      "type": "array",
      "maxItems": 200,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "sourceLinkId",
          "label",
          "opens",
          "starts",
          "submissions"
        ],
        "properties": {
          "sourceLinkId": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 128
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "opens": {
            "type": "integer",
            "minimum": 0,
            "maximum": 1000000000
          },
          "starts": {
            "type": "integer",
            "minimum": 0,
            "maximum": 1000000000
          },
          "submissions": {
            "type": "integer",
            "minimum": 0,
            "maximum": 1000000000
          }
        }
      }
    },
    "privacyThreshold": {
      "type": "integer",
      "minimum": 1,
      "maximum": 100
    }
  }
} as const;
