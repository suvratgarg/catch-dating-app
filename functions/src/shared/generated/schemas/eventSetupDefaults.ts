/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventSetupDefaultsSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/embedded/event_setup_defaults.schema.json",
  "title": "EventSetupDefaults",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "city",
    "timezone",
    "organizerDefaultsRevision",
    "organizerDefaultsHash"
  ],
  "properties": {
    "city": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "value",
        "source"
      ],
      "properties": {
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
        },
        "source": {
          "type": "string",
          "enum": [
            "organizer",
            "event"
          ]
        }
      }
    },
    "timezone": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "value",
        "source"
      ],
      "properties": {
        "value": {
          "type": "string",
          "minLength": 1,
          "maxLength": 100
        },
        "source": {
          "type": "string",
          "enum": [
            "organizer",
            "event"
          ]
        }
      }
    },
    "organizerDefaultsRevision": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0
    },
    "organizerDefaultsHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    }
  },
  "definitions": {
    "basicsInput": {
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
