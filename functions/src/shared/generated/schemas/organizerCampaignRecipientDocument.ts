/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerCampaignRecipientDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_campaign_recipients.schema.json",
  "title": "OrganizerCampaignRecipientDocument",
  "description": "Frozen recipient eligibility and monotonic delivery receipt for one organizer campaign contact.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerCampaignRecipients",
  "x-firestore-path": "organizerCampaignRecipients/{recipientId}",
  "x-document-id-field": "recipientId",
  "x-owner": "campaign approval, dispatcher and provider webhook",
  "required": [
    "organizerId",
    "campaignId",
    "contactId",
    "channel",
    "eligibility",
    "exclusionReason",
    "endpointE164",
    "endpointHash",
    "permissionTermsVersion",
    "permissionUpdatedAt",
    "renderedVariablesHash",
    "inviteLinkId",
    "status",
    "providerMessageId",
    "providerErrorCategory",
    "retryEligible",
    "attemptCount",
    "leaseOwner",
    "leaseExpiresAt",
    "acceptedAt",
    "sentAt",
    "deliveredAt",
    "readAt",
    "failedAt",
    "repliedAt",
    "optedOutAt",
    "createdAt",
    "updatedAt"
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
    "contactId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ],
      "description": "CRM contact for saved-audience recipients; null on programSelection rows — program identity lives in programRecipient."
    },
    "programRecipient": {
      "type": [
        "object",
        "null"
      ],
      "additionalProperties": false,
      "required": [
        "programId",
        "recipientKey",
        "guestIds",
        "householdId",
        "endpointGuestId",
        "messagingConsent"
      ],
      "description": "Program-native recipient identity for recipientSource=programSelection campaigns. One doc per resolved recipientKey (guest:{id} or household:{id}); contactId is null on these rows.",
      "properties": {
        "programId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "recipientKey": {
          "type": "string",
          "minLength": 1,
          "maxLength": 220,
          "description": "guest:{guestId} or household:{householdId}; hashed into the document id in place of contactId."
        },
        "guestIds": {
          "type": "array",
          "minItems": 1,
          "maxItems": 50,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "description": "Program guests covered by this recipient; one for guest recipients, household members for deduped rows."
        },
        "householdId": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            {
              "type": "null"
            }
          ],
          "description": "Household carrying messaging consent for this recipient — the dedupe household for household:{id} rows or the guest's household otherwise."
        },
        "endpointGuestId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "messagingConsent": {
          "type": [
            "object",
            "null"
          ],
          "additionalProperties": false,
          "required": [
            "granted",
            "grantedAt",
            "source"
          ],
          "properties": {
            "granted": {
              "type": "boolean"
            },
            "grantedAt": {
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
            "source": {
              "type": [
                "string",
                "null"
              ],
              "enum": [
                "householdRsvpLink",
                "staff",
                "import",
                "whatsappStop",
                null
              ]
            }
          },
          "description": "Snapshot of the household's explicit messaging consent at approve time; grant decisions re-read live at dispatch."
        }
      }
    },
    "channel": {
      "const": "whatsapp"
    },
    "eligibility": {
      "type": "string",
      "enum": [
        "eligible",
        "excluded"
      ]
    },
    "exclusionReason": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        null,
        "optedOut",
        "noVerifiedEndpoint",
        "duplicateEndpoint",
        "frequencyCapped",
        "providerBlocked",
        "invalidEndpoint",
        "unknownPermission",
        "identityUnresolved",
        "deleted"
      ]
    },
    "endpointE164": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^\\+[1-9][0-9]{7,14}$"
    },
    "endpointHash": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[a-f0-9]{64}$"
    },
    "permissionTermsVersion": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80
    },
    "permissionUpdatedAt": {
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
    "renderedVariablesHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "inviteLinkId": {
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
        "pending",
        "sending",
        "suppressed",
        "accepted",
        "sent",
        "delivered",
        "read",
        "failed",
        "replied",
        "optedOut"
      ]
    },
    "providerMessageId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 240
    },
    "providerErrorCategory": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        null,
        "authentication",
        "template",
        "quality",
        "rateLimit",
        "invalidRecipient",
        "policy",
        "provider",
        "unknown"
      ]
    },
    "retryEligible": {
      "type": "boolean"
    },
    "attemptCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 20
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
    "acceptedAt": {
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
    "sentAt": {
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
    "deliveredAt": {
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
    "readAt": {
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
    "failedAt": {
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
    "repliedAt": {
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
    "optedOutAt": {
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
    }
  }
} as const;
