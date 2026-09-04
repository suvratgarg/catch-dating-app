/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getCrossPathsSuggestionsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/get_cross_paths_suggestions_response.schema.json",
  "title": "GetCrossPathsSuggestionsCallableResponse",
  "description": "Roster-private Cross Paths suggestions. The response contains only sanitized person and event projections plus a short-lived server-signed token.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "rankingVersion",
    "suggestions"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "rankingVersion": {
      "type": "integer",
      "const": 1
    },
    "suggestions": {
      "type": "array",
      "maxItems": 2,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "person",
          "event",
          "reasonCodes",
          "suggestionToken",
          "tokenExpiresAt"
        ],
        "properties": {
          "person": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "uid",
              "name",
              "age",
              "gender",
              "city",
              "photoUrls",
              "promptAnswers",
              "relationshipGoal"
            ],
            "properties": {
              "uid": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              "name": {
                "type": "string",
                "minLength": 1,
                "maxLength": 80
              },
              "age": {
                "type": "integer",
                "minimum": 18,
                "maximum": 99
              },
              "gender": {
                "type": "string",
                "enum": [
                  "man",
                  "woman",
                  "nonBinary",
                  "other"
                ]
              },
              "city": {
                "anyOf": [
                  {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120,
                    "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
                  },
                  {
                    "type": "null"
                  }
                ]
              },
              "photoUrls": {
                "type": "array",
                "minItems": 3,
                "maxItems": 6,
                "items": {
                  "type": "string",
                  "format": "uri",
                  "maxLength": 2048
                }
              },
              "promptAnswers": {
                "type": "array",
                "minItems": 3,
                "maxItems": 3,
                "items": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "prompt",
                    "answer"
                  ],
                  "properties": {
                    "prompt": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 140
                    },
                    "answer": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 300
                    }
                  }
                }
              },
              "relationshipGoal": {
                "type": "string",
                "minLength": 1,
                "maxLength": 80
              }
            }
          },
          "event": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "eventId",
              "organizerId",
              "startTime",
              "endTime",
              "meetingPoint",
              "activityKind",
              "photoUrl",
              "viewerBookingStatus",
              "pairHoldAvailable"
            ],
            "properties": {
              "eventId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              "organizerId": {
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
              "startTime": {
                "type": "string",
                "format": "date-time"
              },
              "endTime": {
                "type": "string",
                "format": "date-time"
              },
              "meetingPoint": {
                "type": "string",
                "minLength": 1,
                "maxLength": 240
              },
              "activityKind": {
                "type": "string",
                "enum": [
                  "socialRun",
                  "running",
                  "walking",
                  "pickleball",
                  "padel",
                  "tennis",
                  "badminton",
                  "cycling",
                  "spinClass",
                  "yoga",
                  "strengthTraining",
                  "pubQuiz",
                  "barCrawl",
                  "dinner",
                  "singlesMixer",
                  "openActivity"
                ]
              },
              "photoUrl": {
                "type": [
                  "string",
                  "null"
                ],
                "format": "uri",
                "maxLength": 2048
              },
              "viewerBookingStatus": {
                "type": "string",
                "enum": [
                  "signedUp",
                  "canBookNow"
                ]
              },
              "pairHoldAvailable": {
                "type": "boolean"
              }
            }
          },
          "reasonCodes": {
            "type": "array",
            "minItems": 4,
            "maxItems": 5,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "enum": [
                "attending_event",
                "viewer_attending",
                "booking_available",
                "mutual_preferences",
                "showcase_ready"
              ]
            }
          },
          "suggestionToken": {
            "type": "string",
            "minLength": 40,
            "maxLength": 4096
          },
          "tokenExpiresAt": {
            "type": "string",
            "format": "date-time"
          }
        }
      }
    }
  },
  "definitions": {
    "reasonCode": {
      "type": "string",
      "enum": [
        "attending_event",
        "viewer_attending",
        "booking_available",
        "mutual_preferences",
        "showcase_ready"
      ]
    },
    "promptAnswer": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "prompt",
        "answer"
      ],
      "properties": {
        "prompt": {
          "type": "string",
          "minLength": 1,
          "maxLength": 140
        },
        "answer": {
          "type": "string",
          "minLength": 1,
          "maxLength": 300
        }
      }
    },
    "person": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "uid",
        "name",
        "age",
        "gender",
        "city",
        "photoUrls",
        "promptAnswers",
        "relationshipGoal"
      ],
      "properties": {
        "uid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80
        },
        "age": {
          "type": "integer",
          "minimum": 18,
          "maximum": 99
        },
        "gender": {
          "type": "string",
          "enum": [
            "man",
            "woman",
            "nonBinary",
            "other"
          ]
        },
        "city": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 120,
              "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
            },
            {
              "type": "null"
            }
          ]
        },
        "photoUrls": {
          "type": "array",
          "minItems": 3,
          "maxItems": 6,
          "items": {
            "type": "string",
            "format": "uri",
            "maxLength": 2048
          }
        },
        "promptAnswers": {
          "type": "array",
          "minItems": 3,
          "maxItems": 3,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "prompt",
              "answer"
            ],
            "properties": {
              "prompt": {
                "type": "string",
                "minLength": 1,
                "maxLength": 140
              },
              "answer": {
                "type": "string",
                "minLength": 1,
                "maxLength": 300
              }
            }
          }
        },
        "relationshipGoal": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80
        }
      }
    },
    "event": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "eventId",
        "organizerId",
        "startTime",
        "endTime",
        "meetingPoint",
        "activityKind",
        "photoUrl",
        "viewerBookingStatus",
        "pairHoldAvailable"
      ],
      "properties": {
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "organizerId": {
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
        "startTime": {
          "type": "string",
          "format": "date-time"
        },
        "endTime": {
          "type": "string",
          "format": "date-time"
        },
        "meetingPoint": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "activityKind": {
          "type": "string",
          "enum": [
            "socialRun",
            "running",
            "walking",
            "pickleball",
            "padel",
            "tennis",
            "badminton",
            "cycling",
            "spinClass",
            "yoga",
            "strengthTraining",
            "pubQuiz",
            "barCrawl",
            "dinner",
            "singlesMixer",
            "openActivity"
          ]
        },
        "photoUrl": {
          "type": [
            "string",
            "null"
          ],
          "format": "uri",
          "maxLength": 2048
        },
        "viewerBookingStatus": {
          "type": "string",
          "enum": [
            "signedUp",
            "canBookNow"
          ]
        },
        "pairHoldAvailable": {
          "type": "boolean"
        }
      }
    },
    "suggestion": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "person",
        "event",
        "reasonCodes",
        "suggestionToken",
        "tokenExpiresAt"
      ],
      "properties": {
        "person": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "uid",
            "name",
            "age",
            "gender",
            "city",
            "photoUrls",
            "promptAnswers",
            "relationshipGoal"
          ],
          "properties": {
            "uid": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "name": {
              "type": "string",
              "minLength": 1,
              "maxLength": 80
            },
            "age": {
              "type": "integer",
              "minimum": 18,
              "maximum": 99
            },
            "gender": {
              "type": "string",
              "enum": [
                "man",
                "woman",
                "nonBinary",
                "other"
              ]
            },
            "city": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 120,
                  "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
                },
                {
                  "type": "null"
                }
              ]
            },
            "photoUrls": {
              "type": "array",
              "minItems": 3,
              "maxItems": 6,
              "items": {
                "type": "string",
                "format": "uri",
                "maxLength": 2048
              }
            },
            "promptAnswers": {
              "type": "array",
              "minItems": 3,
              "maxItems": 3,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "prompt",
                  "answer"
                ],
                "properties": {
                  "prompt": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 140
                  },
                  "answer": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 300
                  }
                }
              }
            },
            "relationshipGoal": {
              "type": "string",
              "minLength": 1,
              "maxLength": 80
            }
          }
        },
        "event": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "eventId",
            "organizerId",
            "startTime",
            "endTime",
            "meetingPoint",
            "activityKind",
            "photoUrl",
            "viewerBookingStatus",
            "pairHoldAvailable"
          ],
          "properties": {
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "organizerId": {
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
            "startTime": {
              "type": "string",
              "format": "date-time"
            },
            "endTime": {
              "type": "string",
              "format": "date-time"
            },
            "meetingPoint": {
              "type": "string",
              "minLength": 1,
              "maxLength": 240
            },
            "activityKind": {
              "type": "string",
              "enum": [
                "socialRun",
                "running",
                "walking",
                "pickleball",
                "padel",
                "tennis",
                "badminton",
                "cycling",
                "spinClass",
                "yoga",
                "strengthTraining",
                "pubQuiz",
                "barCrawl",
                "dinner",
                "singlesMixer",
                "openActivity"
              ]
            },
            "photoUrl": {
              "type": [
                "string",
                "null"
              ],
              "format": "uri",
              "maxLength": 2048
            },
            "viewerBookingStatus": {
              "type": "string",
              "enum": [
                "signedUp",
                "canBookNow"
              ]
            },
            "pairHoldAvailable": {
              "type": "boolean"
            }
          }
        },
        "reasonCodes": {
          "type": "array",
          "minItems": 4,
          "maxItems": 5,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "enum": [
              "attending_event",
              "viewer_attending",
              "booking_available",
              "mutual_preferences",
              "showcase_ready"
            ]
          }
        },
        "suggestionToken": {
          "type": "string",
          "minLength": 40,
          "maxLength": 4096
        },
        "tokenExpiresAt": {
          "type": "string",
          "format": "date-time"
        }
      }
    }
  }
} as const;
