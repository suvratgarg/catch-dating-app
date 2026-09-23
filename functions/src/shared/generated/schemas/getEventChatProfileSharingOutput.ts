/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getEventChatProfileSharingCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/get_event_chat_profile_sharing_response.schema.json",
  "title": "GetEventChatProfileSharingCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "organizerId",
    "revision",
    "selection",
    "canShare",
    "profileRevision",
    "membershipRevision",
    "coreFields",
    "photoIds"
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
    "revision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "selection": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "profileRevision",
            "membershipRevision",
            "coreFieldIds",
            "photoId",
            "card",
            "termsVersion"
          ],
          "properties": {
            "profileRevision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "membershipRevision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "coreFieldIds": {
              "type": "array",
              "maxItems": 14,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "enum": [
                  "age",
                  "gender",
                  "city",
                  "heightCm",
                  "occupation",
                  "company",
                  "education",
                  "languages",
                  "relationshipGoal",
                  "drinking",
                  "smoking",
                  "workout",
                  "diet",
                  "children"
                ]
              }
            },
            "photoId": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 80,
                  "pattern": "^[A-Za-z0-9_-]+$"
                },
                {
                  "type": "null"
                }
              ]
            },
            "card": {
              "anyOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "responseId",
                    "revision",
                    "questionIds"
                  ],
                  "properties": {
                    "responseId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    },
                    "revision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "questionIds": {
                      "type": "array",
                      "uniqueItems": true,
                      "maxItems": 20,
                      "items": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 180
                      },
                      "minItems": 1
                    }
                  }
                },
                {
                  "type": "null"
                }
              ]
            },
            "firstName": {
              "type": "string",
              "minLength": 1,
              "maxLength": 80,
              "pattern": "^\\S(?:[\\s\\S]*\\S)?$"
            },
            "introduction": {
              "type": "string",
              "minLength": 1,
              "maxLength": 500,
              "pattern": "^\\S(?:[\\s\\S]*\\S)?$"
            },
            "termsVersion": {
              "type": "string",
              "enum": [
                "event-profile-sharing-v1",
                "event-profile-sharing-v2"
              ]
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "canShare": {
      "type": "boolean"
    },
    "profileRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "membershipRevision": {
      "anyOf": [
        {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        {
          "type": "null"
        }
      ]
    },
    "coreFields": {
      "type": "array",
      "maxItems": 14,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "fieldId",
          "value"
        ],
        "properties": {
          "fieldId": {
            "type": "string",
            "enum": [
              "age",
              "gender",
              "city",
              "heightCm",
              "occupation",
              "company",
              "education",
              "languages",
              "relationshipGoal",
              "drinking",
              "smoking",
              "workout",
              "diet",
              "children"
            ]
          },
          "value": {
            "anyOf": [
              {
                "type": "string",
                "maxLength": 10000
              },
              {
                "type": "number"
              },
              {
                "type": "boolean"
              },
              {
                "type": "array",
                "maxItems": 100,
                "items": {
                  "type": "string",
                  "maxLength": 10000
                }
              }
            ]
          }
        }
      }
    },
    "photoIds": {
      "type": "array",
      "maxItems": 12,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 80
      }
    },
    "preview": {
      "anyOf": [
        {
          "title": "GetEventChatProfileCallableResponse",
          "type": "object",
          "additionalProperties": false,
          "required": [
            "eventId",
            "participantUid",
            "displayName",
            "coreFields",
            "cardFields",
            "photo"
          ],
          "properties": {
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "participantUid": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "displayName": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "introduction": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 500
            },
            "coreFields": {
              "type": "array",
              "maxItems": 14,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "fieldId",
                  "value"
                ],
                "properties": {
                  "fieldId": {
                    "type": "string",
                    "enum": [
                      "age",
                      "gender",
                      "city",
                      "heightCm",
                      "occupation",
                      "company",
                      "education",
                      "languages",
                      "relationshipGoal",
                      "drinking",
                      "smoking",
                      "workout",
                      "diet",
                      "children"
                    ]
                  },
                  "value": {
                    "anyOf": [
                      {
                        "type": "string",
                        "maxLength": 10000
                      },
                      {
                        "type": "number"
                      },
                      {
                        "type": "boolean"
                      },
                      {
                        "type": "array",
                        "maxItems": 100,
                        "items": {
                          "type": "string",
                          "maxLength": 10000
                        }
                      }
                    ]
                  }
                }
              }
            },
            "cardFields": {
              "type": "array",
              "maxItems": 20,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "label",
                  "value"
                ],
                "properties": {
                  "label": {
                    "type": "string",
                    "maxLength": 240
                  },
                  "value": {
                    "anyOf": [
                      {
                        "type": "string",
                        "maxLength": 10000
                      },
                      {
                        "type": "number"
                      },
                      {
                        "type": "boolean"
                      },
                      {
                        "type": "array",
                        "maxItems": 100,
                        "items": {
                          "type": "string",
                          "maxLength": 10000
                        }
                      }
                    ]
                  }
                }
              }
            },
            "photo": {
              "anyOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "title": "GetParticipantFormPhotoCallableResponse",
                  "description": "Bounded metadata-free JPEG bytes for private in-memory review; never an original upload URL.",
                  "required": [
                    "contentType",
                    "previewBase64",
                    "width",
                    "height"
                  ],
                  "properties": {
                    "contentType": {
                      "type": "string",
                      "const": "image/jpeg"
                    },
                    "previewBase64": {
                      "type": "string",
                      "minLength": 4,
                      "maxLength": 349528,
                      "pattern": "^[A-Za-z0-9+/]+={0,2}$"
                    },
                    "width": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 640
                    },
                    "height": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 640
                    }
                  }
                },
                {
                  "type": "null"
                }
              ]
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
