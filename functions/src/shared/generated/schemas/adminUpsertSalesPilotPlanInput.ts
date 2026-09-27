/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminUpsertSalesPilotPlanCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_upsert_sales_pilot_plan_payload.schema.json",
  "title": "commercial.pilots.upsert request",
  "description": "Strict private Sales commercial request; current role, scope, revision and evidence policy are transactional.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "opportunityId",
    "requestId",
    "expectedRevision",
    "plan"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "opportunityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000000
    },
    "plan": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "status",
        "workflowId",
        "objective",
        "successMeasures",
        "startsAt",
        "endsAt",
        "reviewEvidence",
        "outcomeEvidence"
      ],
      "properties": {
        "status": {
          "enum": [
            "draft",
            "reviewed",
            "active",
            "completed",
            "cancelled"
          ]
        },
        "workflowId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "objective": {
          "type": "string",
          "minLength": 1,
          "maxLength": 1000
        },
        "successMeasures": {
          "type": "array",
          "minItems": 1,
          "maxItems": 8,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          }
        },
        "startsAt": {
          "anyOf": [
            {
              "type": "string",
              "format": "date-time"
            },
            {
              "type": "null"
            }
          ]
        },
        "endsAt": {
          "anyOf": [
            {
              "type": "string",
              "format": "date-time"
            },
            {
              "type": "null"
            }
          ]
        },
        "reviewEvidence": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "evidenceId"
              ],
              "properties": {
                "evidenceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 96,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "null"
            }
          ]
        },
        "outcomeEvidence": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "evidenceId"
              ],
              "properties": {
                "evidenceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 96,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "null"
            }
          ]
        }
      }
    }
  }
} as const;
