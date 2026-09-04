/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getEventSuccessPresenceSummaryCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/get_event_success_presence_summary_response.schema.json",
  "title": "GetEventSuccessPresenceSummaryCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "serverTimeMillis",
    "liveControlRevision",
    "nextRoundIndex",
    "policy",
    "entries",
    "lateArrivals"
  ],
  "properties": {
    "serverTimeMillis": {
      "type": "integer",
      "minimum": 0
    },
    "liveControlRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "nextRoundIndex": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100
    },
    "policy": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "heartbeatIntervalSeconds",
        "presentWindowSeconds",
        "likelyDepartedAfterSeconds"
      ],
      "properties": {
        "heartbeatIntervalSeconds": {
          "type": "integer",
          "minimum": 10,
          "maximum": 300
        },
        "presentWindowSeconds": {
          "type": "integer",
          "minimum": 30,
          "maximum": 900
        },
        "likelyDepartedAfterSeconds": {
          "type": "integer",
          "minimum": 60,
          "maximum": 3600
        }
      }
    },
    "entries": {
      "type": "array",
      "maxItems": 200,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "uid",
          "displayName",
          "presenceState",
          "heartbeatAtMillis"
        ],
        "properties": {
          "uid": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "displayName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "presenceState": {
            "type": "string",
            "enum": [
              "present",
              "idle",
              "likelyDeparted"
            ]
          },
          "heartbeatAtMillis": {
            "type": "integer",
            "minimum": 0
          }
        }
      }
    },
    "lateArrivals": {
      "type": "array",
      "maxItems": 200,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "uid",
          "displayName",
          "checkedInAtMillis"
        ],
        "properties": {
          "uid": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "displayName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "checkedInAtMillis": {
            "type": "integer",
            "minimum": 0
          }
        }
      }
    }
  },
  "definitions": {
    "presencePolicy": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "heartbeatIntervalSeconds",
        "presentWindowSeconds",
        "likelyDepartedAfterSeconds"
      ],
      "properties": {
        "heartbeatIntervalSeconds": {
          "type": "integer",
          "minimum": 10,
          "maximum": 300
        },
        "presentWindowSeconds": {
          "type": "integer",
          "minimum": 30,
          "maximum": 900
        },
        "likelyDepartedAfterSeconds": {
          "type": "integer",
          "minimum": 60,
          "maximum": 3600
        }
      }
    },
    "presenceEntry": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "uid",
        "displayName",
        "presenceState",
        "heartbeatAtMillis"
      ],
      "properties": {
        "uid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "displayName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "presenceState": {
          "type": "string",
          "enum": [
            "present",
            "idle",
            "likelyDeparted"
          ]
        },
        "heartbeatAtMillis": {
          "type": "integer",
          "minimum": 0
        }
      }
    },
    "lateArrivalEntry": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "uid",
        "displayName",
        "checkedInAtMillis"
      ],
      "properties": {
        "uid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "displayName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "checkedInAtMillis": {
          "type": "integer",
          "minimum": 0
        }
      }
    }
  }
} as const;
