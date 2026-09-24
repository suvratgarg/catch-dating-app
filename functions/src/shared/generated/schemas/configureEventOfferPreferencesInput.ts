/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const configureEventOfferPreferencesCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/configure_event_offer_preferences_payload.schema.json",
  "title": "ConfigureEventOfferPreferencesCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "eventId",
    "requestId",
    "expectedEventSourceRevision",
    "expectedPreferencesRevision",
    "reviewedDefaultsHash",
    "intents"
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
    "requestId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{7,127}$"
    },
    "expectedPreferencesRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000000
    },
    "reviewedDefaultsHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "intents": {
      "title": "EventPreferenceIntents",
      "type": "object",
      "additionalProperties": false,
      "required": [
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
        "usualDurationMinutes": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "value"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "set"
                },
                "value": {
                  "type": "integer",
                  "minimum": 15,
                  "maximum": 240
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "clear"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "inherit"
                }
              }
            }
          ]
        },
        "preferredVenueId": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "value"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "set"
                },
                "value": {
                  "type": "string",
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "clear"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "inherit"
                }
              }
            }
          ]
        },
        "offerValidityMinutes": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "value"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "set"
                },
                "value": {
                  "type": "integer",
                  "minimum": 5,
                  "maximum": 10080
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "clear"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "inherit"
                }
              }
            }
          ]
        },
        "collectionPreference": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "value"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "set"
                },
                "value": {
                  "type": "string",
                  "enum": [
                    "manualInstructions",
                    "reusablePage",
                    "personalRequest",
                    "catchCheckout"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "clear"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "inherit"
                }
              }
            }
          ]
        },
        "currency": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "value"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "set"
                },
                "value": {
                  "type": "string",
                  "pattern": "^[A-Z]{3}$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "clear"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "inherit"
                }
              }
            }
          ]
        },
        "offerMessageTemplate": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "value"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "set"
                },
                "value": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 1000
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "clear"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "inherit"
                }
              }
            }
          ]
        },
        "paymentInstructions": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "value"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "set"
                },
                "value": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 1000
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "clear"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "inherit"
                }
              }
            }
          ]
        },
        "reusablePaymentPage": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "value"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "set"
                },
                "value": {
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
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "clear"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "inherit"
                }
              }
            }
          ]
        },
        "admissionPreset": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "value"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "set"
                },
                "value": {
                  "type": "string",
                  "enum": [
                    "openCapacity",
                    "inviteOnly",
                    "balancedSingles",
                    "fixedCohortCaps"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "clear"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "inherit"
                }
              }
            }
          ]
        },
        "expectedAmountMinor": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "value"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "set"
                },
                "value": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 100000000
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "clear"
                }
              }
            }
          ]
        }
      }
    },
    "expectedEventSourceRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
