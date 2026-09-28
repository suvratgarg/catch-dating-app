/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminGetSalesCommercialDetailResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_get_sales_commercial_detail_response.schema.json",
  "title": "admin_get_sales_commercial_detail_response response",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "opportunity",
    "pilotPlan",
    "quote",
    "quoteVersion",
    "approvedDecision",
    "acceptedDecision",
    "settlementAttestation",
    "history",
    "historyTruncated",
    "paymentStatus",
    "bookedHostRevenueMinor"
  ],
  "properties": {
    "opportunity": {
      "title": "SalesOpportunityDocument",
      "description": "Private sales pipeline stage, independent of public organizer status.",
      "type": "object",
      "additionalProperties": false,
      "x-firestore-collection": "salesOpportunities",
      "x-firestore-path": "salesOpportunities/{opportunityId}",
      "x-owner": "private Sales opportunity service",
      "required": [
        "schemaVersion",
        "classification",
        "opportunityId",
        "organizerId",
        "revision",
        "motion",
        "stage",
        "ownerUid",
        "nextStep",
        "nextStepAt",
        "stageEnteredAt",
        "createdAt",
        "updatedAt",
        "updatedBy"
      ],
      "properties": {
        "schemaVersion": {
          "const": 1
        },
        "classification": {
          "const": "sales_private"
        },
        "opportunityId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "organizerId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 1000000000
        },
        "motion": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160
        },
        "stage": {
          "enum": [
            "new_enquiry",
            "ready_to_contact",
            "contacted",
            "in_conversation",
            "demo_arranged",
            "demo_completed",
            "pilot_agreed",
            "pilot_running",
            "commercial_discussion",
            "closed_won",
            "closed_lost"
          ]
        },
        "ownerUid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "nextStep": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 0,
              "maxLength": 320
            },
            {
              "type": "null"
            }
          ]
        },
        "nextStepAt": {
          "anyOf": [
            {
              "type": "string",
              "format": "date-time",
              "maxLength": 48
            },
            {
              "type": "null"
            }
          ]
        },
        "stageEnteredAt": {
          "type": "string",
          "format": "date-time",
          "maxLength": 48
        },
        "createdAt": {
          "type": "string",
          "format": "date-time",
          "maxLength": 48
        },
        "updatedAt": {
          "type": "string",
          "format": "date-time",
          "maxLength": 48
        },
        "updatedBy": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      },
      "x-document-id-field": "opportunityId"
    },
    "pilotPlan": {
      "anyOf": [
        {
          "title": "salesPilotPlans document",
          "description": "Private revisioned pilot scope; no revenue or product activation authority.",
          "type": "object",
          "additionalProperties": false,
          "x-firestore-collection": "salesPilotPlans",
          "x-firestore-path": "salesPilotPlans/{opportunityId}",
          "x-owner": "private Sales commercial service",
          "required": [
            "schemaVersion",
            "classification",
            "organizerId",
            "opportunityId",
            "revision",
            "status",
            "workflowId",
            "objective",
            "successMeasures",
            "startsAt",
            "endsAt",
            "reviewEvidence",
            "outcomeEvidence",
            "updatedAt",
            "updatedBy"
          ],
          "properties": {
            "schemaVersion": {
              "const": 1
            },
            "classification": {
              "const": "sales_private"
            },
            "organizerId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "opportunityId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "revision": {
              "type": "integer",
              "minimum": 1
            },
            "status": {
              "enum": [
                "draft",
                "reviewed",
                "active",
                "completed",
                "cancelled"
              ]
            },
            "workflowId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "objective": {
              "type": "string",
              "minLength": 1,
              "maxLength": 1000
            },
            "successMeasures": {
              "type": "array",
              "minItems": 1,
              "maxItems": 8,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 240
              }
            },
            "startsAt": {
              "anyOf": [
                {
                  "type": "string",
                  "format": "date-time",
                  "maxLength": 48
                },
                {
                  "type": "null"
                }
              ]
            },
            "endsAt": {
              "anyOf": [
                {
                  "type": "string",
                  "format": "date-time",
                  "maxLength": 48
                },
                {
                  "type": "null"
                }
              ]
            },
            "reviewEvidence": {
              "anyOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "evidenceId",
                    "sourceRef",
                    "contentHash",
                    "observedAt"
                  ],
                  "properties": {
                    "evidenceId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 96,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "sourceRef": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 512
                    },
                    "contentHash": {
                      "type": "string",
                      "pattern": "^[a-f0-9]{64}$"
                    },
                    "observedAt": {
                      "type": "string",
                      "format": "date-time",
                      "maxLength": 48
                    }
                  }
                },
                {
                  "type": "null"
                }
              ]
            },
            "outcomeEvidence": {
              "anyOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "evidenceId",
                    "sourceRef",
                    "contentHash",
                    "observedAt"
                  ],
                  "properties": {
                    "evidenceId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 96,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "sourceRef": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 512
                    },
                    "contentHash": {
                      "type": "string",
                      "pattern": "^[a-f0-9]{64}$"
                    },
                    "observedAt": {
                      "type": "string",
                      "format": "date-time",
                      "maxLength": 48
                    }
                  }
                },
                {
                  "type": "null"
                }
              ]
            },
            "updatedAt": {
              "type": "string",
              "format": "date-time",
              "maxLength": 48
            },
            "updatedBy": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          },
          "x-document-id-field": "opportunityId"
        },
        {
          "type": "null"
        }
      ]
    },
    "quote": {
      "anyOf": [
        {
          "title": "salesQuotes document",
          "description": "Current quote head; accepted terms do not prove collection.",
          "type": "object",
          "additionalProperties": false,
          "x-firestore-collection": "salesQuotes",
          "x-firestore-path": "salesQuotes/{quoteId}",
          "x-owner": "private Sales commercial service",
          "required": [
            "schemaVersion",
            "classification",
            "organizerId",
            "opportunityId",
            "quoteId",
            "revision",
            "termVersion",
            "status",
            "approvedDecisionId",
            "acceptedDecisionId",
            "updatedAt",
            "updatedBy"
          ],
          "properties": {
            "schemaVersion": {
              "const": 1
            },
            "classification": {
              "const": "sales_private"
            },
            "organizerId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "opportunityId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "quoteId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "revision": {
              "type": "integer",
              "minimum": 1
            },
            "termVersion": {
              "type": "integer",
              "minimum": 1
            },
            "status": {
              "enum": [
                "draft",
                "approved",
                "accepted_reviewed"
              ]
            },
            "approvedDecisionId": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 96,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                {
                  "type": "null"
                }
              ]
            },
            "acceptedDecisionId": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 96,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                {
                  "type": "null"
                }
              ]
            },
            "updatedAt": {
              "type": "string",
              "format": "date-time",
              "maxLength": 48
            },
            "updatedBy": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          },
          "x-document-id-field": "quoteId"
        },
        {
          "type": "null"
        }
      ]
    },
    "quoteVersion": {
      "anyOf": [
        {
          "title": "salesQuoteVersions document",
          "description": "Immutable exact commercial terms with reviewed source fact references.",
          "type": "object",
          "additionalProperties": false,
          "x-firestore-collection": "salesQuoteVersions",
          "x-firestore-path": "salesQuoteVersions/{versionId}",
          "x-owner": "private Sales commercial service",
          "required": [
            "schemaVersion",
            "classification",
            "organizerId",
            "opportunityId",
            "quoteId",
            "termVersion",
            "terms",
            "termsHash",
            "createdAt",
            "createdBy"
          ],
          "properties": {
            "schemaVersion": {
              "const": 1
            },
            "classification": {
              "const": "sales_private"
            },
            "organizerId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "opportunityId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "quoteId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "termVersion": {
              "type": "integer",
              "minimum": 1
            },
            "terms": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "currency",
                "amountMinor",
                "billingCadence",
                "scope",
                "validUntil",
                "sourceFactRefs"
              ],
              "properties": {
                "currency": {
                  "type": "string",
                  "pattern": "^[A-Z]{3}$"
                },
                "amountMinor": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 1000000000000
                },
                "billingCadence": {
                  "enum": [
                    "one_time",
                    "monthly",
                    "annual",
                    "usage_based"
                  ]
                },
                "scope": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "validUntil": {
                  "type": "string",
                  "format": "date-time",
                  "maxLength": 48
                },
                "sourceFactRefs": {
                  "type": "array",
                  "minItems": 1,
                  "maxItems": 20,
                  "uniqueItems": true,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 96,
                    "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                  }
                }
              }
            },
            "termsHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "createdAt": {
              "type": "string",
              "format": "date-time",
              "maxLength": 48
            },
            "createdBy": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "approvedDecision": {
      "anyOf": [
        {
          "title": "salesCommercialDecisions document",
          "description": "Append-only exact-version approval or reviewed terms acceptance; not a receipt.",
          "type": "object",
          "additionalProperties": false,
          "x-firestore-collection": "salesCommercialDecisions",
          "x-firestore-path": "salesCommercialDecisions/{decisionId}",
          "x-owner": "private Sales commercial service",
          "required": [
            "schemaVersion",
            "classification",
            "decisionId",
            "organizerId",
            "opportunityId",
            "quoteId",
            "termVersion",
            "termsHash",
            "kind",
            "evidence",
            "approvedDecisionId",
            "actorUid",
            "decidedAt",
            "paymentStatus"
          ],
          "properties": {
            "schemaVersion": {
              "const": 1
            },
            "classification": {
              "const": "sales_private"
            },
            "decisionId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "organizerId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "opportunityId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "quoteId": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 96,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                {
                  "type": "null"
                }
              ]
            },
            "termVersion": {
              "anyOf": [
                {
                  "type": "integer",
                  "minimum": 1
                },
                {
                  "type": "null"
                }
              ]
            },
            "termsHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "kind": {
              "enum": [
                "quote_approved",
                "terms_acceptance_reviewed"
              ]
            },
            "evidence": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "evidenceId",
                "sourceRef",
                "contentHash",
                "observedAt"
              ],
              "properties": {
                "evidenceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 96,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "sourceRef": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512
                },
                "contentHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "observedAt": {
                  "type": "string",
                  "format": "date-time",
                  "maxLength": 48
                }
              }
            },
            "approvedDecisionId": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 96,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                {
                  "type": "null"
                }
              ]
            },
            "actorUid": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "decidedAt": {
              "type": "string",
              "format": "date-time",
              "maxLength": 48
            },
            "paymentStatus": {
              "const": "unknown"
            }
          },
          "x-document-id-field": "decisionId"
        },
        {
          "type": "null"
        }
      ]
    },
    "acceptedDecision": {
      "anyOf": [
        {
          "title": "salesCommercialDecisions document",
          "description": "Append-only exact-version approval or reviewed terms acceptance; not a receipt.",
          "type": "object",
          "additionalProperties": false,
          "x-firestore-collection": "salesCommercialDecisions",
          "x-firestore-path": "salesCommercialDecisions/{decisionId}",
          "x-owner": "private Sales commercial service",
          "required": [
            "schemaVersion",
            "classification",
            "decisionId",
            "organizerId",
            "opportunityId",
            "quoteId",
            "termVersion",
            "termsHash",
            "kind",
            "evidence",
            "approvedDecisionId",
            "actorUid",
            "decidedAt",
            "paymentStatus"
          ],
          "properties": {
            "schemaVersion": {
              "const": 1
            },
            "classification": {
              "const": "sales_private"
            },
            "decisionId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "organizerId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "opportunityId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "quoteId": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 96,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                {
                  "type": "null"
                }
              ]
            },
            "termVersion": {
              "anyOf": [
                {
                  "type": "integer",
                  "minimum": 1
                },
                {
                  "type": "null"
                }
              ]
            },
            "termsHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "kind": {
              "enum": [
                "quote_approved",
                "terms_acceptance_reviewed"
              ]
            },
            "evidence": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "evidenceId",
                "sourceRef",
                "contentHash",
                "observedAt"
              ],
              "properties": {
                "evidenceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 96,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "sourceRef": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512
                },
                "contentHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "observedAt": {
                  "type": "string",
                  "format": "date-time",
                  "maxLength": 48
                }
              }
            },
            "approvedDecisionId": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 96,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                {
                  "type": "null"
                }
              ]
            },
            "actorUid": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "decidedAt": {
              "type": "string",
              "format": "date-time",
              "maxLength": 48
            },
            "paymentStatus": {
              "const": "unknown"
            }
          },
          "x-document-id-field": "decisionId"
        },
        {
          "type": "null"
        }
      ]
    },
    "settlementAttestation": {
      "anyOf": [
        {
          "title": "SalesHostSettlementAttestationsDocument",
          "description": "Owner-attested first-party host subscription collection; provider unconfirmed and separate from guest payments.",
          "type": "object",
          "additionalProperties": false,
          "x-firestore-collection": "salesHostSettlementAttestations",
          "x-firestore-path": "salesHostSettlementAttestations/{attestationId}",
          "x-owner": "private Sales commercial service",
          "required": [
            "schemaVersion",
            "classification",
            "revision",
            "attestationId",
            "organizerId",
            "opportunityId",
            "quoteId",
            "termVersion",
            "termsHash",
            "amountMinor",
            "currency",
            "purpose",
            "receivedAt",
            "settlementMethod",
            "settlementReference",
            "recipientAccountScope",
            "settlementIdentityHash",
            "servicePeriod",
            "evidence",
            "status",
            "providerConfirmed",
            "actorUid",
            "attestedAt"
          ],
          "properties": {
            "schemaVersion": {
              "const": 1
            },
            "classification": {
              "const": "sales_private"
            },
            "revision": {
              "const": 1
            },
            "attestationId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "organizerId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "opportunityId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "quoteId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "termVersion": {
              "type": "integer",
              "minimum": 1
            },
            "termsHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "amountMinor": {
              "type": "integer",
              "minimum": 1,
              "maximum": 1000000000000
            },
            "currency": {
              "type": "string",
              "pattern": "^[A-Z]{3}$"
            },
            "purpose": {
              "const": "host_subscription"
            },
            "receivedAt": {
              "type": "string",
              "format": "date-time",
              "maxLength": 48
            },
            "settlementMethod": {
              "enum": [
                "bank_transfer",
                "cash",
                "other_external"
              ]
            },
            "settlementReference": {
              "type": "string",
              "minLength": 6,
              "maxLength": 120,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9 ./_-]*$"
            },
            "recipientAccountScope": {
              "type": "string",
              "minLength": 3,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9 ./_-]*$"
            },
            "settlementIdentityHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "servicePeriod": {
              "anyOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "startsAt",
                    "endsAt"
                  ],
                  "properties": {
                    "startsAt": {
                      "type": "string",
                      "format": "date-time",
                      "maxLength": 48
                    },
                    "endsAt": {
                      "type": "string",
                      "format": "date-time",
                      "maxLength": 48
                    }
                  }
                },
                {
                  "type": "null"
                }
              ]
            },
            "evidence": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "evidenceId",
                "sourceRef",
                "contentHash",
                "observedAt"
              ],
              "properties": {
                "evidenceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 96,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "sourceRef": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512
                },
                "contentHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "observedAt": {
                  "type": "string",
                  "format": "date-time",
                  "maxLength": 48
                }
              }
            },
            "status": {
              "const": "manual_attested_collected"
            },
            "providerConfirmed": {
              "const": false
            },
            "actorUid": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "attestedAt": {
              "type": "string",
              "format": "date-time",
              "maxLength": 48
            }
          },
          "x-document-id-field": "attestationId"
        },
        {
          "type": "null"
        }
      ]
    },
    "history": {
      "type": "array",
      "maxItems": 25,
      "items": {
        "title": "salesOpportunityStageHistory document",
        "description": "Append-only private stage movement with explicit loss/reopen reason.",
        "type": "object",
        "additionalProperties": false,
        "x-firestore-collection": "salesOpportunityStageHistory",
        "x-firestore-path": "salesOpportunityStageHistory/{historyId}",
        "x-owner": "private Sales commercial service",
        "required": [
          "schemaVersion",
          "classification",
          "historyId",
          "organizerId",
          "opportunityId",
          "fromStage",
          "toStage",
          "reason",
          "actorUid",
          "changedAt"
        ],
        "properties": {
          "schemaVersion": {
            "const": 1
          },
          "classification": {
            "const": "sales_private"
          },
          "historyId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "organizerId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "opportunityId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "fromStage": {
            "anyOf": [
              {
                "type": "string",
                "minLength": 1,
                "maxLength": 96
              },
              {
                "type": "null"
              }
            ]
          },
          "toStage": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96
          },
          "reason": {
            "anyOf": [
              {
                "type": "string",
                "minLength": 1,
                "maxLength": 1000
              },
              {
                "type": "null"
              }
            ]
          },
          "actorUid": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "changedAt": {
            "type": "string",
            "format": "date-time",
            "maxLength": 48
          }
        },
        "x-document-id-field": "historyId"
      }
    },
    "historyTruncated": {
      "type": "boolean"
    },
    "paymentStatus": {
      "enum": [
        "unknown",
        "manual_attested"
      ]
    },
    "bookedHostRevenueMinor": {
      "type": "null"
    }
  }
} as const;
