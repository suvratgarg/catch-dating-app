/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getOrganizerFormResponseDetailCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/get_organizer_form_response_detail_response.schema.json",
  "title": "GetOrganizerFormResponseDetailCallableResponse",
  "description": "One immutable response with classified answers and expiring asset downloads.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "response",
    "answers",
    "consentVersion",
    "completionMillis"
  ],
  "properties": {
    "response": {
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
    "answers": {
      "type": "array",
      "maxItems": 200,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "questionId",
          "key",
          "label",
          "kind",
          "privacyClass",
          "hostPresentation",
          "answer",
          "origin",
          "assetDownloads"
        ],
        "properties": {
          "questionId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "key": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
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
          "privacyClass": {
            "type": "string",
            "enum": [
              "contact",
              "profile",
              "sensitive",
              "organizerCustom"
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
          },
          "origin": {
            "type": "string",
            "enum": [
              "anonymous",
              "respondentGranted",
              "organizerAcquired",
              "revoked"
            ]
          },
          "assetDownloads": {
            "type": "array",
            "maxItems": 10,
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "assetId",
                "fileName",
                "contentType",
                "sizeBytes",
                "downloadUrl",
                "expiresAtMillis"
              ],
              "properties": {
                "assetId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "fileName": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 240
                },
                "contentType": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 100
                },
                "sizeBytes": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 26214400
                },
                "downloadUrl": {
                  "type": "string",
                  "format": "uri",
                  "maxLength": 4000
                },
                "expiresAtMillis": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                }
              }
            }
          }
        }
      }
    },
    "consentVersion": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80
    },
    "completionMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 604800000
    },
    "applicationId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "contactId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
