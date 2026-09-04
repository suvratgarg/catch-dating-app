/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listOrganizerApplicationsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/list_organizer_applications_response.schema.json",
  "title": "ListOrganizerApplicationsCallableResponse",
  "description": "Safe organizer application review rows and opaque pagination state.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "applications",
    "nextCursor"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "applications": {
      "type": "array",
      "maxItems": 100,
      "items": {
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
      }
    },
    "nextCursor": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    }
  },
  "definitions": {
    "application": {
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
    }
  }
} as const;
