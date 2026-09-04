/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getParticipantOrganizerApplicationFormCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/get_participant_organizer_application_form_response.schema.json",
  "title": "GetParticipantOrganizerApplicationFormCallableResponse",
  "description": "Published application form plus participant-private suggestions. Suggested values require explicit review and never grant organizer access.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "formVersionId",
    "targetKind",
    "targetId",
    "title",
    "description",
    "questions",
    "consentCopy",
    "consentVersion",
    "retentionCopy"
  ],
  "properties": {
    "organizerId": {
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
    "title": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "description": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    },
    "questions": {
      "type": "array",
      "minItems": 1,
      "maxItems": 100,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "question",
          "suggestion"
        ],
        "properties": {
          "question": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "questionId",
              "key",
              "label",
              "helpText",
              "kind",
              "required",
              "options",
              "canonicalFieldId",
              "privacyClass",
              "prefillPolicy",
              "hostPresentation"
            ],
            "properties": {
              "questionId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 120
              },
              "key": {
                "type": "string",
                "pattern": "^[A-Za-z][A-Za-z0-9_]{0,79}$"
              },
              "label": {
                "type": "string",
                "minLength": 1,
                "maxLength": 240
              },
              "helpText": {
                "type": [
                  "string",
                  "null"
                ],
                "maxLength": 500
              },
              "kind": {
                "type": "string",
                "enum": [
                  "shortText",
                  "longText",
                  "singleChoice",
                  "multiChoice",
                  "date",
                  "phone",
                  "email",
                  "url",
                  "number",
                  "boolean",
                  "file"
                ]
              },
              "required": {
                "type": "boolean"
              },
              "options": {
                "type": "array",
                "maxItems": 100,
                "items": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "optionId",
                    "label",
                    "value"
                  ],
                  "properties": {
                    "optionId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 80
                    },
                    "label": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160
                    },
                    "value": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160
                    }
                  }
                }
              },
              "canonicalFieldId": {
                "anyOf": [
                  {
                    "type": "string",
                    "x-catch-catalog": "../catalogs/person_fields.json",
                    "enum": [
                      "givenName",
                      "familyName",
                      "displayName",
                      "dateOfBirth",
                      "age",
                      "gender",
                      "phoneNumber",
                      "email",
                      "instagramHandle",
                      "linkedinUrl",
                      "profilePhoto",
                      "city",
                      "heightCm",
                      "occupation",
                      "company",
                      "education",
                      "languages",
                      "relationshipGoal",
                      "interestedInGenders",
                      "drinking",
                      "smoking",
                      "religion",
                      "workout",
                      "diet",
                      "children"
                    ]
                  },
                  {
                    "type": "null"
                  }
                ]
              },
              "privacyClass": {
                "type": "string",
                "enum": [
                  "contact",
                  "profile",
                  "sensitive",
                  "organizerCustom"
                ]
              },
              "prefillPolicy": {
                "type": "string",
                "enum": [
                  "never",
                  "participantReviewRequired"
                ]
              },
              "hostPresentation": {
                "type": "string",
                "enum": [
                  "detailOnly",
                  "filterable",
                  "sortable"
                ]
              }
            }
          },
          "suggestion": {
            "oneOf": [
              {
                "type": "null"
              },
              {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "value",
                  "source",
                  "requiresParticipantReview"
                ],
                "properties": {
                  "value": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "valueKind",
                      "textValue",
                      "numberValue",
                      "booleanValue",
                      "dateValue",
                      "optionValues",
                      "assetIds"
                    ],
                    "properties": {
                      "valueKind": {
                        "type": "string",
                        "enum": [
                          "empty",
                          "text",
                          "number",
                          "boolean",
                          "date",
                          "options",
                          "assets"
                        ]
                      },
                      "textValue": {
                        "type": [
                          "string",
                          "null"
                        ],
                        "maxLength": 4000
                      },
                      "numberValue": {
                        "type": [
                          "number",
                          "null"
                        ],
                        "minimum": -1000000000,
                        "maximum": 1000000000
                      },
                      "booleanValue": {
                        "type": [
                          "boolean",
                          "null"
                        ]
                      },
                      "dateValue": {
                        "type": [
                          "string",
                          "null"
                        ],
                        "format": "date"
                      },
                      "optionValues": {
                        "type": "array",
                        "maxItems": 100,
                        "items": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160
                        }
                      },
                      "assetIds": {
                        "type": "array",
                        "maxItems": 10,
                        "uniqueItems": true,
                        "items": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 180
                        }
                      }
                    }
                  },
                  "source": {
                    "type": "string",
                    "enum": [
                      "portableIntake",
                      "privateProfile",
                      "verifiedAuth"
                    ]
                  },
                  "requiresParticipantReview": {
                    "const": true
                  }
                }
              }
            ]
          }
        }
      }
    },
    "consentCopy": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000
    },
    "consentVersion": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80
    },
    "retentionCopy": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    }
  },
  "definitions": {
    "questionWithSuggestion": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "question",
        "suggestion"
      ],
      "properties": {
        "question": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "questionId",
            "key",
            "label",
            "helpText",
            "kind",
            "required",
            "options",
            "canonicalFieldId",
            "privacyClass",
            "prefillPolicy",
            "hostPresentation"
          ],
          "properties": {
            "questionId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "key": {
              "type": "string",
              "pattern": "^[A-Za-z][A-Za-z0-9_]{0,79}$"
            },
            "label": {
              "type": "string",
              "minLength": 1,
              "maxLength": 240
            },
            "helpText": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 500
            },
            "kind": {
              "type": "string",
              "enum": [
                "shortText",
                "longText",
                "singleChoice",
                "multiChoice",
                "date",
                "phone",
                "email",
                "url",
                "number",
                "boolean",
                "file"
              ]
            },
            "required": {
              "type": "boolean"
            },
            "options": {
              "type": "array",
              "maxItems": 100,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "optionId",
                  "label",
                  "value"
                ],
                "properties": {
                  "optionId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 80
                  },
                  "label": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 160
                  },
                  "value": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 160
                  }
                }
              }
            },
            "canonicalFieldId": {
              "anyOf": [
                {
                  "type": "string",
                  "x-catch-catalog": "../catalogs/person_fields.json",
                  "enum": [
                    "givenName",
                    "familyName",
                    "displayName",
                    "dateOfBirth",
                    "age",
                    "gender",
                    "phoneNumber",
                    "email",
                    "instagramHandle",
                    "linkedinUrl",
                    "profilePhoto",
                    "city",
                    "heightCm",
                    "occupation",
                    "company",
                    "education",
                    "languages",
                    "relationshipGoal",
                    "interestedInGenders",
                    "drinking",
                    "smoking",
                    "religion",
                    "workout",
                    "diet",
                    "children"
                  ]
                },
                {
                  "type": "null"
                }
              ]
            },
            "privacyClass": {
              "type": "string",
              "enum": [
                "contact",
                "profile",
                "sensitive",
                "organizerCustom"
              ]
            },
            "prefillPolicy": {
              "type": "string",
              "enum": [
                "never",
                "participantReviewRequired"
              ]
            },
            "hostPresentation": {
              "type": "string",
              "enum": [
                "detailOnly",
                "filterable",
                "sortable"
              ]
            }
          }
        },
        "suggestion": {
          "oneOf": [
            {
              "type": "null"
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "value",
                "source",
                "requiresParticipantReview"
              ],
              "properties": {
                "value": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "valueKind",
                    "textValue",
                    "numberValue",
                    "booleanValue",
                    "dateValue",
                    "optionValues",
                    "assetIds"
                  ],
                  "properties": {
                    "valueKind": {
                      "type": "string",
                      "enum": [
                        "empty",
                        "text",
                        "number",
                        "boolean",
                        "date",
                        "options",
                        "assets"
                      ]
                    },
                    "textValue": {
                      "type": [
                        "string",
                        "null"
                      ],
                      "maxLength": 4000
                    },
                    "numberValue": {
                      "type": [
                        "number",
                        "null"
                      ],
                      "minimum": -1000000000,
                      "maximum": 1000000000
                    },
                    "booleanValue": {
                      "type": [
                        "boolean",
                        "null"
                      ]
                    },
                    "dateValue": {
                      "type": [
                        "string",
                        "null"
                      ],
                      "format": "date"
                    },
                    "optionValues": {
                      "type": "array",
                      "maxItems": 100,
                      "items": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160
                      }
                    },
                    "assetIds": {
                      "type": "array",
                      "maxItems": 10,
                      "uniqueItems": true,
                      "items": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 180
                      }
                    }
                  }
                },
                "source": {
                  "type": "string",
                  "enum": [
                    "portableIntake",
                    "privateProfile",
                    "verifiedAuth"
                  ]
                },
                "requiresParticipantReview": {
                  "const": true
                }
              }
            }
          ]
        }
      }
    },
    "suggestion": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "value",
        "source",
        "requiresParticipantReview"
      ],
      "properties": {
        "value": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "valueKind",
            "textValue",
            "numberValue",
            "booleanValue",
            "dateValue",
            "optionValues",
            "assetIds"
          ],
          "properties": {
            "valueKind": {
              "type": "string",
              "enum": [
                "empty",
                "text",
                "number",
                "boolean",
                "date",
                "options",
                "assets"
              ]
            },
            "textValue": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 4000
            },
            "numberValue": {
              "type": [
                "number",
                "null"
              ],
              "minimum": -1000000000,
              "maximum": 1000000000
            },
            "booleanValue": {
              "type": [
                "boolean",
                "null"
              ]
            },
            "dateValue": {
              "type": [
                "string",
                "null"
              ],
              "format": "date"
            },
            "optionValues": {
              "type": "array",
              "maxItems": 100,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              }
            },
            "assetIds": {
              "type": "array",
              "maxItems": 10,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              }
            }
          }
        },
        "source": {
          "type": "string",
          "enum": [
            "portableIntake",
            "privateProfile",
            "verifiedAuth"
          ]
        },
        "requiresParticipantReview": {
          "const": true
        }
      }
    }
  }
} as const;
