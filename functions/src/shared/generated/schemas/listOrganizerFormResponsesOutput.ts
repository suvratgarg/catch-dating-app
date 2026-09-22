/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listOrganizerFormResponsesCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/list_organizer_form_responses_response.schema.json",
  "title": "ListOrganizerFormResponsesCallableResponse",
  "description": "Safe response inbox rows and opaque pagination cursor.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "items",
    "nextCursor"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "items": {
      "type": "array",
      "maxItems": 100,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "responseId",
          "formId",
          "formTitle",
          "versionId",
          "version",
          "status",
          "identityKind",
          "identity",
          "sourceLinkId",
          "sourceLabel",
          "submittedAtMillis",
          "withdrawnAtMillis",
          "highlights",
          "conversionKinds"
        ],
        "properties": {
          "responseId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "formId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "formTitle": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160
          },
          "versionId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "version": {
            "type": "integer",
            "minimum": 1,
            "maximum": 1000000
          },
          "status": {
            "type": "string",
            "enum": [
              "submitted",
              "withdrawn"
            ]
          },
          "identityKind": {
            "type": "string",
            "enum": [
              "anonymous",
              "emailVerified",
              "phoneVerified",
              "catchAccount"
            ]
          },
          "identity": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "displayName",
              "email",
              "phoneE164",
              "searchName",
              "origin"
            ],
            "properties": {
              "displayName": {
                "type": [
                  "string",
                  "null"
                ],
                "maxLength": 160
              },
              "email": {
                "type": [
                  "string",
                  "null"
                ],
                "format": "email",
                "maxLength": 320
              },
              "phoneE164": {
                "type": [
                  "string",
                  "null"
                ],
                "pattern": "^\\+[1-9][0-9]{7,14}$"
              },
              "searchName": {
                "type": [
                  "string",
                  "null"
                ],
                "maxLength": 160
              },
              "origin": {
                "type": "string",
                "enum": [
                  "anonymous",
                  "respondentGranted",
                  "organizerAcquired"
                ]
              }
            }
          },
          "sourceLinkId": {
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
          },
          "sourceLabel": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 120
          },
          "submittedAtMillis": {
            "type": "integer",
            "minimum": 0,
            "maximum": 9007199254740991
          },
          "withdrawnAtMillis": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0,
            "maximum": 9007199254740991
          },
          "highlights": {
            "type": "array",
            "maxItems": 12,
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "questionId",
                "label",
                "answer"
              ],
              "properties": {
                "questionId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "label": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 240
                },
                "answer": {
                  "anyOf": [
                    {
                      "type": "string",
                      "maxLength": 10000
                    },
                    {
                      "type": "number",
                      "minimum": -1000000000,
                      "maximum": 1000000000
                    },
                    {
                      "type": "boolean"
                    },
                    {
                      "type": "null"
                    },
                    {
                      "type": "array",
                      "maxItems": 100,
                      "uniqueItems": true,
                      "items": {
                        "type": "string",
                        "maxLength": 500
                      }
                    }
                  ]
                }
              }
            }
          },
          "conversionKinds": {
            "type": "array",
            "maxItems": 4,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "enum": [
                "crmContact",
                "application",
                "eventAttendeeProposal",
                "followUp"
              ]
            }
          }
        }
      }
    },
    "answerFilterOptions": {
      "type": "array",
      "maxItems": 100,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "questionId",
          "label",
          "options"
        ],
        "properties": {
          "questionId": {
            "type": "string"
          },
          "label": {
            "type": "string"
          },
          "options": {
            "type": "array",
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "value",
                "label"
              ],
              "properties": {
                "value": {
                  "type": "string"
                },
                "label": {
                  "type": "string"
                }
              }
            }
          }
        }
      }
    },
    "nextCursor": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    },
    "entries": {
      "type": "array",
      "maxItems": 100,
      "description": "Present only when includeApplications is true. A converted native response has both source summaries and occurs once.",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "entryId",
          "submittedAtMillis",
          "response",
          "application"
        ],
        "properties": {
          "entryId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 200
          },
          "submittedAtMillis": {
            "type": "integer",
            "minimum": 0
          },
          "response": {
            "anyOf": [
              {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "responseId",
                  "formId",
                  "formTitle",
                  "versionId",
                  "version",
                  "status",
                  "identityKind",
                  "identity",
                  "sourceLinkId",
                  "sourceLabel",
                  "submittedAtMillis",
                  "withdrawnAtMillis",
                  "highlights",
                  "conversionKinds"
                ],
                "properties": {
                  "responseId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "formId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "formTitle": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 160
                  },
                  "versionId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "version": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 1000000
                  },
                  "status": {
                    "type": "string",
                    "enum": [
                      "submitted",
                      "withdrawn"
                    ]
                  },
                  "identityKind": {
                    "type": "string",
                    "enum": [
                      "anonymous",
                      "emailVerified",
                      "phoneVerified",
                      "catchAccount"
                    ]
                  },
                  "identity": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "displayName",
                      "email",
                      "phoneE164",
                      "searchName",
                      "origin"
                    ],
                    "properties": {
                      "displayName": {
                        "type": [
                          "string",
                          "null"
                        ],
                        "maxLength": 160
                      },
                      "email": {
                        "type": [
                          "string",
                          "null"
                        ],
                        "format": "email",
                        "maxLength": 320
                      },
                      "phoneE164": {
                        "type": [
                          "string",
                          "null"
                        ],
                        "pattern": "^\\+[1-9][0-9]{7,14}$"
                      },
                      "searchName": {
                        "type": [
                          "string",
                          "null"
                        ],
                        "maxLength": 160
                      },
                      "origin": {
                        "type": "string",
                        "enum": [
                          "anonymous",
                          "respondentGranted",
                          "organizerAcquired"
                        ]
                      }
                    }
                  },
                  "sourceLinkId": {
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
                  },
                  "sourceLabel": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "maxLength": 120
                  },
                  "submittedAtMillis": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 9007199254740991
                  },
                  "withdrawnAtMillis": {
                    "type": [
                      "integer",
                      "null"
                    ],
                    "minimum": 0,
                    "maximum": 9007199254740991
                  },
                  "highlights": {
                    "type": "array",
                    "maxItems": 12,
                    "items": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "questionId",
                        "label",
                        "answer"
                      ],
                      "properties": {
                        "questionId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 180
                        },
                        "label": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 240
                        },
                        "answer": {
                          "anyOf": [
                            {
                              "type": "string",
                              "maxLength": 10000
                            },
                            {
                              "type": "number",
                              "minimum": -1000000000,
                              "maximum": 1000000000
                            },
                            {
                              "type": "boolean"
                            },
                            {
                              "type": "null"
                            },
                            {
                              "type": "array",
                              "maxItems": 100,
                              "uniqueItems": true,
                              "items": {
                                "type": "string",
                                "maxLength": 500
                              }
                            }
                          ]
                        }
                      }
                    }
                  },
                  "conversionKinds": {
                    "type": "array",
                    "maxItems": 4,
                    "uniqueItems": true,
                    "items": {
                      "type": "string",
                      "enum": [
                        "crmContact",
                        "application",
                        "eventAttendeeProposal",
                        "followUp"
                      ]
                    }
                  }
                }
              },
              {
                "type": "null"
              }
            ]
          },
          "application": {
            "anyOf": [
              {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "applicationId",
                  "formId",
                  "formVersionId",
                  "targetKind",
                  "targetId",
                  "applicantDisplayName",
                  "reviewStatus",
                  "dataAccessState",
                  "sourceKind",
                  "providerId",
                  "submittedAtMillis",
                  "revision"
                ],
                "properties": {
                  "applicationId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "formId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "formVersionId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "targetKind": {
                    "type": "string",
                    "enum": [
                      "organizer",
                      "event",
                      "campaign"
                    ]
                  },
                  "targetId": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "applicantDisplayName": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 160
                  },
                  "reviewStatus": {
                    "type": "string",
                    "enum": [
                      "submitted",
                      "inReview",
                      "approved",
                      "waitlisted",
                      "declined",
                      "withdrawn"
                    ]
                  },
                  "dataAccessState": {
                    "type": "string",
                    "enum": [
                      "organizerImported",
                      "activeParticipantGrant",
                      "revokedParticipantGrant",
                      "submittedFormResponse"
                    ]
                  },
                  "sourceKind": {
                    "type": "string",
                    "enum": [
                      "native",
                      "tabularImport",
                      "connector"
                    ]
                  },
                  "providerId": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "minLength": 1,
                    "maxLength": 80
                  },
                  "submittedAtMillis": {
                    "type": "integer",
                    "minimum": 0
                  },
                  "revision": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 9007199254740991
                  },
                  "contactId": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "sourceResponseId": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "minLength": 1,
                    "maxLength": 180
                  }
                }
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
} as const;
