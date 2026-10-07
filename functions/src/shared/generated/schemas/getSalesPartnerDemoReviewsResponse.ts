/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getSalesPartnerDemoReviewsResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/get_sales_partner_demo_reviews_response.schema.json",
  "title": "GetSalesPartnerDemoReviewsResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "assignmentRevision",
    "rows",
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
    "assignmentRevision": {
      "type": "integer",
      "minimum": 1
    },
    "rows": {
      "type": "array",
      "maxItems": 20,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "organizerId",
          "assignmentRevision",
          "blueprintId",
          "blueprintRevision",
          "preview",
          "previewHash",
          "validUntil",
          "evaluatedAt",
          "synthetic",
          "interactiveAvailable",
          "sendAuthority",
          "capabilityApprovalAuthority",
          "organizerControlAuthority",
          "proposalRevision",
          "proposedWording"
        ],
        "properties": {
          "organizerId": {
            "type": "string",
            "pattern": "^[A-Za-z0-9_-]{3,128}$"
          },
          "assignmentRevision": {
            "type": "integer",
            "minimum": 1
          },
          "blueprintId": {
            "type": "string",
            "pattern": "^[A-Za-z0-9_-]{3,128}$"
          },
          "blueprintRevision": {
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
          "validUntil": {
            "type": "string",
            "format": "date-time"
          },
          "evaluatedAt": {
            "type": "string",
            "format": "date-time"
          },
          "synthetic": {
            "const": true
          },
          "interactiveAvailable": {
            "const": false
          },
          "sendAuthority": {
            "const": false
          },
          "capabilityApprovalAuthority": {
            "const": false
          },
          "organizerControlAuthority": {
            "const": false
          },
          "proposalRevision": {
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
          }
        }
      }
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
    "getSalesPartnerDemoReviews"
  ]
} as const;
