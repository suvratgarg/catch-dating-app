/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceLateJoinInputSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "eventOpen",
    "departureConfirmed",
    "now",
    "policy",
    "guest",
    "guidance",
    "lastMessage",
    "messagesThisEpisode",
    "context",
    "setting"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "eventOpen": {
      "type": "boolean"
    },
    "departureConfirmed": {
      "type": "boolean"
    },
    "now": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991,
      "description": "UTC milliseconds."
    },
    "policy": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "destination",
        "cutoff",
        "maxMessagesPerEpisode",
        "minimumMinutesBetweenMessages",
        "updateOn",
        "unanswered"
      ],
      "properties": {
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
                "permittedStopIds"
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
                "permittedStopIds": {
                  "type": "array",
                  "minItems": 1,
                  "maxItems": 1000,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 2000
                  },
                  "uniqueItems": true
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
                "permittedCheckpointIds"
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
                "permittedCheckpointIds": {
                  "type": "array",
                  "minItems": 1,
                  "maxItems": 1000,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 2000
                  },
                  "uniqueItems": true
                }
              }
            }
          ]
        },
        "cutoff": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "eventEnd"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "time"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "UTC milliseconds."
                }
              }
            }
          ]
        },
        "maxMessagesPerEpisode": {
          "type": "integer",
          "minimum": 0,
          "maximum": 100
        },
        "minimumMinutesBetweenMessages": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1440
        },
        "updateOn": {
          "type": "string",
          "const": "materialGuidanceChange"
        },
        "unanswered": {
          "type": "string",
          "enum": [
            "keepUnknownUntilCutoff",
            "hostReviewAtDeadline"
          ]
        }
      }
    },
    "guest": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "attendeeId",
        "episodeId",
        "admission",
        "attendance",
        "intention",
        "deliveryEligibility"
      ],
      "properties": {
        "attendeeId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "episodeId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "admission": {
          "type": "string",
          "enum": [
            "admitted",
            "pending",
            "declined"
          ]
        },
        "attendance": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "value",
                "revision",
                "observedAt",
                "source"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "known"
                },
                "value": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "checkedIn"
                  ],
                  "properties": {
                    "checkedIn": {
                      "type": "boolean"
                    }
                  }
                },
                "revision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "Nonnegative safe integer revision."
                },
                "observedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "UTC milliseconds."
                },
                "source": {
                  "type": "string",
                  "enum": [
                    "host",
                    "guest",
                    "provider",
                    "system"
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
                  "const": "unknown"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "notCollected",
                    "notConfirmed",
                    "sourceUnavailable"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "lastValue",
                "observedAt",
                "staleAt"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "stale"
                },
                "lastValue": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "checkedIn"
                  ],
                  "properties": {
                    "checkedIn": {
                      "type": "boolean"
                    }
                  }
                },
                "observedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "UTC milliseconds."
                },
                "staleAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "UTC milliseconds."
                }
              }
            }
          ]
        },
        "intention": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unknown"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "claimedEta"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "onMyWay"
                },
                "claimedEta": {
                  "anyOf": [
                    {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "UTC milliseconds."
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
                "target"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "joinLater"
                },
                "target": {
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
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "notComing"
                }
              }
            }
          ]
        },
        "deliveryEligibility": {
          "type": "string",
          "enum": [
            "eligible",
            "unreachable",
            "unknown"
          ]
        }
      }
    },
    "guidance": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "value",
            "revision",
            "observedAt",
            "source"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "known"
            },
            "value": {
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
            "revision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991,
              "description": "Nonnegative safe integer revision."
            },
            "observedAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991,
              "description": "UTC milliseconds."
            },
            "source": {
              "type": "string",
              "enum": [
                "host",
                "guest",
                "provider",
                "system"
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
              "const": "unknown"
            },
            "reason": {
              "type": "string",
              "enum": [
                "notCollected",
                "notConfirmed",
                "sourceUnavailable"
              ]
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "lastValue",
            "observedAt",
            "staleAt"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "stale"
            },
            "lastValue": {
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
            "observedAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991,
              "description": "UTC milliseconds."
            },
            "staleAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991,
              "description": "UTC milliseconds."
            }
          }
        }
      ]
    },
    "lastMessage": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "materialKey",
            "at"
          ],
          "properties": {
            "materialKey": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            },
            "at": {
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
    },
    "messagesThisEpisode": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000
    },
    "responseDeadline": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991,
      "description": "UTC milliseconds."
    },
    "context": {
      "anyOf": [
        {
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
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "mode",
            "rehearsalId",
            "virtualEventId",
            "clockId"
          ],
          "properties": {
            "mode": {
              "type": "string",
              "const": "rehearsal"
            },
            "rehearsalId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            },
            "virtualEventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "clockId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            }
          }
        }
      ]
    },
    "setting": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "authority",
            "policyVersion"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "enabled"
            },
            "authority": {
              "type": "string",
              "enum": [
                "observe",
                "prepare",
                "executeWithinPolicy"
              ]
            },
            "policyVersion": {
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
            "reason"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "disabled"
            },
            "reason": {
              "type": "string",
              "enum": [
                "hostChoice",
                "organizerDefault"
              ]
            }
          }
        }
      ]
    }
  },
  "allOf": [
    {
      "if": {
        "properties": {
          "policy": {
            "properties": {
              "unanswered": {
                "const": "hostReviewAtDeadline"
              }
            }
          }
        }
      },
      "then": {
        "required": [
          "responseDeadline"
        ]
      }
    }
  ],
  "title": "EventAssistanceLateJoinInput"
} as const;
