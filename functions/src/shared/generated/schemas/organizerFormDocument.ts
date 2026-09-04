/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerFormDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_forms.schema.json",
  "title": "OrganizerFormDocument",
  "description": "Organizer-owned generic form metadata and lifecycle. Editable content lives in a draft and published content in immutable versions.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerForms",
  "x-firestore-path": "organizerForms/{formId}",
  "x-document-id-field": "formId",
  "x-owner": "organizer form management callables",
  "required": [
    "organizerId",
    "createdByUid",
    "title",
    "description",
    "purpose",
    "status",
    "templateId",
    "publicFormId",
    "defaultTargetKind",
    "defaultTargetId",
    "activeVersionId",
    "draftRevision",
    "publishedVersion",
    "submittedResponseCount",
    "createdAt",
    "updatedAt",
    "publishedAt",
    "pausedAt",
    "archivedAt",
    "lastResponseAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "createdByUid": {
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
    "status": {
      "type": "string",
      "enum": [
        "draft",
        "published",
        "paused",
        "archived"
      ]
    },
    "templateId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 120
    },
    "publicFormId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{20,80}$"
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
    "activeVersionId": {
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
    "draftRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "publishedVersion": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000
    },
    "submittedResponseCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000000
    },
    "consequenceProjection": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "version",
        "coverage",
        "identityPolicy",
        "enabledAutomationActionKinds",
        "enabledAutomationActionKindCounts"
      ],
      "properties": {
        "version": {
          "type": "integer",
          "enum": [
            1
          ]
        },
        "coverage": {
          "type": "string",
          "enum": [
            "exact",
            "identityOnly",
            "unavailable"
          ]
        },
        "identityPolicy": {
          "anyOf": [
            {
              "type": "string",
              "enum": [
                "anonymous",
                "emailVerified",
                "phoneVerified",
                "emailOrPhoneVerified",
                "catchAccount"
              ]
            },
            {
              "type": "null"
            }
          ]
        },
        "enabledAutomationActionKinds": {
          "type": "array",
          "maxItems": 7,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "enum": [
              "notifyTeam",
              "addOrganizerTag",
              "createCrmContact",
              "addApplicationQueue",
              "proposeEventAttendee",
              "signedWebhook",
              "campaignHandoff"
            ]
          }
        },
        "enabledAutomationActionKindCounts": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "notifyTeam",
            "addOrganizerTag",
            "createCrmContact",
            "addApplicationQueue",
            "proposeEventAttendee",
            "signedWebhook",
            "campaignHandoff"
          ],
          "properties": {
            "notifyTeam": {
              "type": "integer",
              "minimum": 0,
              "maximum": 1000000
            },
            "addOrganizerTag": {
              "type": "integer",
              "minimum": 0,
              "maximum": 1000000
            },
            "createCrmContact": {
              "type": "integer",
              "minimum": 0,
              "maximum": 1000000
            },
            "addApplicationQueue": {
              "type": "integer",
              "minimum": 0,
              "maximum": 1000000
            },
            "proposeEventAttendee": {
              "type": "integer",
              "minimum": 0,
              "maximum": 1000000
            },
            "signedWebhook": {
              "type": "integer",
              "minimum": 0,
              "maximum": 1000000
            },
            "campaignHandoff": {
              "type": "integer",
              "minimum": 0,
              "maximum": 1000000
            }
          }
        }
      }
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
    "publishedAt": {
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
    "pausedAt": {
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
    "archivedAt": {
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
    "lastResponseAt": {
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
    }
  }
} as const;
