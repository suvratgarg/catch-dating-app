/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminGetSalesDemoPartnerReviewResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_get_sales_demo_partner_review_response.schema.json",
  "title": "AdminGetSalesDemoPartnerReviewResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "blueprintId",
    "blueprintRevision",
    "partnerUid",
    "assignmentRevision",
    "preview",
    "previewHash",
    "sharingRevision",
    "proposedWording",
    "proposalRevision",
    "sharingState",
    "expiresAt",
    "sharingCurrent",
    "maximumExpiresAt",
    "evaluatedAt",
    "sendAuthority",
    "capabilityApprovalAuthority",
    "organizerControlAuthority"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "blueprintId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "blueprintRevision": {
      "type": "integer",
      "minimum": 1
    },
    "partnerUid": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "assignmentRevision": {
      "type": "integer",
      "minimum": 1
    },
    "preview": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "brandName",
        "headline",
        "scenario",
        "steps",
        "retainedTools",
        "limitations",
        "cta"
      ],
      "properties": {
        "brandName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160
        },
        "headline": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160
        },
        "scenario": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160
        },
        "steps": {
          "type": "array",
          "minItems": 3,
          "maxItems": 3,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160
          }
        },
        "retainedTools": {
          "type": "array",
          "maxItems": 8,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160
          }
        },
        "limitations": {
          "type": "array",
          "minItems": 1,
          "maxItems": 8,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160
          }
        },
        "cta": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160
        }
      }
    },
    "previewHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "sharingRevision": {
      "type": "integer",
      "minimum": 0
    },
    "proposedWording": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "headline",
            "scenario",
            "cta"
          ],
          "properties": {
            "headline": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[^<>\\u0000-\\u001f]+$"
            },
            "scenario": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[^<>\\u0000-\\u001f]+$"
            },
            "cta": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[^<>\\u0000-\\u001f]+$"
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "proposalRevision": {
      "type": "integer",
      "minimum": 0
    },
    "sharingState": {
      "type": "string",
      "enum": [
        "none",
        "active",
        "withdrawn"
      ]
    },
    "expiresAt": {
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
    "sharingCurrent": {
      "type": "boolean"
    },
    "maximumExpiresAt": {
      "type": "string",
      "format": "date-time"
    },
    "evaluatedAt": {
      "type": "string",
      "format": "date-time"
    },
    "sendAuthority": {
      "const": false
    },
    "capabilityApprovalAuthority": {
      "const": false
    },
    "organizerControlAuthority": {
      "const": false
    }
  },
  "x-callable-aliases": [
    "adminGetSalesDemoPartnerReview"
  ]
} as const;
