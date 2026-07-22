// GENERATED FILE. Run: npm --workspace catch-admin run generate:callable-validators
import Ajv, {type ErrorObject, type ValidateFunction} from "ajv";
import addFormats from "ajv-formats";

const model = {
  "names": [
    "adminAssignSafetyTriageItem",
    "adminCreateMarketingContentDraft",
    "adminDecideAccessApplication",
    "adminDecideClubClaim",
    "adminDecideOrganizerEventCandidate",
    "adminDecideOrganizerIntake",
    "adminDecideOrganizerPolicyGap",
    "adminDecideSafetyTriageItem",
    "adminGetAccessApplicationDetails",
    "adminGetAdminUserRoles",
    "adminGetClubClaimRequestDetails",
    "adminGetEventDetails",
    "adminGetEventIntakeDashboard",
    "adminGetEventSupplyReadiness",
    "adminGetHostAnalytics",
    "adminGetMarketingOpsDashboard",
    "adminGetOrganizerDetails",
    "adminGetOverview",
    "adminGetSafetyTriageDetails",
    "adminGetUserAnalytics",
    "adminListAdminRoleAssignments",
    "adminListClubClaimRequests",
    "adminListEventDetails",
    "adminListExternalEventDetails",
    "adminListIntakeOperations",
    "adminListOrganizerDetails",
    "adminPublishExternalEvent",
    "adminRecordEventIntakeReviewDecision",
    "adminRecordMarketingReviewDecision",
    "adminRecordOrganizerCuration",
    "adminResolveOrganizerEventLocation",
    "adminSetAdminUserRoles",
    "adminSetClubIndexStatus",
    "adminUpdateEventDetails",
    "adminUpdateOrganizerDetails"
  ],
  "schemas": [
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_decide_club_claim_payload.schema.json",
      "title": "AdminDecideClubClaimCallablePayload",
      "description": "Callable payload accepted by adminDecideClubClaim.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "decision"
      ],
      "properties": {
        "requestId": {
          "$ref": "../shared/event_common.schema.json#/definitions/documentId"
        },
        "decision": {
          "type": "string",
          "enum": [
            "approve",
            "reject"
          ]
        },
        "decisionReason": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 1000
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/shared/event_common.schema.json",
      "title": "Event and organizer common contract definitions",
      "description": "Shared enum, scalar, and embedded definitions for event, organizer, participation, and saved-event contracts.",
      "definitions": {
        "demoMetadataFields": {
          "synthetic": {
            "type": "boolean",
            "description": "Internal demo seed marker used for cleanup and diagnostics."
          },
          "seedPrefix": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120,
            "description": "Internal demo seed prefix used for cleanup and diagnostics."
          },
          "scenario": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120,
            "description": "Internal demo seed scenario name used for cleanup and diagnostics."
          },
          "demoOps": {
            "type": "boolean",
            "description": "Internal demo-operations marker used for cleanup and diagnostics."
          },
          "demoOpsId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180,
            "description": "Internal demo-operations id used for cleanup and diagnostics."
          },
          "demoOpsCommand": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80,
            "description": "Internal demo-operations command name used for cleanup and diagnostics."
          }
        },
        "internalDemoFieldNames": [
          "synthetic",
          "seedPrefix",
          "scenario",
          "demoOps",
          "demoOpsId",
          "demoOpsCommand"
        ],
        "documentId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "citySlug": {
          "$ref": "profile_common.schema.json#/definitions/citySlug"
        },
        "strictCitySlug": {
          "$ref": "profile_common.schema.json#/definitions/strictCitySlug"
        },
        "cityId": {
          "$ref": "profile_common.schema.json#/definitions/cityId"
        },
        "marketId": {
          "$ref": "profile_common.schema.json#/definitions/marketId"
        },
        "timestamp": {
          "$ref": "profile_common.schema.json#/definitions/timestamp"
        },
        "nullableTimestamp": {
          "$ref": "profile_common.schema.json#/definitions/nullableTimestamp"
        },
        "latitude": {
          "$ref": "profile_common.schema.json#/definitions/latitude"
        },
        "longitude": {
          "$ref": "profile_common.schema.json#/definitions/longitude"
        },
        "urlOrNull": {
          "anyOf": [
            {
              "$ref": "profile_common.schema.json#/definitions/url"
            },
            {
              "type": "null"
            }
          ]
        },
        "eventMeetingLocation": {
          "type": "object",
          "additionalProperties": false,
          "description": "Canonical meeting location selected from Google Places or a manually pinned map coordinate.",
          "required": [
            "name",
            "latitude",
            "longitude"
          ],
          "properties": {
            "name": {
              "type": "string",
              "minLength": 1,
              "maxLength": 240
            },
            "address": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 500
            },
            "placeId": {
              "type": [
                "string",
                "null"
              ],
              "minLength": 1,
              "maxLength": 256
            },
            "latitude": {
              "$ref": "profile_common.schema.json#/definitions/strictLatitude"
            },
            "longitude": {
              "$ref": "profile_common.schema.json#/definitions/strictLongitude"
            },
            "notes": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 1000
            }
          }
        },
        "nullableString": {
          "$ref": "profile_common.schema.json#/definitions/nullableString"
        },
        "contactString": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 320
        },
        "paceLevel": {
          "type": "string",
          "enum": [
            "easy",
            "moderate",
            "fast",
            "competitive"
          ]
        },
        "activityKind": {
          "type": "string",
          "enum": [
            "socialRun",
            "running",
            "walking",
            "pickleball",
            "padel",
            "tennis",
            "badminton",
            "cycling",
            "spinClass",
            "yoga",
            "strengthTraining",
            "pubQuiz",
            "barCrawl",
            "dinner",
            "singlesMixer",
            "openActivity"
          ]
        },
        "eventInteractionModel": {
          "type": "string",
          "enum": [
            "pacePods",
            "pairedRotations",
            "teamRotations",
            "seatedTable",
            "freeFormMixer",
            "hostLedProgram",
            "openFormat"
          ]
        },
        "eventSuccessUnitKind": {
          "type": "string",
          "enum": [
            "wholeGroup",
            "pods",
            "pairs",
            "teams",
            "tables"
          ]
        },
        "eventSuccessRotationRepeatStrategy": {
          "type": "string",
          "enum": [
            "avoid",
            "allowWhenExhausted"
          ]
        },
        "eventSuccessActivityAssignmentAttribute": {
          "type": "string",
          "enum": [
            "paceBand",
            "skillBand",
            "roleBand"
          ]
        },
        "eventSuccessPhoneAvailability": {
          "type": "string",
          "enum": [
            "continuous",
            "plannedPauses",
            "arrivalAndPostEventOnly",
            "hostOnlyLive",
            "noneDuringActivity"
          ]
        },
        "eventSuccessRotationSuitability": {
          "type": "string",
          "enum": [
            "none",
            "plannedBreaks",
            "continuousRounds"
          ]
        },
        "eventSuccessAssignmentAlgorithm": {
          "type": "string",
          "enum": [
            "none",
            "pacePods",
            "socialPods",
            "pairRotations",
            "teamBalancer",
            "tableSeating"
          ]
        },
        "eventSuccessCompatibilityPolicy": {
          "type": "string",
          "enum": [
            "none",
            "socialCohortBalance",
            "mutualInterestOnly",
            "questionnaireClueOnly"
          ]
        },
        "eventSuccessFormatPrimitives": {
          "type": "object",
          "additionalProperties": false,
          "description": "Optional event-success behavior primitives for custom or unsupported activity formats. These fields translate a saved event format into the small set of primitives event success can reason about.",
          "properties": {
            "phoneAvailability": {
              "$ref": "#/definitions/eventSuccessPhoneAvailability"
            },
            "rotationSuitability": {
              "$ref": "#/definitions/eventSuccessRotationSuitability"
            },
            "assignmentAlgorithm": {
              "$ref": "#/definitions/eventSuccessAssignmentAlgorithm"
            },
            "compatibilityPolicy": {
              "$ref": "#/definitions/eventSuccessCompatibilityPolicy"
            }
          }
        },
        "eventSuccessStructureConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "unitKind",
            "unitSize",
            "revealCountdownSeconds"
          ],
          "properties": {
            "unitKind": {
              "$ref": "#/definitions/eventSuccessUnitKind"
            },
            "unitSize": {
              "type": "integer",
              "minimum": 1,
              "maximum": 1000
            },
            "unitCount": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 1,
              "maximum": 200
            },
            "rotationIntervalMinutes": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 5,
              "maximum": 180
            },
            "revealCountdownSeconds": {
              "type": "integer",
              "minimum": 0,
              "maximum": 60
            },
            "rotationRepeatStrategy": {
              "$ref": "#/definitions/eventSuccessRotationRepeatStrategy"
            },
            "maxPairMeetings": {
              "type": "integer",
              "minimum": 1,
              "maximum": 10
            },
            "balanceActivityAttributes": {
              "type": "array",
              "maxItems": 8,
              "uniqueItems": true,
              "items": {
                "$ref": "#/definitions/eventSuccessActivityAssignmentAttribute"
              }
            },
            "clusterActivityAttributes": {
              "type": "array",
              "maxItems": 8,
              "uniqueItems": true,
              "items": {
                "$ref": "#/definitions/eventSuccessActivityAssignmentAttribute"
              }
            }
          }
        },
        "eventSuccessQuestionnaireConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "templateId"
          ],
          "properties": {
            "templateId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "customTitle": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 80
            },
            "customQuestions": {
              "type": "array",
              "maxItems": 8,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "id",
                  "prompt",
                  "options"
                ],
                "properties": {
                  "id": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "prompt": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 140
                  },
                  "options": {
                    "type": "array",
                    "minItems": 2,
                    "maxItems": 5,
                    "items": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "id",
                        "label"
                      ],
                      "properties": {
                        "id": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 120
                        },
                        "label": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 80
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        },
        "eventFormatSnapshot": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "version",
            "activityKind",
            "interactionModel"
          ],
          "properties": {
            "version": {
              "type": "integer",
              "const": 1
            },
            "activityKind": {
              "$ref": "#/definitions/activityKind"
            },
            "interactionModel": {
              "$ref": "#/definitions/eventInteractionModel"
            },
            "customActivityLabel": {
              "type": "string",
              "minLength": 1,
              "maxLength": 80
            },
            "defaultPlaybookId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "defaultModuleIds": {
              "type": "array",
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 120
              },
              "maxItems": 30,
              "uniqueItems": true
            },
            "eventSuccessPrimitives": {
              "$ref": "#/definitions/eventSuccessFormatPrimitives"
            },
            "activityDetails": {
              "type": "object",
              "additionalProperties": true
            }
          }
        },
        "clubLifecycleStatus": {
          "type": "string",
          "enum": [
            "active",
            "archived"
          ]
        },
        "organizerLifecycleStatus": {
          "type": "string",
          "enum": [
            "active",
            "archived"
          ]
        },
        "organizerType": {
          "type": "string",
          "enum": [
            "club",
            "community",
            "individual",
            "eventProducer",
            "venue",
            "brand"
          ],
          "description": "Canonical organizer classification. Club is one organizer subtype; missing legacy values normalize to club during migration."
        },
        "clubMembershipRole": {
          "type": "string",
          "enum": [
            "owner",
            "host",
            "member"
          ]
        },
        "clubHostRole": {
          "type": "string",
          "enum": [
            "owner",
            "host"
          ]
        },
        "clubHostProfile": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "uid",
            "displayName",
            "avatarUrl",
            "role"
          ],
          "properties": {
            "uid": {
              "$ref": "#/definitions/documentId"
            },
            "displayName": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "avatarUrl": {
              "$ref": "#/definitions/urlOrNull"
            },
            "role": {
              "$ref": "#/definitions/clubHostRole"
            }
          }
        },
        "clubMembershipStatus": {
          "type": "string",
          "enum": [
            "active",
            "left",
            "deleted"
          ]
        },
        "eventLifecycleStatus": {
          "type": "string",
          "enum": [
            "active",
            "cancelled"
          ]
        },
        "eventParticipationStatus": {
          "type": "string",
          "enum": [
            "signedUp",
            "waitlisted",
            "attended",
            "cancelled",
            "deleted"
          ]
        },
        "eventWaitlistOfferStatus": {
          "type": "string",
          "enum": [
            "active",
            "accepted",
            "declined",
            "expired",
            "cancelled"
          ]
        },
        "eventWaitlistOfferSource": {
          "type": "string",
          "enum": [
            "host",
            "autoPromotion",
            "ratioBalancing",
            "cancellation"
          ]
        },
        "genderAtSignup": {
          "anyOf": [
            {
              "$ref": "profile_common.schema.json#/definitions/gender"
            },
            {
              "type": "null"
            }
          ]
        },
        "nonNegativeInteger": {
          "type": "integer",
          "minimum": 0
        },
        "eventConstraints": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "minAge",
            "maxAge",
            "maxMen",
            "maxWomen"
          ],
          "properties": {
            "minAge": {
              "type": "integer",
              "minimum": 0,
              "maximum": 120
            },
            "maxAge": {
              "type": "integer",
              "minimum": 0,
              "maximum": 120
            },
            "maxMen": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 0
            },
            "maxWomen": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 0
            }
          }
        },
        "eventPolicyBundle": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "version",
            "admission",
            "pricing",
            "cancellation",
            "settlement"
          ],
          "properties": {
            "version": {
              "type": "integer",
              "const": 1
            },
            "admission": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "format",
                "capacityLimit",
                "waitlistPolicy",
                "inviteRequired",
                "membershipRequired",
                "manualApprovalRequired",
                "privateAccessPolicy",
                "cohortCapacityLimits",
                "balancedRatioPolicy"
              ],
              "properties": {
                "format": {
                  "type": "string",
                  "enum": [
                    "open",
                    "inviteOnly",
                    "manualApproval",
                    "fixedCohortCaps",
                    "balancedRatio",
                    "membersOnly"
                  ]
                },
                "capacityLimit": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 1000
                },
                "waitlistPolicy": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "mode",
                    "offerWindowMinutes"
                  ],
                  "properties": {
                    "mode": {
                      "type": "string",
                      "enum": [
                        "disabled",
                        "rankedOffer",
                        "broadcastFirstComeFirstServed",
                        "manualReview"
                      ]
                    },
                    "offerWindowMinutes": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 10080
                    }
                  }
                },
                "inviteRequired": {
                  "type": "boolean"
                },
                "membershipRequired": {
                  "type": "boolean"
                },
                "manualApprovalRequired": {
                  "type": "boolean"
                },
                "privateAccessPolicy": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "mode",
                    "inviteCodeHint",
                    "privateLinkEnabled"
                  ],
                  "properties": {
                    "mode": {
                      "type": "string",
                      "enum": [
                        "none",
                        "inviteCode"
                      ]
                    },
                    "inviteCodeHint": {
                      "type": [
                        "string",
                        "null"
                      ],
                      "maxLength": 64
                    },
                    "privateLinkEnabled": {
                      "type": "boolean"
                    }
                  }
                },
                "cohortCapacityLimits": {
                  "type": "object",
                  "additionalProperties": {
                    "type": "integer",
                    "minimum": 0
                  }
                },
                "balancedRatioPolicy": {
                  "type": [
                    "object",
                    "null"
                  ],
                  "additionalProperties": false,
                  "required": [
                    "leftCohortId",
                    "rightCohortId",
                    "maxSkew",
                    "openingBufferPerCohort",
                    "outOfRatioCohortPolicy"
                  ],
                  "properties": {
                    "leftCohortId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 120
                    },
                    "rightCohortId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 120
                    },
                    "maxSkew": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 1000
                    },
                    "openingBufferPerCohort": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 1000
                    },
                    "outOfRatioCohortPolicy": {
                      "type": "string",
                      "enum": [
                        "admitWithinGeneralCapacity",
                        "waitlist",
                        "manualReview",
                        "reject"
                      ]
                    }
                  }
                }
              }
            },
            "pricing": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "basePriceInPaise",
                "cohortAdjustmentsInPaise",
                "demandPricingRules"
              ],
              "properties": {
                "basePriceInPaise": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 100000000
                },
                "cohortAdjustmentsInPaise": {
                  "type": "object",
                  "additionalProperties": {
                    "type": "integer",
                    "minimum": -100000000,
                    "maximum": 100000000
                  }
                },
                "demandPricingRules": {
                  "type": "array",
                  "maxItems": 20,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "pricedCohortId",
                      "balancingCohortId",
                      "stepAdjustmentInPaise",
                      "maxAdjustmentInPaise",
                      "freeSkew",
                      "demandStep"
                    ],
                    "properties": {
                      "pricedCohortId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 120
                      },
                      "balancingCohortId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 120
                      },
                      "stepAdjustmentInPaise": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 100000000
                      },
                      "maxAdjustmentInPaise": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 100000000
                      },
                      "freeSkew": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 1000
                      },
                      "demandStep": {
                        "type": "integer",
                        "minimum": 1,
                        "maximum": 1000
                      }
                    }
                  }
                }
              }
            },
            "cancellation": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "policyId"
              ],
              "properties": {
                "policyId": {
                  "type": "string",
                  "enum": [
                    "flexible",
                    "standard",
                    "strict"
                  ]
                }
              }
            },
            "settlement": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "hostPayoutTiming"
              ],
              "properties": {
                "hostPayoutTiming": {
                  "type": "string",
                  "enum": [
                    "afterEventCompletion"
                  ]
                }
              }
            }
          }
        },
        "eventPolicyDefaults": {
          "type": "object",
          "additionalProperties": false,
          "properties": {
            "admissionPreset": {
              "type": "string",
              "enum": [
                "openCapacity",
                "inviteOnly",
                "balancedSingles",
                "fixedCohortCaps"
              ]
            },
            "minAge": {
              "type": "integer",
              "minimum": 0,
              "maximum": 120
            },
            "maxAge": {
              "type": "integer",
              "minimum": 0,
              "maximum": 120
            },
            "maxMen": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 0
            },
            "maxWomen": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 0
            },
            "dynamicPricingEnabled": {
              "type": "boolean"
            },
            "dynamicPricingStepInPaise": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 0,
              "maximum": 100000000
            },
            "dynamicPricingMaxInPaise": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 0,
              "maximum": 100000000
            },
            "cancellationPolicyId": {
              "type": "string",
              "enum": [
                "flexible",
                "standard",
                "strict"
              ]
            }
          }
        },
        "eventSuccessDefaults": {
          "type": "object",
          "additionalProperties": false,
          "properties": {
            "enabled": {
              "type": "boolean"
            },
            "playbookId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "selectedModuleIds": {
              "type": "array",
              "maxItems": 24,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 120
              }
            },
            "moduleSelectionConfigured": {
              "type": "boolean"
            },
            "structureConfig": {
              "$ref": "#/definitions/eventSuccessStructureConfig"
            },
            "hostGoal": {
              "type": "string",
              "maxLength": 300
            },
            "wingmanRequestsEnabled": {
              "type": "boolean"
            },
            "contextualOpenersEnabled": {
              "type": "boolean"
            },
            "compatibilityAffectsRanking": {
              "type": "boolean"
            },
            "questionnaireConfig": {
              "$ref": "#/definitions/eventSuccessQuestionnaireConfig"
            },
            "attendeePrompt": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 300
            }
          }
        },
        "clubHostDefaults": {
          "type": "object",
          "additionalProperties": false,
          "properties": {
            "primaryActivityKind": {
              "$ref": "#/definitions/activityKind"
            },
            "supportedActivityKinds": {
              "type": "array",
              "maxItems": 16,
              "uniqueItems": true,
              "items": {
                "$ref": "#/definitions/activityKind"
              }
            },
            "eventPolicy": {
              "$ref": "#/definitions/eventPolicyDefaults"
            },
            "eventSuccess": {
              "$ref": "#/definitions/eventSuccessDefaults"
            },
            "eventSuccessByActivityKind": {
              "type": "object",
              "maxProperties": 16,
              "additionalProperties": {
                "$ref": "#/definitions/eventSuccessDefaults"
              }
            }
          }
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/shared/profile_common.schema.json",
      "title": "Profile common contract definitions",
      "description": "Shared enum, scalar, and Firestore value definitions for profile contracts.",
      "definitions": {
        "timestamp": {
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
        "nullableTimestamp": {
          "anyOf": [
            {
              "$ref": "#/definitions/timestamp"
            },
            {
              "type": "null"
            }
          ]
        },
        "gender": {
          "type": "string",
          "enum": [
            "man",
            "woman",
            "nonBinary",
            "other"
          ]
        },
        "educationLevel": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "highSchool",
            "someCollege",
            "bachelors",
            "masters",
            "phd",
            "tradeSchool",
            "other",
            null
          ]
        },
        "religion": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "hindu",
            "muslim",
            "christian",
            "sikh",
            "jain",
            "buddhist",
            "other",
            "nonReligious",
            null
          ]
        },
        "language": {
          "type": "string",
          "enum": [
            "english",
            "hindi",
            "marathi",
            "tamil",
            "telugu",
            "kannada",
            "bengali",
            "gujarati",
            "punjabi",
            "malayalam",
            "odia",
            "other"
          ]
        },
        "relationshipGoal": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "relationship",
            "casual",
            "marriage",
            "friendship",
            "unsure",
            null
          ]
        },
        "drinkingHabit": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "never",
            "socially",
            "often",
            null
          ]
        },
        "smokingHabit": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "never",
            "occasionally",
            "often",
            null
          ]
        },
        "workoutFrequency": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "never",
            "sometimes",
            "often",
            "everyday",
            null
          ]
        },
        "dietaryPreference": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "omnivore",
            "vegetarian",
            "vegan",
            "jain",
            "other",
            null
          ]
        },
        "childrenStatus": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "dontHave",
            "haveWantMore",
            "haveNoMore",
            "wantSomeday",
            "dontWant",
            null
          ]
        },
        "preferredDistance": {
          "type": "string",
          "enum": [
            "fiveK",
            "tenK",
            "halfMarathon",
            "marathon"
          ]
        },
        "runReason": {
          "type": "string",
          "enum": [
            "fitness",
            "community",
            "mindfulness",
            "challenge",
            "weightLoss",
            "raceTraining",
            "social"
          ]
        },
        "preferredRunTime": {
          "type": "string",
          "enum": [
            "earlyMorning",
            "morning",
            "afternoon",
            "evening",
            "night"
          ]
        },
        "citySlug": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 80,
          "pattern": "^[a-z0-9-]+$"
        },
        "strictCitySlug": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80,
          "pattern": "^[a-z0-9-]+$"
        },
        "cityId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
        },
        "marketId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
        },
        "strictLatitude": {
          "type": "number",
          "minimum": -90,
          "maximum": 90
        },
        "strictLongitude": {
          "type": "number",
          "minimum": -180,
          "maximum": 180
        },
        "nullableString": {
          "type": [
            "string",
            "null"
          ]
        },
        "nullableShortText": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 120
        },
        "url": {
          "type": "string",
          "format": "uri",
          "maxLength": 2048
        },
        "photoUrlList": {
          "type": "array",
          "maxItems": 6,
          "items": {
            "$ref": "#/definitions/url"
          }
        },
        "heightCm": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 120,
          "maximum": 220
        },
        "latitude": {
          "type": [
            "number",
            "null"
          ],
          "minimum": -90,
          "maximum": 90
        },
        "longitude": {
          "type": [
            "number",
            "null"
          ],
          "minimum": -180,
          "maximum": 180
        },
        "age": {
          "type": "integer",
          "minimum": 18,
          "maximum": 120
        },
        "paceSecsPerKm": {
          "type": "integer",
          "minimum": 1
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_decide_organizer_event_candidate_payload.schema.json",
      "title": "AdminDecideOrganizerEventCandidateCallablePayload",
      "description": "Callable payload accepted by adminDecideOrganizerEventCandidate. This records a manual admin review decision for a private external event candidate without importing the event.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "candidateId",
        "decision",
        "checklist",
        "note"
      ],
      "properties": {
        "candidateId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "decision": {
          "type": "string",
          "enum": [
            "approve_for_import",
            "hold",
            "reject"
          ]
        },
        "checklist": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "identityReviewed",
            "sourceEventReviewed",
            "timeReviewed",
            "locationReviewed",
            "dedupeReviewed",
            "ownerSafeCopyReviewed",
            "importPolicyAcknowledged"
          ],
          "properties": {
            "identityReviewed": {
              "type": "boolean"
            },
            "sourceEventReviewed": {
              "type": "boolean"
            },
            "timeReviewed": {
              "type": "boolean"
            },
            "locationReviewed": {
              "type": "boolean"
            },
            "dedupeReviewed": {
              "type": "boolean"
            },
            "ownerSafeCopyReviewed": {
              "type": "boolean"
            },
            "importPolicyAcknowledged": {
              "type": "boolean"
            }
          }
        },
        "note": {
          "type": "string",
          "minLength": 1,
          "maxLength": 1000
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_decide_organizer_intake_payload.schema.json",
      "title": "AdminDecideOrganizerIntakeCallablePayload",
      "description": "Callable payload accepted by adminDecideOrganizerIntake. This records a manual admin review decision for a private organizer-intake candidate.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "entityId",
        "decision",
        "appVisibility",
        "checklist",
        "note"
      ],
      "properties": {
        "entityId": {
          "$ref": "../shared/event_common.schema.json#/definitions/documentId"
        },
        "decision": {
          "type": "string",
          "enum": [
            "approve_public",
            "hold",
            "suppress"
          ]
        },
        "appVisibility": {
          "type": "string",
          "enum": [
            "hidden",
            "discoverable"
          ]
        },
        "checklist": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "identityReviewed",
            "surfaceInventoryReviewed",
            "ownerSafeCopyReviewed",
            "marketScopeReviewed",
            "mediaRightsReviewed",
            "crawlDisabledReviewed"
          ],
          "properties": {
            "identityReviewed": {
              "type": "boolean"
            },
            "surfaceInventoryReviewed": {
              "type": "boolean"
            },
            "ownerSafeCopyReviewed": {
              "type": "boolean"
            },
            "marketScopeReviewed": {
              "type": "boolean"
            },
            "mediaRightsReviewed": {
              "type": "boolean"
            },
            "crawlDisabledReviewed": {
              "type": "boolean"
            },
            "manualReportsReviewed": {
              "type": "boolean",
              "description": "True when the reviewer explicitly inspected manual reports that have no local raw artifact. Raw evidence remains outside Firestore; replay validation decides when this acknowledgement is required."
            }
          }
        },
        "note": {
          "type": "string",
          "minLength": 1,
          "maxLength": 1000
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_decide_organizer_policy_gap_payload.schema.json",
      "title": "AdminDecideOrganizerPolicyGapCallablePayload",
      "description": "Callable payload accepted by adminDecideOrganizerPolicyGap. This records a manual product/admin review decision for an organizer intake policy gap without enabling crawls, provider lookups, imports, defaults, or naming migrations.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "gapId",
        "decision",
        "requiredInputsReviewed",
        "checklist",
        "note"
      ],
      "properties": {
        "gapId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160
        },
        "decision": {
          "type": "string",
          "enum": [
            "accept",
            "hold",
            "reject"
          ]
        },
        "requiredInputsReviewed": {
          "type": "array",
          "maxItems": 20,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          },
          "uniqueItems": true
        },
        "checklist": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requiredInputsReviewed",
            "costAndSafetyReviewed",
            "implementationOwnerReviewed",
            "behaviorStillDisabledAcknowledged"
          ],
          "properties": {
            "requiredInputsReviewed": {
              "type": "boolean"
            },
            "costAndSafetyReviewed": {
              "type": "boolean"
            },
            "implementationOwnerReviewed": {
              "type": "boolean"
            },
            "behaviorStillDisabledAcknowledged": {
              "type": "boolean"
            }
          }
        },
        "note": {
          "type": "string",
          "minLength": 1,
          "maxLength": 1000
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_get_event_details_payload.schema.json",
      "title": "AdminGetEventDetailsCallablePayload",
      "description": "Callable payload accepted by adminGetEventDetails. This loads a canonical events/{eventId} document for the admin event publishing workspace.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "eventId"
      ],
      "properties": {
        "eventId": {
          "$ref": "../shared/event_common.schema.json#/definitions/documentId"
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_get_organizer_details_payload.schema.json",
      "title": "AdminGetOrganizerDetailsCallablePayload",
      "description": "Callable payload accepted by adminGetOrganizerDetails.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "organizerId"
      ],
      "properties": {
        "organizerId": {
          "$ref": "../shared/event_common.schema.json#/definitions/documentId"
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_list_event_details_payload.schema.json",
      "title": "AdminListEventDetailsCallablePayload",
      "description": "Callable payload accepted by adminListEventDetails. This lists canonical events/{eventId} rows for the admin event publishing workspace.",
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "query": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 160
        },
        "clubId": {
          "anyOf": [
            {
              "$ref": "../shared/event_common.schema.json#/definitions/documentId"
            },
            {
              "type": "null"
            }
          ]
        },
        "organizerId": {
          "anyOf": [
            {
              "$ref": "../shared/event_common.schema.json#/definitions/documentId"
            },
            {
              "type": "null"
            }
          ]
        },
        "citySlug": {
          "anyOf": [
            {
              "$ref": "../shared/event_common.schema.json#/definitions/marketId"
            },
            {
              "type": "null"
            }
          ]
        },
        "citySlugs": {
          "anyOf": [
            {
              "type": "array",
              "items": {
                "$ref": "../shared/event_common.schema.json#/definitions/marketId"
              },
              "minItems": 1,
              "maxItems": 10,
              "uniqueItems": true
            },
            {
              "type": "null"
            }
          ]
        },
        "activityKind": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "socialRun",
            "running",
            "walking",
            "pickleball",
            "padel",
            "tennis",
            "badminton",
            "cycling",
            "spinClass",
            "yoga",
            "strengthTraining",
            "pubQuiz",
            "barCrawl",
            "dinner",
            "singlesMixer",
            "openActivity",
            null
          ]
        },
        "status": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "active",
            "cancelled",
            null
          ]
        },
        "timeWindow": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "upcoming",
            "past",
            "all",
            null
          ],
          "description": "Optional server-side startTime window used by admin event lists. Upcoming and past are evaluated against callable server time."
        },
        "limit": {
          "type": "integer",
          "minimum": 1,
          "maximum": 100
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_list_external_event_details_payload.schema.json",
      "title": "AdminListExternalEventDetailsCallablePayload",
      "description": "Callable payload accepted by adminListExternalEventDetails. This lists read-only externalEvents/{eventId} rows for the admin event supply workspace.",
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "query": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 160
        },
        "citySlug": {
          "anyOf": [
            {
              "$ref": "../shared/event_common.schema.json#/definitions/citySlug"
            },
            {
              "type": "null"
            }
          ]
        },
        "citySlugs": {
          "anyOf": [
            {
              "type": "array",
              "items": {
                "$ref": "../shared/event_common.schema.json#/definitions/citySlug"
              },
              "minItems": 1,
              "maxItems": 10,
              "uniqueItems": true
            },
            {
              "type": "null"
            }
          ]
        },
        "publicationStatus": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "draft",
            "public",
            "archived",
            "removed",
            null
          ]
        },
        "status": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "active",
            "cancelled",
            null
          ]
        },
        "timeWindow": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "upcoming",
            "past",
            "all",
            null
          ],
          "description": "Optional server-side startTime window used by admin external event lists. Upcoming and past are evaluated against callable server time."
        },
        "limit": {
          "type": "integer",
          "minimum": 1,
          "maximum": 100
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_list_intake_operations_payload.schema.json",
      "title": "AdminListIntakeOperationsCallablePayload",
      "description": "Read-only filters for the durable Supply Intake operations inventory. This callable never requests or executes a run.",
      "type": "object",
      "additionalProperties": false,
      "allOf": [
        {
          "if": {
            "required": [
              "humanReviewRequired"
            ],
            "properties": {
              "humanReviewRequired": {
                "const": true
              }
            }
          },
          "then": {
            "properties": {
              "primaryStage": {
                "type": "null"
              },
              "entityKind": {
                "type": "null"
              },
              "lifecycleStatus": {
                "type": "null"
              }
            }
          }
        }
      ],
      "properties": {
        "workflowId": {
          "type": "string",
          "enum": [
            "supply-intake"
          ]
        },
        "runId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "primaryStage": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "incoming",
            "verify",
            "resolve",
            "ready",
            null
          ]
        },
        "entityKind": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "event",
            "organizer",
            "source_result",
            "source_profile",
            null
          ]
        },
        "lifecycleStatus": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "queued",
            "in_progress",
            "waiting",
            "ready",
            "published",
            "terminal",
            null
          ]
        },
        "runStatus": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "planned",
            "queued",
            "running",
            "paused",
            "completed",
            "failed",
            "cancelled",
            null
          ]
        },
        "humanReviewRequired": {
          "type": "boolean",
          "description": "When true, returns only work items carrying the canonical human_review_required task flag."
        },
        "runLimit": {
          "type": "integer",
          "minimum": 1,
          "maximum": 25
        },
        "workItemLimit": {
          "type": "integer",
          "minimum": 1,
          "maximum": 200
        },
        "runCursor": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 1000
        },
        "workItemCursor": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 1000
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_list_organizer_details_payload.schema.json",
      "title": "AdminListOrganizerDetailsCallablePayload",
      "description": "Callable payload accepted by adminListOrganizerDetails. This lists canonical organizer profile rows from organizers/{organizerId} for the admin publishing workspace.",
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "query": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 160
        },
        "citySlug": {
          "anyOf": [
            {
              "$ref": "../shared/event_common.schema.json#/definitions/marketId"
            },
            {
              "type": "null"
            }
          ]
        },
        "citySlugs": {
          "anyOf": [
            {
              "type": "array",
              "items": {
                "$ref": "../shared/event_common.schema.json#/definitions/marketId"
              },
              "minItems": 1,
              "maxItems": 10,
              "uniqueItems": true
            },
            {
              "type": "null"
            }
          ]
        },
        "publishStatus": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "draft",
            "qa",
            "published",
            "suppressed",
            "removed",
            null
          ]
        },
        "appVisibility": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "discoverable",
            "hidden",
            null
          ]
        },
        "limit": {
          "type": "integer",
          "minimum": 1,
          "maximum": 100
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_publish_external_event_payload.schema.json",
      "title": "AdminPublishExternalEventCallablePayload",
      "description": "Callable payload accepted by adminPublishExternalEvent. This publishes one preflight-approved read-only externalEvents/{eventId} document from eventSupplyReadiness/current.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "sourceActionId",
        "targetPath",
        "reviewNote",
        "checklist"
      ],
      "properties": {
        "sourceActionId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "targetPath": {
          "type": "string",
          "pattern": "^externalEvents/[A-Za-z0-9_-]{1,180}$"
        },
        "reviewNote": {
          "type": "string",
          "minLength": 1,
          "maxLength": 1000
        },
        "checklist": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "preflightActionReviewed",
            "outboundLinksReviewed",
            "noCatchBookingPaymentsWaitlist",
            "ownerSafeCopyReviewed"
          ],
          "properties": {
            "preflightActionReviewed": {
              "type": "boolean"
            },
            "outboundLinksReviewed": {
              "type": "boolean"
            },
            "noCatchBookingPaymentsWaitlist": {
              "type": "boolean"
            },
            "ownerSafeCopyReviewed": {
              "type": "boolean"
            }
          }
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_record_event_intake_review_decision_payload.schema.json",
      "title": "AdminRecordEventIntakeReviewDecisionCallablePayload",
      "description": "Callable payload accepted by adminRecordEventIntakeReviewDecision. This records a manual admin decision for private event-intake artifacts without publishing marketing content or creating canonical events.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "targetType",
        "targetId",
        "decision",
        "checklist",
        "note"
      ],
      "properties": {
        "targetType": {
          "type": "string",
          "enum": [
            "source_profile",
            "query_template",
            "run_plan",
            "source_result",
            "event_candidate"
          ]
        },
        "targetId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "decision": {
          "type": "string",
          "enum": [
            "approve",
            "needs_changes",
            "hold",
            "reject"
          ]
        },
        "runId": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 180
        },
        "note": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000
        },
        "edits": {
          "type": "object",
          "additionalProperties": true
        },
        "checklist": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "sourceReviewed",
            "dateReviewed",
            "venueReviewed",
            "copyReviewed",
            "rightsReviewed",
            "noCatchHostingImplied"
          ],
          "properties": {
            "sourceReviewed": {
              "type": "boolean"
            },
            "dateReviewed": {
              "type": "boolean"
            },
            "venueReviewed": {
              "type": "boolean"
            },
            "copyReviewed": {
              "type": "boolean"
            },
            "rightsReviewed": {
              "type": "boolean"
            },
            "noCatchHostingImplied": {
              "type": "boolean"
            }
          }
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_record_organizer_curation_payload.schema.json",
      "title": "AdminRecordOrganizerCurationCallablePayload",
      "description": "Callable payload accepted by adminRecordOrganizerCuration. This records one low-volume manual organizer-intake curation operation for deterministic export into repo-backed curation batches.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "operationType",
        "reason"
      ],
      "properties": {
        "operationId": {
          "$ref": "../shared/event_common.schema.json#/definitions/documentId"
        },
        "operationType": {
          "type": "string",
          "enum": [
            "attach_surface",
            "merge_entity",
            "split_surface",
            "suppress_entity",
            "surface_decision"
          ]
        },
        "entityId": {
          "$ref": "../shared/event_common.schema.json#/definitions/documentId"
        },
        "sourceEntityId": {
          "$ref": "../shared/event_common.schema.json#/definitions/documentId"
        },
        "targetEntityId": {
          "$ref": "../shared/event_common.schema.json#/definitions/documentId"
        },
        "surfaceId": {
          "$ref": "../shared/event_common.schema.json#/definitions/documentId"
        },
        "newEntityId": {
          "$ref": "../shared/event_common.schema.json#/definitions/documentId"
        },
        "sourceCandidateId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "decision": {
          "type": "string",
          "enum": [
            "accept_primary",
            "accept_secondary",
            "reject_wrong_entity",
            "mark_ambiguous",
            "mark_historical"
          ]
        },
        "surface": {
          "$ref": "#/definitions/surface"
        },
        "reason": {
          "type": "string",
          "minLength": 1,
          "maxLength": 500
        }
      },
      "definitions": {
        "urlOrNull": {
          "anyOf": [
            {
              "type": "string",
              "format": "uri"
            },
            {
              "type": "null"
            }
          ]
        },
        "surface": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "surfaceId",
            "platform",
            "surfaceKind",
            "url",
            "normalizedKey",
            "role",
            "status",
            "confidence",
            "crawl",
            "evidenceRefs",
            "notes"
          ],
          "properties": {
            "surfaceId": {
              "$ref": "../shared/event_common.schema.json#/definitions/documentId"
            },
            "platform": {
              "type": "string",
              "enum": [
                "bookMyShow",
                "district",
                "instagram",
                "linkedin",
                "luma",
                "news",
                "officialWebsite",
                "partiful",
                "sortMyScene",
                "userReport",
                "other"
              ]
            },
            "surfaceKind": {
              "type": "string",
              "enum": [
                "eventListing",
                "eventCalendar",
                "organizerProfile",
                "personProfile",
                "press",
                "socialProfile",
                "website",
                "wrongEntity"
              ]
            },
            "url": {
              "$ref": "#/definitions/urlOrNull"
            },
            "normalizedKey": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 240
            },
            "role": {
              "type": "string",
              "enum": [
                "primary",
                "secondary",
                "backup",
                "historical",
                "ambiguous",
                "rejected"
              ]
            },
            "status": {
              "type": "string",
              "enum": [
                "active",
                "candidate",
                "ambiguous",
                "historical",
                "rejected"
              ]
            },
            "confidence": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "entityMatch",
                "ownership",
                "city"
              ],
              "properties": {
                "entityMatch": {
                  "type": "string",
                  "enum": [
                    "low",
                    "medium",
                    "high"
                  ]
                },
                "ownership": {
                  "type": "string",
                  "enum": [
                    "low",
                    "medium",
                    "high"
                  ]
                },
                "city": {
                  "type": "string",
                  "enum": [
                    "low",
                    "medium",
                    "high"
                  ]
                }
              }
            },
            "crawl": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "eventDiscoveryStatus",
                "policy",
                "supportsEventExtraction"
              ],
              "properties": {
                "eventDiscoveryStatus": {
                  "type": "string",
                  "enum": [
                    "disabled",
                    "candidate",
                    "approved",
                    "paused"
                  ]
                },
                "policy": {
                  "type": "string",
                  "enum": [
                    "manualOnly",
                    "blocked",
                    "apiPreferred"
                  ]
                },
                "supportsEventExtraction": {
                  "type": "boolean"
                }
              }
            },
            "evidenceRefs": {
              "type": "array",
              "items": {
                "$ref": "#/definitions/evidenceRef"
              }
            },
            "notes": {
              "type": "string",
              "maxLength": 500
            }
          }
        },
        "evidenceRef": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "type",
            "ref",
            "description"
          ],
          "properties": {
            "type": {
              "type": "string",
              "enum": [
                "hostDiscoveryRun",
                "seedClub",
                "userReportedSearchResult",
                "manualNote"
              ]
            },
            "ref": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 240
            },
            "description": {
              "type": "string",
              "minLength": 1,
              "maxLength": 400
            }
          }
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_resolve_organizer_event_location_payload.schema.json",
      "title": "AdminResolveOrganizerEventLocationCallablePayload",
      "description": "Callable payload accepted by adminResolveOrganizerEventLocation. This records reviewed coordinates for a private external event candidate without importing the event.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "candidateId",
        "location",
        "checklist",
        "note"
      ],
      "properties": {
        "candidateId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "location": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "name",
            "latitude",
            "longitude"
          ],
          "properties": {
            "name": {
              "type": "string",
              "minLength": 1,
              "maxLength": 240
            },
            "address": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 500
            },
            "placeId": {
              "type": [
                "string",
                "null"
              ],
              "minLength": 1,
              "maxLength": 256
            },
            "latitude": {
              "$ref": "../shared/event_common.schema.json#/definitions/latitude"
            },
            "longitude": {
              "$ref": "../shared/event_common.schema.json#/definitions/longitude"
            },
            "notes": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 1000
            }
          }
        },
        "checklist": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "sourceLocationReviewed",
            "coordinatesReviewed",
            "placeIdentityReviewed",
            "importSafetyReviewed"
          ],
          "properties": {
            "sourceLocationReviewed": {
              "type": "boolean"
            },
            "coordinatesReviewed": {
              "type": "boolean"
            },
            "placeIdentityReviewed": {
              "type": "boolean"
            },
            "importSafetyReviewed": {
              "type": "boolean"
            }
          }
        },
        "note": {
          "type": "string",
          "minLength": 1,
          "maxLength": 1000
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_set_club_index_status_payload.schema.json",
      "title": "AdminSetClubIndexStatusCallablePayload",
      "description": "Callable payload accepted by adminSetClubIndexStatus.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "clubId",
        "indexStatus",
        "checklist"
      ],
      "properties": {
        "clubId": {
          "$ref": "../shared/event_common.schema.json#/definitions/documentId"
        },
        "indexStatus": {
          "type": "string",
          "enum": [
            "noindex",
            "indexReady",
            "indexed"
          ]
        },
        "checklist": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "sourceEvidenceVerified",
            "mediaRightsVerified",
            "cadenceVerified",
            "ownerContactVerified"
          ],
          "properties": {
            "sourceEvidenceVerified": {
              "type": "boolean"
            },
            "mediaRightsVerified": {
              "type": "boolean"
            },
            "cadenceVerified": {
              "type": "boolean"
            },
            "ownerContactVerified": {
              "type": "boolean"
            }
          }
        },
        "reviewNote": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 1000
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_update_event_details_payload.schema.json",
      "title": "AdminUpdateEventDetailsCallablePayload",
      "description": "Callable payload accepted by adminUpdateEventDetails. This edits low-risk app-facing canonical event fields through an audited admin callable.",
      "x-callable-shape": "patch",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "eventId",
        "fields"
      ],
      "properties": {
        "eventId": {
          "$ref": "../shared/event_common.schema.json#/definitions/documentId"
        },
        "reviewNote": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 1000
        },
        "fields": {
          "type": "object",
          "additionalProperties": false,
          "minProperties": 1,
          "properties": {
            "description": {
              "type": "string",
              "maxLength": 2000
            },
            "photoUrl": {
              "$ref": "../shared/event_common.schema.json#/definitions/urlOrNull"
            },
            "distanceKm": {
              "type": "number",
              "minimum": 0,
              "maximum": 100
            },
            "pace": {
              "$ref": "../shared/event_common.schema.json#/definitions/paceLevel"
            },
            "eventFormat": {
              "$ref": "../shared/event_common.schema.json#/definitions/eventFormatSnapshot"
            }
          }
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_update_organizer_details_payload.schema.json",
      "title": "AdminUpdateOrganizerDetailsCallablePayload",
      "description": "Callable payload accepted by adminUpdateOrganizerDetails. This edits owner-safe organizer listing fields through an audited admin callable.",
      "x-callable-shape": "patch",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "organizerId",
        "fields"
      ],
      "properties": {
        "organizerId": {
          "$ref": "../shared/event_common.schema.json#/definitions/documentId"
        },
        "fields": {
          "type": "object",
          "additionalProperties": false,
          "minProperties": 1,
          "properties": {
            "name": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "description": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            },
            "location": {
              "$ref": "../shared/event_common.schema.json#/definitions/marketId"
            },
            "area": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "tags": {
              "type": "array",
              "maxItems": 20,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 80
              }
            },
            "instagramHandle": {
              "$ref": "../shared/event_common.schema.json#/definitions/contactString"
            },
            "phoneNumber": {
              "$ref": "../shared/event_common.schema.json#/definitions/contactString"
            },
            "email": {
              "$ref": "../shared/event_common.schema.json#/definitions/contactString"
            },
            "imageUrl": {
              "$ref": "../shared/event_common.schema.json#/definitions/urlOrNull"
            },
            "profileImageUrl": {
              "$ref": "../shared/event_common.schema.json#/definitions/urlOrNull"
            },
            "organizerType": {
              "$ref": "../shared/event_common.schema.json#/definitions/organizerType"
            },
            "publicCategoryLabel": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 120
            },
            "entityKind": {
              "type": "string",
              "enum": [
                "club",
                "venue",
                "eventOrganizer",
                "creatorCommunity",
                "brand"
              ]
            },
            "entitySubtypes": {
              "type": "array",
              "maxItems": 20,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 80
              }
            },
            "displayCategory": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 120
            },
            "cityName": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 120
            },
            "regionName": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 120
            },
            "countryCode": {
              "type": [
                "string",
                "null"
              ],
              "pattern": "^[A-Z]{2}$"
            },
            "countryName": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 120
            },
            "appVisibility": {
              "type": "string",
              "enum": [
                "discoverable",
                "hidden"
              ]
            },
            "publicPage": {
              "type": "object",
              "additionalProperties": false,
              "minProperties": 1,
              "properties": {
                "slug": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-z0-9-]+$"
                },
                "citySlug": {
                  "$ref": "../shared/event_common.schema.json#/definitions/citySlug"
                },
                "canonicalPath": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 240
                },
                "publishStatus": {
                  "type": "string",
                  "enum": [
                    "draft",
                    "qa",
                    "published",
                    "suppressed",
                    "removed"
                  ]
                },
                "seoTitle": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 120
                },
                "seoDescription": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 320
                }
              }
            },
            "provenance": {
              "type": "object",
              "additionalProperties": false,
              "minProperties": 1,
              "properties": {
                "sourceConfidence": {
                  "type": "string",
                  "enum": [
                    "seedOnly",
                    "low",
                    "medium",
                    "high",
                    "ownerVerified"
                  ]
                },
                "verificationStatus": {
                  "type": "string",
                  "enum": [
                    "unverified",
                    "sourceBacked",
                    "ownerVerified"
                  ]
                }
              }
            },
            "publicProfile": {
              "type": "object",
              "additionalProperties": false,
              "minProperties": 1,
              "properties": {
                "headline": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 160
                },
                "summary": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 800
                },
                "sourceSummary": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 800
                },
                "formats": {
                  "type": "array",
                  "maxItems": 12,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 80
                  }
                },
                "fitNotes": {
                  "type": "array",
                  "maxItems": 8,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 400
                  }
                },
                "missingEvidence": {
                  "type": "array",
                  "maxItems": 12,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 200
                  }
                }
              }
            }
          }
        },
        "reviewNote": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 1000
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/host_analytics_query_payload.schema.json",
      "title": "HostAnalyticsQueryCallablePayload",
      "description": "Callable payload accepted by getHostAnalytics and adminGetHostAnalytics.",
      "x-callable-aliases": [
        "getHostAnalytics",
        "adminGetHostAnalytics"
      ],
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "clubId": {
          "anyOf": [
            {
              "$ref": "../shared/event_common.schema.json#/definitions/documentId"
            },
            {
              "type": "null"
            }
          ]
        },
        "organizerId": {
          "anyOf": [
            {
              "$ref": "../shared/event_common.schema.json#/definitions/documentId"
            },
            {
              "type": "null"
            }
          ]
        },
        "eventId": {
          "anyOf": [
            {
              "$ref": "../shared/event_common.schema.json#/definitions/documentId"
            },
            {
              "type": "null"
            }
          ]
        },
        "rangePreset": {
          "type": "string",
          "enum": [
            "7d",
            "30d",
            "90d",
            "12m",
            "month",
            "custom"
          ]
        },
        "startDate": {
          "type": [
            "string",
            "null"
          ],
          "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
        },
        "endDate": {
          "type": [
            "string",
            "null"
          ],
          "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
        },
        "granularity": {
          "type": "string",
          "enum": [
            "day",
            "week",
            "month"
          ]
        },
        "timezone": {
          "type": "string",
          "minLength": 1,
          "maxLength": 64
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/user_analytics_query_payload.schema.json",
      "title": "UserAnalyticsQueryCallablePayload",
      "description": "Callable payload accepted by getUserAnalytics and adminGetUserAnalytics.",
      "x-callable-aliases": [
        "getUserAnalytics",
        "adminGetUserAnalytics"
      ],
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "userId": {
          "anyOf": [
            {
              "$ref": "../shared/event_common.schema.json#/definitions/documentId"
            },
            {
              "type": "null"
            }
          ],
          "description": "Admin-only user scope override. getUserAnalytics always scopes to the signed-in user."
        },
        "rangePreset": {
          "type": "string",
          "enum": [
            "7d",
            "30d",
            "90d",
            "month",
            "custom"
          ]
        },
        "startDate": {
          "type": [
            "string",
            "null"
          ],
          "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
        },
        "endDate": {
          "type": [
            "string",
            "null"
          ],
          "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
        },
        "granularity": {
          "type": "string",
          "enum": [
            "day",
            "week",
            "month"
          ]
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callable_responses/admin_list_intake_operations_response.schema.json",
      "title": "AdminListIntakeOperationsCallableResponse",
      "description": "Read-only persisted run and work-item projection for the Supply Intake Operations workspace.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "generatedAt",
        "workflowId",
        "executionMode",
        "source",
        "capabilities",
        "summary",
        "runs",
        "workItems",
        "nextRunCursor",
        "nextWorkItemCursor"
      ],
      "properties": {
        "schemaVersion": {
          "type": "integer",
          "const": 1
        },
        "generatedAt": {
          "type": "string",
          "format": "date-time"
        },
        "workflowId": {
          "type": "string",
          "const": "supply-intake"
        },
        "executionMode": {
          "type": "string",
          "const": "shadow"
        },
        "source": {
          "type": "string",
          "enum": [
            "firestore",
            "sample"
          ]
        },
        "capabilities": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requestRuns",
            "networkFetches",
            "modelCalls",
            "publicWrites",
            "ruleDeployment"
          ],
          "properties": {
            "requestRuns": {
              "type": "boolean",
              "const": false
            },
            "networkFetches": {
              "type": "boolean",
              "const": false
            },
            "modelCalls": {
              "type": "boolean",
              "const": false
            },
            "publicWrites": {
              "type": "boolean",
              "const": false
            },
            "ruleDeployment": {
              "type": "boolean",
              "const": false
            }
          }
        },
        "summary": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "loadedRunCount",
            "workItemCount",
            "humanReviewCount",
            "stages"
          ],
          "properties": {
            "loadedRunCount": {
              "type": "integer",
              "minimum": 0
            },
            "workItemCount": {
              "type": "integer",
              "minimum": 0
            },
            "humanReviewCount": {
              "type": "integer",
              "minimum": 0
            },
            "stages": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "incoming",
                "verify",
                "resolve",
                "ready"
              ],
              "properties": {
                "incoming": {
                  "type": "integer",
                  "minimum": 0
                },
                "verify": {
                  "type": "integer",
                  "minimum": 0
                },
                "resolve": {
                  "type": "integer",
                  "minimum": 0
                },
                "ready": {
                  "type": "integer",
                  "minimum": 0
                }
              }
            }
          }
        },
        "runs": {
          "type": "array",
          "maxItems": 25,
          "items": {
            "$ref": "../operations/run.schema.json"
          }
        },
        "workItems": {
          "type": "array",
          "maxItems": 200,
          "items": {
            "allOf": [
              {
                "$ref": "../operations/work_item.schema.json"
              },
              {
                "properties": {
                  "workflowId": {
                    "const": "supply-intake"
                  },
                  "primaryStage": {
                    "enum": [
                      "incoming",
                      "verify",
                      "resolve",
                      "ready"
                    ]
                  }
                }
              }
            ]
          }
        },
        "nextRunCursor": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 1000
        },
        "nextWorkItemCursor": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 1000
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/operations/run.schema.json",
      "title": "OperationRun",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "runId",
        "workflowId",
        "revision",
        "mode",
        "status",
        "scope",
        "rulesetVersion",
        "policyVersion",
        "inputHash",
        "budgets",
        "counters",
        "checkpoint",
        "createdAt",
        "updatedAt",
        "startedAt",
        "finishedAt",
        "failure",
        "metadata"
      ],
      "properties": {
        "schemaVersion": {
          "type": "integer",
          "const": 1
        },
        "runId": {
          "$ref": "common.schema.json#/definitions/id"
        },
        "workflowId": {
          "$ref": "common.schema.json#/definitions/workflowId"
        },
        "revision": {
          "type": "integer",
          "minimum": 0
        },
        "mode": {
          "type": "string",
          "enum": [
            "shadow",
            "assisted",
            "autonomous"
          ]
        },
        "status": {
          "type": "string",
          "enum": [
            "planned",
            "queued",
            "running",
            "paused",
            "completed",
            "failed",
            "cancelled"
          ]
        },
        "scope": {
          "type": "object",
          "additionalProperties": true,
          "maxProperties": 40
        },
        "rulesetVersion": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "policyVersion": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "inputHash": {
          "$ref": "common.schema.json#/definitions/sha256"
        },
        "budgets": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "maxWorkItems",
            "maxModelCalls",
            "maxModelTokens",
            "maxCostMicros",
            "deadlineAt"
          ],
          "properties": {
            "maxWorkItems": {
              "type": "integer",
              "minimum": 1,
              "maximum": 10000
            },
            "maxModelCalls": {
              "type": "integer",
              "minimum": 0
            },
            "maxModelTokens": {
              "type": "integer",
              "minimum": 0
            },
            "maxCostMicros": {
              "type": "integer",
              "minimum": 0
            },
            "deadlineAt": {
              "$ref": "common.schema.json#/definitions/nullableIsoDateTime"
            }
          }
        },
        "counters": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "discovered",
            "processed",
            "modelCalls",
            "modelTokens",
            "costMicros",
            "escalated",
            "published",
            "failed"
          ],
          "properties": {
            "discovered": {
              "type": "integer",
              "minimum": 0
            },
            "processed": {
              "type": "integer",
              "minimum": 0
            },
            "modelCalls": {
              "type": "integer",
              "minimum": 0
            },
            "modelTokens": {
              "type": "integer",
              "minimum": 0
            },
            "costMicros": {
              "type": "integer",
              "minimum": 0
            },
            "escalated": {
              "type": "integer",
              "minimum": 0
            },
            "published": {
              "type": "integer",
              "minimum": 0
            },
            "failed": {
              "type": "integer",
              "minimum": 0
            }
          }
        },
        "checkpoint": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "lastSequence",
            "cursor"
          ],
          "properties": {
            "lastSequence": {
              "type": "integer",
              "minimum": 0
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
        "createdAt": {
          "$ref": "common.schema.json#/definitions/isoDateTime"
        },
        "updatedAt": {
          "$ref": "common.schema.json#/definitions/isoDateTime"
        },
        "startedAt": {
          "$ref": "common.schema.json#/definitions/nullableIsoDateTime"
        },
        "finishedAt": {
          "$ref": "common.schema.json#/definitions/nullableIsoDateTime"
        },
        "failure": {
          "anyOf": [
            {
              "$ref": "common.schema.json#/definitions/failure"
            },
            {
              "type": "null"
            }
          ]
        },
        "metadata": {
          "type": "object",
          "additionalProperties": true,
          "maxProperties": 40
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/operations/common.schema.json",
      "title": "OperationsCommonDefinitions",
      "definitions": {
        "id": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "workflowId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "pattern": "^[a-z][a-z0-9_-]*$"
        },
        "code": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "pattern": "^[a-z][a-z0-9_.:-]*$"
        },
        "isoDateTime": {
          "type": "string",
          "format": "date-time"
        },
        "nullableIsoDateTime": {
          "type": [
            "string",
            "null"
          ],
          "format": "date-time"
        },
        "sha256": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "actor": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "actorType",
            "actorId"
          ],
          "properties": {
            "actorType": {
              "type": "string",
              "enum": [
                "human",
                "agent",
                "system"
              ]
            },
            "actorId": {
              "$ref": "#/definitions/id"
            }
          }
        },
        "evidenceRef": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "artifactId",
            "contentHash",
            "observedAt",
            "locator"
          ],
          "properties": {
            "artifactId": {
              "$ref": "#/definitions/id"
            },
            "contentHash": {
              "$ref": "#/definitions/sha256"
            },
            "observedAt": {
              "$ref": "#/definitions/isoDateTime"
            },
            "locator": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 1000
            }
          }
        },
        "failure": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "code",
            "message",
            "retryable"
          ],
          "properties": {
            "code": {
              "$ref": "#/definitions/code"
            },
            "message": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            },
            "retryable": {
              "type": "boolean"
            }
          }
        },
        "metricSet": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "fieldExactness",
            "eventPrecision",
            "duplicatePrecision",
            "duplicateRecall",
            "correctionRate",
            "escalationRate"
          ],
          "properties": {
            "fieldExactness": {
              "type": "number",
              "minimum": 0,
              "maximum": 1
            },
            "eventPrecision": {
              "type": "number",
              "minimum": 0,
              "maximum": 1
            },
            "duplicatePrecision": {
              "type": "number",
              "minimum": 0,
              "maximum": 1
            },
            "duplicateRecall": {
              "type": "number",
              "minimum": 0,
              "maximum": 1
            },
            "correctionRate": {
              "type": "number",
              "minimum": 0,
              "maximum": 1
            },
            "escalationRate": {
              "type": "number",
              "minimum": 0,
              "maximum": 1
            }
          }
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/operations/work_item.schema.json",
      "title": "OperationWorkItem",
      "description": "One exclusively staged unit of work. Task flags are orthogonal and may overlap.",
      "type": "object",
      "additionalProperties": false,
      "allOf": [
        {
          "if": {
            "properties": {
              "lifecycleStatus": {
                "const": "terminal"
              }
            }
          },
          "then": {
            "properties": {
              "outcome": {
                "type": "string",
                "not": {
                  "const": "published"
                }
              }
            }
          }
        },
        {
          "if": {
            "properties": {
              "lifecycleStatus": {
                "const": "published"
              }
            }
          },
          "then": {
            "properties": {
              "outcome": {
                "const": "published"
              }
            }
          }
        },
        {
          "if": {
            "properties": {
              "lifecycleStatus": {
                "enum": [
                  "queued",
                  "in_progress",
                  "waiting",
                  "ready"
                ]
              }
            }
          },
          "then": {
            "properties": {
              "outcome": {
                "type": "null"
              }
            }
          }
        },
        {
          "if": {
            "anyOf": [
              {
                "required": [
                  "blockerCodes"
                ],
                "properties": {
                  "blockerCodes": {
                    "contains": {
                      "const": "human_review_required"
                    }
                  }
                }
              },
              {
                "required": [
                  "normalizedPayload"
                ],
                "properties": {
                  "normalizedPayload": {
                    "type": "object",
                    "required": [
                      "owner"
                    ],
                    "properties": {
                      "owner": {
                        "const": "human"
                      }
                    }
                  }
                }
              }
            ]
          },
          "then": {
            "properties": {
              "taskFlags": {
                "contains": {
                  "const": "human_review_required"
                }
              }
            }
          }
        },
        {
          "if": {
            "required": [
              "lifecycleStatus"
            ],
            "properties": {
              "lifecycleStatus": {
                "enum": [
                  "published",
                  "terminal"
                ]
              }
            }
          },
          "then": {
            "properties": {
              "taskFlags": {
                "not": {
                  "contains": {
                    "const": "human_review_required"
                  }
                }
              },
              "blockerCodes": {
                "not": {
                  "contains": {
                    "const": "human_review_required"
                  }
                }
              },
              "normalizedPayload": {
                "not": {
                  "required": [
                    "owner"
                  ],
                  "properties": {
                    "owner": {
                      "const": "human"
                    }
                  }
                }
              }
            }
          }
        }
      ],
      "required": [
        "schemaVersion",
        "workItemId",
        "workflowId",
        "runId",
        "entityKind",
        "externalKey",
        "revision",
        "candidateHash",
        "primaryStage",
        "lifecycleStatus",
        "outcome",
        "taskFlags",
        "blockerCodes",
        "warningCodes",
        "priority",
        "attemptCount",
        "evidenceRefs",
        "fieldProvenance",
        "normalizedPayload",
        "decisionId",
        "publicationPlanId",
        "createdAt",
        "updatedAt",
        "staleAt",
        "expiresAt"
      ],
      "properties": {
        "schemaVersion": {
          "type": "integer",
          "const": 1
        },
        "workItemId": {
          "$ref": "common.schema.json#/definitions/id"
        },
        "workflowId": {
          "$ref": "common.schema.json#/definitions/workflowId"
        },
        "runId": {
          "$ref": "common.schema.json#/definitions/id"
        },
        "entityKind": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80,
          "pattern": "^[a-z][a-z0-9_]*$"
        },
        "externalKey": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 500
        },
        "revision": {
          "type": "integer",
          "minimum": 0
        },
        "candidateHash": {
          "$ref": "common.schema.json#/definitions/sha256"
        },
        "primaryStage": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80,
          "pattern": "^[a-z][a-z0-9_]*$"
        },
        "lifecycleStatus": {
          "type": "string",
          "enum": [
            "queued",
            "in_progress",
            "waiting",
            "ready",
            "published",
            "terminal"
          ]
        },
        "outcome": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 120,
          "pattern": "^[a-z][a-z0-9_]*$"
        },
        "taskFlags": {
          "type": "array",
          "maxItems": 40,
          "uniqueItems": true,
          "items": {
            "$ref": "common.schema.json#/definitions/code"
          }
        },
        "blockerCodes": {
          "type": "array",
          "maxItems": 40,
          "uniqueItems": true,
          "items": {
            "$ref": "common.schema.json#/definitions/code"
          }
        },
        "warningCodes": {
          "type": "array",
          "maxItems": 40,
          "uniqueItems": true,
          "items": {
            "$ref": "common.schema.json#/definitions/code"
          }
        },
        "priority": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "attemptCount": {
          "type": "integer",
          "minimum": 0
        },
        "evidenceRefs": {
          "type": "array",
          "maxItems": 100,
          "items": {
            "$ref": "common.schema.json#/definitions/evidenceRef"
          }
        },
        "fieldProvenance": {
          "type": "array",
          "maxItems": 200,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "field",
              "artifactId",
              "contentHash",
              "locator",
              "extractedBy",
              "extractorVersion",
              "confidence"
            ],
            "properties": {
              "field": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              },
              "artifactId": {
                "$ref": "common.schema.json#/definitions/id"
              },
              "contentHash": {
                "$ref": "common.schema.json#/definitions/sha256"
              },
              "locator": {
                "type": [
                  "string",
                  "null"
                ],
                "maxLength": 1000
              },
              "extractedBy": {
                "type": "string",
                "enum": [
                  "deterministic",
                  "model",
                  "human"
                ]
              },
              "extractorVersion": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              },
              "confidence": {
                "type": [
                  "number",
                  "null"
                ],
                "minimum": 0,
                "maximum": 1
              }
            }
          }
        },
        "normalizedPayload": {
          "type": "object",
          "additionalProperties": true
        },
        "decisionId": {
          "anyOf": [
            {
              "$ref": "common.schema.json#/definitions/id"
            },
            {
              "type": "null"
            }
          ]
        },
        "publicationPlanId": {
          "anyOf": [
            {
              "$ref": "common.schema.json#/definitions/id"
            },
            {
              "type": "null"
            }
          ]
        },
        "createdAt": {
          "$ref": "common.schema.json#/definitions/isoDateTime"
        },
        "updatedAt": {
          "$ref": "common.schema.json#/definitions/isoDateTime"
        },
        "staleAt": {
          "$ref": "common.schema.json#/definitions/nullableIsoDateTime"
        },
        "expiresAt": {
          "$ref": "common.schema.json#/definitions/nullableIsoDateTime"
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callable_responses/host_analytics_response.schema.json",
      "title": "HostAnalyticsCallableResponse",
      "description": "Shared aggregate analytics response returned by host and admin analytics callables. Values are aggregate-only and host-safe.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "generatedAt",
        "timezone",
        "range",
        "scope",
        "summaryCards",
        "trend",
        "topEvents",
        "reviewSummary",
        "discoverySummary",
        "dataQuality"
      ],
      "properties": {
        "generatedAt": {
          "type": "string",
          "format": "date-time"
        },
        "timezone": {
          "type": "string",
          "minLength": 1,
          "maxLength": 64
        },
        "range": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "startDate",
            "endDate",
            "granularity"
          ],
          "properties": {
            "startDate": {
              "type": "string",
              "format": "date-time"
            },
            "endDate": {
              "type": "string",
              "format": "date-time"
            },
            "granularity": {
              "type": "string",
              "enum": [
                "day",
                "week",
                "month"
              ]
            },
            "preset": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 24
            }
          }
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "organizerIds",
            "clubIds",
            "eventIds"
          ],
          "properties": {
            "organizerIds": {
              "type": "array",
              "items": {
                "$ref": "../shared/event_common.schema.json#/definitions/documentId"
              }
            },
            "clubIds": {
              "type": "array",
              "items": {
                "$ref": "../shared/event_common.schema.json#/definitions/documentId"
              }
            },
            "eventIds": {
              "type": "array",
              "items": {
                "$ref": "../shared/event_common.schema.json#/definitions/documentId"
              }
            },
            "clubName": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 160
            },
            "organizerName": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 160
            },
            "eventTitle": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 160
            }
          }
        },
        "summaryCards": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/metricCard"
          }
        },
        "trend": {
          "type": "array",
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "periodStart",
              "periodEnd",
              "metrics"
            ],
            "properties": {
              "periodStart": {
                "type": "string",
                "format": "date-time"
              },
              "periodEnd": {
                "type": "string",
                "format": "date-time"
              },
              "metrics": {
                "type": "object",
                "additionalProperties": {
                  "type": "number"
                }
              }
            }
          }
        },
        "topEvents": {
          "type": "array",
          "maxItems": 25,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "eventId",
              "clubId",
              "title",
              "startTime",
              "status",
              "capacityLimit",
              "bookedCount",
              "checkedInCount",
              "waitlistedCount",
              "fillRate",
              "checkInRate",
              "grossRevenueMinor",
              "currency",
              "checkoutStartedCount",
              "checkoutDropoffCount",
              "paymentCompletedCount",
              "paymentFailedCount",
              "paymentRefundedCount",
              "reviewCount",
              "averageRating",
              "demandCount",
              "inviteOpenCount",
              "mutualMatchCount",
              "chatStartedCount",
              "repeatAttendeeCount"
            ],
            "properties": {
              "eventId": {
                "$ref": "../shared/event_common.schema.json#/definitions/documentId"
              },
              "clubId": {
                "$ref": "../shared/event_common.schema.json#/definitions/documentId"
              },
              "organizerId": {
                "$ref": "../shared/event_common.schema.json#/definitions/documentId"
              },
              "title": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              },
              "startTime": {
                "type": "string",
                "format": "date-time"
              },
              "status": {
                "type": "string",
                "maxLength": 48
              },
              "capacityLimit": {
                "type": "integer",
                "minimum": 0
              },
              "bookedCount": {
                "type": "integer",
                "minimum": 0
              },
              "checkedInCount": {
                "type": "integer",
                "minimum": 0
              },
              "waitlistedCount": {
                "type": "integer",
                "minimum": 0
              },
              "fillRate": {
                "type": "number",
                "minimum": 0
              },
              "checkInRate": {
                "type": "number",
                "minimum": 0
              },
              "grossRevenueMinor": {
                "type": "integer",
                "minimum": 0
              },
              "currency": {
                "type": "string",
                "minLength": 3,
                "maxLength": 3
              },
              "checkoutStartedCount": {
                "type": "integer",
                "minimum": 0
              },
              "checkoutDropoffCount": {
                "type": "integer",
                "minimum": 0
              },
              "paymentCompletedCount": {
                "type": "integer",
                "minimum": 0
              },
              "paymentFailedCount": {
                "type": "integer",
                "minimum": 0
              },
              "paymentRefundedCount": {
                "type": "integer",
                "minimum": 0
              },
              "reviewCount": {
                "type": "integer",
                "minimum": 0
              },
              "averageRating": {
                "type": "number",
                "minimum": 0,
                "maximum": 5
              },
              "demandCount": {
                "type": "integer",
                "minimum": 0
              },
              "inviteOpenCount": {
                "type": "integer",
                "minimum": 0
              },
              "mutualMatchCount": {
                "type": "integer",
                "minimum": 0
              },
              "chatStartedCount": {
                "type": "integer",
                "minimum": 0
              },
              "repeatAttendeeCount": {
                "type": "integer",
                "minimum": 0
              }
            }
          }
        },
        "reviewSummary": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "newReviews",
            "publishedReviews",
            "verifiedReviews",
            "publicReviews",
            "ownerResponseCount",
            "averageRating"
          ],
          "properties": {
            "newReviews": {
              "type": "integer",
              "minimum": 0
            },
            "publishedReviews": {
              "type": "integer",
              "minimum": 0
            },
            "verifiedReviews": {
              "type": "integer",
              "minimum": 0
            },
            "publicReviews": {
              "type": "integer",
              "minimum": 0
            },
            "ownerResponseCount": {
              "type": "integer",
              "minimum": 0
            },
            "averageRating": {
              "type": "number",
              "minimum": 0,
              "maximum": 5
            }
          }
        },
        "discoverySummary": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "listingViews",
            "searchAppearances",
            "eventViews",
            "organizerSaves",
            "eventSaves",
            "contactClicks",
            "claimClicks",
            "outboundClicks"
          ],
          "properties": {
            "listingViews": {
              "type": "integer",
              "minimum": 0
            },
            "searchAppearances": {
              "type": "integer",
              "minimum": 0
            },
            "eventViews": {
              "type": "integer",
              "minimum": 0
            },
            "organizerSaves": {
              "type": "integer",
              "minimum": 0
            },
            "eventSaves": {
              "type": "integer",
              "minimum": 0
            },
            "contactClicks": {
              "type": "integer",
              "minimum": 0
            },
            "claimClicks": {
              "type": "integer",
              "minimum": 0
            },
            "outboundClicks": {
              "type": "integer",
              "minimum": 0
            }
          }
        },
        "dataQuality": {
          "type": "array",
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "id",
              "state",
              "detail",
              "owner",
              "runbook",
              "nextAction"
            ],
            "properties": {
              "id": {
                "type": "string",
                "minLength": 1,
                "maxLength": 80
              },
              "state": {
                "type": "string",
                "enum": [
                  "ok",
                  "partial",
                  "missing"
                ]
              },
              "detail": {
                "type": "string",
                "minLength": 1,
                "maxLength": 240
              },
              "owner": {
                "type": "string",
                "minLength": 1,
                "maxLength": 80
              },
              "runbook": {
                "type": "string",
                "minLength": 1,
                "maxLength": 200
              },
              "nextAction": {
                "type": "string",
                "minLength": 1,
                "maxLength": 240
              }
            }
          }
        }
      },
      "definitions": {
        "metricCard": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "id",
            "label",
            "value",
            "unit",
            "status"
          ],
          "properties": {
            "id": {
              "type": "string",
              "minLength": 1,
              "maxLength": 80
            },
            "label": {
              "type": "string",
              "minLength": 1,
              "maxLength": 80
            },
            "value": {
              "type": "number"
            },
            "unit": {
              "type": "string",
              "enum": [
                "count",
                "percent",
                "money_minor",
                "rating"
              ]
            },
            "status": {
              "type": "string",
              "enum": [
                "ready",
                "partial",
                "missing"
              ]
            },
            "caption": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 160
            },
            "previousValue": {
              "type": [
                "number",
                "null"
              ]
            }
          }
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callable_responses/user_analytics_response.schema.json",
      "title": "UserAnalyticsCallableResponse",
      "description": "User-safe profile and connection analytics response. Internal scoring columns stay in BigQuery and are intentionally not exposed here.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "generatedAt",
        "timezone",
        "range",
        "scope",
        "summaryCards",
        "trend",
        "connectionSummary",
        "profileSummary",
        "coachingTipRefs",
        "dataQuality"
      ],
      "properties": {
        "generatedAt": {
          "type": "string",
          "format": "date-time"
        },
        "timezone": {
          "type": "string",
          "minLength": 1,
          "maxLength": 64
        },
        "range": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "startDate",
            "endDate",
            "granularity"
          ],
          "properties": {
            "startDate": {
              "type": "string",
              "format": "date-time"
            },
            "endDate": {
              "type": "string",
              "format": "date-time"
            },
            "granularity": {
              "type": "string",
              "enum": [
                "day",
                "week",
                "month"
              ]
            },
            "preset": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 24
            }
          }
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "userId"
          ],
          "properties": {
            "userId": {
              "$ref": "../shared/event_common.schema.json#/definitions/documentId"
            }
          }
        },
        "summaryCards": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/metricCard"
          }
        },
        "trend": {
          "type": "array",
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "periodStart",
              "periodEnd",
              "metrics"
            ],
            "properties": {
              "periodStart": {
                "type": "string",
                "format": "date-time"
              },
              "periodEnd": {
                "type": "string",
                "format": "date-time"
              },
              "metrics": {
                "type": "object",
                "additionalProperties": {
                  "type": "number"
                }
              }
            }
          }
        },
        "connectionSummary": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "outgoingLikes",
            "incomingLikes",
            "privateInterestReceived",
            "mutualCatches",
            "chatsStarted",
            "chatMessagesSent",
            "followThroughRate",
            "eventsAttended"
          ],
          "properties": {
            "outgoingLikes": {
              "type": "integer",
              "minimum": 0
            },
            "incomingLikes": {
              "type": "integer",
              "minimum": 0
            },
            "privateInterestReceived": {
              "type": "integer",
              "minimum": 0
            },
            "mutualCatches": {
              "type": "integer",
              "minimum": 0
            },
            "chatsStarted": {
              "type": "integer",
              "minimum": 0
            },
            "chatMessagesSent": {
              "type": "integer",
              "minimum": 0
            },
            "followThroughRate": {
              "type": "number",
              "minimum": 0
            },
            "eventsAttended": {
              "type": "integer",
              "minimum": 0
            }
          }
        },
        "profileSummary": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "profileViews",
            "uniqueViewers",
            "profileDwellSeconds",
            "photoImpressions",
            "topPhotoId",
            "activeMinutes"
          ],
          "properties": {
            "profileViews": {
              "type": "integer",
              "minimum": 0
            },
            "uniqueViewers": {
              "type": "integer",
              "minimum": 0
            },
            "profileDwellSeconds": {
              "type": "integer",
              "minimum": 0
            },
            "photoImpressions": {
              "type": "integer",
              "minimum": 0
            },
            "topPhotoId": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 180
            },
            "activeMinutes": {
              "type": "integer",
              "minimum": 0
            }
          }
        },
        "coachingTipRefs": {
          "type": "array",
          "maxItems": 4,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "id",
              "copyKey",
              "priority",
              "metricIds"
            ],
            "properties": {
              "id": {
                "type": "string",
                "minLength": 1,
                "maxLength": 80
              },
              "copyKey": {
                "type": "string",
                "minLength": 1,
                "maxLength": 80
              },
              "priority": {
                "type": "integer",
                "minimum": 1,
                "maximum": 5
              },
              "metricIds": {
                "type": "array",
                "items": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 80
                }
              }
            }
          }
        },
        "dataQuality": {
          "type": "array",
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "id",
              "state",
              "detail"
            ],
            "properties": {
              "id": {
                "type": "string",
                "minLength": 1,
                "maxLength": 80
              },
              "state": {
                "type": "string",
                "enum": [
                  "ok",
                  "partial",
                  "missing"
                ]
              },
              "detail": {
                "type": "string",
                "minLength": 1,
                "maxLength": 240
              }
            }
          }
        }
      },
      "definitions": {
        "metricCard": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "id",
            "label",
            "value",
            "unit",
            "status"
          ],
          "properties": {
            "id": {
              "type": "string",
              "minLength": 1,
              "maxLength": 80
            },
            "label": {
              "type": "string",
              "minLength": 1,
              "maxLength": 80
            },
            "value": {
              "type": "number"
            },
            "unit": {
              "type": "string",
              "enum": [
                "count",
                "percent",
                "duration_seconds"
              ]
            },
            "status": {
              "type": "string",
              "enum": [
                "ready",
                "partial",
                "missing"
              ]
            },
            "caption": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 160
            }
          }
        }
      }
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminAssignSafetyTriageItem_payload.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminAssignSafetyTriageItem_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminCreateMarketingContentDraft_payload.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminCreateMarketingContentDraft_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminDecideAccessApplication_payload.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminDecideAccessApplication_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminDecideClubClaim_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminDecideOrganizerEventCandidate_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminDecideOrganizerIntake_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminDecideOrganizerPolicyGap_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminDecideSafetyTriageItem_payload.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminDecideSafetyTriageItem_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetAccessApplicationDetails_payload.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetAccessApplicationDetails_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetAdminUserRoles_payload.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetAdminUserRoles_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetClubClaimRequestDetails_payload.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetClubClaimRequestDetails_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetEventDetails_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetEventIntakeDashboard_payload.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetEventIntakeDashboard_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetEventSupplyReadiness_payload.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetEventSupplyReadiness_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetMarketingOpsDashboard_payload.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetMarketingOpsDashboard_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetOrganizerDetails_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetOverview_payload.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetOverview_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetSafetyTriageDetails_payload.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetSafetyTriageDetails_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminListAdminRoleAssignments_payload.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminListAdminRoleAssignments_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminListClubClaimRequests_payload.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminListClubClaimRequests_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminListEventDetails_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminListExternalEventDetails_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminListOrganizerDetails_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminPublishExternalEvent_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminRecordEventIntakeReviewDecision_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminRecordMarketingReviewDecision_payload.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminRecordMarketingReviewDecision_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminRecordOrganizerCuration_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminResolveOrganizerEventLocation_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminSetAdminUserRoles_payload.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminSetAdminUserRoles_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminSetClubIndexStatus_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminUpdateEventDetails_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminUpdateOrganizerDetails_response.schema.json",
      "type": "object",
      "additionalProperties": true
    }
  ],
  "requestSchemaIds": {
    "adminAssignSafetyTriageItem": "https://catch.app/contracts/admin_runtime/adminAssignSafetyTriageItem_payload.schema.json",
    "adminCreateMarketingContentDraft": "https://catch.app/contracts/admin_runtime/adminCreateMarketingContentDraft_payload.schema.json",
    "adminDecideAccessApplication": "https://catch.app/contracts/admin_runtime/adminDecideAccessApplication_payload.schema.json",
    "adminDecideClubClaim": "https://catch.app/contracts/callables/admin_decide_club_claim_payload.schema.json",
    "adminDecideOrganizerEventCandidate": "https://catch.app/contracts/callables/admin_decide_organizer_event_candidate_payload.schema.json",
    "adminDecideOrganizerIntake": "https://catch.app/contracts/callables/admin_decide_organizer_intake_payload.schema.json",
    "adminDecideOrganizerPolicyGap": "https://catch.app/contracts/callables/admin_decide_organizer_policy_gap_payload.schema.json",
    "adminDecideSafetyTriageItem": "https://catch.app/contracts/admin_runtime/adminDecideSafetyTriageItem_payload.schema.json",
    "adminGetAccessApplicationDetails": "https://catch.app/contracts/admin_runtime/adminGetAccessApplicationDetails_payload.schema.json",
    "adminGetAdminUserRoles": "https://catch.app/contracts/admin_runtime/adminGetAdminUserRoles_payload.schema.json",
    "adminGetClubClaimRequestDetails": "https://catch.app/contracts/admin_runtime/adminGetClubClaimRequestDetails_payload.schema.json",
    "adminGetEventDetails": "https://catch.app/contracts/callables/admin_get_event_details_payload.schema.json",
    "adminGetEventIntakeDashboard": "https://catch.app/contracts/admin_runtime/adminGetEventIntakeDashboard_payload.schema.json",
    "adminGetEventSupplyReadiness": "https://catch.app/contracts/admin_runtime/adminGetEventSupplyReadiness_payload.schema.json",
    "adminGetHostAnalytics": "https://catch.app/contracts/callables/host_analytics_query_payload.schema.json",
    "adminGetMarketingOpsDashboard": "https://catch.app/contracts/admin_runtime/adminGetMarketingOpsDashboard_payload.schema.json",
    "adminGetOrganizerDetails": "https://catch.app/contracts/callables/admin_get_organizer_details_payload.schema.json",
    "adminGetOverview": "https://catch.app/contracts/admin_runtime/adminGetOverview_payload.schema.json",
    "adminGetSafetyTriageDetails": "https://catch.app/contracts/admin_runtime/adminGetSafetyTriageDetails_payload.schema.json",
    "adminGetUserAnalytics": "https://catch.app/contracts/callables/user_analytics_query_payload.schema.json",
    "adminListAdminRoleAssignments": "https://catch.app/contracts/admin_runtime/adminListAdminRoleAssignments_payload.schema.json",
    "adminListClubClaimRequests": "https://catch.app/contracts/admin_runtime/adminListClubClaimRequests_payload.schema.json",
    "adminListEventDetails": "https://catch.app/contracts/callables/admin_list_event_details_payload.schema.json",
    "adminListExternalEventDetails": "https://catch.app/contracts/callables/admin_list_external_event_details_payload.schema.json",
    "adminListIntakeOperations": "https://catch.app/contracts/callables/admin_list_intake_operations_payload.schema.json",
    "adminListOrganizerDetails": "https://catch.app/contracts/callables/admin_list_organizer_details_payload.schema.json",
    "adminPublishExternalEvent": "https://catch.app/contracts/callables/admin_publish_external_event_payload.schema.json",
    "adminRecordEventIntakeReviewDecision": "https://catch.app/contracts/callables/admin_record_event_intake_review_decision_payload.schema.json",
    "adminRecordMarketingReviewDecision": "https://catch.app/contracts/admin_runtime/adminRecordMarketingReviewDecision_payload.schema.json",
    "adminRecordOrganizerCuration": "https://catch.app/contracts/callables/admin_record_organizer_curation_payload.schema.json",
    "adminResolveOrganizerEventLocation": "https://catch.app/contracts/callables/admin_resolve_organizer_event_location_payload.schema.json",
    "adminSetAdminUserRoles": "https://catch.app/contracts/admin_runtime/adminSetAdminUserRoles_payload.schema.json",
    "adminSetClubIndexStatus": "https://catch.app/contracts/callables/admin_set_club_index_status_payload.schema.json",
    "adminUpdateEventDetails": "https://catch.app/contracts/callables/admin_update_event_details_payload.schema.json",
    "adminUpdateOrganizerDetails": "https://catch.app/contracts/callables/admin_update_organizer_details_payload.schema.json"
  },
  "responseSchemaIds": {
    "adminAssignSafetyTriageItem": "https://catch.app/contracts/admin_runtime/adminAssignSafetyTriageItem_response.schema.json",
    "adminCreateMarketingContentDraft": "https://catch.app/contracts/admin_runtime/adminCreateMarketingContentDraft_response.schema.json",
    "adminDecideAccessApplication": "https://catch.app/contracts/admin_runtime/adminDecideAccessApplication_response.schema.json",
    "adminDecideClubClaim": "https://catch.app/contracts/admin_runtime/adminDecideClubClaim_response.schema.json",
    "adminDecideOrganizerEventCandidate": "https://catch.app/contracts/admin_runtime/adminDecideOrganizerEventCandidate_response.schema.json",
    "adminDecideOrganizerIntake": "https://catch.app/contracts/admin_runtime/adminDecideOrganizerIntake_response.schema.json",
    "adminDecideOrganizerPolicyGap": "https://catch.app/contracts/admin_runtime/adminDecideOrganizerPolicyGap_response.schema.json",
    "adminDecideSafetyTriageItem": "https://catch.app/contracts/admin_runtime/adminDecideSafetyTriageItem_response.schema.json",
    "adminGetAccessApplicationDetails": "https://catch.app/contracts/admin_runtime/adminGetAccessApplicationDetails_response.schema.json",
    "adminGetAdminUserRoles": "https://catch.app/contracts/admin_runtime/adminGetAdminUserRoles_response.schema.json",
    "adminGetClubClaimRequestDetails": "https://catch.app/contracts/admin_runtime/adminGetClubClaimRequestDetails_response.schema.json",
    "adminGetEventDetails": "https://catch.app/contracts/admin_runtime/adminGetEventDetails_response.schema.json",
    "adminGetEventIntakeDashboard": "https://catch.app/contracts/admin_runtime/adminGetEventIntakeDashboard_response.schema.json",
    "adminGetEventSupplyReadiness": "https://catch.app/contracts/admin_runtime/adminGetEventSupplyReadiness_response.schema.json",
    "adminGetHostAnalytics": "https://catch.app/contracts/callable_responses/host_analytics_response.schema.json",
    "adminGetMarketingOpsDashboard": "https://catch.app/contracts/admin_runtime/adminGetMarketingOpsDashboard_response.schema.json",
    "adminGetOrganizerDetails": "https://catch.app/contracts/admin_runtime/adminGetOrganizerDetails_response.schema.json",
    "adminGetOverview": "https://catch.app/contracts/admin_runtime/adminGetOverview_response.schema.json",
    "adminGetSafetyTriageDetails": "https://catch.app/contracts/admin_runtime/adminGetSafetyTriageDetails_response.schema.json",
    "adminGetUserAnalytics": "https://catch.app/contracts/callable_responses/user_analytics_response.schema.json",
    "adminListAdminRoleAssignments": "https://catch.app/contracts/admin_runtime/adminListAdminRoleAssignments_response.schema.json",
    "adminListClubClaimRequests": "https://catch.app/contracts/admin_runtime/adminListClubClaimRequests_response.schema.json",
    "adminListEventDetails": "https://catch.app/contracts/admin_runtime/adminListEventDetails_response.schema.json",
    "adminListExternalEventDetails": "https://catch.app/contracts/admin_runtime/adminListExternalEventDetails_response.schema.json",
    "adminListIntakeOperations": "https://catch.app/contracts/callable_responses/admin_list_intake_operations_response.schema.json",
    "adminListOrganizerDetails": "https://catch.app/contracts/admin_runtime/adminListOrganizerDetails_response.schema.json",
    "adminPublishExternalEvent": "https://catch.app/contracts/admin_runtime/adminPublishExternalEvent_response.schema.json",
    "adminRecordEventIntakeReviewDecision": "https://catch.app/contracts/admin_runtime/adminRecordEventIntakeReviewDecision_response.schema.json",
    "adminRecordMarketingReviewDecision": "https://catch.app/contracts/admin_runtime/adminRecordMarketingReviewDecision_response.schema.json",
    "adminRecordOrganizerCuration": "https://catch.app/contracts/admin_runtime/adminRecordOrganizerCuration_response.schema.json",
    "adminResolveOrganizerEventLocation": "https://catch.app/contracts/admin_runtime/adminResolveOrganizerEventLocation_response.schema.json",
    "adminSetAdminUserRoles": "https://catch.app/contracts/admin_runtime/adminSetAdminUserRoles_response.schema.json",
    "adminSetClubIndexStatus": "https://catch.app/contracts/admin_runtime/adminSetClubIndexStatus_response.schema.json",
    "adminUpdateEventDetails": "https://catch.app/contracts/admin_runtime/adminUpdateEventDetails_response.schema.json",
    "adminUpdateOrganizerDetails": "https://catch.app/contracts/admin_runtime/adminUpdateOrganizerDetails_response.schema.json"
  },
  "strictRequests": [
    "adminDecideClubClaim",
    "adminDecideOrganizerEventCandidate",
    "adminDecideOrganizerIntake",
    "adminDecideOrganizerPolicyGap",
    "adminGetEventDetails",
    "adminGetHostAnalytics",
    "adminGetOrganizerDetails",
    "adminGetUserAnalytics",
    "adminListEventDetails",
    "adminListExternalEventDetails",
    "adminListIntakeOperations",
    "adminListOrganizerDetails",
    "adminPublishExternalEvent",
    "adminRecordEventIntakeReviewDecision",
    "adminRecordOrganizerCuration",
    "adminResolveOrganizerEventLocation",
    "adminSetClubIndexStatus",
    "adminUpdateEventDetails",
    "adminUpdateOrganizerDetails"
  ],
  "strictResponses": [
    "adminGetHostAnalytics",
    "adminGetUserAnalytics",
    "adminListIntakeOperations"
  ]
} as const;
const ajv = new Ajv({allErrors: true, strict: false, validateSchema: false});
addFormats(ajv);
for (const schema of model.schemas) ajv.addSchema(schema);

