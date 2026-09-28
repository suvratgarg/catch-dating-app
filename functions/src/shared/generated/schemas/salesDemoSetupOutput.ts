/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesDemoSetupCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/sales_demo_setup_response.schema.json",
  "title": "SalesDemoSetupCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "setupHash",
    "plan",
    "organizerId",
    "formId",
    "editorPath",
    "publicationAuthority",
    "status"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "setupHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "plan": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "mode",
            "requirements"
          ],
          "properties": {
            "mode": {
              "const": "manual"
            },
            "requirements": {
              "type": "array",
              "maxItems": 12,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              },
              "minItems": 1
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "mode",
            "requirements",
            "templateId",
            "title",
            "templateVersion",
            "templateHash",
            "materializerVersion"
          ],
          "properties": {
            "mode": {
              "const": "template"
            },
            "requirements": {
              "type": "array",
              "maxItems": 12,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              }
            },
            "templateId": {
              "type": "string",
              "pattern": "^[A-Za-z0-9_-]{3,128}$"
            },
            "title": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            },
            "templateVersion": {
              "type": "integer",
              "minimum": 1
            },
            "templateHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "materializerVersion": {
              "const": 1
            }
          }
        }
      ]
    },
    "organizerId": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        {
          "type": "null"
        }
      ]
    },
    "formId": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        {
          "type": "null"
        }
      ]
    },
    "editorPath": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^/host/audience/forms/[A-Za-z0-9_-]{3,128}$"
        },
        {
          "type": "null"
        }
      ]
    },
    "publicationAuthority": {
      "const": false
    },
    "status": {
      "enum": [
        "manual_setup",
        "claim_required",
        "ready",
        "prepared"
      ]
    }
  },
  "x-callables": [
    "getSalesDemoSetup",
    "prepareSalesDemoFormDraft"
  ]
} as const;
