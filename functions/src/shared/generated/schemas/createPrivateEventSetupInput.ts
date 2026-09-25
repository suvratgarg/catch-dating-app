/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createPrivateEventSetupCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_private_event_setup_payload.schema.json",
  "title": "CreatePrivateEventSetupCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "requestId",
    "basics"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{7,127}$"
    },
    "basics": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "name",
        "city",
        "localDate",
        "localStartTime",
        "timezone"
      ],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "city": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "const": "inherit",
                  "type": "string"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "value"
              ],
              "properties": {
                "mode": {
                  "const": "set",
                  "type": "string"
                },
                "value": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "cityId",
                    "marketId"
                  ],
                  "properties": {
                    "cityId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    },
                    "marketId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    }
                  }
                }
              }
            }
          ]
        },
        "localDate": {
          "type": "string",
          "pattern": "^[0-9]{4}-[0-9]{2}-[0-9]{2}$"
        },
        "localStartTime": {
          "type": "string",
          "pattern": "^[0-9]{2}:[0-9]{2}$"
        },
        "timezone": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "const": "inherit",
                  "type": "string"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "value"
              ],
              "properties": {
                "mode": {
                  "const": "set",
                  "type": "string"
                },
                "value": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 100
                }
              }
            }
          ]
        },
        "reviewedDefaultsHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        }
      }
    }
  }
} as const;
