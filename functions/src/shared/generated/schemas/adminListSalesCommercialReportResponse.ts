/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminListSalesCommercialReportResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_list_sales_commercial_report_response.schema.json",
  "title": "admin_list_sales_commercial_report_response response",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "rows",
    "nextCursor",
    "pageScope"
  ],
  "properties": {
    "rows": {
      "type": "array",
      "maxItems": 25,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "opportunityId",
          "stage",
          "ownerUid",
          "pilotStatus",
          "pilotRevision",
          "quoteStatus",
          "quoteRevision",
          "termVersion",
          "paymentStatus",
          "manuallyAttestedHostRevenue",
          "bookedHostRevenueMinor"
        ],
        "properties": {
          "opportunityId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "stage": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96
          },
          "ownerUid": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "pilotStatus": {
            "anyOf": [
              {
                "enum": [
                  "draft",
                  "reviewed",
                  "active",
                  "completed",
                  "cancelled"
                ]
              },
              {
                "type": "null"
              }
            ]
          },
          "pilotRevision": {
            "anyOf": [
              {
                "type": "integer",
                "minimum": 1
              },
              {
                "type": "null"
              }
            ]
          },
          "quoteStatus": {
            "anyOf": [
              {
                "enum": [
                  "draft",
                  "approved",
                  "accepted_reviewed"
                ]
              },
              {
                "type": "null"
              }
            ]
          },
          "quoteRevision": {
            "anyOf": [
              {
                "type": "integer",
                "minimum": 1
              },
              {
                "type": "null"
              }
            ]
          },
          "termVersion": {
            "anyOf": [
              {
                "type": "integer",
                "minimum": 1
              },
              {
                "type": "null"
              }
            ]
          },
          "paymentStatus": {
            "enum": [
              "unknown",
              "manual_attested"
            ]
          },
          "manuallyAttestedHostRevenue": {
            "anyOf": [
              {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "amountMinor",
                  "currency",
                  "providerConfirmed",
                  "purpose"
                ],
                "properties": {
                  "amountMinor": {
                    "type": "integer",
                    "minimum": 1
                  },
                  "currency": {
                    "type": "string",
                    "pattern": "^[A-Z]{3}$"
                  },
                  "providerConfirmed": {
                    "const": false
                  },
                  "purpose": {
                    "const": "host_subscription"
                  }
                }
              },
              {
                "type": "null"
              }
            ]
          },
          "bookedHostRevenueMinor": {
            "type": "null"
          }
        }
      }
    },
    "nextCursor": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 512
        },
        {
          "type": "null"
        }
      ]
    },
    "pageScope": {
      "const": true
    }
  }
} as const;
