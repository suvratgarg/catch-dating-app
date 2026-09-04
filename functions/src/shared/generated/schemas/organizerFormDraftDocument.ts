/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerFormDraftDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_form_drafts.schema.json",
  "title": "OrganizerFormDraftDocument",
  "description": "Mutable optimistic-revision builder state for one organizer form.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "revision",
    "definition",
    "updatedByUid",
    "createdAt",
    "updatedAt"
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
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "definition": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "title",
        "description",
        "purpose",
        "defaultTargetKind",
        "defaultTargetId",
        "identityPolicy",
        "sections",
        "logicRules",
        "appearance",
        "availability",
        "consent",
        "completion"
      ],
      "properties": {
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
        "purpose": {
          "type": "string",
          "enum": [
            "application",
            "registration",
            "intake",
            "waiver",
            "feedback",
            "survey"
          ]
        },
        "defaultTargetKind": {
          "type": "string",
          "enum": [
            "organizer",
            "event",
            "campaign"
          ]
        },
        "defaultTargetId": {
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
        "identityPolicy": {
          "type": "string",
          "enum": [
            "anonymous",
            "emailVerified",
            "phoneVerified",
            "emailOrPhoneVerified",
            "catchAccount"
          ]
        },
        "sections": {
          "type": "array",
          "minItems": 1,
          "maxItems": 40,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "sectionId",
              "title",
              "description",
              "pageBreak",
              "questions"
            ],
            "properties": {
              "sectionId": {
                "type": "string",
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
              "pageBreak": {
                "type": "boolean"
              },
              "questions": {
                "type": "array",
                "maxItems": 100,
                "items": {
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
                    "hostPresentation",
                    "validation"
                  ],
                  "properties": {
                    "questionId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
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
                        "file",
                        "acknowledgement",
                        "signature"
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
                            "maxLength": 180
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
                    },
                    "validation": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "minLength",
                        "maxLength",
                        "minNumber",
                        "maxNumber",
                        "earliestDate",
                        "latestDate",
                        "minSelections",
                        "maxSelections",
                        "maxFileCount",
                        "maxFileSizeBytes",
                        "allowedMimeTypes",
                        "patternPreset",
                        "customError"
                      ],
                      "properties": {
                        "minLength": {
                          "type": [
                            "integer",
                            "null"
                          ],
                          "minimum": 0,
                          "maximum": 4000
                        },
                        "maxLength": {
                          "type": [
                            "integer",
                            "null"
                          ],
                          "minimum": 1,
                          "maximum": 4000
                        },
                        "minNumber": {
                          "type": [
                            "number",
                            "null"
                          ],
                          "minimum": -1000000000,
                          "maximum": 1000000000
                        },
                        "maxNumber": {
                          "type": [
                            "number",
                            "null"
                          ],
                          "minimum": -1000000000,
                          "maximum": 1000000000
                        },
                        "earliestDate": {
                          "type": [
                            "string",
                            "null"
                          ],
                          "format": "date"
                        },
                        "latestDate": {
                          "type": [
                            "string",
                            "null"
                          ],
                          "format": "date"
                        },
                        "minSelections": {
                          "type": [
                            "integer",
                            "null"
                          ],
                          "minimum": 0,
                          "maximum": 100
                        },
                        "maxSelections": {
                          "type": [
                            "integer",
                            "null"
                          ],
                          "minimum": 1,
                          "maximum": 100
                        },
                        "maxFileCount": {
                          "type": [
                            "integer",
                            "null"
                          ],
                          "minimum": 1,
                          "maximum": 10
                        },
                        "maxFileSizeBytes": {
                          "type": [
                            "integer",
                            "null"
                          ],
                          "minimum": 1,
                          "maximum": 26214400
                        },
                        "allowedMimeTypes": {
                          "type": "array",
                          "maxItems": 20,
                          "uniqueItems": true,
                          "items": {
                            "type": "string",
                            "pattern": "^[a-z0-9.+-]+/[a-z0-9.+*-]+$",
                            "maxLength": 100
                          }
                        },
                        "patternPreset": {
                          "type": [
                            "string",
                            "null"
                          ],
                          "enum": [
                            null,
                            "lettersAndSpaces",
                            "alphanumeric",
                            "postalCode",
                            "handle"
                          ]
                        },
                        "customError": {
                          "type": [
                            "string",
                            "null"
                          ],
                          "maxLength": 240
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        },
        "logicRules": {
          "type": "array",
          "maxItems": 100,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "ruleId",
              "conditionMode",
              "conditions",
              "action",
              "targetQuestionId",
              "targetSectionId"
            ],
            "properties": {
              "ruleId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              "conditionMode": {
                "type": "string",
                "enum": [
                  "all",
                  "any"
                ]
              },
              "conditions": {
                "type": "array",
                "minItems": 1,
                "maxItems": 20,
                "items": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "questionId",
                    "operator",
                    "expectedValues"
                  ],
                  "properties": {
                    "questionId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    },
                    "operator": {
                      "type": "string",
                      "enum": [
                        "equals",
                        "notEquals",
                        "contains",
                        "notContains",
                        "greaterThan",
                        "lessThan",
                        "answered",
                        "notAnswered"
                      ]
                    },
                    "expectedValues": {
                      "type": "array",
                      "maxItems": 20,
                      "items": {
                        "type": [
                          "string",
                          "number",
                          "boolean"
                        ]
                      }
                    }
                  }
                }
              },
              "action": {
                "type": "string",
                "enum": [
                  "showQuestion",
                  "hideQuestion",
                  "showSection",
                  "hideSection",
                  "routeToSection",
                  "finish"
                ]
              },
              "targetQuestionId": {
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
              "targetSectionId": {
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
              }
            }
          }
        },
        "appearance": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "preset",
            "logoAssetId",
            "coverAssetId",
            "activityKind"
          ],
          "properties": {
            "preset": {
              "type": "string",
              "enum": [
                "editorial",
                "minimal",
                "activity"
              ]
            },
            "logoAssetId": {
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
            "coverAssetId": {
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
            "activityKind": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 80
            }
          }
        },
        "availability": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "opensAt",
            "closesAt",
            "responseLimit",
            "closedMessage"
          ],
          "properties": {
            "opensAt": {
              "anyOf": [
                {
                  "type": "object",
                  "description": "Serialized Firestore Timestamp fixture shape.",
                  "x-firestore-type": "timestamp",
                  "additionalProperties": false,
                  "required": [
                    "_seconds",
                    "_nanoseconds"
                  ],
                  "properties": {
                    "_seconds": {
                      "type": "integer"
                    },
                    "_nanoseconds": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 999999999
                    }
                  }
                },
                {
                  "type": "null"
                }
              ]
            },
            "closesAt": {
              "anyOf": [
                {
                  "type": "object",
                  "description": "Serialized Firestore Timestamp fixture shape.",
                  "x-firestore-type": "timestamp",
                  "additionalProperties": false,
                  "required": [
                    "_seconds",
                    "_nanoseconds"
                  ],
                  "properties": {
                    "_seconds": {
                      "type": "integer"
                    },
                    "_nanoseconds": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 999999999
                    }
                  }
                },
                {
                  "type": "null"
                }
              ]
            },
            "responseLimit": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 1,
              "maximum": 1000000
            },
            "closedMessage": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 500
            }
          }
        },
        "consent": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "consentCopy",
            "consentVersion",
            "retentionCopy"
          ],
          "properties": {
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
          }
        },
        "completion": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "title",
            "message",
            "actionKind",
            "actionLabel",
            "actionUrl"
          ],
          "properties": {
            "title": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            },
            "message": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 1000
            },
            "actionKind": {
              "type": "string",
              "enum": [
                "none",
                "externalUrl",
                "event",
                "eventRuntime"
              ]
            },
            "actionLabel": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 80
            },
            "actionUrl": {
              "type": [
                "string",
                "null"
              ],
              "format": "uri",
              "maxLength": 500
            }
          }
        }
      }
    },
    "updatedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "createdAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    },
    "updatedAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    }
  },
  "x-firestore-collection": "organizerFormDrafts",
  "x-firestore-path": "organizerFormDrafts/{formId}",
  "x-document-id-field": "formId",
  "x-owner": "organizer form draft callables"
} as const;
