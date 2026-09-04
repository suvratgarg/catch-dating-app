/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerCampaignDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_campaigns.schema.json",
  "title": "OrganizerCampaignDocument",
  "description": "One organizer-owned cross-event campaign with frozen approval and aggregate delivery state.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerCampaigns",
  "x-firestore-path": "organizerCampaigns/{campaignId}",
  "x-document-id-field": "campaignId",
  "x-owner": "organizer campaign callables and dispatcher",
  "required": [
    "organizerId",
    "createdByUid",
    "messageClass",
    "channel",
    "status",
    "name",
    "segmentIds",
    "connectionId",
    "templateId",
    "templateVariables",
    "eventId",
    "inviteDestinationKind",
    "scheduledAt",
    "recipientSnapshotHash",
    "contentHash",
    "audienceCounts",
    "deliveryCounts",
    "revision",
    "leaseOwner",
    "leaseExpiresAt",
    "createdAt",
    "updatedAt",
    "approvedAt",
    "dispatchedAt",
    "completedAt",
    "cancelledAt"
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
    "messageClass": {
      "type": "string",
      "enum": [
        "eventFollowUp",
        "organizerUpdate",
        "organizerPromotion"
      ]
    },
    "channel": {
      "const": "whatsapp"
    },
    "status": {
      "type": "string",
      "enum": [
        "draft",
        "previewed",
        "approved",
        "scheduled",
        "resolving",
        "sending",
        "completed",
        "partiallyFailed",
        "cancelled",
        "blocked"
      ]
    },
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "segmentIds": {
      "type": "array",
      "maxItems": 5,
      "uniqueItems": true,
      "description": "Legacy read compatibility only. New campaign writes use savedAudienceId and persist an empty array.",
      "items": {
        "type": "string",
        "enum": [
          "first_time_attendee",
          "repeat_attendee",
          "regular",
          "lapsed_regular",
          "reliable_attendee",
          "advocate",
          "high_impact_advocate",
          "whatsapp_reachable"
        ]
      }
    },
    "savedAudienceId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "description": "Customers-owned reusable audience used by every new campaign. Null or absent only on legacy segment-authored campaigns."
    },
    "savedAudienceRevision": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "savedAudienceDefinitionHash": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[a-f0-9]{64}$"
    },
    "connectionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "templateId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "templateVariables": {
      "type": "object",
      "maxProperties": 20,
      "propertyNames": {
        "pattern": "^[A-Za-z][A-Za-z0-9_]{0,63}$"
      },
      "additionalProperties": {
        "type": "string",
        "minLength": 1,
        "maxLength": 240
      }
    },
    "eventId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "inviteDestinationKind": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        null,
        "catchEvent",
        "eventRuntime",
        "externalBooking",
        "marketingLanding"
      ]
    },
    "scheduledAt": {
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
    "recipientSnapshotHash": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[a-f0-9]{64}$",
      "description": "Exact audience-state hash stored by preview and required unchanged at approval; retained as the frozen recipient snapshot hash after approval."
    },
    "contentHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "audienceCounts": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "total",
        "reachable",
        "optedOut",
        "invalid",
        "duplicate",
        "unsupported",
        "frequencyCapped",
        "providerBlocked",
        "unknown"
      ],
      "properties": {
        "total": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "reachable": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "optedOut": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "invalid": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "duplicate": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "unsupported": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "frequencyCapped": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "providerBlocked": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "unknown": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        }
      }
    },
    "deliveryCounts": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "pending",
        "suppressed",
        "accepted",
        "sent",
        "delivered",
        "read",
        "failed",
        "replied",
        "optedOut"
      ],
      "properties": {
        "pending": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "suppressed": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "accepted": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "sent": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "delivered": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "read": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "failed": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "replied": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "optedOut": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        }
      }
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "leaseOwner": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "leaseExpiresAt": {
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
    "approvedAt": {
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
    "dispatchedAt": {
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
    "cancelledAt": {
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
    "automationOrigin": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "ruleId",
        "ruleRevision",
        "actionId",
        "sourceId",
        "eventKind",
        "contactId"
      ],
      "properties": {
        "ruleId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "ruleRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "actionId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "sourceId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "eventKind": {
          "type": "string",
          "enum": [
            "submitted",
            "withdrawn",
            "applicationAccepted",
            "eventAttended"
          ]
        },
        "contactId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    }
  },
  "definitions": {
    "count": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000
    },
    "audienceCounts": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "total",
        "reachable",
        "optedOut",
        "invalid",
        "duplicate",
        "unsupported",
        "frequencyCapped",
        "providerBlocked",
        "unknown"
      ],
      "properties": {
        "total": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "reachable": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "optedOut": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "invalid": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "duplicate": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "unsupported": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "frequencyCapped": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "providerBlocked": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "unknown": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        }
      }
    },
    "deliveryCounts": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "pending",
        "suppressed",
        "accepted",
        "sent",
        "delivered",
        "read",
        "failed",
        "replied",
        "optedOut"
      ],
      "properties": {
        "pending": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "suppressed": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "accepted": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "sent": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "delivered": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "read": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "failed": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "replied": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "optedOut": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        }
      }
    }
  }
} as const;
