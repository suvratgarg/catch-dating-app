/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const previewEventAssignmentFeaturesCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/preview_event_assignment_features_response.schema.json",
  "title": "PreviewEventAssignmentFeaturesCallableResponse",
  "description": "No answer values or participant identities: current roster coverage for an unsaved mapping.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "revision",
    "rosterCount",
    "coverageBasis",
    "rows",
    "sources",
    "savedRules"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "revision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "rosterCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000
    },
    "coverageBasis": {
      "const": "currentEventRoster"
    },
    "savedRules": {
      "type": "array",
      "maxItems": 8,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "featureId",
          "formId",
          "versionId",
          "questionId",
          "transformVersion",
          "kind",
          "mode",
          "weight"
        ],
        "properties": {
          "featureId": {
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
          "questionId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "transformVersion": {
            "type": "integer",
            "minimum": 1,
            "maximum": 1000000
          },
          "kind": {
            "enum": [
              "category",
              "set",
              "number",
              "ordinal"
            ]
          },
          "mode": {
            "enum": [
              "preferSimilar",
              "preferDifferent",
              "balanceAcrossGroups"
            ]
          },
          "weight": {
            "type": "number",
            "minimum": 0,
            "maximum": 100
          },
          "optionIds": {
            "type": "array",
            "maxItems": 40,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            }
          },
          "scoreByOptionId": {
            "type": "object",
            "maxProperties": 40,
            "propertyNames": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "additionalProperties": {
              "type": "number"
            }
          },
          "minimum": {
            "type": "number"
          },
          "maximum": {
            "type": "number"
          }
        }
      }
    },
    "sources": {
      "type": "array",
      "maxItems": 8,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "formId",
          "formTitle",
          "versionId",
          "isActiveVersion",
          "questions"
        ],
        "properties": {
          "formId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "formTitle": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160
          },
          "versionId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "isActiveVersion": {
            "type": "boolean"
          },
          "questions": {
            "type": "array",
            "maxItems": 100,
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "questionId",
                "label",
                "kind",
                "options",
                "minNumber",
                "maxNumber"
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
                  "enum": [
                    "singleChoice",
                    "multiChoice",
                    "number"
                  ]
                },
                "minNumber": {
                  "type": [
                    "number",
                    "null"
                  ]
                },
                "maxNumber": {
                  "type": [
                    "number",
                    "null"
                  ]
                },
                "options": {
                  "type": "array",
                  "maxItems": 40,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "optionId",
                      "label"
                    ],
                    "properties": {
                      "optionId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 180
                      },
                      "label": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    },
    "rows": {
      "type": "array",
      "maxItems": 8,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "featureId",
          "kind",
          "mode",
          "weight",
          "grantedCount",
          "usableCount",
          "missingCount"
        ],
        "properties": {
          "featureId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "kind": {
            "enum": [
              "category",
              "set",
              "number",
              "ordinal"
            ]
          },
          "mode": {
            "enum": [
              "preferSimilar",
              "preferDifferent",
              "balanceAcrossGroups"
            ]
          },
          "weight": {
            "type": "number",
            "minimum": 0,
            "maximum": 100
          },
          "grantedCount": {
            "type": "integer",
            "minimum": 0,
            "maximum": 1000
          },
          "usableCount": {
            "type": "integer",
            "minimum": 0,
            "maximum": 1000
          },
          "missingCount": {
            "type": "integer",
            "minimum": 0,
            "maximum": 1000
          }
        }
      }
    }
  }
} as const;
