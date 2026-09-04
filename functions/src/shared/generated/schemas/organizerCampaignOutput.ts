/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerCampaignCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/organizer_campaign_response.schema.json",
  "title": "OrganizerCampaignCallableResponse",
  "description": "Sanitized campaign state and aggregate eligibility/delivery counts.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "campaignId",
    "savedAudienceId",
    "status",
    "revision",
    "audienceCounts",
    "deliveryCounts",
    "senderStatus",
    "templateStatus",
    "canApprove",
    "canDispatch",
    "blockers"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "campaignId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "savedAudienceId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
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
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
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
    "senderStatus": {
      "type": "string",
      "enum": [
        "pending",
        "testing",
        "active",
        "degraded",
        "blocked",
        "tokenRevoked",
        "disconnected",
        "notConnected"
      ]
    },
    "templateStatus": {
      "type": "string",
      "enum": [
        "APPROVED",
        "PENDING",
        "REJECTED",
        "PAUSED",
        "DISABLED",
        "DELETED",
        "UNKNOWN",
        "missing"
      ]
    },
    "canApprove": {
      "type": "boolean"
    },
    "canDispatch": {
      "type": "boolean"
    },
    "blockers": {
      "type": "array",
      "maxItems": 20,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "providerSetupRequired",
          "senderInactive",
          "templateMissing",
          "templateUnapproved",
          "savedAudienceMissing",
          "savedAudienceChanged",
          "noReachableRecipients",
          "audienceCoveragePartial",
          "audienceTooLarge",
          "eventMissing",
          "eventUnavailable",
          "scheduleInPast",
          "campaignImmutable",
          "campaignCancelled",
          "campaignComplete",
          "campaignLeaseActive"
        ]
      }
    }
  }
} as const;
