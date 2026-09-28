/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminSalesIntelligencePolicyCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_sales_intelligence_policy_payload.schema.json",
  "title": "AdminSaveSalesIntelligencePolicyPayload",
  "description": "Admin Owner exact-retry mutation of a private seven-factor runtime policy; no policy values are published in source.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "expectedRevision",
    "policy"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0
    },
    "policy": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "policyId",
        "version",
        "status",
        "factors",
        "priorityBands",
        "promptVersion",
        "playbookVersion"
      ],
      "properties": {
        "policyId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "version": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "status": {
          "enum": [
            "active",
            "paused"
          ]
        },
        "factors": {
          "type": "array",
          "minItems": 7,
          "maxItems": 7,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "id",
              "weight",
              "claimKeys",
              "maxAgeDays"
            ],
            "properties": {
              "id": {
                "type": "string",
                "minLength": 1,
                "maxLength": 96,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "weight": {
                "type": "integer",
                "minimum": 1,
                "maximum": 100
              },
              "claimKeys": {
                "type": "array",
                "minItems": 1,
                "maxItems": 5,
                "uniqueItems": true,
                "items": {
                  "enum": [
                    "identity",
                    "recurrence",
                    "operation",
                    "stack",
                    "other"
                  ]
                }
              },
              "maxAgeDays": {
                "type": "integer",
                "minimum": 1,
                "maximum": 365
              }
            }
          }
        },
        "priorityBands": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "high",
            "medium"
          ],
          "properties": {
            "high": {
              "type": "number",
              "minimum": 0,
              "maximum": 100
            },
            "medium": {
              "type": "number",
              "minimum": 0,
              "maximum": 100
            }
          }
        },
        "promptVersion": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "playbookVersion": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        }
      }
    }
  },
  "definitions": {
    "id": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    }
  }
} as const;
