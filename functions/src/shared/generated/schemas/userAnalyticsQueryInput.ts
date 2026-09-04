/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const userAnalyticsQueryCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/user_analytics_query_payload.schema.json",
  "title": "UserAnalyticsQueryCallablePayload",
  "description": "Callable payload accepted by getUserAnalytics and adminGetUserAnalytics.",
  "x-callable-aliases": [
    "getUserAnalytics",
    "adminGetUserAnalytics"
  ],
  "type": "object",
  "additionalProperties": false,
  "properties": {
    "userId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ],
      "description": "Admin-only user scope override. getUserAnalytics always scopes to the signed-in user."
    },
    "rangePreset": {
      "type": "string",
      "enum": [
        "7d",
        "30d",
        "90d",
        "month",
        "custom"
      ]
    },
    "startDate": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
    },
    "endDate": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
    },
    "granularity": {
      "type": "string",
      "enum": [
        "day",
        "week",
        "month"
      ]
    }
  }
} as const;
