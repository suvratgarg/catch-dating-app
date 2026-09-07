/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceGuestResponseSchema: Record<string, unknown> = {
  "oneOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "responseId",
        "intentId",
        "intentRevision",
        "eventId",
        "attendeeId",
        "episodeId",
        "choiceId",
        "receivedAt",
        "value",
        "context",
        "source"
      ],
      "properties": {
        "schemaVersion": {
          "const": 1,
          "type": "integer"
        },
        "responseId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "intentId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "intentRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 1000000
        },
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "attendeeId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "episodeId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "choiceId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "receivedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "value": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "intention"
              ],
              "properties": {
                "kind": {
                  "const": "joinIntent",
                  "type": "string"
                },
                "intention": {
                  "oneOf": [
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
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "instructionRevision"
              ],
              "properties": {
                "kind": {
                  "const": "acknowledge",
                  "type": "string"
                },
                "instructionRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "category"
              ],
              "properties": {
                "kind": {
                  "const": "requestHelp",
                  "type": "string"
                },
                "category": {
                  "type": "string",
                  "enum": [
                    "eventLogistics",
                    "accessibility",
                    "comfortSafety",
                    "other"
                  ]
                }
              }
            }
          ]
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
        "source": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "linkId"
          ],
          "properties": {
            "kind": {
              "const": "guestWeb",
              "type": "string"
            },
            "linkId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
            }
          }
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "responseId",
        "intentId",
        "intentRevision",
        "eventId",
        "attendeeId",
        "episodeId",
        "choiceId",
        "receivedAt",
        "value",
        "context",
        "source"
      ],
      "properties": {
        "schemaVersion": {
          "const": 1,
          "type": "integer"
        },
        "responseId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "intentId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "intentRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 1000000
        },
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "attendeeId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "episodeId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "choiceId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "receivedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "value": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "intention"
              ],
              "properties": {
                "kind": {
                  "const": "joinIntent",
                  "type": "string"
                },
                "intention": {
                  "oneOf": [
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
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "instructionRevision"
              ],
              "properties": {
                "kind": {
                  "const": "acknowledge",
                  "type": "string"
                },
                "instructionRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "category"
              ],
              "properties": {
                "kind": {
                  "const": "requestHelp",
                  "type": "string"
                },
                "category": {
                  "type": "string",
                  "enum": [
                    "eventLogistics",
                    "accessibility",
                    "comfortSafety",
                    "other"
                  ]
                }
              }
            }
          ]
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
        "source": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "attemptId",
            "providerEventId"
          ],
          "properties": {
            "kind": {
              "const": "provider",
              "type": "string"
            },
            "attemptId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
            },
            "providerEventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 512
            }
          }
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "responseId",
        "intentId",
        "intentRevision",
        "eventId",
        "attendeeId",
        "episodeId",
        "choiceId",
        "receivedAt",
        "value",
        "context",
        "source"
      ],
      "properties": {
        "schemaVersion": {
          "const": 1,
          "type": "integer"
        },
        "responseId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "intentId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "intentRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 1000000
        },
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "attendeeId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "episodeId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "choiceId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "receivedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "value": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "intention"
              ],
              "properties": {
                "kind": {
                  "const": "joinIntent",
                  "type": "string"
                },
                "intention": {
                  "oneOf": [
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
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "instructionRevision"
              ],
              "properties": {
                "kind": {
                  "const": "acknowledge",
                  "type": "string"
                },
                "instructionRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "category"
              ],
              "properties": {
                "kind": {
                  "const": "requestHelp",
                  "type": "string"
                },
                "category": {
                  "type": "string",
                  "enum": [
                    "eventLogistics",
                    "accessibility",
                    "comfortSafety",
                    "other"
                  ]
                }
              }
            }
          ]
        },
        "context": {
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
        },
        "source": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "actionId"
          ],
          "properties": {
            "kind": {
              "const": "simulation",
              "type": "string"
            },
            "actionId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
            }
          }
        }
      }
    }
  ],
  "title": "EventAssistanceGuestResponse"
} as const;
