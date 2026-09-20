/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminReviewEventMessagingBudgetCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_review_event_messaging_budget_response.schema.json",
  "title": "AdminReviewEventMessagingBudgetCallableResponse",
  "description": "Read-only Finance review of one current messaging setup and its current revision-fenced decision. The response grants no spending or dispatch authority.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "review",
    "decision",
    "grantsSpendingAuthority",
    "grantsDispatchAuthority"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "review": {
      "title": "EventMessagingSetupReview",
      "description": "Read-only operator review of one event messaging runtime, sender and its two spending ceilings. This artifact grants no dispatch or spending authority.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "kind",
        "context",
        "routeId",
        "senderId",
        "purpose",
        "observedAt",
        "completedAt",
        "grantsDispatchAuthority",
        "runtime",
        "sender",
        "budgets"
      ],
      "properties": {
        "schemaVersion": {
          "type": "integer",
          "const": 1
        },
        "kind": {
          "type": "string",
          "const": "recordedSetupReview"
        },
        "context": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "mode",
            "eventId",
            "organizerId"
          ],
          "properties": {
            "mode": {
              "type": "string",
              "const": "live"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "organizerId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            }
          }
        },
        "routeId": {
          "type": "string",
          "enum": [
            "catchEventSms",
            "catchEventRcs",
            "organizerEventWhatsapp"
          ]
        },
        "senderId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "purpose": {
          "type": "string",
          "enum": [
            "joiningUpdate",
            "joiningInstructions",
            "planChanged",
            "eventCancelled",
            "eventFinished",
            "guestRequirement",
            "assignmentChanged",
            "participationCheck",
            "followUp"
          ]
        },
        "observedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "completedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "grantsDispatchAuthority": {
          "type": "boolean",
          "const": false
        },
        "runtime": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "appliesToPurpose",
            "status",
            "revision",
            "selected",
            "sourceHash",
            "eventEnd"
          ],
          "properties": {
            "appliesToPurpose": {
              "type": "boolean"
            },
            "status": {
              "type": "string",
              "enum": [
                "unconfigured",
                "paused",
                "sourceChanged",
                "expired",
                "eventClosed",
                "configured"
              ]
            },
            "revision": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 1,
              "maximum": 9007199254740991
            },
            "selected": {
              "type": "boolean"
            },
            "sourceHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "eventEnd": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          }
        },
        "sender": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "routeId",
                "senderId",
                "displayName",
                "displayAddress",
                "availability",
                "reviewHash"
              ],
              "properties": {
                "routeId": {
                  "type": "string",
                  "enum": [
                    "catchEventSms",
                    "catchEventRcs",
                    "organizerEventWhatsapp"
                  ]
                },
                "senderId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "displayName": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "displayAddress": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 2000
                },
                "availability": {
                  "type": "string",
                  "enum": [
                    "eligible",
                    "setupRequired",
                    "approvalExpired",
                    "templateUnavailable"
                  ]
                },
                "reviewHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                }
              }
            },
            {
              "type": "null"
            }
          ]
        },
        "budgets": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "senderUnavailable"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "currency",
                "sourceHash",
                "event",
                "senderDay"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "reviewed"
                },
                "currency": {
                  "type": "string",
                  "pattern": "^[A-Z]{3}$"
                },
                "sourceHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "event": {
                  "oneOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "budgetId",
                        "scope",
                        "kind",
                        "reason"
                      ],
                      "properties": {
                        "budgetId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        },
                        "scope": {
                          "oneOf": [
                            {
                              "type": "object",
                              "additionalProperties": false,
                              "required": [
                                "kind",
                                "context"
                              ],
                              "properties": {
                                "kind": {
                                  "type": "string",
                                  "const": "event"
                                },
                                "context": {
                                  "type": "object",
                                  "additionalProperties": false,
                                  "required": [
                                    "mode",
                                    "eventId",
                                    "organizerId"
                                  ],
                                  "properties": {
                                    "mode": {
                                      "type": "string",
                                      "const": "live"
                                    },
                                    "eventId": {
                                      "type": "string",
                                      "minLength": 1,
                                      "maxLength": 160,
                                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                                    },
                                    "organizerId": {
                                      "type": "string",
                                      "minLength": 1,
                                      "maxLength": 2000
                                    }
                                  }
                                }
                              }
                            },
                            {
                              "type": "object",
                              "additionalProperties": false,
                              "required": [
                                "kind",
                                "day"
                              ],
                              "properties": {
                                "kind": {
                                  "type": "string",
                                  "const": "senderDay"
                                },
                                "day": {
                                  "type": "string",
                                  "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
                                }
                              }
                            }
                          ]
                        },
                        "kind": {
                          "type": "string",
                          "const": "unavailable"
                        },
                        "reason": {
                          "type": "string",
                          "enum": [
                            "missing",
                            "invalid"
                          ]
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "budgetId",
                        "scope",
                        "kind",
                        "issue",
                        "revision",
                        "approvalId",
                        "currency",
                        "limitMicros",
                        "chargedMicros",
                        "remainingMicros",
                        "startsAt",
                        "endsAt",
                        "reviewHash"
                      ],
                      "properties": {
                        "budgetId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        },
                        "scope": {
                          "oneOf": [
                            {
                              "type": "object",
                              "additionalProperties": false,
                              "required": [
                                "kind",
                                "context"
                              ],
                              "properties": {
                                "kind": {
                                  "type": "string",
                                  "const": "event"
                                },
                                "context": {
                                  "type": "object",
                                  "additionalProperties": false,
                                  "required": [
                                    "mode",
                                    "eventId",
                                    "organizerId"
                                  ],
                                  "properties": {
                                    "mode": {
                                      "type": "string",
                                      "const": "live"
                                    },
                                    "eventId": {
                                      "type": "string",
                                      "minLength": 1,
                                      "maxLength": 160,
                                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                                    },
                                    "organizerId": {
                                      "type": "string",
                                      "minLength": 1,
                                      "maxLength": 2000
                                    }
                                  }
                                }
                              }
                            },
                            {
                              "type": "object",
                              "additionalProperties": false,
                              "required": [
                                "kind",
                                "day"
                              ],
                              "properties": {
                                "kind": {
                                  "type": "string",
                                  "const": "senderDay"
                                },
                                "day": {
                                  "type": "string",
                                  "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
                                }
                              }
                            }
                          ]
                        },
                        "kind": {
                          "type": "string",
                          "const": "recorded"
                        },
                        "issue": {
                          "type": [
                            "string",
                            "null"
                          ],
                          "enum": [
                            "paused",
                            "expired",
                            "currencyChanged",
                            "agentChanged",
                            "exhausted",
                            null
                          ]
                        },
                        "revision": {
                          "type": "integer",
                          "minimum": 1,
                          "maximum": 9007199254740991
                        },
                        "approvalId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        },
                        "currency": {
                          "type": "string",
                          "pattern": "^[A-Z]{3}$"
                        },
                        "limitMicros": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        },
                        "chargedMicros": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        },
                        "remainingMicros": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        },
                        "startsAt": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        },
                        "endsAt": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        },
                        "reviewHash": {
                          "type": "string",
                          "pattern": "^[a-f0-9]{64}$"
                        }
                      }
                    }
                  ]
                },
                "senderDay": {
                  "oneOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "budgetId",
                        "scope",
                        "kind",
                        "reason"
                      ],
                      "properties": {
                        "budgetId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        },
                        "scope": {
                          "oneOf": [
                            {
                              "type": "object",
                              "additionalProperties": false,
                              "required": [
                                "kind",
                                "context"
                              ],
                              "properties": {
                                "kind": {
                                  "type": "string",
                                  "const": "event"
                                },
                                "context": {
                                  "type": "object",
                                  "additionalProperties": false,
                                  "required": [
                                    "mode",
                                    "eventId",
                                    "organizerId"
                                  ],
                                  "properties": {
                                    "mode": {
                                      "type": "string",
                                      "const": "live"
                                    },
                                    "eventId": {
                                      "type": "string",
                                      "minLength": 1,
                                      "maxLength": 160,
                                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                                    },
                                    "organizerId": {
                                      "type": "string",
                                      "minLength": 1,
                                      "maxLength": 2000
                                    }
                                  }
                                }
                              }
                            },
                            {
                              "type": "object",
                              "additionalProperties": false,
                              "required": [
                                "kind",
                                "day"
                              ],
                              "properties": {
                                "kind": {
                                  "type": "string",
                                  "const": "senderDay"
                                },
                                "day": {
                                  "type": "string",
                                  "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
                                }
                              }
                            }
                          ]
                        },
                        "kind": {
                          "type": "string",
                          "const": "unavailable"
                        },
                        "reason": {
                          "type": "string",
                          "enum": [
                            "missing",
                            "invalid"
                          ]
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "budgetId",
                        "scope",
                        "kind",
                        "issue",
                        "revision",
                        "approvalId",
                        "currency",
                        "limitMicros",
                        "chargedMicros",
                        "remainingMicros",
                        "startsAt",
                        "endsAt",
                        "reviewHash"
                      ],
                      "properties": {
                        "budgetId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        },
                        "scope": {
                          "oneOf": [
                            {
                              "type": "object",
                              "additionalProperties": false,
                              "required": [
                                "kind",
                                "context"
                              ],
                              "properties": {
                                "kind": {
                                  "type": "string",
                                  "const": "event"
                                },
                                "context": {
                                  "type": "object",
                                  "additionalProperties": false,
                                  "required": [
                                    "mode",
                                    "eventId",
                                    "organizerId"
                                  ],
                                  "properties": {
                                    "mode": {
                                      "type": "string",
                                      "const": "live"
                                    },
                                    "eventId": {
                                      "type": "string",
                                      "minLength": 1,
                                      "maxLength": 160,
                                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                                    },
                                    "organizerId": {
                                      "type": "string",
                                      "minLength": 1,
                                      "maxLength": 2000
                                    }
                                  }
                                }
                              }
                            },
                            {
                              "type": "object",
                              "additionalProperties": false,
                              "required": [
                                "kind",
                                "day"
                              ],
                              "properties": {
                                "kind": {
                                  "type": "string",
                                  "const": "senderDay"
                                },
                                "day": {
                                  "type": "string",
                                  "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
                                }
                              }
                            }
                          ]
                        },
                        "kind": {
                          "type": "string",
                          "const": "recorded"
                        },
                        "issue": {
                          "type": [
                            "string",
                            "null"
                          ],
                          "enum": [
                            "paused",
                            "expired",
                            "currencyChanged",
                            "agentChanged",
                            "exhausted",
                            null
                          ]
                        },
                        "revision": {
                          "type": "integer",
                          "minimum": 1,
                          "maximum": 9007199254740991
                        },
                        "approvalId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        },
                        "currency": {
                          "type": "string",
                          "pattern": "^[A-Z]{3}$"
                        },
                        "limitMicros": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        },
                        "chargedMicros": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        },
                        "remainingMicros": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        },
                        "startsAt": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        },
                        "endsAt": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        },
                        "reviewHash": {
                          "type": "string",
                          "pattern": "^[a-f0-9]{64}$"
                        }
                      }
                    }
                  ]
                }
              }
            }
          ]
        }
      },
      "definitions": {
        "id": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "time": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "routeId": {
          "type": "string",
          "enum": [
            "catchEventSms",
            "catchEventRcs",
            "organizerEventWhatsapp"
          ]
        },
        "purpose": {
          "type": "string",
          "enum": [
            "joiningUpdate",
            "joiningInstructions",
            "planChanged",
            "eventCancelled",
            "eventFinished",
            "guestRequirement",
            "assignmentChanged",
            "participationCheck",
            "followUp"
          ]
        },
        "sender": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "routeId",
            "senderId",
            "displayName",
            "displayAddress",
            "availability",
            "reviewHash"
          ],
          "properties": {
            "routeId": {
              "type": "string",
              "enum": [
                "catchEventSms",
                "catchEventRcs",
                "organizerEventWhatsapp"
              ]
            },
            "senderId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "displayName": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            },
            "displayAddress": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 2000
            },
            "availability": {
              "type": "string",
              "enum": [
                "eligible",
                "setupRequired",
                "approvalExpired",
                "templateUnavailable"
              ]
            },
            "reviewHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            }
          }
        },
        "budgetScope": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "context": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "mode",
                    "eventId",
                    "organizerId"
                  ],
                  "properties": {
                    "mode": {
                      "type": "string",
                      "const": "live"
                    },
                    "eventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "organizerId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "day"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "senderDay"
                },
                "day": {
                  "type": "string",
                  "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
                }
              }
            }
          ]
        },
        "budgetReview": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "budgetId",
                "scope",
                "kind",
                "reason"
              ],
              "properties": {
                "budgetId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "scope": {
                  "oneOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "context"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "event"
                        },
                        "context": {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "mode",
                            "eventId",
                            "organizerId"
                          ],
                          "properties": {
                            "mode": {
                              "type": "string",
                              "const": "live"
                            },
                            "eventId": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 160,
                              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                            },
                            "organizerId": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 2000
                            }
                          }
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "day"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "senderDay"
                        },
                        "day": {
                          "type": "string",
                          "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
                        }
                      }
                    }
                  ]
                },
                "kind": {
                  "type": "string",
                  "const": "unavailable"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "missing",
                    "invalid"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "budgetId",
                "scope",
                "kind",
                "issue",
                "revision",
                "approvalId",
                "currency",
                "limitMicros",
                "chargedMicros",
                "remainingMicros",
                "startsAt",
                "endsAt",
                "reviewHash"
              ],
              "properties": {
                "budgetId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "scope": {
                  "oneOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "context"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "event"
                        },
                        "context": {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "mode",
                            "eventId",
                            "organizerId"
                          ],
                          "properties": {
                            "mode": {
                              "type": "string",
                              "const": "live"
                            },
                            "eventId": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 160,
                              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                            },
                            "organizerId": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 2000
                            }
                          }
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "day"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "senderDay"
                        },
                        "day": {
                          "type": "string",
                          "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
                        }
                      }
                    }
                  ]
                },
                "kind": {
                  "type": "string",
                  "const": "recorded"
                },
                "issue": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "enum": [
                    "paused",
                    "expired",
                    "currencyChanged",
                    "agentChanged",
                    "exhausted",
                    null
                  ]
                },
                "revision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991
                },
                "approvalId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "currency": {
                  "type": "string",
                  "pattern": "^[A-Z]{3}$"
                },
                "limitMicros": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "chargedMicros": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "remainingMicros": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "startsAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "endsAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "reviewHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                }
              }
            }
          ]
        }
      }
    },
    "decision": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "decisionId",
            "revision",
            "decisionStatus",
            "decisionKind",
            "reviewedByUid",
            "note",
            "effect",
            "grantsSpendingAuthority"
          ],
          "properties": {
            "decisionId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "revision": {
              "type": "integer",
              "minimum": 1,
              "maximum": 9007199254740991
            },
            "decisionStatus": {
              "type": "string",
              "enum": [
                "approved",
                "held",
                "rejected"
              ]
            },
            "decisionKind": {
              "type": "string",
              "enum": [
                "approve",
                "hold",
                "reject"
              ]
            },
            "reviewedByUid": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "note": {
              "type": "string",
              "minLength": 1,
              "maxLength": 1000
            },
            "effect": {
              "type": "string",
              "const": "decision_only_no_spending_authority"
            },
            "grantsSpendingAuthority": {
              "type": "boolean",
              "const": false
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "grantsSpendingAuthority": {
      "type": "boolean",
      "const": false
    },
    "grantsDispatchAuthority": {
      "type": "boolean",
      "const": false
    }
  },
  "definitions": {
    "decisionSummary": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "decisionId",
        "revision",
        "decisionStatus",
        "decisionKind",
        "reviewedByUid",
        "note",
        "effect",
        "grantsSpendingAuthority"
      ],
      "properties": {
        "decisionId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "decisionStatus": {
          "type": "string",
          "enum": [
            "approved",
            "held",
            "rejected"
          ]
        },
        "decisionKind": {
          "type": "string",
          "enum": [
            "approve",
            "hold",
            "reject"
          ]
        },
        "reviewedByUid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "note": {
          "type": "string",
          "minLength": 1,
          "maxLength": 1000
        },
        "effect": {
          "type": "string",
          "const": "decision_only_no_spending_authority"
        },
        "grantsSpendingAuthority": {
          "type": "boolean",
          "const": false
        }
      }
    }
  }
} as const;
