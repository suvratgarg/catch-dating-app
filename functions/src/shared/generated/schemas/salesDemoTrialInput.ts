/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesDemoTrialCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/sales_demo_trial.schema.json",
  "title": "SalesDemoTrialCallablePayloads",
  "description": "Union of explicit start, exact session read, and bounded synthetic action requests. Auth and App Check are required for every variant.",
  "anyOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "invitationId",
        "grantToken",
        "requestId"
      ],
      "properties": {
        "invitationId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "grantToken": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{43}$"
        },
        "requestId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$"
        }
      }
    },
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
        "requestId",
        "expectedRevision",
        "action"
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
        "requestId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$"
        },
        "expectedRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 1000000
        },
        "action": {
          "enum": [
            "reviewApplication",
            "prepareReply",
            "admitGuest",
            "requestAssistance"
          ]
        },
        "choice": {
          "enum": [
            "approve",
            "needs_info",
            "welcome",
            "clarify"
          ]
        }
      }
    }
  ],
  "definitions": {
    "id": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "requestId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$"
    },
    "grantToken": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{43}$"
    },
    "start": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "invitationId",
        "grantToken",
        "requestId"
      ],
      "properties": {
        "invitationId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "grantToken": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{43}$"
        },
        "requestId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$"
        }
      }
    },
    "get": {
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
    "advance": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "sessionId",
        "grantToken",
        "requestId",
        "expectedRevision",
        "action"
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
        "requestId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$"
        },
        "expectedRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 1000000
        },
        "action": {
          "enum": [
            "reviewApplication",
            "prepareReply",
            "admitGuest",
            "requestAssistance"
          ]
        },
        "choice": {
          "enum": [
            "approve",
            "needs_info",
            "welcome",
            "clarify"
          ]
        }
      }
    }
  },
  "x-callables": [
    "startSalesDemo",
    "getSalesDemoSession",
    "advanceSalesDemo"
  ]
} as const;
