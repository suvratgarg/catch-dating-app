/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesDemoSetupCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/sales_demo_setup.schema.json",
  "title": "SalesDemoSetupCallablePayload",
  "anyOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "sessionId",
        "grantToken"
      ],
      "properties": {
        "sessionId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "grantToken": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{43}$"
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "sessionId",
        "grantToken",
        "setupHash"
      ],
      "properties": {
        "sessionId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "grantToken": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{43}$"
        },
        "setupHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        }
      }
    }
  ],
  "x-callables": [
    "getSalesDemoSetup",
    "prepareSalesDemoFormDraft"
  ]
} as const;
