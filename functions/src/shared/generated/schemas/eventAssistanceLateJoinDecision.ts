/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceLateJoinDecisionSchema: Record<string, unknown> = {
  "anyOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "reason"
      ],
      "properties": {
        "kind": {
          "type": "string",
          "const": "resolved"
        },
        "reason": {
          "type": "string",
          "enum": [
            "joined",
            "declined"
          ]
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "reason"
      ],
      "properties": {
        "kind": {
          "type": "string",
          "const": "cancelled"
        },
        "reason": {
          "type": "string",
          "enum": [
            "eventClosed",
            "notAdmitted",
            "policyDisabled"
          ]
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "reason"
      ],
      "properties": {
        "kind": {
          "type": "string",
          "const": "expired"
        },
        "reason": {
          "type": "string",
          "enum": [
            "cutoff",
            "lateEntryClosed"
          ]
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "reason"
      ],
      "properties": {
        "kind": {
          "type": "string",
          "const": "wait"
        },
        "reason": {
          "type": "string",
          "enum": [
            "departureUnconfirmed",
            "attendanceUnknown",
            "guidanceUnavailable",
            "throttled",
            "unchanged"
          ]
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "reason",
        "guidance"
      ],
      "properties": {
        "kind": {
          "type": "string",
          "const": "hostDecision"
        },
        "reason": {
          "type": "string",
          "enum": [
            "unreachable",
            "entryDecision",
            "missingInformation"
          ]
        },
        "guidance": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "revision",
                "destination",
                "materialKey",
                "text",
                "validUntil"
              ],
              "properties": {
                "revision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "Nonnegative safe integer revision."
                },
                "destination": {
                  "anyOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "placeId",
                        "lateEntry"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "fixedPlace"
                        },
                        "placeId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        },
                        "lateEntry": {
                          "type": "string",
                          "enum": [
                            "allowed",
                            "hostDecision",
                            "closed"
                          ]
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "itineraryId",
                        "stopId"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "itineraryStop"
                        },
                        "itineraryId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 2000
                        },
                        "stopId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 2000
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "routeId",
                        "groupId",
                        "checkpointId"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "groupCheckpoint"
                        },
                        "routeId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 2000
                        },
                        "groupId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        },
                        "checkpointId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 2000
                        }
                      }
                    }
                  ]
                },
                "materialKey": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "text": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "validUntil": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "UTC milliseconds."
                }
              }
            },
            {
              "type": "null",
              "const": null
            }
          ]
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "guidance",
        "messageKey",
        "shouldSend",
        "nextEvaluationAt"
      ],
      "properties": {
        "kind": {
          "type": "string",
          "const": "update"
        },
        "guidance": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "revision",
            "destination",
            "materialKey",
            "text",
            "validUntil"
          ],
          "properties": {
            "revision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991,
              "description": "Nonnegative safe integer revision."
            },
            "destination": {
              "anyOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "placeId",
                    "lateEntry"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "fixedPlace"
                    },
                    "placeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "lateEntry": {
                      "type": "string",
                      "enum": [
                        "allowed",
                        "hostDecision",
                        "closed"
                      ]
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "itineraryId",
                    "stopId"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "itineraryStop"
                    },
                    "itineraryId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "stopId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "routeId",
                    "groupId",
                    "checkpointId"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "groupCheckpoint"
                    },
                    "routeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "groupId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "checkpointId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    }
                  }
                }
              ]
            },
            "materialKey": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            },
            "text": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            },
            "validUntil": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991,
              "description": "UTC milliseconds."
            }
          }
        },
        "messageKey": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000
        },
        "shouldSend": {
          "type": "boolean"
        },
        "nextEvaluationAt": {
          "anyOf": [
            {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            {
              "type": "null"
            }
          ]
        }
      }
    }
  ],
  "title": "EventAssistanceLateJoinDecision"
} as const;
