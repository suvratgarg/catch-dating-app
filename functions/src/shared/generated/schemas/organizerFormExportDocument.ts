/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerFormExportDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_form_exports.schema.json",
  "title": "OrganizerFormExportDocument",
  "description": "Asynchronous, expiring, manager-requested form response export receipt.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "requestedByUid",
    "requestId",
    "format",
    "statuses",
    "versionId",
    "fromMillis",
    "toMillis",
    "status",
    "rowCount",
    "storagePath",
    "errorCode",
    "errorMessage",
    "createdAt",
    "updatedAt",
    "completedAt",
    "expiresAt"
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
    "requestedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 128
    },
    "format": {
      "type": "string",
      "enum": [
        "csv",
        "xlsx"
      ]
    },
    "statuses": {
      "type": "array",
      "minItems": 1,
      "maxItems": 2,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "submitted",
          "withdrawn"
        ]
      }
    },
    "versionId": {
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
    "fromMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "toMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "status": {
      "type": "string",
      "enum": [
        "pending",
        "running",
        "completed",
        "failed",
        "expired"
      ]
    },
    "rowCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100000
    },
    "storagePath": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    },
    "errorCode": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 80
    },
    "errorMessage": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500
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
    },
    "completedAt": {
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
    "expiresAt": {
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
    "responseQuery": {
      "anyOf": [
        {
          "title": "QueryOrganizerFormResponsesCallablePayload",
          "type": "object",
          "additionalProperties": false,
          "required": [
            "organizerId",
            "formId",
            "versionId",
            "statuses",
            "predicate",
            "sort",
            "limit",
            "cursor"
          ],
          "properties": {
            "organizerId": {
              "type": "string",
              "pattern": "^[A-Za-z0-9_-]{1,128}$"
            },
            "formId": {
              "type": "string",
              "pattern": "^[A-Za-z0-9_-]{1,128}$"
            },
            "versionId": {
              "type": "string",
              "pattern": "^[A-Za-z0-9_-]{1,128}$"
            },
            "statuses": {
              "type": "array",
              "minItems": 1,
              "maxItems": 2,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "enum": [
                  "submitted",
                  "withdrawn"
                ]
              }
            },
            "predicate": {
              "type": [
                "object",
                "null"
              ],
              "maxProperties": 5,
              "additionalProperties": true,
              "description": "Published-version-aware compiler validates ALL/ANY tree, operators, value types, sensitive exclusion, depth 3 and maximum 20 leaves before any response scan."
            },
            "sort": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "questionId",
                "direction",
                "nulls"
              ],
              "properties": {
                "questionId": {
                  "anyOf": [
                    {
                      "type": "string",
                      "pattern": "^[A-Za-z0-9_-]{1,128}$"
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "direction": {
                  "type": "string",
                  "enum": [
                    "asc",
                    "desc"
                  ]
                },
                "nulls": {
                  "type": "string",
                  "enum": [
                    "first",
                    "last"
                  ]
                }
              }
            },
            "limit": {
              "type": "integer",
              "minimum": 1,
              "maximum": 100
            },
            "cursor": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 1000
            }
          }
        },
        {
          "type": "null"
        }
      ],
      "description": "Optional exact typed filter and sort. Export covers all matches, not one page."
    },
    "expectedResultHash": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[a-f0-9]{64}$",
      "description": "Required with responseQuery; changed results fail rather than silently exporting a different set."
    },
    "expectedQueryHash": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[a-f0-9]{64}$",
      "description": "Required with responseQuery; binds the published definition and filter semantics."
    }
  },
  "x-firestore-collection": "organizerFormExports",
  "x-firestore-path": "organizerFormExports/{exportId}",
  "x-document-id-field": "exportId",
  "x-owner": "organizer form export pipeline"
} as const;
