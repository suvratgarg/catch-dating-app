/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const setOrganizerFormLifecycleCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/set_organizer_form_lifecycle_response.schema.json",
  "title": "SetOrganizerFormLifecycleCallableResponse",
  "description": "Organizer form summary after a lifecycle transition.",
  "allOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "organizerId",
        "formId",
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
        "consequences",
        "updatedAtMillis",
        "publishedAtMillis",
        "lastResponseAtMillis"
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
        "consequences": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "coverage",
            "identityPolicy",
            "enabledAutomationActionKinds"
          ],
          "properties": {
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
            }
          }
        },
        "updatedAtMillis": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "publishedAtMillis": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "lastResponseAtMillis": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 0,
          "maximum": 9007199254740991
        }
      }
    }
  ]
} as const;
