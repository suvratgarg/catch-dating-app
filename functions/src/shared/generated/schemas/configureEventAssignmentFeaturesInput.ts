/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const configureEventAssignmentFeaturesCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/configure_event_assignment_features_payload.schema.json",
  "title": "ConfigureEventAssignmentFeaturesCallablePayload",
  "description": "Organizer maps reviewed versioned form questions to bounded soft assignment features; it does not grant answer use.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "expectedRevision",
    "requestId",
    "rules"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "rules": {
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
    }
  }
} as const;
