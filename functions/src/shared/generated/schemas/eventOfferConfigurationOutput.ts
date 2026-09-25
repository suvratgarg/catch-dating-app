/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventOfferConfigurationCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/event_offer_configuration_response.schema.json",
  "title": "EventOfferConfigurationCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "eventId",
    "eventSourceRevision",
    "startsAtMillis",
    "nowMillis",
    "paymentTerms",
    "suggestedExpiresAtMillis",
    "preferencesRevision",
    "preferences"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventSourceRevision": {
      "type": "integer",
      "minimum": 1
    },
    "startsAtMillis": {
      "type": "integer",
      "minimum": 1
    },
    "nowMillis": {
      "type": "integer",
      "minimum": 0
    },
    "paymentTerms": {
      "anyOf": [
        {
          "type": "null"
        },
        {
          "title": "EventPaymentTerms",
          "type": "object",
          "additionalProperties": false,
          "required": [
            "revision",
            "preferredCollection",
            "reusablePaymentPage",
            "paymentInstructions",
            "expectedAmountMinor",
            "currency",
            "offerValidityMinutes",
            "offerMessageTemplate",
            "sourceDefaultsRevision",
            "sourceDefaultsHash",
            "fieldSources"
          ],
          "properties": {
            "revision": {
              "type": "integer",
              "minimum": 1,
              "maximum": 1000000000
            },
            "preferredCollection": {
              "anyOf": [
                {
                  "type": "string",
                  "enum": [
                    "manualInstructions",
                    "reusablePage",
                    "personalRequest",
                    "catchCheckout"
                  ]
                },
                {
                  "type": "null"
                }
              ]
            },
            "reusablePaymentPage": {
              "anyOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "url",
                    "reusableForEvents"
                  ],
                  "properties": {
                    "url": {
                      "type": "string",
                      "format": "uri",
                      "maxLength": 2048
                    },
                    "reusableForEvents": {
                      "type": "boolean",
                      "const": true
                    }
                  }
                },
                {
                  "type": "null"
                }
              ]
            },
            "paymentInstructions": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 1000
                },
                {
                  "type": "null"
                }
              ]
            },
            "expectedAmountMinor": {
              "anyOf": [
                {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 100000000
                },
                {
                  "type": "null"
                }
              ]
            },
            "currency": {
              "anyOf": [
                {
                  "type": "string",
                  "pattern": "^[A-Z]{3}$"
                },
                {
                  "type": "null"
                }
              ]
            },
            "offerValidityMinutes": {
              "anyOf": [
                {
                  "type": "integer",
                  "minimum": 5,
                  "maximum": 10080
                },
                {
                  "type": "null"
                }
              ]
            },
            "offerMessageTemplate": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 1000
                },
                {
                  "type": "null"
                }
              ]
            },
            "sourceDefaultsRevision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 1000000000
            },
            "sourceDefaultsHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "fieldSources": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "preferredCollection",
                "reusablePaymentPage",
                "paymentInstructions",
                "expectedAmountMinor",
                "currency",
                "offerValidityMinutes",
                "offerMessageTemplate"
              ],
              "properties": {
                "preferredCollection": {
                  "type": "string",
                  "enum": [
                    "organizer",
                    "event",
                    "cleared"
                  ]
                },
                "reusablePaymentPage": {
                  "type": "string",
                  "enum": [
                    "organizer",
                    "event",
                    "cleared"
                  ]
                },
                "paymentInstructions": {
                  "type": "string",
                  "enum": [
                    "organizer",
                    "event",
                    "cleared"
                  ]
                },
                "expectedAmountMinor": {
                  "type": "string",
                  "enum": [
                    "organizer",
                    "event",
                    "cleared"
                  ]
                },
                "currency": {
                  "type": "string",
                  "enum": [
                    "organizer",
                    "event",
                    "cleared"
                  ]
                },
                "offerValidityMinutes": {
                  "type": "string",
                  "enum": [
                    "organizer",
                    "event",
                    "cleared"
                  ]
                },
                "offerMessageTemplate": {
                  "type": "string",
                  "enum": [
                    "organizer",
                    "event",
                    "cleared"
                  ]
                }
              }
            }
          }
        }
      ]
    },
    "suggestedExpiresAtMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1
    },
    "preferencesRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000000
    },
    "preferences": {
      "anyOf": [
        {
          "type": "null"
        },
        {
          "title": "ResolvedEventPreferences",
          "type": "object",
          "additionalProperties": false,
          "required": [
            "defaultsRevision",
            "defaultsHash",
            "usualDurationMinutes",
            "preferredVenueId",
            "offerValidityMinutes",
            "collectionPreference",
            "currency",
            "offerMessageTemplate",
            "paymentInstructions",
            "reusablePaymentPage",
            "admissionPreset",
            "expectedAmountMinor"
          ],
          "properties": {
            "defaultsRevision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 1000000000
            },
            "defaultsHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "usualDurationMinutes": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "value",
                "source"
              ],
              "properties": {
                "value": {
                  "anyOf": [
                    {
                      "type": "integer",
                      "minimum": 15,
                      "maximum": 240
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "source": {
                  "type": "string",
                  "enum": [
                    "organizer",
                    "event",
                    "cleared"
                  ]
                }
              }
            },
            "preferredVenueId": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "value",
                "source"
              ],
              "properties": {
                "value": {
                  "anyOf": [
                    {
                      "type": "string",
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "source": {
                  "type": "string",
                  "enum": [
                    "organizer",
                    "event",
                    "cleared"
                  ]
                }
              }
            },
            "offerValidityMinutes": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "value",
                "source"
              ],
              "properties": {
                "value": {
                  "anyOf": [
                    {
                      "type": "integer",
                      "minimum": 5,
                      "maximum": 10080
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "source": {
                  "type": "string",
                  "enum": [
                    "organizer",
                    "event",
                    "cleared"
                  ]
                }
              }
            },
            "collectionPreference": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "value",
                "source"
              ],
              "properties": {
                "value": {
                  "anyOf": [
                    {
                      "type": "string",
                      "enum": [
                        "manualInstructions",
                        "reusablePage",
                        "personalRequest",
                        "catchCheckout"
                      ]
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "source": {
                  "type": "string",
                  "enum": [
                    "organizer",
                    "event",
                    "cleared"
                  ]
                }
              }
            },
            "currency": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "value",
                "source"
              ],
              "properties": {
                "value": {
                  "anyOf": [
                    {
                      "type": "string",
                      "pattern": "^[A-Z]{3}$"
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "source": {
                  "type": "string",
                  "enum": [
                    "organizer",
                    "event",
                    "cleared"
                  ]
                }
              }
            },
            "offerMessageTemplate": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "value",
                "source"
              ],
              "properties": {
                "value": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 1000
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "source": {
                  "type": "string",
                  "enum": [
                    "organizer",
                    "event",
                    "cleared"
                  ]
                }
              }
            },
            "paymentInstructions": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "value",
                "source"
              ],
              "properties": {
                "value": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 1000
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "source": {
                  "type": "string",
                  "enum": [
                    "organizer",
                    "event",
                    "cleared"
                  ]
                }
              }
            },
            "reusablePaymentPage": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "value",
                "source"
              ],
              "properties": {
                "value": {
                  "anyOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "url",
                        "reusableForEvents"
                      ],
                      "properties": {
                        "url": {
                          "type": "string",
                          "format": "uri",
                          "maxLength": 2048
                        },
                        "reusableForEvents": {
                          "type": "boolean",
                          "const": true
                        }
                      }
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "source": {
                  "type": "string",
                  "enum": [
                    "organizer",
                    "event",
                    "cleared"
                  ]
                }
              }
            },
            "admissionPreset": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "value",
                "source"
              ],
              "properties": {
                "value": {
                  "anyOf": [
                    {
                      "type": "string",
                      "enum": [
                        "openCapacity",
                        "inviteOnly",
                        "balancedSingles",
                        "fixedCohortCaps"
                      ]
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "source": {
                  "type": "string",
                  "enum": [
                    "organizer",
                    "event",
                    "cleared"
                  ]
                }
              }
            },
            "expectedAmountMinor": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "value",
                "source"
              ],
              "properties": {
                "value": {
                  "anyOf": [
                    {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 100000000
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "source": {
                  "type": "string",
                  "enum": [
                    "organizer",
                    "event",
                    "cleared"
                  ]
                }
              }
            }
          }
        }
      ]
    }
  }
} as const;
