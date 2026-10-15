/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesProviderAttemptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_provider_attempts.schema.json",
  "title": "SalesProviderAttemptDocument",
  "description": "Private internal writing preparation intent and validated result. One immutable identity per job/stage survives lease renewal and crashes. No rendered draft, activation or send authority. Privacy deletion requires the permanent processing fence.",
  "x-firestore-collection": "salesProviderAttempts",
  "x-firestore-path": "salesProviderAttempts/{attemptId}",
  "x-document-id-field": "attemptId",
  "x-owner": "disabled internal Sales writing preparation worker",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "classification",
    "attemptId",
    "jobId",
    "actorUid",
    "organizerId",
    "stage",
    "bindingHash",
    "binding",
    "status",
    "submissionNonce",
    "leaseOwner",
    "month",
    "runBucketId",
    "monthlyBucketId",
    "reservation",
    "createdAt",
    "updatedAt",
    "cache",
    "result"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "attemptId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "jobId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "stage": {
      "const": "writing"
    },
    "bindingHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "binding": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "materialHash",
        "sourceHash",
        "publicMaterialHash",
        "policyHash",
        "stageHash",
        "providerId",
        "modelId",
        "promptVersion",
        "ownerUid",
        "authorizationId",
        "publicReviewId",
        "participantScope",
        "runLimitsHash",
        "monthlyLimitsHash",
        "inputTokenCeiling"
      ],
      "properties": {
        "materialHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "sourceHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "publicMaterialHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "policyHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "stageHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "providerId": {
          "enum": [
            "deepseek",
            "openai",
            "anthropic"
          ]
        },
        "modelId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 128
        },
        "promptVersion": {
          "type": "string",
          "minLength": 1,
          "maxLength": 100
        },
        "ownerUid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "authorizationId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "publicReviewId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "participantScope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "partnerUid",
                "assignmentRevision"
              ],
              "properties": {
                "partnerUid": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "assignmentRevision": {
                  "type": "integer",
                  "minimum": 1
                }
              }
            },
            {
              "type": "null"
            }
          ]
        },
        "runLimitsHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "monthlyLimitsHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "inputTokenCeiling": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        }
      }
    },
    "status": {
      "enum": [
        "intent",
        "completed"
      ]
    },
    "submissionNonce": {
      "type": "string",
      "minLength": 1,
      "maxLength": 64
    },
    "leaseOwner": {
      "type": "string",
      "minLength": 1,
      "maxLength": 64
    },
    "month": {
      "type": "string",
      "pattern": "^[0-9]{4}-[0-9]{2}$"
    },
    "runBucketId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "monthlyBucketId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "reservation": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "modelCalls",
        "networkRequests",
        "modelInputTokens",
        "modelOutputTokens",
        "modelCostMicros"
      ],
      "properties": {
        "modelCalls": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000000000
        },
        "networkRequests": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000000000
        },
        "modelInputTokens": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000000000
        },
        "modelOutputTokens": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000000000
        },
        "modelCostMicros": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000000000
        }
      }
    },
    "createdAt": {
      "type": "string",
      "format": "date-time"
    },
    "updatedAt": {
      "type": "string",
      "format": "date-time"
    },
    "cache": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "schemaVersion",
            "output",
            "provenance"
          ],
          "properties": {
            "schemaVersion": {
              "const": 1
            },
            "output": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "observationAlias",
                "capabilityAlias",
                "referenceAlias",
                "ctaAlias",
                "reasonToBlock",
                "omittedAliases"
              ],
              "properties": {
                "observationAlias": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 32,
                      "pattern": "^option_[0-9]+$"
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "capabilityAlias": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 32,
                      "pattern": "^option_[0-9]+$"
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "referenceAlias": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 32,
                      "pattern": "^option_[0-9]+$"
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "ctaAlias": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 32,
                      "pattern": "^option_[0-9]+$"
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "reasonToBlock": {
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
                "omittedAliases": {
                  "type": "array",
                  "maxItems": 100,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 32,
                    "pattern": "^option_[0-9]+$"
                  }
                }
              }
            },
            "provenance": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "task",
                "promptVersion",
                "modelId",
                "providerId",
                "cacheKey",
                "cacheHit",
                "usage",
                "metadata",
                "request",
                "monthlyWindow"
              ],
              "properties": {
                "task": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 100
                },
                "promptVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 100
                },
                "modelId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 128
                },
                "providerId": {
                  "enum": [
                    "deepseek",
                    "openai",
                    "anthropic"
                  ]
                },
                "cacheKey": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "cacheHit": {
                  "const": false
                },
                "usage": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "inputTokens",
                    "outputTokens",
                    "costMicros"
                  ],
                  "properties": {
                    "inputTokens": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 1000000000000
                    },
                    "outputTokens": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 1000000000000
                    },
                    "costMicros": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 1000000000000
                    }
                  }
                },
                "metadata": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "providerId",
                    "modelId",
                    "requestId",
                    "attemptCount",
                    "durationMs",
                    "finishReason",
                    "costBasis",
                    "estimatedCostMicros",
                    "tokens"
                  ],
                  "properties": {
                    "providerId": {
                      "enum": [
                        "deepseek",
                        "openai",
                        "anthropic"
                      ]
                    },
                    "modelId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 128
                    },
                    "requestId": {
                      "anyOf": [
                        {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 128,
                          "pattern": "^[A-Za-z0-9_-]+$"
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "attemptCount": {
                      "const": 1
                    },
                    "durationMs": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 600000
                    },
                    "finishReason": {
                      "const": "stop"
                    },
                    "costBasis": {
                      "const": "reserved_ceiling"
                    },
                    "estimatedCostMicros": {
                      "type": "null"
                    },
                    "tokens": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "inputTotal",
                        "ordinaryInput",
                        "cacheRead",
                        "cacheWrite",
                        "outputTotal",
                        "reasoningOutput"
                      ],
                      "properties": {
                        "inputTotal": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 1000000000000
                        },
                        "ordinaryInput": {
                          "anyOf": [
                            {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 1000000000000
                            },
                            {
                              "type": "null"
                            }
                          ]
                        },
                        "cacheRead": {
                          "anyOf": [
                            {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 1000000000000
                            },
                            {
                              "type": "null"
                            }
                          ]
                        },
                        "cacheWrite": {
                          "anyOf": [
                            {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 1000000000000
                            },
                            {
                              "type": "null"
                            }
                          ]
                        },
                        "outputTotal": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 1000000000000
                        },
                        "reasoningOutput": {
                          "anyOf": [
                            {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 1000000000000
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
                "request": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "maxInputBytes",
                    "estimatedInputTokens",
                    "maxOutputTokens",
                    "maxCostMicros",
                    "maxNetworkRequests"
                  ],
                  "properties": {
                    "maxInputBytes": {
                      "const": 32768
                    },
                    "estimatedInputTokens": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 1000000
                    },
                    "maxOutputTokens": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 8192
                    },
                    "maxCostMicros": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 100000000
                    },
                    "maxNetworkRequests": {
                      "const": 1
                    }
                  }
                },
                "monthlyWindow": {
                  "type": "string",
                  "pattern": "^[0-9]{4}-[0-9]{2}$"
                }
              }
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "result": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "selection",
            "selectionHash",
            "policyHash",
            "stageHash",
            "authorizationId",
            "stage",
            "sendAuthority"
          ],
          "properties": {
            "selection": {
              "title": "OutreachDraftingSelection",
              "type": "object",
              "additionalProperties": false,
              "required": [
                "organizerId",
                "contactId",
                "opportunityId",
                "language",
                "observationId",
                "capabilityId",
                "referenceId",
                "ctaId",
                "reasonToBlock",
                "omittedIds"
              ],
              "properties": {
                "organizerId": {
                  "type": "string",
                  "minLength": 1
                },
                "contactId": {
                  "type": "string",
                  "minLength": 1
                },
                "opportunityId": {
                  "type": "string",
                  "minLength": 1
                },
                "language": {
                  "const": "en"
                },
                "observationId": {
                  "type": [
                    "string",
                    "null"
                  ]
                },
                "capabilityId": {
                  "type": [
                    "string",
                    "null"
                  ]
                },
                "referenceId": {
                  "type": [
                    "string",
                    "null"
                  ]
                },
                "ctaId": {
                  "type": [
                    "string",
                    "null"
                  ]
                },
                "reasonToBlock": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 200
                },
                "omittedIds": {
                  "type": "array",
                  "maxItems": 20,
                  "uniqueItems": true,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 160
                  }
                }
              }
            },
            "selectionHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "policyHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "stageHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "authorizationId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "stage": {
              "const": "writing"
            },
            "sendAuthority": {
              "const": false
            }
          }
        },
        {
          "type": "null"
        }
      ]
    }
  },
  "allOf": [
    {
      "if": {
        "properties": {
          "status": {
            "const": "intent"
          }
        }
      },
      "then": {
        "properties": {
          "cache": {
            "type": "null"
          },
          "result": {
            "type": "null"
          }
        }
      },
      "else": {
        "properties": {
          "cache": {
            "type": "object"
          },
          "result": {
            "type": "object"
          }
        }
      }
    }
  ]
} as const;
