/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const privateEventSetupCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/private_event_setup_response.schema.json",
  "title": "PrivateEventSetupCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "organizerId",
    "setupRevision",
    "name",
    "city",
    "localDate",
    "localStartTime",
    "timezone",
    "startTimeMillis",
    "publicationState",
    "status",
    "setupDefaults",
    "detailsConfigured",
    "eventPreferences"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "setupRevision": {
      "type": "integer",
      "minimum": 1
    },
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "city": {
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
    "localDate": {
      "type": "string",
      "pattern": "^[0-9]{4}-[0-9]{2}-[0-9]{2}$"
    },
    "localStartTime": {
      "type": "string",
      "pattern": "^[0-9]{2}:[0-9]{2}$"
    },
    "timezone": {
      "type": "string",
      "minLength": 1,
      "maxLength": 100
    },
    "startTimeMillis": {
      "type": "integer"
    },
    "publicationState": {
      "type": "string",
      "const": "private"
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "cancelled"
      ]
    },
    "setupDefaults": {
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
    },
    "detailsConfigured": {
      "type": "boolean"
    },
    "eventPreferences": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "revision",
            "preferences",
            "paymentTerms"
          ],
          "properties": {
            "revision": {
              "type": "integer",
              "minimum": 1,
              "maximum": 1000000000
            },
            "preferences": {
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
            },
            "paymentTerms": {
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
          }
        },
        {
          "type": "null"
        }
      ]
    }
  }
} as const;