function validators(ids: Record<string, string>): Record<string, ValidateFunction> {
  return Object.fromEntries(Object.entries(ids).map(([name, id]) => {
    const validate = ajv.getSchema(id);
    if (!validate) throw new Error(`Missing generated validator for ${name}.`);
    return [name, validate];
  }));
}

const requestValidators = validators(model.requestSchemaIds);
const responseValidators = validators(model.responseSchemaIds);

export const adminCallableValidationCoverage = {
  callables: model.names,
  strictRequests: model.strictRequests,
  strictResponses: model.strictResponses,
} as const;

export class AdminCallableValidationError extends Error {
  constructor(
    readonly callable: string,
    readonly direction: "request" | "response",
    readonly instancePath: string,
    readonly validationErrors: ErrorObject[]
  ) {
    const first = validationErrors[0];
    super(`Invalid ${direction} for ${callable} at ${instancePath}: ${first?.message ?? "schema validation failed"}`);
    this.name = "AdminCallableValidationError";
  }
}

function validate(
  direction: "request" | "response",
  callable: string,
  value: unknown
) {
  const validateFunction = direction === "request" ? requestValidators[callable] : responseValidators[callable];
  if (!validateFunction) {
    throw new AdminCallableValidationError(callable, direction, "/", [{
      instancePath: "", schemaPath: "", keyword: "missing-validator", params: {}, message: "validator is not generated",
    }]);
  }
  if (validateFunction(value)) return;
  const errors = validateFunction.errors ?? [];
  const instancePath = errors[0]?.instancePath || "/";
  throw new AdminCallableValidationError(callable, direction, instancePath, [...errors]);
}

export function validateAdminCallableRequest(callable: string, value: unknown) {
  validate("request", callable, value);
}

export function validateAdminCallableResponse(callable: string, value: unknown) {
  validate("response", callable, value);
}
