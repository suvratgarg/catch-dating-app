/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listParticipantMessagingPreferencesCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/list_participant_messaging_preferences_response.schema.json",
  "title": "ListParticipantMessagingPreferencesCallableResponse",
  "description": "Bounded participant-only WhatsApp permission directory; no contact endpoints or CRM fields.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "catchPreference",
    "organizers",
    "nextCursor"
  ],
  "properties": {
    "catchPreference": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "status",
        "receiptId"
      ],
      "properties": {
        "status": {
          "type": "string",
          "enum": [
            "unknown",
            "optedIn",
            "optedOut"
          ]
        },
        "purposes": {
          "type": "object",
          "additionalProperties": false,
          "properties": {
            "eventOperations": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "status",
                "receiptId"
              ],
              "properties": {
                "status": {
                  "type": "string",
                  "enum": [
                    "unknown",
                    "optedIn",
                    "optedOut"
                  ]
                },
                "receiptId": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    },
                    {
                      "type": "null"
                    }
                  ]
                }
              }
            },
            "marketing": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "status",
                "receiptId"
              ],
              "properties": {
                "status": {
                  "type": "string",
                  "enum": [
                    "unknown",
                    "optedIn",
                    "optedOut"
                  ]
                },
                "receiptId": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    },
                    {
                      "type": "null"
                    }
                  ]
                }
              }
            }
          }
        },
        "receiptId": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            {
              "type": "null"
            }
          ]
        }
      }
    },
    "organizers": {
      "type": "array",
      "maxItems": 30,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "organizerId",
          "organizerName",
          "preference"
        ],
        "properties": {
          "organizerId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "organizerName": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 240
          },
          "preference": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "status",
              "receiptId"
            ],
            "properties": {
              "status": {
                "type": "string",
                "enum": [
                  "unknown",
                  "optedIn",
                  "optedOut"
                ]
              },
              "purposes": {
                "type": "object",
                "additionalProperties": false,
                "properties": {
                  "eventOperations": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "status",
                      "receiptId"
                    ],
                    "properties": {
                      "status": {
                        "type": "string",
                        "enum": [
                          "unknown",
                          "optedIn",
                          "optedOut"
                        ]
                      },
                      "receiptId": {
                        "anyOf": [
                          {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 180
                          },
                          {
                            "type": "null"
                          }
                        ]
                      }
                    }
                  },
                  "marketing": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "status",
                      "receiptId"
                    ],
                    "properties": {
                      "status": {
                        "type": "string",
                        "enum": [
                          "unknown",
                          "optedIn",
                          "optedOut"
                        ]
                      },
                      "receiptId": {
                        "anyOf": [
                          {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 180
                          },
                          {
                            "type": "null"
                          }
                        ]
                      }
                    }
                  }
                }
              },
              "receiptId": {
                "anyOf": [
                  {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  {
                    "type": "null"
                  }
                ]
              }
            }
          }
        }
      }
    },
    "nextCursor": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    }
  },
  "definitions": {
    "purposeSummaries": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "eventOperations": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "status",
            "receiptId"
          ],
          "properties": {
            "status": {
              "type": "string",
              "enum": [
                "unknown",
                "optedIn",
                "optedOut"
              ]
            },
            "receiptId": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                {
                  "type": "null"
                }
              ]
            }
          }
        },
        "marketing": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "status",
            "receiptId"
          ],
          "properties": {
            "status": {
              "type": "string",
              "enum": [
                "unknown",
                "optedIn",
                "optedOut"
              ]
            },
            "receiptId": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                {
                  "type": "null"
                }
              ]
            }
          }
        }
      }
    },
    "purposeSummary": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "status",
        "receiptId"
      ],
      "properties": {
        "status": {
          "type": "string",
          "enum": [
            "unknown",
            "optedIn",
            "optedOut"
          ]
        },
        "receiptId": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            {
              "type": "null"
            }
          ]
        }
      }
    }
  }
} as const;
