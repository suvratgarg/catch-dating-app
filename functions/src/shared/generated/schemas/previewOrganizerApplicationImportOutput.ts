/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const previewOrganizerApplicationImportCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/preview_organizer_application_import_response.schema.json",
  "title": "PreviewOrganizerApplicationImportCallableResponse",
  "description": "Safe import preview with deterministic mapping suggestions and bounded row errors.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formVersionId",
    "columns",
    "sampleRows",
    "rowCount",
    "validRowCount",
    "invalidRowCount"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "formVersionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "columns": {
      "type": "array",
      "maxItems": 100,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "headerIndex",
          "header",
          "questionId",
          "questionLabel",
          "suggestionConfidence"
        ],
        "properties": {
          "headerIndex": {
            "type": "integer",
            "minimum": 0,
            "maximum": 99
          },
          "header": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          },
          "questionId": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 1,
            "maxLength": 120
          },
          "questionLabel": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 1,
            "maxLength": 240
          },
          "suggestionConfidence": {
            "type": "string",
            "enum": [
              "explicit",
              "exact",
              "alias",
              "none"
            ]
          }
        }
      }
    },
    "sampleRows": {
      "type": "array",
      "maxItems": 20,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "rowId",
          "displayName",
          "errors"
        ],
        "properties": {
          "rowId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "displayName": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 160
          },
          "errors": {
            "type": "array",
            "maxItems": 100,
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "questionId",
                "code",
                "message"
              ],
              "properties": {
                "questionId": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "minLength": 1,
                  "maxLength": 120
                },
                "code": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 80
                },
                "message": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 240
                }
              }
            }
          }
        }
      }
    },
    "rowCount": {
      "type": "integer",
      "minimum": 1,
      "maximum": 200
    },
    "validRowCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 200
    },
    "invalidRowCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 200
    }
  },
  "definitions": {
    "column": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "headerIndex",
        "header",
        "questionId",
        "questionLabel",
        "suggestionConfidence"
      ],
      "properties": {
        "headerIndex": {
          "type": "integer",
          "minimum": 0,
          "maximum": 99
        },
        "header": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "questionId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 120
        },
        "questionLabel": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 240
        },
        "suggestionConfidence": {
          "type": "string",
          "enum": [
            "explicit",
            "exact",
            "alias",
            "none"
          ]
        }
      }
    },
    "error": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "questionId",
        "code",
        "message"
      ],
      "properties": {
        "questionId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 120
        },
        "code": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80
        },
        "message": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        }
      }
    },
    "row": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "rowId",
        "displayName",
        "errors"
      ],
      "properties": {
        "rowId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "displayName": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 160
        },
        "errors": {
          "type": "array",
          "maxItems": 100,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "questionId",
              "code",
              "message"
            ],
            "properties": {
              "questionId": {
                "type": [
                  "string",
                  "null"
                ],
                "minLength": 1,
                "maxLength": 120
              },
              "code": {
                "type": "string",
                "minLength": 1,
                "maxLength": 80
              },
              "message": {
                "type": "string",
                "minLength": 1,
                "maxLength": 240
              }
            }
          }
        }
      }
    }
  }
} as const;
