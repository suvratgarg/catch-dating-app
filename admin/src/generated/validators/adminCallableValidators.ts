// GENERATED FILE. Run: npm --workspace catch-admin run generate:callable-validators
import Ajv, {type ErrorObject, type ValidateFunction} from "ajv";
import addFormats from "ajv-formats";

const model = {
  "names": [
    "adminAssignSafetyTriageItem",
    "adminCreateMarketingContentDraft",
    "adminCreateOrganizerDraftFromCandidate",
    "adminDecideAccessApplication",
    "adminDecideOrganizerClaim",
    "adminDecideOrganizerEventCandidate",
    "adminDecideOrganizerIntake",
    "adminDecideOrganizerPolicyGap",
    "adminDecideSafetyTriageItem",
    "adminGetAccessApplicationDetails",
    "adminGetAdminUserRoles",
    "adminGetEventDetails",
    "adminGetEventIntakeDashboard",
    "adminGetEventSupplyReadiness",
    "adminGetHostAnalytics",
    "adminGetMarketingOpsDashboard",
    "adminGetOrganizerClaimRequestDetails",
    "adminGetOrganizerDetails",
    "adminGetOverview",
    "adminGetSafetyTriageDetails",
    "adminGetUserAnalytics",
    "adminListActionExecutions",
    "adminListAdminRoleAssignments",
    "adminListCrossPathsShowcaseCandidates",
    "adminListEventDetails",
    "adminListExternalEventDetails",
    "adminListIntakeOperations",
    "adminListOrganizerClaimRequests",
    "adminListOrganizerDetails",
    "adminPublishExternalEvent",
    "adminRecordEventIntakeReviewDecision",
    "adminRecordMarketingReviewDecision",
    "adminRecordOrganizerCuration",
    "adminResolveOrganizerEventLocation",
    "adminSetAdminUserRoles",
    "adminSetCrossPathsShowcaseEligibility",
    "adminSetOrganizerIndexStatus",
    "adminTakedownExternalEvent",
    "adminUpdateEventDetails",
    "adminUpdateOrganizerDetails"
  ],
  "schemas": [
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_assign_safety_triage_item_payload.schema.json",
      "title": "Admin Assign Safety Triage Item Callable Payload",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "targetPath",
        "assigneeUid",
        "note"
      ],
      "properties": {
        "targetPath": {
          "type": "string",
          "maxLength": 260,
          "pattern": "^(reports|moderationFlags|eventSafetyReports)/[^/]+$"
        },
        "assigneeUid": {
          "anyOf": [
            {
              "type": "string",
              "pattern": "^[A-Za-z0-9_-]{3,128}$"
            },
            {
              "type": "null"
            }
          ]
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
      "$id": "https://catch.app/contracts/callables/admin_create_marketing_content_draft_payload.schema.json",
      "title": "Admin Create Marketing Content Draft Callable Payload",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "draftType"
      ],
      "properties": {
        "draftType": {
          "type": "string",
          "enum": [
            "event_highlights",
            "feature_explainer"
          ]
        },
        "cityId": {
          "anyOf": [
            {
              "type": "string",
              "pattern": "^[a-z0-9-]{2,60}$"
            },
            {
              "type": "null"
            }
          ]
        },
        "weekStart": {
          "anyOf": [
            {
              "type": "string",
              "format": "date"
            },
            {
              "type": "null"
            }
          ]
        },
        "sourceRecommendationSetId": {
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
        "title": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 140
            },
            {
              "type": "null"
            }
          ]
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_create_organizer_draft_from_candidate_payload.schema.json",
      "title": "AdminCreateOrganizerDraftFromCandidateCallablePayload",
      "description": "Creates one unclaimed, source-backed organizer draft from an exact reviewed Supply Intake work item. The callable cannot publish, index, expose in the app, enable crawling, or assign ownership.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "workItemId",
        "candidateId",
        "publicSlug",
        "name",
        "organizerType",
        "reviewNote"
      ],
      "properties": {
        "workItemId": {
          "$ref": "../operations/common.schema.json#/definitions/id"
        },
        "candidateId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "publicSlug": {
          "type": "string",
          "minLength": 3,
          "maxLength": 64,
          "pattern": "^[a-z0-9](?:[a-z0-9-]{1,62}[a-z0-9])$",
          "description": "Human-readable public route slug. The callable allocates a separate opaque Firestore organizer document id."
        },
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "organizerType": {
          "$ref": "../shared/event_common.schema.json#/definitions/organizerType"
        },
        "reviewNote": {
          "type": "string",
          "minLength": 10,
          "maxLength": 500
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
        "eventItineraryItem": {
          "type": "object",
          "additionalProperties": false,
          "description": "One public, event-local run-of-show entry. Offset is measured from the event start so rescheduling does not rewrite the itinerary.",
          "required": [
            "id",
            "kind",
            "offsetMinutes",
            "title"
          ],
          "properties": {
            "id": {
              "type": "string",
              "minLength": 1,
              "maxLength": 80,
              "pattern": "^[A-Za-z0-9_-]+$"
            },
            "kind": {
              "type": "string",
              "enum": [
                "gather",
                "activity",
                "stop",
                "break",
                "transition",
                "finish"
              ]
            },
            "offsetMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 1440
            },
            "durationMinutes": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 1,
              "maximum": 1440
            },
            "title": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "description": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 500
            },
            "location": {
              "anyOf": [
                {
                  "$ref": "#/definitions/eventMeetingLocation"
                },
                {
                  "type": "null"
                }
              ]
            },
            "routeDistanceMeters": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 0,
              "maximum": 1000000
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
        "eventSuccessTopology": {
          "type": "string",
          "enum": [
            "set",
            "sequence",
            "adjacency"
          ]
        },
        "eventSuccessResourceLabelId": {
          "type": "string",
          "enum": [
            "court",
            "table",
            "lane",
            "board"
          ]
        },
        "eventSuccessResourceCapacity": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "concurrentUnits",
            "resourceLabelId",
            "seatsPerUnit"
          ],
          "properties": {
            "concurrentUnits": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 1,
              "maximum": 200
            },
            "resourceLabelId": {
              "$ref": "#/definitions/eventSuccessResourceLabelId"
            },
            "seatsPerUnit": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 1,
              "maximum": 1000
            }
          }
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
        "eventSuccessMatchingObjective": {
          "type": "string",
          "enum": [
            "coverage",
            "romantic",
            "affinity",
            "novelty",
            "balance",
            "spread"
          ]
        },
        "eventSuccessUnitOutcome": {
          "type": "string",
          "enum": [
            "none",
            "completion",
            "score",
            "rank"
          ]
        },
        "eventSuccessAccountability": {
          "type": "string",
          "enum": [
            "none",
            "rollCall",
            "sweep"
          ]
        },
        "eventSuccessDurationShape": {
          "type": "string",
          "enum": [
            "continuous",
            "rounds",
            "courses",
            "segments"
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
            },
            "matchingObjective": {
              "$ref": "#/definitions/eventSuccessMatchingObjective"
            },
            "unitOutcome": {
              "$ref": "#/definitions/eventSuccessUnitOutcome"
            },
            "accountability": {
              "$ref": "#/definitions/eventSuccessAccountability"
            },
            "durationShape": {
              "$ref": "#/definitions/eventSuccessDurationShape"
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
            "topology": {
              "$ref": "#/definitions/eventSuccessTopology"
            },
            "resourceCapacity": {
              "anyOf": [
                {
                  "$ref": "#/definitions/eventSuccessResourceCapacity"
                },
                {
                  "type": "null"
                }
              ]
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
          },
          "allOf": [
            {
              "if": {
                "required": [
                  "resourceCapacity"
                ],
                "properties": {
                  "resourceCapacity": {
                    "type": "object",
                    "required": [
                      "seatsPerUnit"
                    ],
                    "properties": {
                      "seatsPerUnit": {
                        "type": "integer"
                      }
                    }
                  }
                }
              },
              "then": {
                "required": [
                  "topology"
                ],
                "properties": {
                  "topology": {
                    "const": "adjacency"
                  }
                }
              }
            }
          ]
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
        "routeEventPlan": {
          "type": "object",
          "description": "Composable operations for an event that moves through a route. Activity kind remains the broader format authority.",
          "additionalProperties": false,
          "required": [
            "version",
            "movementMode",
            "routeShape",
            "groupStrategy",
            "stopCadence",
            "stopKinds",
            "roleKinds"
          ],
          "properties": {
            "version": {
              "type": "integer",
              "enum": [
                1,
                2
              ]
            },
            "movementMode": {
              "type": "string",
              "enum": [
                "run",
                "walk",
                "ride",
                "mixed"
              ]
            },
            "routeShape": {
              "type": "string",
              "enum": [
                "loop",
                "outAndBack",
                "pointToPoint"
              ]
            },
            "groupStrategy": {
              "type": "string",
              "enum": [
                "together",
                "paceGroups",
                "selfDirected"
              ]
            },
            "stopCadence": {
              "type": "string",
              "enum": [
                "continuous",
                "flexibleStops",
                "hostedStops"
              ]
            },
            "stopKinds": {
              "type": "array",
              "minItems": 1,
              "maxItems": 7,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "enum": [
                  "water",
                  "regroup",
                  "venue",
                  "photoSpot",
                  "viewpoint",
                  "hazard",
                  "turnaround"
                ]
              }
            },
            "roleKinds": {
              "type": "array",
              "minItems": 1,
              "maxItems": 6,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "enum": [
                  "routeLead",
                  "sweep",
                  "pacer",
                  "stopHost",
                  "marshal",
                  "photographer"
                ]
              }
            },
            "path": {
              "type": "array",
              "minItems": 2,
              "maxItems": 500,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "latitude",
                  "longitude"
                ],
                "properties": {
                  "latitude": {
                    "$ref": "profile_common.schema.json#/definitions/strictLatitude"
                  },
                  "longitude": {
                    "$ref": "profile_common.schema.json#/definitions/strictLongitude"
                  }
                }
              }
            },
            "paceGroups": {
              "type": "array",
              "maxItems": 12,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "id",
                  "label",
                  "sortOrder"
                ],
                "properties": {
                  "id": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 80,
                    "pattern": "^[A-Za-z0-9_-]+$"
                  },
                  "label": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 80
                  },
                  "targetPaceSecondsPerKm": {
                    "type": [
                      "integer",
                      "null"
                    ],
                    "minimum": 120,
                    "maximum": 1800
                  },
                  "sortOrder": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 1000
                  }
                }
              }
            },
            "liveTrackingPolicy": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "staleAfterSeconds",
                "retentionMinutes"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "enum": [
                    "disabled",
                    "hostOnly",
                    "authorizedOperators"
                  ]
                },
                "staleAfterSeconds": {
                  "type": "integer",
                  "minimum": 30,
                  "maximum": 600
                },
                "retentionMinutes": {
                  "type": "integer",
                  "minimum": 5,
                  "maximum": 1440
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
              "additionalProperties": true,
              "properties": {
                "routePlan": {
                  "$ref": "#/definitions/routeEventPlan"
                }
              }
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
              "enum": [
                1,
                2
              ],
              "description": "Version 2 models cancellation as notApplicable for free events. Version 1 remains readable for legacy snapshots."
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
                },
                "crossPathsPairInventory": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "enabled",
                    "reservedPairCapacity",
                    "holdDurationMinutes"
                  ],
                  "properties": {
                    "enabled": {
                      "type": "boolean"
                    },
                    "reservedPairCapacity": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 100
                    },
                    "holdDurationMinutes": {
                      "type": "integer",
                      "minimum": 5,
                      "maximum": 30
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
                    "notApplicable",
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
          },
          "if": {
            "properties": {
              "version": {
                "const": 2
              },
              "pricing": {
                "properties": {
                  "basePriceInPaise": {
                    "const": 0
                  }
                },
                "required": [
                  "basePriceInPaise"
                ]
              }
            },
            "required": [
              "version",
              "pricing"
            ]
          },
          "then": {
            "properties": {
              "cancellation": {
                "properties": {
                  "policyId": {
                    "const": "notApplicable"
                  }
                }
              }
            }
          },
          "else": {
            "if": {
              "properties": {
                "version": {
                  "const": 2
                }
              },
              "required": [
                "version"
              ]
            },
            "then": {
              "properties": {
                "cancellation": {
                  "properties": {
                    "policyId": {
                      "enum": [
                        "flexible",
                        "standard",
                        "strict"
                      ]
                    }
                  }
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
            "crossPathsPairCapacity": {
              "type": "integer",
              "minimum": 0,
              "maximum": 100
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
            "layoutId": {
              "type": [
                "string",
                "null"
              ],
              "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
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
      "$id": "https://catch.app/contracts/callables/admin_decide_access_application_payload.schema.json",
      "title": "Admin Decide Access Application Callable Payload",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "applicationUid",
        "decision",
        "note"
      ],
      "properties": {
        "applicationUid": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "decision": {
          "type": "string",
          "enum": [
            "approve",
            "deny"
          ]
        },
        "note": {
          "type": "string",
          "minLength": 1,
          "maxLength": 1000
        },
        "cohortId": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            {
              "type": "null"
            }
          ]
        }
      }
    },
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
      "$id": "https://catch.app/contracts/callables/admin_decide_organizer_event_candidate_payload.schema.json",
      "title": "AdminDecideOrganizerEventCandidateCallablePayload",
      "description": "Callable payload accepted by adminDecideOrganizerEventCandidate. This records a manual admin review decision for a private external event candidate without importing the event.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "candidateId",
        "decision",
        "checklist",
        "blockerResolutions",
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
        "blockerResolutions": {
          "type": "array",
          "maxItems": 6,
          "items": {
            "$ref": "../embedded/external_event_blocker_resolution.schema.json"
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
      "$id": "https://catch.app/contracts/embedded/external_event_blocker_resolution.schema.json",
      "title": "ExternalEventBlockerResolution",
      "description": "One explicit, event-scoped resolution or policy-backed waiver for a governed external-event import blocker.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "blockerCode",
        "outcome",
        "policyGapDecisionId",
        "note"
      ],
      "properties": {
        "blockerCode": {
          "type": "string",
          "enum": [
            "missing_exact_coordinates",
            "missing_end_time",
            "missing_location_detail",
            "requires_event_defaults_policy",
            "requires_owner_safe_copy_review",
            "duplicate_normalized_event_key"
          ]
        },
        "outcome": {
          "type": "string",
          "enum": [
            "resolved",
            "waived"
          ]
        },
        "policyGapDecisionId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 180
        },
        "note": {
          "type": "string",
          "minLength": 1,
          "maxLength": 1000
        }
      },
      "allOf": [
        {
          "if": {
            "properties": {
              "outcome": {
                "const": "waived"
              }
            }
          },
          "then": {
            "properties": {
              "policyGapDecisionId": {
                "type": "string"
              }
            }
          }
        },
        {
          "if": {
            "properties": {
              "outcome": {
                "const": "resolved"
              }
            }
          },
          "then": {
            "properties": {
              "policyGapDecisionId": {
                "type": "null"
              }
            }
          }
        }
      ]
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
        "publishStatus",
        "indexStatus",
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
        "publishStatus": {
          "type": "string",
          "enum": [
            "draft",
            "published",
            "suppressed"
          ],
          "description": "Explicit public-web publication switch. Approval does not imply publication."
        },
        "indexStatus": {
          "type": "string",
          "enum": [
            "noindex",
            "indexed"
          ],
          "description": "Explicit search-indexing switch. Indexed requires a published web page."
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
            },
            "claimTargetReviewed": {
              "type": "boolean"
            },
            "takedownPathReviewed": {
              "type": "boolean"
            },
            "impersonationReviewed": {
              "type": "boolean"
            },
            "operatingStatusReviewed": {
              "type": "boolean"
            },
            "eventAccuracyReviewed": {
              "type": "boolean"
            },
            "unclaimedAffordancesReviewed": {
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
      "$id": "https://catch.app/contracts/callables/admin_decide_safety_triage_item_payload.schema.json",
      "title": "Admin Decide Safety Triage Item Callable Payload",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "targetPath",
        "decision",
        "note"
      ],
      "properties": {
        "targetPath": {
          "$ref": "#/definitions/targetPath"
        },
        "decision": {
          "type": "string",
          "enum": [
            "review",
            "dismiss"
          ]
        },
        "note": {
          "type": "string",
          "minLength": 1,
          "maxLength": 1000
        }
      },
      "definitions": {
        "targetPath": {
          "type": "string",
          "maxLength": 260,
          "pattern": "^(reports|moderationFlags|eventSafetyReports)/[^/]+$"
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_get_access_application_details_payload.schema.json",
      "title": "AdminGetAccessApplicationDetailsCallablePayload",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "applicationUid"
      ],
      "properties": {
        "applicationUid": {
          "$ref": "../shared/event_common.schema.json#/definitions/documentId"
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_get_admin_user_roles_payload.schema.json",
      "title": "AdminGetAdminUserRolesCallablePayload",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "targetUid"
      ],
      "properties": {
        "targetUid": {
          "$ref": "../shared/event_common.schema.json#/definitions/documentId"
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
      "$id": "https://catch.app/contracts/callables/admin_get_event_intake_dashboard_payload.schema.json",
      "title": "AdminGetEventIntakeDashboardCallablePayload",
      "type": "object",
      "additionalProperties": false
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_get_event_supply_readiness_payload.schema.json",
      "title": "AdminGetEventSupplyReadinessCallablePayload",
      "type": "object",
      "additionalProperties": false
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_get_marketing_ops_dashboard_payload.schema.json",
      "title": "AdminGetMarketingOpsDashboardCallablePayload",
      "type": "object",
      "additionalProperties": false
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
      "$id": "https://catch.app/contracts/callables/admin_get_overview_payload.schema.json",
      "title": "Admin Get Overview Callable Payload",
      "type": "object",
      "additionalProperties": false
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_get_safety_triage_details_payload.schema.json",
      "title": "AdminGetSafetyTriageDetailsCallablePayload",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "targetPath"
      ],
      "properties": {
        "targetPath": {
          "type": "string",
          "pattern": "^(reports|moderationFlags|eventSafetyReports)/[A-Za-z0-9_-]{1,180}$"
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_list_action_executions_payload.schema.json",
      "title": "AdminListActionExecutionsCallablePayload",
      "type": "object",
      "additionalProperties": false,
      "properties": {
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
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_list_admin_role_assignments_payload.schema.json",
      "title": "AdminListAdminRoleAssignmentsCallablePayload",
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "status": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "active",
            "revoked",
            "all",
            null
          ]
        },
        "limit": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 1,
          "maximum": 100
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_list_cross_paths_showcase_candidates_payload.schema.json",
      "title": "AdminListCrossPathsShowcaseCandidatesCallablePayload",
      "description": "Callable payload for a bounded, role-gated Cross Paths showcase review queue.",
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "uid": {
          "anyOf": [
            {
              "$ref": "../shared/event_common.schema.json#/definitions/documentId"
            },
            {
              "type": "null"
            }
          ]
        },
        "status": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "all",
            "eligible",
            "needsReview",
            "paused",
            null
          ]
        },
        "marketId": {
          "anyOf": [
            {
              "$ref": "../shared/event_common.schema.json#/definitions/marketId"
            },
            {
              "type": "null"
            }
          ]
        },
        "cursor": {
          "anyOf": [
            {
              "$ref": "../shared/event_common.schema.json#/definitions/documentId"
            },
            {
              "type": "null"
            }
          ]
        },
        "limit": {
          "type": "integer",
          "minimum": 1,
          "maximum": 50
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
        "executionMode",
        "idempotencyKey",
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
        "executionMode": {
          "type": "string",
          "enum": [
            "dry_run",
            "apply"
          ]
        },
        "idempotencyKey": {
          "type": "string",
          "minLength": 8,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9:_-]+$"
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
          "description": "Changed fields only. Each entry freezes the reviewed before and after values so extractor-learning and audit consumers can distinguish a correction from a whole-record resubmission.",
          "maxProperties": 40,
          "additionalProperties": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "before",
              "after"
            ],
            "properties": {
              "before": {},
              "after": {}
            }
          }
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
      "$id": "https://catch.app/contracts/callables/admin_record_marketing_review_decision_payload.schema.json",
      "title": "Admin Record Marketing Review Decision Callable Payload",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "targetType",
        "targetId",
        "decision",
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
            "event_candidate",
            "recommendation_item",
            "recommendation_set",
            "content_draft"
          ]
        },
        "targetId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 500
        },
        "decision": {
          "type": "string",
          "enum": [
            "approve",
            "needs_changes",
            "hold",
            "reject",
            "export_ready"
          ]
        },
        "runId": {
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
          "$ref": "#/definitions/checklist"
        }
      },
      "definitions": {
        "checklist": {
          "type": "object",
          "additionalProperties": false,
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
      "description": "Callable payload accepted by adminRecordOrganizerCuration. This records one durable low-volume manual organizer-intake curation operation in Firestore.",
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
      "$id": "https://catch.app/contracts/callables/admin_set_admin_user_roles_payload.schema.json",
      "title": "Admin Set Admin User Roles Callable Payload",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "targetUid",
        "roles",
        "note"
      ],
      "properties": {
        "targetUid": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "roles": {
          "type": "array",
          "uniqueItems": true,
          "items": {
            "$ref": "#/definitions/adminRole"
          }
        },
        "note": {
          "type": "string",
          "minLength": 1,
          "maxLength": 1000
        }
      },
      "definitions": {
        "adminRole": {
          "type": "string",
          "enum": [
            "admin",
            "adminOwner",
            "safetyReviewer",
            "support",
            "finance",
            "analyticsViewer"
          ]
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_set_cross_paths_showcase_eligibility_payload.schema.json",
      "title": "AdminSetCrossPathsShowcaseEligibilityCallablePayload",
      "description": "Callable payload for an audited human Cross Paths showcase eligibility decision.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "uid",
        "status",
        "reviewChecklist",
        "reviewNote"
      ],
      "properties": {
        "uid": {
          "$ref": "../shared/event_common.schema.json#/definitions/documentId"
        },
        "status": {
          "type": "string",
          "enum": [
            "eligible",
            "needsReview",
            "paused"
          ]
        },
        "reviewChecklist": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "primaryPortraitClear",
            "profileRepresentsCurrentMember",
            "showcasePolicyReviewed"
          ],
          "properties": {
            "primaryPortraitClear": {
              "type": "boolean"
            },
            "profileRepresentsCurrentMember": {
              "type": "boolean"
            },
            "showcasePolicyReviewed": {
              "type": "boolean"
            }
          }
        },
        "reviewNote": {
          "type": "string",
          "minLength": 1,
          "maxLength": 1000
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_takedown_external_event_payload.schema.json",
      "title": "AdminTakedownExternalEventCallablePayload",
      "description": "Callable payload accepted by adminTakedownExternalEvent. Dry-run validates and receipts a reviewed takedown; apply removes the external event from discovery without deleting audit history.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "eventId",
        "executionMode",
        "idempotencyKey",
        "reviewNote",
        "checklist"
      ],
      "properties": {
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9_-]+$"
        },
        "executionMode": {
          "type": "string",
          "enum": [
            "dry_run",
            "apply"
          ]
        },
        "idempotencyKey": {
          "type": "string",
          "minLength": 8,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9:_-]+$"
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
            "sourceStatusReviewed",
            "takedownAuthorityReviewed",
            "downstreamVisibilityReviewed"
          ],
          "properties": {
            "sourceStatusReviewed": {
              "type": "boolean"
            },
            "takedownAuthorityReviewed": {
              "type": "boolean"
            },
            "downstreamVisibilityReviewed": {
              "type": "boolean"
            }
          }
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
            "crossPathsDiscoveryEnabled": {
              "type": "boolean"
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
      "$id": "https://catch.app/contracts/callables/admin_list_club_claim_requests_payload.schema.json",
      "title": "AdminListClubClaimRequestsCallablePayload",
      "type": "object",
      "additionalProperties": false
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callables/admin_get_club_claim_request_details_payload.schema.json",
      "title": "AdminGetClubClaimRequestDetailsCallablePayload",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId"
      ],
      "properties": {
        "requestId": {
          "$ref": "../shared/event_common.schema.json#/definitions/documentId"
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
      "$id": "https://catch.app/contracts/callable_responses/admin_assign_safety_triage_item_response.schema.json",
      "title": "Admin Assign Safety Triage Item Callable Response",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "targetPath",
        "assignment"
      ],
      "properties": {
        "targetPath": {
          "type": "string",
          "maxLength": 260,
          "pattern": "^(reports|moderationFlags|eventSafetyReports)/[^/]+$"
        },
        "assignment": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "ownerTeam",
            "assigneeUid",
            "queue",
            "severity"
          ],
          "properties": {
            "ownerTeam": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "assigneeUid": {
              "anyOf": [
                {
                  "type": "string",
                  "pattern": "^[A-Za-z0-9_-]{3,128}$"
                },
                {
                  "type": "null"
                }
              ]
            },
            "queue": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "severity": {
              "type": "string",
              "enum": [
                "high",
                "medium",
                "watch"
              ]
            }
          }
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callable_responses/admin_create_marketing_content_draft_response.schema.json",
      "title": "Admin Create Marketing Content Draft Callable Response",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "draft",
        "bridge",
        "dashboardPath"
      ],
      "properties": {
        "draft": {
          "type": "object",
          "minProperties": 1,
          "additionalProperties": true
        },
        "bridge": {
          "type": "object",
          "minProperties": 1,
          "additionalProperties": true
        },
        "dashboardPath": {
          "type": "string",
          "minLength": 1,
          "maxLength": 260
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callable_responses/admin_create_organizer_draft_from_candidate_response.schema.json",
      "title": "AdminCreateOrganizerDraftFromCandidateCallableResponse",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "organizerId",
        "organizerPath",
        "curationPath",
        "created",
        "appVisibility",
        "ownershipState",
        "claimState",
        "publishStatus",
        "indexStatus",
        "crawlStatus"
      ],
      "properties": {
        "organizerId": {
          "type": "string",
          "minLength": 3,
          "maxLength": 64
        },
        "organizerPath": {
          "type": "string",
          "pattern": "^organizers/[^/]+$"
        },
        "curationPath": {
          "type": "string",
          "pattern": "^organizerIntakeCurationDecisions/[^/]+$"
        },
        "created": {
          "type": "boolean"
        },
        "appVisibility": {
          "const": "hidden"
        },
        "ownershipState": {
          "const": "programmatic"
        },
        "claimState": {
          "const": "unclaimed"
        },
        "publishStatus": {
          "const": "draft"
        },
        "indexStatus": {
          "const": "noindex"
        },
        "crawlStatus": {
          "const": "disabled"
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callable_responses/admin_decide_access_application_response.schema.json",
      "title": "Admin Decide Access Application Callable Response",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "applicationUid",
        "decision",
        "status"
      ],
      "properties": {
        "applicationUid": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "decision": {
          "type": "string",
          "enum": [
            "approve",
            "deny"
          ]
        },
        "status": {
          "type": "string",
          "enum": [
            "approvedForProfile",
            "notSelectedYet"
          ]
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callable_responses/admin_decide_safety_triage_item_response.schema.json",
      "title": "Admin Decide Safety Triage Item Callable Response",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "targetPath",
        "decision",
        "status"
      ],
      "properties": {
        "targetPath": {
          "type": "string",
          "maxLength": 260,
          "pattern": "^(reports|moderationFlags|eventSafetyReports)/[^/]+$"
        },
        "decision": {
          "type": "string",
          "enum": [
            "review",
            "dismiss"
          ]
        },
        "status": {
          "type": "string",
          "enum": [
            "reviewed",
            "dismissed"
          ]
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callable_responses/admin_get_overview_response.schema.json",
      "title": "Admin Get Overview Callable Response",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "generatedAt",
        "timezone",
        "metrics",
        "queues",
        "dataQuality"
      ],
      "properties": {
        "generatedAt": {
          "type": "string",
          "format": "date-time"
        },
        "timezone": {
          "const": "UTC"
        },
        "metrics": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/metric"
          }
        },
        "queues": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "safetyReports",
            "moderationFlags",
            "eventSafetyReports",
            "accessApplications",
            "clubClaimRequests",
            "clubIndexReviews",
            "paymentIssues"
          ],
          "properties": {
            "safetyReports": {
              "$ref": "#/definitions/queue"
            },
            "moderationFlags": {
              "$ref": "#/definitions/queue"
            },
            "eventSafetyReports": {
              "$ref": "#/definitions/queue"
            },
            "accessApplications": {
              "$ref": "#/definitions/queue"
            },
            "clubClaimRequests": {
              "$ref": "#/definitions/queue"
            },
            "clubIndexReviews": {
              "$ref": "#/definitions/queue"
            },
            "paymentIssues": {
              "$ref": "#/definitions/queue"
            }
          }
        },
        "dataQuality": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/dataQuality"
          }
        }
      },
      "definitions": {
        "metric": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "id",
            "label",
            "value"
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
              "maxLength": 160
            },
            "value": {
              "type": "number"
            },
            "unit": {
              "type": "string",
              "minLength": 1,
              "maxLength": 80
            }
          }
        },
        "queue": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/queueItem"
          }
        },
        "queueItem": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "id",
            "title",
            "detail",
            "status",
            "createdAt",
            "targetPath"
          ],
          "properties": {
            "id": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "title": {
              "type": "string",
              "minLength": 1,
              "maxLength": 240
            },
            "detail": {
              "type": "string",
              "maxLength": 1000
            },
            "status": {
              "type": "string",
              "minLength": 1,
              "maxLength": 80
            },
            "createdAt": {
              "anyOf": [
                {
                  "type": "string",
                  "format": "date-time"
                },
                {
                  "type": "null"
                }
              ]
            },
            "targetPath": {
              "type": "string",
              "minLength": 3,
              "maxLength": 260
            }
          }
        },
        "dataQuality": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "id",
            "label",
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
              "maxLength": 120
            },
            "label": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            },
            "state": {
              "type": "string",
              "enum": [
                "ok",
                "warning",
                "blocked"
              ]
            },
            "detail": {
              "type": "string",
              "maxLength": 1000
            },
            "owner": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            },
            "runbook": {
              "type": "string",
              "minLength": 1,
              "maxLength": 260
            },
            "nextAction": {
              "type": "string",
              "minLength": 1,
              "maxLength": 1000
            }
          }
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callable_responses/admin_list_action_executions_response.schema.json",
      "title": "AdminListActionExecutionsCallableResponse",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "generatedAt",
        "rows",
        "nextCursor"
      ],
      "properties": {
        "schemaVersion": {
          "const": 1
        },
        "generatedAt": {
          "type": "string",
          "format": "date-time"
        },
        "rows": {
          "type": "array",
          "maxItems": 100,
          "items": {
            "$ref": "#/definitions/execution"
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
        "execution": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "schemaVersion",
            "executionId",
            "actionId",
            "callable",
            "actorUid",
            "actorRoles",
            "status",
            "requestHash",
            "responseHash",
            "target",
            "errorCode",
            "errorMessage",
            "cliVersion",
            "startedAt",
            "finishedAt",
            "updatedAt"
          ],
          "properties": {
            "schemaVersion": {
              "const": 1
            },
            "executionId": {
              "type": "string",
              "pattern": "^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"
            },
            "actionId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "callable": {
              "type": "string",
              "pattern": "^admin[A-Z][A-Za-z0-9]+$"
            },
            "actorUid": {
              "type": "string",
              "minLength": 1,
              "maxLength": 128
            },
            "actorRoles": {
              "type": "array",
              "uniqueItems": true,
              "items": {
                "enum": [
                  "admin",
                  "adminOwner",
                  "safetyReviewer",
                  "support",
                  "finance",
                  "analyticsViewer"
                ]
              }
            },
            "status": {
              "enum": [
                "started",
                "succeeded",
                "failed",
                "indeterminate"
              ]
            },
            "requestHash": {
              "type": "string",
              "pattern": "^[0-9a-f]{64}$"
            },
            "responseHash": {
              "type": [
                "string",
                "null"
              ],
              "pattern": "^[0-9a-f]{64}$"
            },
            "target": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 500
            },
            "errorCode": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 120
            },
            "errorMessage": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 500
            },
            "cliVersion": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 80
            },
            "startedAt": {
              "type": "string",
              "format": "date-time"
            },
            "finishedAt": {
              "type": [
                "string",
                "null"
              ],
              "format": "date-time"
            },
            "updatedAt": {
              "type": "string",
              "format": "date-time"
            }
          }
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callable_responses/admin_list_cross_paths_showcase_candidates_response.schema.json",
      "title": "AdminListCrossPathsShowcaseCandidatesCallableResponse",
      "description": "Bounded admin-safe projection of public profiles and their server-only Cross Paths showcase review state.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "generatedAt",
        "candidates",
        "nextCursor"
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
        "candidates": {
          "type": "array",
          "maxItems": 50,
          "items": {
            "$ref": "#/definitions/candidate"
          }
        },
        "nextCursor": {
          "anyOf": [
            {
              "$ref": "../shared/event_common.schema.json#/definitions/documentId"
            },
            {
              "type": "null"
            }
          ]
        }
      },
      "definitions": {
        "reasonCode": {
          "type": "string",
          "enum": [
            "insufficient_photos",
            "incomplete_prompts",
            "missing_relationship_goal",
            "broken_media",
            "photo_moderation_pending",
            "photo_moderation_rejected",
            "public_profile_missing",
            "profile_changed",
            "reviewer_hold",
            "manual_pause"
          ]
        },
        "candidate": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "uid",
            "name",
            "age",
            "gender",
            "city",
            "photoUrls",
            "promptAnswers",
            "relationshipGoal",
            "automaticStatus",
            "automaticReasonCodes",
            "storedStatus",
            "effectiveStatus",
            "effectiveReasonCodes",
            "profileFingerprint",
            "reviewedByUid",
            "reviewedAt",
            "reviewNote"
          ],
          "properties": {
            "uid": {
              "$ref": "../shared/event_common.schema.json#/definitions/documentId"
            },
            "name": {
              "type": [
                "string",
                "null"
              ],
              "minLength": 1,
              "maxLength": 80
            },
            "age": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 18,
              "maximum": 99
            },
            "gender": {
              "type": [
                "string",
                "null"
              ],
              "minLength": 1,
              "maxLength": 40
            },
            "city": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 80
            },
            "photoUrls": {
              "type": "array",
              "maxItems": 6,
              "items": {
                "type": "string",
                "format": "uri",
                "maxLength": 2048
              }
            },
            "promptAnswers": {
              "type": "array",
              "maxItems": 3,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "prompt",
                  "answer"
                ],
                "properties": {
                  "prompt": {
                    "type": "string",
                    "maxLength": 140
                  },
                  "answer": {
                    "type": "string",
                    "maxLength": 300
                  }
                }
              }
            },
            "relationshipGoal": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 80
            },
            "automaticStatus": {
              "type": "string",
              "enum": [
                "ready",
                "blocked"
              ]
            },
            "automaticReasonCodes": {
              "type": "array",
              "maxItems": 7,
              "uniqueItems": true,
              "items": {
                "$ref": "#/definitions/reasonCode"
              }
            },
            "storedStatus": {
              "type": [
                "string",
                "null"
              ],
              "enum": [
                "eligible",
                "needsReview",
                "paused",
                null
              ]
            },
            "effectiveStatus": {
              "type": "string",
              "enum": [
                "eligible",
                "needsReview",
                "paused"
              ]
            },
            "effectiveReasonCodes": {
              "type": "array",
              "maxItems": 12,
              "uniqueItems": true,
              "items": {
                "$ref": "#/definitions/reasonCode"
              }
            },
            "profileFingerprint": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "reviewedByUid": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 128
            },
            "reviewedAt": {
              "type": [
                "string",
                "null"
              ],
              "format": "date-time"
            },
            "reviewNote": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 1000
            }
          }
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
        "organizerDraftLinks",
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
        "organizerDraftLinks": {
          "type": "array",
          "maxItems": 200,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "workItemId",
              "candidateId",
              "organizerId",
              "curationPath"
            ],
            "properties": {
              "workItemId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 200
              },
              "candidateId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 200
              },
              "organizerId": {
                "type": "string",
                "minLength": 3,
                "maxLength": 64,
                "pattern": "^[a-z0-9]+(?:-[a-z0-9]+)*$"
              },
              "curationPath": {
                "type": "string",
                "pattern": "^organizerIntakeCurationDecisions/[A-Za-z0-9_-]+$",
                "maxLength": 300
              }
            }
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
      "$id": "https://catch.app/contracts/operations/work_item.schema.json",
      "title": "OperationWorkItem",
      "description": "One exclusively staged unit of work. Task flags are orthogonal and may overlap.",
      "type": "object",
      "additionalProperties": false,
      "allOf": [
        {
          "if": {
            "properties": {
              "normalizedPayload": {
                "type": "object",
                "required": [
                  "kind"
                ],
                "properties": {
                  "kind": {
                    "const": "liveSourceWake"
                  }
                }
              }
            }
          },
          "then": {
            "properties": {
              "workflowId": {
                "const": "event-assistance"
              },
              "entityKind": {
                "const": "source_signal"
              },
              "normalizedPayload": {
                "$ref": "event_assistance_source_work.schema.json"
              }
            }
          }
        },
        {
          "if": {
            "properties": {
              "normalizedPayload": {
                "type": "object",
                "required": [
                  "kind"
                ],
                "properties": {
                  "kind": {
                    "const": "liveLateJoin"
                  }
                }
              }
            }
          },
          "then": {
            "properties": {
              "workflowId": {
                "const": "event-assistance"
              },
              "entityKind": {
                "const": "guest_episode"
              },
              "normalizedPayload": {
                "$ref": "event_assistance_live_work.schema.json"
              }
            }
          }
        },
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
        },
        {
          "if": {
            "properties": {
              "normalizedPayload": {
                "type": "object",
                "required": [
                  "intake"
                ],
                "properties": {
                  "intake": {
                    "type": "object",
                    "required": [
                      "recordType"
                    ],
                    "properties": {
                      "recordType": {
                        "const": "organizer_publication_packet"
                      }
                    }
                  }
                }
              }
            }
          },
          "then": {
            "properties": {
              "normalizedPayload": {
                "properties": {
                  "intake": {
                    "$ref": "#/definitions/organizerPublicationPacketIntake"
                  }
                }
              }
            }
          }
        },
        {
          "if": {
            "properties": {
              "normalizedPayload": {
                "type": "object",
                "required": [
                  "intake"
                ],
                "properties": {
                  "intake": {
                    "type": "object",
                    "required": [
                      "recordType"
                    ],
                    "properties": {
                      "recordType": {
                        "const": "supply_freshness_coverage"
                      }
                    }
                  }
                }
              }
            }
          },
          "then": {
            "properties": {
              "normalizedPayload": {
                "properties": {
                  "intake": {
                    "$ref": "#/definitions/supplyFreshnessCoverageIntake"
                  }
                }
              }
            }
          }
        },
        {
          "if": {
            "properties": {
              "normalizedPayload": {
                "type": "object",
                "required": [
                  "intake"
                ],
                "properties": {
                  "intake": {
                    "type": "object",
                    "required": [
                      "recordType"
                    ],
                    "properties": {
                      "recordType": {
                        "const": "orphan_event_candidate"
                      }
                    }
                  }
                }
              }
            }
          },
          "then": {
            "properties": {
              "entityKind": {
                "const": "event"
              },
              "lifecycleStatus": {
                "not": {
                  "const": "published"
                }
              },
              "blockerCodes": {
                "contains": {
                  "const": "organizer_not_in_inventory"
                }
              },
              "normalizedPayload": {
                "properties": {
                  "intake": {
                    "$ref": "#/definitions/orphanEventCandidateIntake"
                  }
                }
              }
            }
          }
        },
        {
          "if": {
            "properties": {
              "normalizedPayload": {
                "type": "object",
                "required": [
                  "intake"
                ],
                "properties": {
                  "intake": {
                    "type": "object",
                    "required": [
                      "recordType"
                    ],
                    "properties": {
                      "recordType": {
                        "const": "event_candidate"
                      }
                    }
                  }
                }
              }
            }
          },
          "then": {
            "properties": {
              "entityKind": {
                "const": "event"
              },
              "normalizedPayload": {
                "properties": {
                  "intake": {
                    "$ref": "#/definitions/eventCandidateIntake"
                  }
                }
              }
            }
          }
        },
        {
          "if": {
            "properties": {
              "normalizedPayload": {
                "type": "object",
                "required": [
                  "intake"
                ],
                "properties": {
                  "intake": {
                    "type": "object",
                    "required": [
                      "recordType"
                    ],
                    "properties": {
                      "recordType": {
                        "const": "event_source_result"
                      }
                    }
                  }
                }
              }
            }
          },
          "then": {
            "properties": {
              "entityKind": {
                "const": "source_result"
              },
              "normalizedPayload": {
                "properties": {
                  "intake": {
                    "$ref": "#/definitions/eventSourceResultIntake"
                  }
                }
              }
            }
          }
        },
        {
          "if": {
            "properties": {
              "normalizedPayload": {
                "type": "object",
                "required": [
                  "intake"
                ],
                "properties": {
                  "intake": {
                    "type": "object",
                    "required": [
                      "recordType"
                    ],
                    "properties": {
                      "recordType": {
                        "const": "event_source_profile"
                      }
                    }
                  }
                }
              }
            }
          },
          "then": {
            "properties": {
              "entityKind": {
                "const": "source_profile"
              },
              "normalizedPayload": {
                "properties": {
                  "intake": {
                    "$ref": "#/definitions/eventSourceProfileIntake"
                  }
                }
              }
            }
          }
        }
      ],
      "definitions": {
        "boundedString": {
          "type": "string",
          "minLength": 1,
          "maxLength": 500
        },
        "boundedStringArray": {
          "type": "array",
          "maxItems": 40,
          "items": {
            "$ref": "#/definitions/boundedString"
          }
        },
        "eventCandidateIntake": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "recordType",
            "candidate"
          ],
          "properties": {
            "recordType": {
              "const": "event_candidate"
            },
            "candidate": {
              "type": "object",
              "additionalProperties": true,
              "required": [
                "id",
                "title",
                "startDate",
                "sourceResultIds",
                "reviewState",
                "requiresVerification",
                "warnings",
                "blockerCodes",
                "publicationEligibility"
              ],
              "properties": {
                "id": {
                  "$ref": "#/definitions/boundedString"
                },
                "title": {
                  "$ref": "#/definitions/boundedString"
                },
                "startDate": {
                  "type": "string",
                  "maxLength": 40
                },
                "sourceResultIds": {
                  "type": "array",
                  "maxItems": 40,
                  "items": {
                    "$ref": "#/definitions/boundedString"
                  }
                },
                "reviewState": {
                  "$ref": "#/definitions/boundedString"
                },
                "requiresVerification": {
                  "type": "boolean"
                },
                "warnings": {
                  "$ref": "#/definitions/boundedStringArray"
                },
                "blockerCodes": {
                  "$ref": "#/definitions/boundedStringArray"
                },
                "publicationEligibility": {
                  "const": "review_gated"
                }
              }
            }
          }
        },
        "eventSourceResultIntake": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "recordType",
            "result"
          ],
          "properties": {
            "recordType": {
              "const": "event_source_result"
            },
            "result": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "id",
                "sourceProfileId",
                "sourceLabel",
                "queryTemplateId",
                "resultType",
                "title",
                "url",
                "snippet",
                "observedAt",
                "status",
                "riskFlags",
                "operatorNotes"
              ],
              "properties": {
                "id": {
                  "$ref": "#/definitions/boundedString"
                },
                "sourceProfileId": {
                  "$ref": "#/definitions/boundedString"
                },
                "sourceLabel": {
                  "$ref": "#/definitions/boundedString"
                },
                "queryTemplateId": {
                  "$ref": "#/definitions/boundedString"
                },
                "resultType": {
                  "$ref": "#/definitions/boundedString"
                },
                "title": {
                  "$ref": "#/definitions/boundedString"
                },
                "url": {
                  "type": "string",
                  "maxLength": 2000
                },
                "snippet": {
                  "type": "string",
                  "maxLength": 1000
                },
                "observedAt": {
                  "type": "string",
                  "maxLength": 80
                },
                "status": {
                  "$ref": "#/definitions/boundedString"
                },
                "riskFlags": {
                  "$ref": "#/definitions/boundedStringArray"
                },
                "operatorNotes": {
                  "type": "string",
                  "maxLength": 1000
                }
              }
            }
          }
        },
        "eventSourceProfileIntake": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "recordType",
            "profile"
          ],
          "properties": {
            "recordType": {
              "const": "event_source_profile"
            },
            "profile": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "id",
                "label",
                "type",
                "status",
                "cadence",
                "riskLevel",
                "allowedUse",
                "items"
              ],
              "properties": {
                "id": {
                  "$ref": "#/definitions/boundedString"
                },
                "label": {
                  "$ref": "#/definitions/boundedString"
                },
                "type": {
                  "$ref": "#/definitions/boundedString"
                },
                "status": {
                  "$ref": "#/definitions/boundedString"
                },
                "cadence": {
                  "$ref": "#/definitions/boundedString"
                },
                "riskLevel": {
                  "type": "string",
                  "enum": [
                    "low",
                    "medium",
                    "high"
                  ]
                },
                "allowedUse": {
                  "$ref": "#/definitions/boundedString"
                },
                "items": {
                  "type": "array",
                  "maxItems": 40,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "label",
                      "url"
                    ],
                    "properties": {
                      "label": {
                        "$ref": "#/definitions/boundedString"
                      },
                      "url": {
                        "type": "string",
                        "maxLength": 2000
                      }
                    }
                  }
                }
              }
            }
          }
        },
        "orphanEventCandidateIntake": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "recordType",
            "candidate"
          ],
          "properties": {
            "recordType": {
              "const": "orphan_event_candidate"
            },
            "candidate": {
              "type": "object",
              "additionalProperties": true,
              "required": [
                "id",
                "candidateId",
                "publicationEligibility",
                "blockerCodes",
                "attribution"
              ],
              "properties": {
                "id": {
                  "$ref": "#/definitions/boundedString"
                },
                "candidateId": {
                  "$ref": "#/definitions/boundedString"
                },
                "publicationEligibility": {
                  "const": "blocked_orphan"
                },
                "blockerCodes": {
                  "type": "array",
                  "maxItems": 40,
                  "contains": {
                    "const": "organizer_not_in_inventory"
                  },
                  "items": {
                    "$ref": "#/definitions/boundedString"
                  }
                },
                "attribution": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "state",
                    "organizerEvidence",
                    "match"
                  ],
                  "properties": {
                    "state": {
                      "const": "orphan"
                    },
                    "organizerEvidence": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "name",
                        "url"
                      ],
                      "properties": {
                        "name": {
                          "anyOf": [
                            {
                              "$ref": "#/definitions/boundedString"
                            },
                            {
                              "type": "null"
                            }
                          ]
                        },
                        "url": {
                          "anyOf": [
                            {
                              "$ref": "#/definitions/boundedString"
                            },
                            {
                              "type": "null"
                            }
                          ]
                        }
                      }
                    },
                    "match": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "decision",
                        "policyId",
                        "threshold",
                        "rationale",
                        "matchedEntityId",
                        "score",
                        "matchingSignals",
                        "blockingKeys"
                      ],
                      "properties": {
                        "decision": {
                          "$ref": "#/definitions/boundedString"
                        },
                        "policyId": {
                          "$ref": "#/definitions/boundedString"
                        },
                        "threshold": {
                          "type": "number",
                          "minimum": 0,
                          "maximum": 1
                        },
                        "rationale": {
                          "$ref": "#/definitions/boundedString"
                        },
                        "matchedEntityId": {
                          "type": "null"
                        },
                        "score": {
                          "type": "number",
                          "minimum": 0,
                          "maximum": 1
                        },
                        "matchingSignals": {
                          "$ref": "#/definitions/boundedStringArray"
                        },
                        "blockingKeys": {
                          "$ref": "#/definitions/boundedStringArray"
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        },
        "supplyFreshnessCoverageIntake": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "recordType",
            "coverage"
          ],
          "properties": {
            "recordType": {
              "const": "supply_freshness_coverage"
            },
            "coverage": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "schemaVersion",
                "recordType",
                "coverageId",
                "runId",
                "kind",
                "scopeKey",
                "runKey",
                "market",
                "sourceProfileId",
                "entityId",
                "surfaceId",
                "schedulerStatus",
                "surfacePolicy",
                "fetchEnabled",
                "completedAt",
                "policyVersion",
                "requestHash"
              ],
              "properties": {
                "schemaVersion": {
                  "type": "integer",
                  "const": 1
                },
                "recordType": {
                  "const": "supply_freshness_coverage"
                },
                "coverageId": {
                  "$ref": "common.schema.json#/definitions/id"
                },
                "runId": {
                  "$ref": "common.schema.json#/definitions/id"
                },
                "kind": {
                  "type": "string",
                  "enum": [
                    "city_discovery_sweep",
                    "candidate_verification",
                    "known_organizer_event_refresh",
                    "event_detail_prepublication"
                  ]
                },
                "scopeKey": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 500
                },
                "runKey": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 500
                },
                "market": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 80
                },
                "sourceProfileId": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 160
                },
                "entityId": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 200
                },
                "surfaceId": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 200
                },
                "schedulerStatus": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 40
                },
                "surfacePolicy": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 80
                },
                "fetchEnabled": {
                  "type": "boolean"
                },
                "completedAt": {
                  "$ref": "common.schema.json#/definitions/isoDateTime"
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 120
                },
                "requestHash": {
                  "$ref": "common.schema.json#/definitions/sha256"
                }
              }
            }
          }
        },
        "organizerPublicationPacketIntake": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "recordType",
            "packet"
          ],
          "properties": {
            "recordType": {
              "const": "organizer_publication_packet"
            },
            "packet": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "packetId",
                "entityId",
                "canonicalHostId",
                "displayName",
                "status",
                "priority",
                "markets",
                "blockers",
                "dataBlockers",
                "evidenceBlockers",
                "approvalChecklist",
                "evidenceSummary",
                "publicPresence",
                "adminDecision",
                "nextActions"
              ],
              "properties": {
                "packetId": {
                  "$ref": "#/definitions/boundedString"
                },
                "entityId": {
                  "$ref": "#/definitions/boundedString"
                },
                "canonicalHostId": {
                  "$ref": "#/definitions/boundedString"
                },
                "displayName": {
                  "$ref": "#/definitions/boundedString"
                },
                "status": {
                  "$ref": "#/definitions/boundedString"
                },
                "priority": {
                  "$ref": "#/definitions/boundedString"
                },
                "markets": {
                  "type": "array",
                  "maxItems": 8,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "slug",
                      "displayName"
                    ],
                    "properties": {
                      "slug": {
                        "$ref": "#/definitions/boundedString"
                      },
                      "displayName": {
                        "$ref": "#/definitions/boundedString"
                      }
                    }
                  }
                },
                "blockers": {
                  "$ref": "#/definitions/boundedStringArray"
                },
                "dataBlockers": {
                  "$ref": "#/definitions/boundedStringArray"
                },
                "evidenceBlockers": {
                  "$ref": "#/definitions/boundedStringArray"
                },
                "approvalChecklist": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "crawlDisabledReviewed",
                    "identityReviewed",
                    "marketScopeReviewed",
                    "mediaRightsReviewed",
                    "ownerSafeCopyReviewed",
                    "surfaceInventoryReviewed"
                  ],
                  "properties": {
                    "crawlDisabledReviewed": {
                      "type": "boolean"
                    },
                    "identityReviewed": {
                      "type": "boolean"
                    },
                    "marketScopeReviewed": {
                      "type": "boolean"
                    },
                    "mediaRightsReviewed": {
                      "type": "boolean"
                    },
                    "ownerSafeCopyReviewed": {
                      "type": "boolean"
                    },
                    "surfaceInventoryReviewed": {
                      "type": "boolean"
                    }
                  }
                },
                "evidenceSummary": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "records",
                    "manualReportsWithoutArtifacts",
                    "unresolvedLocalRefs",
                    "missingSurfaceEvidence",
                    "rawProviderArtifactRefs",
                    "firestoreForbiddenArtifactRefs",
                    "riskFlags"
                  ],
                  "properties": {
                    "records": {
                      "type": "integer",
                      "minimum": 0
                    },
                    "manualReportsWithoutArtifacts": {
                      "type": "integer",
                      "minimum": 0
                    },
                    "unresolvedLocalRefs": {
                      "type": "integer",
                      "minimum": 0
                    },
                    "missingSurfaceEvidence": {
                      "type": "integer",
                      "minimum": 0
                    },
                    "rawProviderArtifactRefs": {
                      "type": "integer",
                      "minimum": 0
                    },
                    "firestoreForbiddenArtifactRefs": {
                      "type": "integer",
                      "minimum": 0
                    },
                    "riskFlags": {
                      "type": "array",
                      "maxItems": 12,
                      "items": {
                        "$ref": "#/definitions/boundedString"
                      }
                    }
                  }
                },
                "publicPresence": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "canonicalPath",
                    "claimTargetPath",
                    "publishStatus",
                    "indexStatus",
                    "appVisibility",
                    "projectionStatus"
                  ],
                  "properties": {
                    "canonicalPath": {
                      "anyOf": [
                        {
                          "$ref": "#/definitions/boundedString"
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "claimTargetPath": {
                      "anyOf": [
                        {
                          "$ref": "#/definitions/boundedString"
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "publishStatus": {
                      "$ref": "#/definitions/boundedString"
                    },
                    "indexStatus": {
                      "$ref": "#/definitions/boundedString"
                    },
                    "appVisibility": {
                      "$ref": "#/definitions/boundedString"
                    },
                    "projectionStatus": {
                      "$ref": "#/definitions/boundedString"
                    }
                  }
                },
                "adminDecision": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "allowedDecisions",
                    "defaultAppVisibility",
                    "currentDecision"
                  ],
                  "properties": {
                    "allowedDecisions": {
                      "$ref": "#/definitions/boundedStringArray"
                    },
                    "defaultAppVisibility": {
                      "$ref": "#/definitions/boundedString"
                    },
                    "currentDecision": {
                      "anyOf": [
                        {
                          "type": "null"
                        },
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "decision",
                            "publishStatus",
                            "indexStatus",
                            "decidedAt",
                            "appVisibility"
                          ],
                          "properties": {
                            "decision": {
                              "$ref": "#/definitions/boundedString"
                            },
                            "publishStatus": {
                              "$ref": "#/definitions/boundedString"
                            },
                            "indexStatus": {
                              "$ref": "#/definitions/boundedString"
                            },
                            "decidedAt": {
                              "$ref": "#/definitions/boundedString"
                            },
                            "appVisibility": {
                              "$ref": "#/definitions/boundedString"
                            }
                          }
                        }
                      ]
                    }
                  }
                },
                "nextActions": {
                  "type": "array",
                  "maxItems": 12,
                  "items": {
                    "$ref": "#/definitions/boundedString"
                  }
                }
              }
            }
          }
        }
      },
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
      "$id": "https://catch.app/contracts/operations/event_assistance_source_work.schema.json",
      "title": "EventAssistanceSourceWork",
      "description": "Private bounded source-change fanout using Operations work items. Waking work grants no domain or provider authority.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "kind",
        "signalId",
        "source",
        "scope",
        "expiresAt",
        "checkpoint"
      ],
      "properties": {
        "schemaVersion": {
          "const": 1,
          "type": "integer"
        },
        "kind": {
          "const": "liveSourceWake",
          "type": "string"
        },
        "signalId": {
          "$ref": "common.schema.json#/definitions/id"
        },
        "source": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "eventId",
            "collection",
            "documentId",
            "occurredAt"
          ],
          "properties": {
            "eventId": {
              "$ref": "common.schema.json#/definitions/id"
            },
            "collection": {
              "type": "string",
              "enum": [
                "events",
                "eventAttendees",
                "eventSuccessPlans",
                "eventAssistanceGuests",
                "eventAssistanceSettings",
                "eventAssistanceGroupProgress",
                "eventAssistanceMemberships",
                "eventAssistanceMessages"
              ]
            },
            "documentId": {
              "$ref": "common.schema.json#/definitions/id"
            },
            "occurredAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          }
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "context",
            "attendeeId"
          ],
          "properties": {
            "context": {
              "$ref": "../shared/event_assistance_guest.schema.json#/definitions/liveContext"
            },
            "attendeeId": {
              "anyOf": [
                {
                  "$ref": "common.schema.json#/definitions/id"
                },
                {
                  "type": "null"
                }
              ]
            }
          }
        },
        "expiresAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "checkpoint": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "phase",
            "cursor",
            "visited",
            "dueAt",
            "failures",
            "retries"
          ],
          "properties": {
            "phase": {
              "type": "string",
              "enum": [
                "scan",
                "retry",
                "complete",
                "review",
                "expired"
              ]
            },
            "cursor": {
              "anyOf": [
                {
                  "$ref": "common.schema.json#/definitions/id"
                },
                {
                  "type": "null"
                }
              ]
            },
            "visited": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10000
            },
            "dueAt": {
              "anyOf": [
                {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                {
                  "type": "null"
                }
              ]
            },
            "failures": {
              "type": "array",
              "maxItems": 100,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "workItemId",
                  "reason"
                ],
                "properties": {
                  "workItemId": {
                    "$ref": "common.schema.json#/definitions/id"
                  },
                  "reason": {
                    "type": "string",
                    "enum": [
                      "busy",
                      "unavailable"
                    ]
                  }
                }
              }
            },
            "retries": {
              "type": "integer",
              "minimum": 0,
              "maximum": 5
            }
          }
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/shared/event_assistance_guest.schema.json",
      "title": "EventAssistanceGuestContracts",
      "definitions": {
        "id": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "millis": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "liveContext": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "mode",
            "eventId",
            "organizerId"
          ],
          "properties": {
            "mode": {
              "type": "string",
              "const": "live"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "organizerId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            }
          }
        },
        "workflow": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "occurrenceId"
          ],
          "properties": {
            "kind": {
              "$ref": "event_assistance_common.schema.json#/definitions/workflowKind"
            },
            "occurrenceId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
            }
          }
        },
        "Guest": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "schemaVersion",
            "guestId",
            "context",
            "attendeeId",
            "attendeeGeneration",
            "episodeId",
            "revision",
            "lifecycle",
            "intention",
            "createdAt",
            "updatedAt",
            "sourceGeneration",
            "participation"
          ],
          "properties": {
            "schemaVersion": {
              "const": 1
            },
            "guestId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "context": {
              "$ref": "#/definitions/liveContext"
            },
            "attendeeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "attendeeGeneration": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "episodeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "revision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "lifecycle": {
              "enum": [
                "active",
                "closed"
              ]
            },
            "intention": {
              "$ref": "event_assistance_common.schema.json#/definitions/JoinIntent"
            },
            "createdAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "updatedAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "sourceGeneration": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "participation": {
              "$ref": "event_assistance_common.schema.json#/definitions/Participation"
            }
          }
        },
        "Thread": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "schemaVersion",
            "threadId",
            "guestId",
            "context",
            "attendeeId",
            "episodeId",
            "workflow",
            "messageId",
            "revision",
            "createdAt",
            "updatedAt"
          ],
          "properties": {
            "schemaVersion": {
              "const": 1
            },
            "threadId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "guestId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "context": {
              "$ref": "#/definitions/liveContext"
            },
            "attendeeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "episodeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "workflow": {
              "$ref": "#/definitions/workflow"
            },
            "messageId": {
              "type": "string",
              "pattern": "^outbox:[a-f0-9]{64}$"
            },
            "revision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "createdAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "updatedAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          }
        },
        "Grant": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "schemaVersion",
            "linkId",
            "threadId",
            "guestId",
            "context",
            "attendeeId",
            "episodeId",
            "tokenHash",
            "signingKeyId",
            "issuedAt",
            "expiresAt",
            "revokedAt"
          ],
          "properties": {
            "schemaVersion": {
              "const": 1
            },
            "linkId": {
              "type": "string",
              "pattern": "^[a-f0-9]{32}$"
            },
            "threadId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "guestId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "context": {
              "$ref": "#/definitions/liveContext"
            },
            "attendeeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "episodeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "tokenHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "signingKeyId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "issuedAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "expiresAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "revokedAt": {
              "anyOf": [
                {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                {
                  "type": "null"
                }
              ]
            }
          }
        },
        "Case": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "schemaVersion",
                "caseId",
                "guestId",
                "context",
                "attendeeId",
                "episodeId",
                "responseId",
                "messageId",
                "status",
                "receivedAt",
                "category",
                "owner"
              ],
              "properties": {
                "schemaVersion": {
                  "const": 1
                },
                "caseId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "guestId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "context": {
                  "$ref": "#/definitions/liveContext"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "responseId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "messageId": {
                  "type": "string",
                  "pattern": "^outbox:[a-f0-9]{64}$"
                },
                "status": {
                  "enum": [
                    "open",
                    "resolved"
                  ]
                },
                "receivedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "category": {
                  "enum": [
                    "eventLogistics",
                    "accessibility",
                    "other"
                  ]
                },
                "owner": {
                  "const": "eventLead"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "schemaVersion",
                "caseId",
                "guestId",
                "context",
                "attendeeId",
                "episodeId",
                "responseId",
                "messageId",
                "status",
                "receivedAt",
                "category",
                "owner"
              ],
              "properties": {
                "schemaVersion": {
                  "const": 1
                },
                "caseId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "guestId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "context": {
                  "$ref": "#/definitions/liveContext"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "responseId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "messageId": {
                  "type": "string",
                  "pattern": "^outbox:[a-f0-9]{64}$"
                },
                "status": {
                  "enum": [
                    "open",
                    "resolved"
                  ]
                },
                "receivedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "category": {
                  "enum": [
                    "comfortSafety"
                  ]
                },
                "owner": {
                  "const": "authorizedSafetyOperator"
                }
              }
            }
          ]
        },
        "GuestView": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "status",
                "serverTime",
                "reason"
              ],
              "properties": {
                "status": {
                  "const": "unavailable"
                },
                "serverTime": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "reason": {
                  "enum": [
                    "expired",
                    "eventClosed",
                    "guestUnavailable",
                    "noInstructions",
                    "alreadyJoined"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "status",
                "serverTime",
                "eventTitle",
                "guestRevision",
                "intentId",
                "intentRevision",
                "instructionRevision",
                "title",
                "text",
                "expiresAt",
                "response",
                "choices"
              ],
              "properties": {
                "status": {
                  "const": "ready"
                },
                "serverTime": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "eventTitle": {
                  "type": "string",
                  "maxLength": 160
                },
                "guestRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "intentId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "intentRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "instructionRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "title": {
                  "type": "string",
                  "maxLength": 120
                },
                "text": {
                  "type": "string",
                  "maxLength": 2000
                },
                "expiresAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "response": {
                  "anyOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "label",
                        "receivedAt"
                      ],
                      "properties": {
                        "label": {
                          "type": "string",
                          "maxLength": 80
                        },
                        "receivedAt": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        }
                      }
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "choices": {
                  "type": "array",
                  "maxItems": 20,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "choiceId",
                      "label"
                    ],
                    "properties": {
                      "choiceId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160,
                        "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
          ]
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/shared/event_assistance_common.schema.json",
      "title": "Event assistance shared definitions",
      "definitions": {
        "workflowKind": {
          "type": "string",
          "enum": [
            "venueReadiness",
            "routeReadiness",
            "formatReadiness",
            "rosterReadiness",
            "requiredGuestData",
            "resourceReadiness",
            "staffingReadiness",
            "messagingReadiness",
            "admissionReview",
            "financialReadiness",
            "joiningInstructions",
            "identityResolution",
            "guestAdmission",
            "guestCheckIn",
            "lateJoin",
            "participationChange",
            "guestPrerequisite",
            "allocationRepair",
            "placementConfirmation",
            "resourceRecovery",
            "fairParticipation",
            "roundPublication",
            "unitProgress",
            "outcomeRecording",
            "programmeRecovery",
            "departure",
            "checkpoint",
            "groupTransfer",
            "routeRecovery",
            "locationFreshness",
            "accountability",
            "planChangeCommunication",
            "deliveryRecovery",
            "replyOwnership",
            "guestAssistance",
            "comfortSafety",
            "attendanceSync",
            "concurrencyRecovery",
            "operationRecovery",
            "contextBoundary",
            "overrideReview",
            "eventClosure",
            "attendanceReconciliation",
            "financialReconciliation",
            "postEventFollowUp",
            "eventLearning"
          ],
          "x-catch-catalog": "../catalogs/event_assistance_workflows.json"
        },
        "Scope": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "event"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "attendeeId",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guest"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "groupId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "group"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "resourceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resource"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "eventId",
                "unitId",
                "round"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unit"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "round": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10000
                }
              }
            }
          ]
        },
        "ExecutionContext": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "eventId",
                "organizerId"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "live"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "organizerId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "rehearsalId",
                "virtualEventId",
                "clockId"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "rehearsal"
                },
                "rehearsalId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "virtualEventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "clockId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                }
              }
            }
          ]
        },
        "JoiningTarget": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "placeId",
                "lateEntry"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "fixedPlace"
                },
                "placeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "lateEntry": {
                  "type": "string",
                  "enum": [
                    "allowed",
                    "hostDecision",
                    "closed"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "itineraryId",
                "stopId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "itineraryStop"
                },
                "itineraryId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "stopId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "routeId",
                "groupId",
                "checkpointId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "groupCheckpoint"
                },
                "routeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "checkpointId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                }
              }
            }
          ]
        },
        "JoinDestination": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "placeId",
                "lateEntry"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "fixedPlace"
                },
                "placeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "lateEntry": {
                  "type": "string",
                  "enum": [
                    "allowed",
                    "hostDecision",
                    "closed"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "itineraryId",
                "permittedStopIds"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "itineraryStop"
                },
                "itineraryId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "permittedStopIds": {
                  "type": "array",
                  "minItems": 1,
                  "maxItems": 1000,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 2000
                  },
                  "uniqueItems": true
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "routeId",
                "groupId",
                "permittedCheckpointIds"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "groupCheckpoint"
                },
                "routeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "permittedCheckpointIds": {
                  "type": "array",
                  "minItems": 1,
                  "maxItems": 1000,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 2000
                  },
                  "uniqueItems": true
                }
              }
            }
          ]
        },
        "JoinIntent": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unknown"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "claimedEta"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "onMyWay"
                },
                "claimedEta": {
                  "anyOf": [
                    {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "UTC milliseconds."
                    },
                    {
                      "type": "null",
                      "const": null
                    }
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "target"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "joinLater"
                },
                "target": {
                  "$ref": "#/definitions/JoiningTarget"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "notComing"
                }
              }
            }
          ]
        },
        "JoiningGuidance": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "revision",
            "destination",
            "materialKey",
            "text",
            "validUntil"
          ],
          "properties": {
            "revision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991,
              "description": "Nonnegative safe integer revision."
            },
            "destination": {
              "$ref": "#/definitions/JoiningTarget"
            },
            "materialKey": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            },
            "text": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            },
            "validUntil": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991,
              "description": "UTC milliseconds."
            }
          }
        },
        "PolicySetting": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "authority",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "enabled"
                },
                "authority": {
                  "type": "string",
                  "enum": [
                    "observe",
                    "prepare",
                    "executeWithinPolicy"
                  ]
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "reason"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "disabled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "hostChoice",
                    "organizerDefault"
                  ]
                }
              }
            }
          ]
        },
        "Signal": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "groupId",
                "progressRevision"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "departureConfirmed"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "progressRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "Nonnegative safe integer revision."
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "attendeeId",
                "guidance"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "guidanceChanged"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "guidance": {
                  "$ref": "#/definitions/JoiningGuidance"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "attendeeId",
                "checkedIn",
                "attendanceRevision",
                "episodeId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "attendanceChanged"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "checkedIn": {
                  "type": "boolean"
                },
                "attendanceRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "Nonnegative safe integer revision."
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "attendeeId",
                "intent"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "joinIntentChanged"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "intent": {
                  "$ref": "#/definitions/JoinIntent"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "deliveryId",
                "outcome"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "deliveryChanged"
                },
                "deliveryId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "outcome": {
                  "type": "string",
                  "enum": [
                    "accepted",
                    "delivered",
                    "definiteFailure",
                    "unknown"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "instanceId",
                "deadlineKind"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "deadlineReached"
                },
                "instanceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "deadlineKind": {
                  "type": "string",
                  "enum": [
                    "response",
                    "joiningCutoff",
                    "deliveryExpiry"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "attendeeId",
                "from",
                "to"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "groupTransferred"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "from": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "to": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "resourceId",
                "revision"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resourceChanged"
                },
                "resourceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "revision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "Nonnegative safe integer revision."
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "revision"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "programmeChanged"
                },
                "revision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "Nonnegative safe integer revision."
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "unitId",
                "revision"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "outcomeChanged"
                },
                "unitId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "revision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "Nonnegative safe integer revision."
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "groupId",
                "revision"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "accountabilityReported"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "revision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "Nonnegative safe integer revision."
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "requirement",
                "revision"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "requirementsChanged"
                },
                "requirement": {
                  "$ref": "#/definitions/Requirement"
                },
                "revision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "Nonnegative safe integer revision."
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "policyVersion"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "policyChanged"
                },
                "policyVersion": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "attendeeId",
                "caseId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "assistanceRequested"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "caseId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "disposition"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "eventClosed"
                },
                "disposition": {
                  "type": "string",
                  "enum": [
                    "completed",
                    "aborted"
                  ]
                }
              }
            }
          ]
        },
        "Requirement": {
          "type": "string",
          "enum": [
            "meetingPlace",
            "route",
            "format",
            "roster",
            "guestData",
            "resources",
            "responsibilities",
            "messaging",
            "paymentProvider"
          ]
        },
        "LateJoinEvaluation": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "reason"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resolved"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "joined",
                    "declined"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "reason"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "cancelled"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "eventClosed",
                    "notAdmitted",
                    "policyDisabled",
                    "participationInactive"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "reason"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "expired"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "cutoff",
                    "lateEntryClosed"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "reason"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "wait"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "departureUnconfirmed",
                    "attendanceUnknown",
                    "guidanceUnavailable",
                    "throttled",
                    "unchanged",
                    "participationUnknown"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "reason",
                "guidance"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "hostDecision"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "unreachable",
                    "entryDecision",
                    "missingInformation"
                  ]
                },
                "guidance": {
                  "anyOf": [
                    {
                      "$ref": "#/definitions/JoiningGuidance"
                    },
                    {
                      "type": "null",
                      "const": null
                    }
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "guidance",
                "messageKey",
                "shouldSend",
                "nextEvaluationAt"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "update"
                },
                "guidance": {
                  "$ref": "#/definitions/JoiningGuidance"
                },
                "messageKey": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "shouldSend": {
                  "type": "boolean"
                },
                "nextEvaluationAt": {
                  "anyOf": [
                    {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    {
                      "type": "null"
                    }
                  ]
                }
              }
            }
          ]
        },
        "RequirementPolicy_meetingPlace": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requirement",
            "dueBeforeStartMinutes",
            "disposition"
          ],
          "properties": {
            "requirement": {
              "type": "string",
              "const": "meetingPlace"
            },
            "dueBeforeStartMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "disposition": {
              "type": "string",
              "enum": [
                "blockSelectedOperation",
                "hostMayAcceptException"
              ]
            }
          }
        },
        "venueReadinessConfig": {
          "$ref": "#/definitions/RequirementPolicy_meetingPlace"
        },
        "RequirementPolicy_route": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requirement",
            "dueBeforeStartMinutes",
            "disposition"
          ],
          "properties": {
            "requirement": {
              "type": "string",
              "const": "route"
            },
            "dueBeforeStartMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "disposition": {
              "type": "string",
              "enum": [
                "blockSelectedOperation",
                "hostMayAcceptException"
              ]
            }
          }
        },
        "routeReadinessConfig": {
          "$ref": "#/definitions/RequirementPolicy_route"
        },
        "RequirementPolicy_format": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requirement",
            "dueBeforeStartMinutes",
            "disposition"
          ],
          "properties": {
            "requirement": {
              "type": "string",
              "const": "format"
            },
            "dueBeforeStartMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "disposition": {
              "type": "string",
              "enum": [
                "blockSelectedOperation",
                "hostMayAcceptException"
              ]
            }
          }
        },
        "formatReadinessConfig": {
          "$ref": "#/definitions/RequirementPolicy_format"
        },
        "RequirementPolicy_roster": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requirement",
            "dueBeforeStartMinutes",
            "disposition"
          ],
          "properties": {
            "requirement": {
              "type": "string",
              "const": "roster"
            },
            "dueBeforeStartMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "disposition": {
              "type": "string",
              "enum": [
                "blockSelectedOperation",
                "hostMayAcceptException"
              ]
            }
          }
        },
        "rosterReadinessConfig": {
          "$ref": "#/definitions/RequirementPolicy_roster"
        },
        "RequirementPolicy_guestData": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requirement",
            "dueBeforeStartMinutes",
            "disposition"
          ],
          "properties": {
            "requirement": {
              "type": "string",
              "const": "guestData"
            },
            "dueBeforeStartMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "disposition": {
              "type": "string",
              "enum": [
                "blockSelectedOperation",
                "hostMayAcceptException"
              ]
            }
          }
        },
        "requiredGuestDataConfig": {
          "$ref": "#/definitions/RequirementPolicy_guestData"
        },
        "RequirementPolicy_resources": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requirement",
            "dueBeforeStartMinutes",
            "disposition"
          ],
          "properties": {
            "requirement": {
              "type": "string",
              "const": "resources"
            },
            "dueBeforeStartMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "disposition": {
              "type": "string",
              "enum": [
                "blockSelectedOperation",
                "hostMayAcceptException"
              ]
            }
          }
        },
        "resourceReadinessConfig": {
          "$ref": "#/definitions/RequirementPolicy_resources"
        },
        "RequirementPolicy_responsibilities": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requirement",
            "dueBeforeStartMinutes",
            "disposition"
          ],
          "properties": {
            "requirement": {
              "type": "string",
              "const": "responsibilities"
            },
            "dueBeforeStartMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "disposition": {
              "type": "string",
              "enum": [
                "blockSelectedOperation",
                "hostMayAcceptException"
              ]
            }
          }
        },
        "staffingReadinessConfig": {
          "$ref": "#/definitions/RequirementPolicy_responsibilities"
        },
        "RequirementPolicy_messaging": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requirement",
            "dueBeforeStartMinutes",
            "disposition"
          ],
          "properties": {
            "requirement": {
              "type": "string",
              "const": "messaging"
            },
            "dueBeforeStartMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "disposition": {
              "type": "string",
              "enum": [
                "blockSelectedOperation",
                "hostMayAcceptException"
              ]
            }
          }
        },
        "messagingReadinessConfig": {
          "$ref": "#/definitions/RequirementPolicy_messaging"
        },
        "admissionReviewConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "offerExpiryMinutes",
            "admission",
            "releaseCapacity"
          ],
          "properties": {
            "offerExpiryMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "admission": {
              "type": "string",
              "const": "existingEntitlementPolicy"
            },
            "releaseCapacity": {
              "type": "string",
              "const": "confirmedOnly"
            }
          }
        },
        "RequirementPolicy_paymentProvider": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requirement",
            "dueBeforeStartMinutes",
            "disposition"
          ],
          "properties": {
            "requirement": {
              "type": "string",
              "const": "paymentProvider"
            },
            "dueBeforeStartMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "disposition": {
              "type": "string",
              "enum": [
                "blockSelectedOperation",
                "hostMayAcceptException"
              ]
            }
          }
        },
        "financialReadinessConfig": {
          "$ref": "#/definitions/RequirementPolicy_paymentProvider"
        },
        "NoticePolicy": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "templateIntent",
            "audience",
            "maximumPerGuest",
            "expiryMinutes"
          ],
          "properties": {
            "templateIntent": {
              "type": "string",
              "enum": [
                "joining",
                "planChange",
                "followUp"
              ]
            },
            "audience": {
              "type": "string",
              "const": "affectedGuests"
            },
            "maximumPerGuest": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "expiryMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            }
          }
        },
        "joiningInstructionsConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "templateIntent",
            "audience",
            "maximumPerGuest",
            "expiryMinutes"
          ],
          "properties": {
            "templateIntent": {
              "type": "string",
              "const": "joining"
            },
            "audience": {
              "type": "string",
              "const": "affectedGuests"
            },
            "maximumPerGuest": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "expiryMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            }
          }
        },
        "identityResolutionConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "ambiguousIdentity",
            "fallback"
          ],
          "properties": {
            "ambiguousIdentity": {
              "type": "string",
              "const": "humanResolution"
            },
            "fallback": {
              "type": "string",
              "const": "hostAssistedOperationalOnly"
            }
          }
        },
        "guestAdmissionConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "admission",
            "overCapacity",
            "exception"
          ],
          "properties": {
            "admission": {
              "type": "string",
              "const": "existingEntitlementPolicy"
            },
            "overCapacity": {
              "type": "string",
              "const": "deny"
            },
            "exception": {
              "type": "string",
              "const": "authorizedHost"
            }
          }
        },
        "guestCheckInConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "operation",
            "conflict",
            "attendanceProof"
          ],
          "properties": {
            "operation": {
              "type": "string",
              "const": "absolute"
            },
            "conflict": {
              "type": "string",
              "const": "revisionFence"
            },
            "attendanceProof": {
              "type": "string",
              "const": "configuredEventPolicy"
            }
          }
        },
        "LateJoinPolicy": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "destination",
            "cutoff",
            "maxMessagesPerEpisode",
            "minimumMinutesBetweenMessages",
            "updateOn",
            "unanswered"
          ],
          "properties": {
            "destination": {
              "$ref": "#/definitions/JoinDestination"
            },
            "cutoff": {
              "anyOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "eventEnd"
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "at"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "time"
                    },
                    "at": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "UTC milliseconds."
                    }
                  }
                }
              ]
            },
            "maxMessagesPerEpisode": {
              "type": "integer",
              "minimum": 0,
              "maximum": 100
            },
            "minimumMinutesBetweenMessages": {
              "type": "integer",
              "minimum": 0,
              "maximum": 1440
            },
            "updateOn": {
              "type": "string",
              "const": "materialGuidanceChange"
            },
            "unanswered": {
              "type": "string",
              "enum": [
                "keepUnknownUntilCutoff",
                "hostReviewAtDeadline"
              ]
            }
          }
        },
        "lateJoinConfig": {
          "$ref": "#/definitions/LateJoinPolicy"
        },
        "participationChangeConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "eligibility",
            "reentry",
            "guestOptOut"
          ],
          "properties": {
            "eligibility": {
              "type": "string",
              "const": "explicitParticipation"
            },
            "reentry": {
              "type": "string",
              "const": "newEpisode"
            },
            "guestOptOut": {
              "type": "string",
              "const": "honor"
            }
          }
        },
        "guestPrerequisiteConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "requirementsFrom",
            "fallback"
          ],
          "properties": {
            "requirementsFrom": {
              "type": "string",
              "const": "selectedCapabilities"
            },
            "fallback": {
              "type": "string",
              "const": "explicitlySupportedOnly"
            }
          }
        },
        "AssignmentPolicy": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "scope",
            "publication",
            "preserveCompleted",
            "hardConstraints"
          ],
          "properties": {
            "scope": {
              "type": "string",
              "const": "futureOnly"
            },
            "publication": {
              "type": "string",
              "const": "hostConfirmed"
            },
            "preserveCompleted": {
              "type": "boolean",
              "const": true
            },
            "hardConstraints": {
              "type": "string",
              "const": "neverRelax"
            }
          }
        },
        "allocationRepairConfig": {
          "$ref": "#/definitions/AssignmentPolicy"
        },
        "placementConfirmationConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "observation",
            "assignmentIsNotObservation"
          ],
          "properties": {
            "observation": {
              "type": "string",
              "const": "explicitHost"
            },
            "assignmentIsNotObservation": {
              "type": "boolean",
              "const": true
            }
          }
        },
        "resourceRecoveryConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "scope",
            "publication",
            "preserveCompleted",
            "hardConstraints",
            "resourceChange"
          ],
          "properties": {
            "scope": {
              "type": "string",
              "const": "futureOnly"
            },
            "publication": {
              "type": "string",
              "const": "hostConfirmed"
            },
            "preserveCompleted": {
              "type": "boolean",
              "const": true
            },
            "hardConstraints": {
              "type": "string",
              "const": "neverRelax"
            },
            "resourceChange": {
              "type": "string",
              "const": "hostConfirmed"
            }
          }
        },
        "fairParticipationConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "objective",
            "hardConstraints",
            "publication"
          ],
          "properties": {
            "objective": {
              "type": "string",
              "const": "minimizeRepeatedExclusion"
            },
            "hardConstraints": {
              "type": "string",
              "const": "neverRelax"
            },
            "publication": {
              "type": "string",
              "const": "hostConfirmed"
            }
          }
        },
        "roundPublicationConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "futureDrafts",
            "publication",
            "publishedHistory"
          ],
          "properties": {
            "futureDrafts": {
              "type": "string",
              "const": "private"
            },
            "publication": {
              "type": "string",
              "const": "hostConfirmed"
            },
            "publishedHistory": {
              "type": "string",
              "const": "immutableWithCorrections"
            }
          }
        },
        "unitProgressConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "clock",
            "progress",
            "completedResults"
          ],
          "properties": {
            "clock": {
              "type": "string",
              "const": "perUnit"
            },
            "progress": {
              "type": "string",
              "const": "hostConfirmed"
            },
            "completedResults": {
              "type": "string",
              "const": "preserve"
            }
          }
        },
        "outcomeRecordingConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "correction",
            "publication"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "enum": [
                "completion",
                "score",
                "rank"
              ]
            },
            "correction": {
              "type": "string",
              "const": "revisionedFullRound"
            },
            "publication": {
              "type": "string",
              "const": "existingRevealGate"
            }
          }
        },
        "ProgrammePolicy": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "scope",
            "publication",
            "alreadyPublished"
          ],
          "properties": {
            "scope": {
              "type": "string",
              "const": "remainingProgramme"
            },
            "publication": {
              "type": "string",
              "const": "hostConfirmed"
            },
            "alreadyPublished": {
              "type": "string",
              "const": "correctExplicitly"
            }
          }
        },
        "programmeRecoveryConfig": {
          "$ref": "#/definitions/ProgrammePolicy"
        },
        "departureConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "confirmation",
            "scope",
            "plannedTimeIsNotProof"
          ],
          "properties": {
            "confirmation": {
              "type": "string",
              "const": "responsibleOperator"
            },
            "scope": {
              "type": "string",
              "const": "perMovingGroup"
            },
            "plannedTimeIsNotProof": {
              "type": "boolean",
              "const": true
            }
          }
        },
        "checkpointConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "reportBy",
            "scope",
            "reportDeadlineMinutes"
          ],
          "properties": {
            "reportBy": {
              "type": "string",
              "const": "responsibleOperator"
            },
            "scope": {
              "type": "string",
              "const": "departureRoster"
            },
            "reportDeadlineMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            }
          }
        },
        "groupTransferConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "handover",
            "membership"
          ],
          "properties": {
            "handover": {
              "type": "string",
              "const": "receivingOperatorAcknowledges"
            },
            "membership": {
              "type": "string",
              "const": "singleActiveGroup"
            }
          }
        },
        "routeRecoveryConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "scope",
            "publication",
            "alreadyPublished",
            "alternative"
          ],
          "properties": {
            "scope": {
              "type": "string",
              "const": "remainingProgramme"
            },
            "publication": {
              "type": "string",
              "const": "hostConfirmed"
            },
            "alreadyPublished": {
              "type": "string",
              "const": "correctExplicitly"
            },
            "alternative": {
              "type": "string",
              "const": "hostApproved"
            }
          }
        },
        "locationFreshnessConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "staleAfterSeconds",
            "fallback",
            "tracking"
          ],
          "properties": {
            "staleAfterSeconds": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "fallback": {
              "type": "string",
              "const": "confirmedJoiningPoint"
            },
            "tracking": {
              "type": "string",
              "const": "authorizedOperatorOnly"
            }
          }
        },
        "accountabilityConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "mode",
            "evidence",
            "unknownIsNotIncident"
          ],
          "properties": {
            "mode": {
              "type": "string",
              "enum": [
                "rollCall",
                "sweep"
              ]
            },
            "evidence": {
              "type": "string",
              "const": "explicitDisposition"
            },
            "unknownIsNotIncident": {
              "type": "boolean",
              "const": true
            }
          }
        },
        "planChangeCommunicationConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "templateIntent",
            "audience",
            "maximumPerGuest",
            "expiryMinutes"
          ],
          "properties": {
            "templateIntent": {
              "type": "string",
              "const": "planChange"
            },
            "audience": {
              "type": "string",
              "const": "affectedGuests"
            },
            "maximumPerGuest": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "expiryMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            }
          }
        },
        "RecoveryPolicy": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "maximumAttempts",
            "onUnknown",
            "expiresAfterMinutes"
          ],
          "properties": {
            "maximumAttempts": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "onUnknown": {
              "type": "string",
              "const": "reconcileBeforeRetry"
            },
            "expiresAfterMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            }
          }
        },
        "deliveryRecoveryConfig": {
          "$ref": "#/definitions/RecoveryPolicy"
        },
        "HumanCasePolicy": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "owner",
            "visibility",
            "dueMinutes"
          ],
          "properties": {
            "owner": {
              "type": "string",
              "enum": [
                "eventLead",
                "groupLead",
                "sweep",
                "checkIn",
                "specialist"
              ]
            },
            "visibility": {
              "type": "string",
              "enum": [
                "operational",
                "restricted"
              ]
            },
            "dueMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            }
          }
        },
        "replyOwnershipConfig": {
          "$ref": "#/definitions/HumanCasePolicy"
        },
        "guestAssistanceConfig": {
          "$ref": "#/definitions/HumanCasePolicy"
        },
        "comfortSafetyConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "owner",
            "visibility",
            "dueMinutes"
          ],
          "properties": {
            "owner": {
              "type": "string",
              "enum": [
                "eventLead",
                "groupLead",
                "sweep",
                "checkIn",
                "specialist"
              ]
            },
            "visibility": {
              "type": "string",
              "const": "restricted"
            },
            "dueMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            }
          }
        },
        "attendanceSyncConfig": {
          "$ref": "#/definitions/RecoveryPolicy"
        },
        "concurrencyRecoveryConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "staleWrite",
            "retry"
          ],
          "properties": {
            "staleWrite": {
              "type": "string",
              "const": "reject"
            },
            "retry": {
              "type": "string",
              "const": "revalidateIntent"
            }
          }
        },
        "operationRecoveryConfig": {
          "$ref": "#/definitions/RecoveryPolicy"
        },
        "contextBoundaryConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "context",
            "crossContext"
          ],
          "properties": {
            "context": {
              "type": "string",
              "const": "eventAndModeBound"
            },
            "crossContext": {
              "type": "string",
              "const": "deny"
            }
          }
        },
        "overrideReviewConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "hardLimits",
            "permittedOverride"
          ],
          "properties": {
            "hardLimits": {
              "type": "string",
              "const": "neverOverride"
            },
            "permittedOverride": {
              "type": "string",
              "const": "scopedReasonedExpiring"
            }
          }
        },
        "eventClosureConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "pendingLiveWork",
            "survivingObligations",
            "unresolvedAccountability"
          ],
          "properties": {
            "pendingLiveWork": {
              "type": "string",
              "const": "cancel"
            },
            "survivingObligations": {
              "type": "string",
              "const": "handoff"
            },
            "unresolvedAccountability": {
              "type": "string",
              "const": "explicitPolicy"
            }
          }
        },
        "attendanceReconciliationConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "silence",
            "corrections",
            "pendingSync"
          ],
          "properties": {
            "silence": {
              "type": "string",
              "const": "notEvidence"
            },
            "corrections": {
              "type": "string",
              "const": "revisioned"
            },
            "pendingSync": {
              "type": "string",
              "const": "retain"
            }
          }
        },
        "financialReconciliationConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "owner",
            "moneyMovement"
          ],
          "properties": {
            "owner": {
              "type": "string",
              "const": "paymentProviderWorkflow"
            },
            "moneyMovement": {
              "type": "string",
              "const": "separatelyAuthorized"
            }
          }
        },
        "postEventFollowUpConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "templateIntent",
            "audience",
            "maximumPerGuest",
            "expiryMinutes"
          ],
          "properties": {
            "templateIntent": {
              "type": "string",
              "const": "followUp"
            },
            "audience": {
              "type": "string",
              "const": "affectedGuests"
            },
            "maximumPerGuest": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            },
            "expiryMinutes": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10080
            }
          }
        },
        "eventLearningConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "metrics",
            "missingCoverage",
            "sensitiveDetails"
          ],
          "properties": {
            "metrics": {
              "type": "string",
              "const": "observedOutcomes"
            },
            "missingCoverage": {
              "type": "string",
              "const": "explicit"
            },
            "sensitiveDetails": {
              "type": "string",
              "const": "excluded"
            }
          }
        },
        "WorkflowPolicy": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "venueReadiness",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/venueReadinessConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "routeReadiness",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/routeReadinessConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "formatReadiness",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/formatReadinessConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "rosterReadiness",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/rosterReadinessConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "requiredGuestData",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/requiredGuestDataConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "resourceReadiness",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/resourceReadinessConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "staffingReadiness",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/staffingReadinessConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "messagingReadiness",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/messagingReadinessConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "admissionReview",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/admissionReviewConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "financialReadiness",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/financialReadinessConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "joiningInstructions",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/joiningInstructionsConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "identityResolution",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "eventId",
                    "attendeeId",
                    "episodeId"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "guest"
                    },
                    "eventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "episodeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                },
                "config": {
                  "$ref": "#/definitions/identityResolutionConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "guestAdmission",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "eventId",
                    "attendeeId",
                    "episodeId"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "guest"
                    },
                    "eventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "episodeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                },
                "config": {
                  "$ref": "#/definitions/guestAdmissionConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "guestCheckIn",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "eventId",
                    "attendeeId",
                    "episodeId"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "guest"
                    },
                    "eventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "episodeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                },
                "config": {
                  "$ref": "#/definitions/guestCheckInConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "lateJoin",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "eventId",
                    "attendeeId",
                    "episodeId"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "guest"
                    },
                    "eventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "episodeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                },
                "config": {
                  "$ref": "#/definitions/lateJoinConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "participationChange",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "eventId",
                    "attendeeId",
                    "episodeId"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "guest"
                    },
                    "eventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "episodeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                },
                "config": {
                  "$ref": "#/definitions/participationChangeConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "guestPrerequisite",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "eventId",
                    "attendeeId",
                    "episodeId"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "guest"
                    },
                    "eventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "episodeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                },
                "config": {
                  "$ref": "#/definitions/guestPrerequisiteConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "allocationRepair",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/allocationRepairConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "placementConfirmation",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "eventId",
                    "attendeeId",
                    "episodeId"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "guest"
                    },
                    "eventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "episodeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                },
                "config": {
                  "$ref": "#/definitions/placementConfirmationConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "resourceRecovery",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "eventId",
                    "resourceId"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "resource"
                    },
                    "eventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "resourceId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                },
                "config": {
                  "$ref": "#/definitions/resourceRecoveryConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "fairParticipation",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/fairParticipationConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "roundPublication",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/roundPublicationConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "unitProgress",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "eventId",
                    "unitId",
                    "round"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "unit"
                    },
                    "eventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "unitId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "round": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 10000
                    }
                  }
                },
                "config": {
                  "$ref": "#/definitions/unitProgressConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "outcomeRecording",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "eventId",
                    "unitId",
                    "round"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "unit"
                    },
                    "eventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "unitId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "round": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 10000
                    }
                  }
                },
                "config": {
                  "$ref": "#/definitions/outcomeRecordingConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "programmeRecovery",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/programmeRecoveryConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "departure",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "eventId",
                    "groupId"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "group"
                    },
                    "eventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "groupId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                },
                "config": {
                  "$ref": "#/definitions/departureConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "checkpoint",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "eventId",
                    "groupId"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "group"
                    },
                    "eventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "groupId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                },
                "config": {
                  "$ref": "#/definitions/checkpointConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "groupTransfer",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "eventId",
                    "groupId"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "group"
                    },
                    "eventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "groupId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                },
                "config": {
                  "$ref": "#/definitions/groupTransferConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "routeRecovery",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/routeRecoveryConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "locationFreshness",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/locationFreshnessConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "accountability",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/accountabilityConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "planChangeCommunication",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/planChangeCommunicationConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "deliveryRecovery",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/deliveryRecoveryConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "replyOwnership",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/replyOwnershipConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "guestAssistance",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "eventId",
                    "attendeeId",
                    "episodeId"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "guest"
                    },
                    "eventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "episodeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                },
                "config": {
                  "$ref": "#/definitions/guestAssistanceConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "comfortSafety",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "eventId",
                    "attendeeId",
                    "episodeId"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "guest"
                    },
                    "eventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "episodeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                },
                "config": {
                  "$ref": "#/definitions/comfortSafetyConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "attendanceSync",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/attendanceSyncConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "concurrencyRecovery",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/concurrencyRecoveryConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "operationRecovery",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/operationRecoveryConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "contextBoundary",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/contextBoundaryConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "overrideReview",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/overrideReviewConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "eventClosure",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/eventClosureConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "attendanceReconciliation",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/attendanceReconciliationConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "financialReconciliation",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/financialReconciliationConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "postEventFollowUp",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/postEventFollowUpConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "version",
                "scope",
                "config",
                "setting"
              ],
              "properties": {
                "kind": {
                  "const": "eventLearning",
                  "type": "string"
                },
                "version": {
                  "const": 1,
                  "type": "integer"
                },
                "scope": {
                  "$ref": "#/definitions/Scope"
                },
                "config": {
                  "$ref": "#/definitions/eventLearningConfig"
                },
                "setting": {
                  "$ref": "#/definitions/PolicySetting"
                }
              }
            }
          ]
        },
        "Command": {
          "oneOf": [
            {
              "$ref": "#/definitions/ConfirmDepartureCommand"
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "setJoinIntent"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "attendeeId",
                    "intent",
                    "episodeId",
                    "expectedParticipationRevision"
                  ],
                  "properties": {
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "intent": {
                      "$ref": "#/definitions/JoinIntent"
                    },
                    "episodeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "expectedParticipationRevision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "checkInGuest"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "attendeeId",
                    "checkedIn",
                    "expectedAttendanceRevision"
                  ],
                  "properties": {
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "checkedIn": {
                      "type": "boolean"
                    },
                    "expectedAttendanceRevision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "Nonnegative safe integer revision."
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "publishGuidance"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "attendeeId",
                    "guidance"
                  ],
                  "properties": {
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "guidance": {
                      "$ref": "#/definitions/JoiningGuidance"
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "sendOperationalMessage"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "attendeeId",
                    "guidanceRevision",
                    "intent",
                    "expiresAt"
                  ],
                  "properties": {
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "guidanceRevision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "Nonnegative safe integer revision."
                    },
                    "intent": {
                      "type": "string",
                      "enum": [
                        "joining",
                        "planChange",
                        "followUp"
                      ]
                    },
                    "expiresAt": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "UTC milliseconds."
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "openHostCase"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "attendeeId",
                    "reason",
                    "owner"
                  ],
                  "properties": {
                    "attendeeId": {
                      "anyOf": [
                        {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        },
                        {
                          "type": "null",
                          "const": null
                        }
                      ]
                    },
                    "reason": {
                      "type": "string",
                      "enum": [
                        "unreachable",
                        "entryDecision",
                        "missingInformation",
                        "assistance",
                        "accountability"
                      ]
                    },
                    "owner": {
                      "type": "string",
                      "enum": [
                        "eventLead",
                        "groupLead",
                        "sweep"
                      ]
                    }
                  }
                }
              }
            },
            {
              "$ref": "#/definitions/SetParticipationCommand"
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "proposeAllocation"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "attendeeIds",
                    "targetUnitId",
                    "expectedAllocationRevision"
                  ],
                  "properties": {
                    "attendeeIds": {
                      "type": "array",
                      "minItems": 1,
                      "maxItems": 1000,
                      "items": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160,
                        "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                      },
                      "uniqueItems": true
                    },
                    "targetUnitId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "expectedAllocationRevision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "Nonnegative safe integer revision."
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "publishAllocation"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "proposalId",
                    "decisionId"
                  ],
                  "properties": {
                    "proposalId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "decisionId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "confirmPlacement"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "attendeeId",
                    "resourceId",
                    "expectedAssignmentRevision"
                  ],
                  "properties": {
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "resourceId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "expectedAssignmentRevision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "Nonnegative safe integer revision."
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "changeResource"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "resourceId",
                    "status",
                    "decisionId"
                  ],
                  "properties": {
                    "resourceId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "status": {
                      "type": "string",
                      "enum": [
                        "available",
                        "unavailable"
                      ]
                    },
                    "decisionId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                }
              }
            },
            {
              "$ref": "#/definitions/TransferGroupCommand"
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "recordCheckpoint"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "groupId",
                    "checkpointId",
                    "accountedFor",
                    "expectedProgressRevision"
                  ],
                  "properties": {
                    "groupId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "checkpointId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "accountedFor": {
                      "type": "array",
                      "items": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160,
                        "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                      },
                      "maxItems": 1000,
                      "uniqueItems": true
                    },
                    "expectedProgressRevision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "Nonnegative safe integer revision."
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "changeProgramme"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "changeId",
                    "action",
                    "decisionId"
                  ],
                  "properties": {
                    "changeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "action": {
                      "type": "string",
                      "enum": [
                        "pause",
                        "resume",
                        "extend",
                        "skip",
                        "reorder"
                      ]
                    },
                    "decisionId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "recordOutcome"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "unitId",
                    "round",
                    "outcome",
                    "expectedOutcomeRevision"
                  ],
                  "properties": {
                    "unitId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "round": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 10000
                    },
                    "outcome": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "completed"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "completion"
                            },
                            "completed": {
                              "type": "boolean"
                            }
                          }
                        },
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "score"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "score"
                            },
                            "score": {
                              "type": "number",
                              "minimum": -9007199254740991,
                              "maximum": 9007199254740991
                            }
                          }
                        },
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "rank"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "rank"
                            },
                            "rank": {
                              "type": "number",
                              "minimum": -9007199254740991,
                              "maximum": 9007199254740991
                            }
                          }
                        }
                      ]
                    },
                    "expectedOutcomeRevision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "Nonnegative safe integer revision."
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "changeRoute"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "routeRevision",
                    "alternativeId",
                    "decisionId"
                  ],
                  "properties": {
                    "routeRevision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "Nonnegative safe integer revision."
                    },
                    "alternativeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "decisionId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resolveAccountability"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "attendeeId",
                    "episodeId",
                    "disposition"
                  ],
                  "properties": {
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "episodeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "disposition": {
                      "type": "string",
                      "enum": [
                        "returned",
                        "departed",
                        "unresolved"
                      ]
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resolveClaim"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "claimId",
                    "outcome"
                  ],
                  "properties": {
                    "claimId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "outcome": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "attendeeId"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "link"
                            },
                            "attendeeId": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 160,
                              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                            }
                          }
                        },
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "reason"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "reject"
                            },
                            "reason": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 2000
                            }
                          }
                        }
                      ]
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "admitGuest"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "attendeeId",
                    "entitlementDecisionId"
                  ],
                  "properties": {
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "entitlementDecisionId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "assignResponsibility"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "operatorId",
                    "role",
                    "scope"
                  ],
                  "properties": {
                    "operatorId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "role": {
                      "type": "string",
                      "enum": [
                        "lead",
                        "checkIn",
                        "pacer",
                        "sweep",
                        "marshal"
                      ]
                    },
                    "scope": {
                      "$ref": "#/definitions/Scope"
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resolveAssistance"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "caseId",
                    "outcome",
                    "owner"
                  ],
                  "properties": {
                    "caseId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "outcome": {
                      "type": "string",
                      "enum": [
                        "resolved",
                        "declined",
                        "transferred"
                      ]
                    },
                    "owner": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "reconcileAttendance"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "attendeeId",
                    "expectedAttendanceRevision"
                  ],
                  "properties": {
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "expectedAttendanceRevision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "Nonnegative safe integer revision."
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "requestRequiredData"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "attendeeId",
                    "fieldIds",
                    "expiresAt"
                  ],
                  "properties": {
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "fieldIds": {
                      "type": "array",
                      "minItems": 1,
                      "maxItems": 1000,
                      "items": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 2000
                      },
                      "uniqueItems": true
                    },
                    "expiresAt": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "UTC milliseconds."
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "reconcileRoster"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "sourceId",
                    "sourceRevision"
                  ],
                  "properties": {
                    "sourceId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "sourceRevision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "Nonnegative safe integer revision."
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "reconcileFinance"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "providerCaseId"
                  ],
                  "properties": {
                    "providerCaseId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "repairDelivery"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "deliveryId",
                    "action"
                  ],
                  "properties": {
                    "deliveryId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "action": {
                      "type": "string",
                      "enum": [
                        "reconcile",
                        "retryDefiniteFailure",
                        "manualHandoff"
                      ]
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resumeOperation"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "instanceId",
                    "expectedRevision"
                  ],
                  "properties": {
                    "instanceId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "expectedRevision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "Nonnegative safe integer revision."
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "completeEvent"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "decisionId",
                    "disposition",
                    "unresolvedCaseIds"
                  ],
                  "properties": {
                    "decisionId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "disposition": {
                      "type": "string",
                      "enum": [
                        "completed",
                        "aborted"
                      ]
                    },
                    "unresolvedCaseIds": {
                      "type": "array",
                      "items": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 2000
                      },
                      "maxItems": 1000,
                      "uniqueItems": true
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "controlUnitProgress"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "unitId",
                    "progress",
                    "expectedRevision"
                  ],
                  "properties": {
                    "unitId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "progress": {
                      "type": "string",
                      "enum": [
                        "ready",
                        "active",
                        "paused",
                        "completed"
                      ]
                    },
                    "expectedRevision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "Nonnegative safe integer revision."
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "controlReveal"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "action",
                    "expectedLiveRevision",
                    "decisionId"
                  ],
                  "properties": {
                    "action": {
                      "type": "string",
                      "enum": [
                        "startCountdown",
                        "cancelPending",
                        "publish"
                      ]
                    },
                    "expectedLiveRevision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "Nonnegative safe integer revision."
                    },
                    "decisionId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "applyOverride"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "constraintId",
                    "ruleKind",
                    "scope",
                    "reason",
                    "expiresAt",
                    "decisionId"
                  ],
                  "properties": {
                    "constraintId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "ruleKind": {
                      "type": "string",
                      "enum": [
                        "softPreference",
                        "overrideableOperatingRule"
                      ]
                    },
                    "scope": {
                      "$ref": "#/definitions/Scope"
                    },
                    "reason": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "expiresAt": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "UTC milliseconds."
                    },
                    "decisionId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "setLocationSharing"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "operatorId",
                    "enabled",
                    "scope"
                  ],
                  "properties": {
                    "operatorId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "enabled": {
                      "type": "boolean"
                    },
                    "scope": {
                      "$ref": "#/definitions/Scope"
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "requestCheckpointReport"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "groupId",
                    "checkpointId",
                    "dueAt"
                  ],
                  "properties": {
                    "groupId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "checkpointId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "dueAt": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "UTC milliseconds."
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "recordNoShow"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "attendeeId",
                    "evidence",
                    "decisionId"
                  ],
                  "properties": {
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "evidence": {
                      "type": "string",
                      "enum": [
                        "guestDeclined",
                        "hostConfirmed"
                      ]
                    },
                    "decisionId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "routeRestrictedCase"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "restrictedCaseId",
                    "operationalNeed"
                  ],
                  "properties": {
                    "restrictedCaseId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "operationalNeed": {
                      "type": "string",
                      "enum": [
                        "separation",
                        "pause",
                        "assistance"
                      ]
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "context",
                "eventId",
                "operationId",
                "payload"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "resolveRestrictedCase"
                },
                "context": {
                  "$ref": "#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "payload": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "restrictedCaseId",
                    "resolutionId"
                  ],
                  "properties": {
                    "restrictedCaseId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "resolutionId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    }
                  }
                }
              }
            }
          ]
        },
        "KnownGuestState": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "attendeeId",
            "episodeId",
            "admission",
            "attendance",
            "intention",
            "deliveryEligibility",
            "participation"
          ],
          "properties": {
            "attendeeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "episodeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "admission": {
              "type": "string",
              "enum": [
                "admitted",
                "pending",
                "declined"
              ]
            },
            "attendance": {
              "$ref": "#/definitions/Fact___type___object___additionalProperties__false__required____checkedIn____properties____checkedIn____type___boolean____"
            },
            "intention": {
              "$ref": "#/definitions/JoinIntent"
            },
            "deliveryEligibility": {
              "type": "string",
              "enum": [
                "eligible",
                "unreachable",
                "unknown"
              ]
            },
            "participation": {
              "enum": [
                "active",
                "temporaryBreak",
                "departed",
                "unknown"
              ]
            }
          }
        },
        "Fact___type___object___additionalProperties__false__required____checkedIn____properties____checkedIn____type___boolean____": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "value",
                "revision",
                "observedAt",
                "source"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "known"
                },
                "value": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "checkedIn"
                  ],
                  "properties": {
                    "checkedIn": {
                      "type": "boolean"
                    }
                  }
                },
                "revision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "Nonnegative safe integer revision."
                },
                "observedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "UTC milliseconds."
                },
                "source": {
                  "type": "string",
                  "enum": [
                    "host",
                    "guest",
                    "provider",
                    "system"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "reason"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unknown"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "notCollected",
                    "notConfirmed",
                    "sourceUnavailable"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "lastValue",
                "observedAt",
                "staleAt"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "stale"
                },
                "lastValue": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "checkedIn"
                  ],
                  "properties": {
                    "checkedIn": {
                      "type": "boolean"
                    }
                  }
                },
                "observedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "UTC milliseconds."
                },
                "staleAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "UTC milliseconds."
                }
              }
            }
          ]
        },
        "Fact____ref_____definitions_JoiningGuidance__": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "value",
                "revision",
                "observedAt",
                "source"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "known"
                },
                "value": {
                  "$ref": "#/definitions/JoiningGuidance"
                },
                "revision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "Nonnegative safe integer revision."
                },
                "observedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "UTC milliseconds."
                },
                "source": {
                  "type": "string",
                  "enum": [
                    "host",
                    "guest",
                    "provider",
                    "system"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "reason"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unknown"
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "notCollected",
                    "notConfirmed",
                    "sourceUnavailable"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "lastValue",
                "observedAt",
                "staleAt"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "stale"
                },
                "lastValue": {
                  "$ref": "#/definitions/JoiningGuidance"
                },
                "observedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "UTC milliseconds."
                },
                "staleAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "UTC milliseconds."
                }
              }
            }
          ]
        },
        "LateJoinInput": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "eventId",
            "eventOpen",
            "departureConfirmed",
            "now",
            "policy",
            "guest",
            "guidance",
            "lastMessage",
            "messagesThisEpisode",
            "context",
            "setting"
          ],
          "properties": {
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "eventOpen": {
              "type": "boolean"
            },
            "departureConfirmed": {
              "type": "boolean"
            },
            "now": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991,
              "description": "UTC milliseconds."
            },
            "policy": {
              "$ref": "#/definitions/LateJoinPolicy"
            },
            "guest": {
              "$ref": "#/definitions/KnownGuestState"
            },
            "guidance": {
              "$ref": "#/definitions/Fact____ref_____definitions_JoiningGuidance__"
            },
            "lastMessage": {
              "anyOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "materialKey",
                    "at"
                  ],
                  "properties": {
                    "materialKey": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "at": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991,
                      "description": "UTC milliseconds."
                    }
                  }
                },
                {
                  "type": "null",
                  "const": null
                }
              ]
            },
            "messagesThisEpisode": {
              "type": "integer",
              "minimum": 0,
              "maximum": 1000
            },
            "responseDeadline": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991,
              "description": "UTC milliseconds."
            },
            "context": {
              "$ref": "#/definitions/ExecutionContext"
            },
            "setting": {
              "$ref": "#/definitions/PolicySetting"
            }
          },
          "allOf": [
            {
              "if": {
                "properties": {
                  "policy": {
                    "properties": {
                      "unanswered": {
                        "const": "hostReviewAtDeadline"
                      }
                    }
                  }
                }
              },
              "then": {
                "required": [
                  "responseDeadline"
                ]
              }
            }
          ]
        },
        "ConfirmDepartureCommand": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "context",
            "eventId",
            "operationId",
            "payload"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "confirmDeparture"
            },
            "context": {
              "$ref": "#/definitions/ExecutionContext"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "operationId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "payload": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "groupId",
                "destination",
                "expectedProgressRevision"
              ],
              "properties": {
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "destination": {
                  "$ref": "#/definitions/JoiningTarget"
                },
                "expectedProgressRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "Nonnegative safe integer revision."
                }
              }
            }
          }
        },
        "Participation": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "state",
                "resumeAtUnit"
              ],
              "properties": {
                "state": {
                  "const": "active"
                },
                "resumeAtUnit": {
                  "type": "null"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "state",
                "resumeAtUnit"
              ],
              "properties": {
                "state": {
                  "const": "temporaryBreak"
                },
                "resumeAtUnit": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    {
                      "type": "null"
                    }
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "state",
                "resumeAtUnit"
              ],
              "properties": {
                "state": {
                  "const": "departed"
                },
                "resumeAtUnit": {
                  "type": "null"
                }
              }
            }
          ]
        },
        "SetParticipationCommand": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "context",
            "eventId",
            "operationId",
            "payload"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "setParticipation"
            },
            "context": {
              "$ref": "#/definitions/ExecutionContext"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "operationId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "payload": {
              "oneOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "attendeeId",
                    "state",
                    "resumeAtUnit",
                    "episodeId",
                    "expectedParticipationRevision"
                  ],
                  "properties": {
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "state": {
                      "const": "active"
                    },
                    "resumeAtUnit": {
                      "type": "null"
                    },
                    "episodeId": {
                      "anyOf": [
                        {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "expectedParticipationRevision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "attendeeId",
                    "state",
                    "resumeAtUnit",
                    "episodeId",
                    "expectedParticipationRevision"
                  ],
                  "properties": {
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "state": {
                      "const": "temporaryBreak"
                    },
                    "resumeAtUnit": {
                      "anyOf": [
                        {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "episodeId": {
                      "anyOf": [
                        {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "expectedParticipationRevision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "attendeeId",
                    "state",
                    "resumeAtUnit",
                    "episodeId",
                    "expectedParticipationRevision"
                  ],
                  "properties": {
                    "attendeeId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "state": {
                      "const": "departed"
                    },
                    "resumeAtUnit": {
                      "type": "null"
                    },
                    "episodeId": {
                      "anyOf": [
                        {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "expectedParticipationRevision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    }
                  }
                }
              ]
            }
          }
        },
        "TransferGroupCommand": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "context",
            "eventId",
            "operationId",
            "payload"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "transferGroup"
            },
            "context": {
              "$ref": "#/definitions/ExecutionContext"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "operationId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "payload": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "attendeeId",
                "episodeId",
                "expectedParticipationRevision",
                "expectedMembershipRevision",
                "decision"
              ],
              "properties": {
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "expectedParticipationRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "expectedMembershipRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "decision": {
                  "oneOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "groupId"
                      ],
                      "properties": {
                        "kind": {
                          "const": "place"
                        },
                        "groupId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "from",
                        "to",
                        "receivingOperatorId",
                        "expiresAtMillis"
                      ],
                      "properties": {
                        "kind": {
                          "const": "propose"
                        },
                        "from": {
                          "anyOf": [
                            {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 160,
                              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                            },
                            {
                              "type": "null"
                            }
                          ]
                        },
                        "to": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        },
                        "receivingOperatorId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 180
                        },
                        "expiresAtMillis": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "transferId"
                      ],
                      "properties": {
                        "kind": {
                          "const": "accept"
                        },
                        "transferId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "transferId"
                      ],
                      "properties": {
                        "kind": {
                          "const": "reject"
                        },
                        "transferId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "transferId"
                      ],
                      "properties": {
                        "kind": {
                          "const": "cancel"
                        },
                        "transferId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind"
                      ],
                      "properties": {
                        "kind": {
                          "const": "leave"
                        }
                      }
                    }
                  ]
                }
              }
            }
          }
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/operations/event_assistance_live_work.schema.json",
      "title": "EventAssistanceLiveWork",
      "description": "Private normalized payload for one durable live guest episode. Due times and evaluation state are explicit; publication is not provider delivery.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "kind",
        "scope",
        "options",
        "expiresAt",
        "maxEvaluations",
        "checkpoint"
      ],
      "properties": {
        "schemaVersion": {
          "type": "integer",
          "const": 1
        },
        "kind": {
          "type": "string",
          "const": "liveLateJoin"
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "context",
            "attendeeId",
            "episodeId"
          ],
          "properties": {
            "context": {
              "$ref": "../shared/event_assistance_guest.schema.json#/definitions/liveContext"
            },
            "attendeeId": {
              "$ref": "common.schema.json#/definitions/id"
            },
            "episodeId": {
              "$ref": "common.schema.json#/definitions/id"
            }
          }
        },
        "options": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "routes",
            "responseDeadline",
            "deliveryPolicy"
          ],
          "properties": {
            "routes": {
              "$ref": "../shared/event_assistance_messaging.schema.json#/definitions/LateJoinAutomation/properties/routes"
            },
            "responseDeadline": {
              "anyOf": [
                {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                {
                  "type": "null",
                  "const": null
                }
              ]
            },
            "deliveryPolicy": {
              "$ref": "../shared/event_assistance_messaging.schema.json#/definitions/MessageIntent/oneOf/0/properties/deliveryPolicy"
            },
            "laterChoices": {
              "type": "array",
              "maxItems": 17,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "label",
                  "target"
                ],
                "properties": {
                  "label": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 80
                  },
                  "target": {
                    "$ref": "../shared/event_assistance_common.schema.json#/definitions/JoiningTarget"
                  }
                }
              }
            }
          }
        },
        "expiresAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "maxEvaluations": {
          "type": "integer",
          "minimum": 1,
          "maximum": 10000
        },
        "checkpoint": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "dueAt",
            "evaluatedAt",
            "evaluations",
            "sourceHash",
            "observation",
            "publication"
          ],
          "properties": {
            "dueAt": {
              "anyOf": [
                {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                {
                  "type": "null",
                  "const": null
                }
              ]
            },
            "evaluatedAt": {
              "anyOf": [
                {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                {
                  "type": "null",
                  "const": null
                }
              ]
            },
            "evaluations": {
              "type": "integer",
              "minimum": 0,
              "maximum": 10000
            },
            "sourceHash": {
              "anyOf": [
                {
                  "$ref": "common.schema.json#/definitions/sha256"
                },
                {
                  "type": "null",
                  "const": null
                }
              ]
            },
            "observation": {
              "anyOf": [
                {
                  "oneOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "decision"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "decision"
                        },
                        "decision": {
                          "$ref": "event_assistance_late_join_decision.schema.json"
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "reason"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "sourceNotReady"
                        },
                        "reason": {
                          "type": "string",
                          "enum": [
                            "episodeMissing",
                            "guestSourceChanged",
                            "membershipMissing",
                            "membershipSourceChanged",
                            "unconfigured",
                            "disabled",
                            "settingSourceChanged",
                            "eventClosed",
                            "runtimeNotLive",
                            "progressUnconfirmed",
                            "progressSourceChanged",
                            "destinationUnavailable"
                          ]
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "reason"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "historyUnavailable"
                        },
                        "reason": {
                          "type": "string",
                          "enum": [
                            "historyLimit",
                            "deliveryConflict",
                            "ambiguousHistory"
                          ]
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "responseDeadlineMissing"
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "episodeChanged"
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "workExpired"
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "evaluationLimit"
                        }
                      }
                    }
                  ]
                },
                {
                  "type": "null",
                  "const": null
                }
              ]
            },
            "publication": {
              "anyOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "messageId",
                    "threadId"
                  ],
                  "properties": {
                    "messageId": {
                      "$ref": "common.schema.json#/definitions/id"
                    },
                    "threadId": {
                      "$ref": "common.schema.json#/definitions/id"
                    }
                  }
                },
                {
                  "type": "null",
                  "const": null
                }
              ]
            }
          }
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/shared/event_assistance_messaging.schema.json",
      "title": "EventAssistanceMessaging",
      "description": "Logical event-service messages, channel attempts and scoped self-reports. Provider acceptance is not delivery, and a guest response never proves physical attendance.",
      "definitions": {
        "EventServiceRouteId": {
          "type": "string",
          "enum": [
            "catchEventSms",
            "catchEventRcs",
            "organizerEventWhatsapp"
          ]
        },
        "ResponseValue": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "intention"
              ],
              "properties": {
                "kind": {
                  "const": "joinIntent",
                  "type": "string"
                },
                "intention": {
                  "oneOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "claimedEta"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "onMyWay"
                        },
                        "claimedEta": {
                          "anyOf": [
                            {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 9007199254740991,
                              "description": "UTC milliseconds."
                            },
                            {
                              "type": "null",
                              "const": null
                            }
                          ]
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "target"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "joinLater"
                        },
                        "target": {
                          "$ref": "event_assistance_common.schema.json#/definitions/JoiningTarget"
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "notComing"
                        }
                      }
                    }
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "instructionRevision"
              ],
              "properties": {
                "kind": {
                  "const": "acknowledge",
                  "type": "string"
                },
                "instructionRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "category"
              ],
              "properties": {
                "kind": {
                  "const": "requestHelp",
                  "type": "string"
                },
                "category": {
                  "type": "string",
                  "enum": [
                    "eventLogistics",
                    "accessibility",
                    "comfortSafety",
                    "other"
                  ]
                }
              }
            }
          ]
        },
        "MessageIntent": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "schemaVersion",
                "intentId",
                "revision",
                "context",
                "eventId",
                "attendeeId",
                "episodeId",
                "workflow",
                "createdAt",
                "expiresAt",
                "permittedRoutes",
                "deliveryPolicy",
                "kind",
                "guidance",
                "choices"
              ],
              "properties": {
                "schemaVersion": {
                  "const": 1,
                  "type": "integer"
                },
                "intentId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "revision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 1000000
                },
                "context": {
                  "$ref": "event_assistance_common.schema.json#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "workflow": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "occurrenceId"
                  ],
                  "properties": {
                    "kind": {
                      "$ref": "event_assistance_common.schema.json#/definitions/workflowKind"
                    },
                    "occurrenceId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                    }
                  }
                },
                "createdAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "expiresAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "permittedRoutes": {
                  "type": "array",
                  "minItems": 1,
                  "maxItems": 3,
                  "items": {
                    "type": "string",
                    "enum": [
                      "catchEventSms",
                      "catchEventRcs",
                      "organizerEventWhatsapp"
                    ]
                  },
                  "uniqueItems": true
                },
                "deliveryPolicy": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "maxAttempts",
                    "maxAttemptsPerRoute",
                    "minimumRetrySeconds"
                  ],
                  "properties": {
                    "maxAttempts": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 6
                    },
                    "maxAttemptsPerRoute": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 3
                    },
                    "minimumRetrySeconds": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 3600
                    }
                  }
                },
                "kind": {
                  "const": "joiningUpdate",
                  "type": "string"
                },
                "guidance": {
                  "$ref": "event_assistance_common.schema.json#/definitions/JoiningGuidance"
                },
                "choices": {
                  "type": "array",
                  "minItems": 1,
                  "maxItems": 20,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "choiceId",
                      "label",
                      "value"
                    ],
                    "properties": {
                      "choiceId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160,
                        "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                      },
                      "label": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 80
                      },
                      "value": {
                        "oneOf": [
                          {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "kind",
                              "intention"
                            ],
                            "properties": {
                              "kind": {
                                "const": "joinIntent",
                                "type": "string"
                              },
                              "intention": {
                                "oneOf": [
                                  {
                                    "type": "object",
                                    "additionalProperties": false,
                                    "required": [
                                      "kind",
                                      "claimedEta"
                                    ],
                                    "properties": {
                                      "kind": {
                                        "type": "string",
                                        "const": "onMyWay"
                                      },
                                      "claimedEta": {
                                        "anyOf": [
                                          {
                                            "type": "integer",
                                            "minimum": 0,
                                            "maximum": 9007199254740991,
                                            "description": "UTC milliseconds."
                                          },
                                          {
                                            "type": "null",
                                            "const": null
                                          }
                                        ]
                                      }
                                    }
                                  },
                                  {
                                    "type": "object",
                                    "additionalProperties": false,
                                    "required": [
                                      "kind",
                                      "target"
                                    ],
                                    "properties": {
                                      "kind": {
                                        "type": "string",
                                        "const": "joinLater"
                                      },
                                      "target": {
                                        "$ref": "event_assistance_common.schema.json#/definitions/JoiningTarget"
                                      }
                                    }
                                  },
                                  {
                                    "type": "object",
                                    "additionalProperties": false,
                                    "required": [
                                      "kind"
                                    ],
                                    "properties": {
                                      "kind": {
                                        "type": "string",
                                        "const": "notComing"
                                      }
                                    }
                                  }
                                ]
                              }
                            }
                          },
                          {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "kind",
                              "category"
                            ],
                            "properties": {
                              "kind": {
                                "const": "requestHelp",
                                "type": "string"
                              },
                              "category": {
                                "type": "string",
                                "enum": [
                                  "eventLogistics",
                                  "accessibility",
                                  "comfortSafety",
                                  "other"
                                ]
                              }
                            }
                          }
                        ]
                      }
                    }
                  }
                },
                "automation": {
                  "$ref": "#/definitions/LateJoinAutomation"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "schemaVersion",
                "intentId",
                "revision",
                "context",
                "eventId",
                "attendeeId",
                "episodeId",
                "workflow",
                "createdAt",
                "expiresAt",
                "permittedRoutes",
                "deliveryPolicy",
                "kind",
                "noticeKind",
                "title",
                "body",
                "instructionRevision",
                "choices"
              ],
              "properties": {
                "schemaVersion": {
                  "const": 1,
                  "type": "integer"
                },
                "intentId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "revision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 1000000
                },
                "context": {
                  "$ref": "event_assistance_common.schema.json#/definitions/ExecutionContext"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "workflow": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "occurrenceId"
                  ],
                  "properties": {
                    "kind": {
                      "$ref": "event_assistance_common.schema.json#/definitions/workflowKind"
                    },
                    "occurrenceId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                    }
                  }
                },
                "createdAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "expiresAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "permittedRoutes": {
                  "type": "array",
                  "minItems": 1,
                  "maxItems": 3,
                  "items": {
                    "type": "string",
                    "enum": [
                      "catchEventSms",
                      "catchEventRcs",
                      "organizerEventWhatsapp"
                    ]
                  },
                  "uniqueItems": true
                },
                "deliveryPolicy": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "maxAttempts",
                    "maxAttemptsPerRoute",
                    "minimumRetrySeconds"
                  ],
                  "properties": {
                    "maxAttempts": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 6
                    },
                    "maxAttemptsPerRoute": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 3
                    },
                    "minimumRetrySeconds": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 3600
                    }
                  }
                },
                "kind": {
                  "const": "operationalNotice",
                  "type": "string"
                },
                "noticeKind": {
                  "type": "string",
                  "enum": [
                    "joiningInstructions",
                    "planChanged",
                    "eventCancelled",
                    "eventFinished",
                    "guestRequirement",
                    "assignmentChanged",
                    "participationCheck",
                    "followUp"
                  ]
                },
                "title": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 120
                },
                "body": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "instructionRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "choices": {
                  "type": "array",
                  "minItems": 0,
                  "maxItems": 20,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "choiceId",
                      "label",
                      "value"
                    ],
                    "properties": {
                      "choiceId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160,
                        "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                      },
                      "label": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 80
                      },
                      "value": {
                        "oneOf": [
                          {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "kind",
                              "instructionRevision"
                            ],
                            "properties": {
                              "kind": {
                                "const": "acknowledge",
                                "type": "string"
                              },
                              "instructionRevision": {
                                "type": "integer",
                                "minimum": 0,
                                "maximum": 9007199254740991
                              }
                            }
                          },
                          {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "kind",
                              "category"
                            ],
                            "properties": {
                              "kind": {
                                "const": "requestHelp",
                                "type": "string"
                              },
                              "category": {
                                "type": "string",
                                "enum": [
                                  "eventLogistics",
                                  "accessibility",
                                  "comfortSafety",
                                  "other"
                                ]
                              }
                            }
                          }
                        ]
                      }
                    }
                  }
                }
              }
            }
          ]
        },
        "ProviderBinding": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "routeId",
                "transport",
                "senderIdentity",
                "provider",
                "senderId",
                "bindingRevision",
                "recipientEndpointId",
                "fallbackOwner"
              ],
              "properties": {
                "routeId": {
                  "const": "catchEventSms",
                  "type": "string"
                },
                "transport": {
                  "const": "sms",
                  "type": "string"
                },
                "senderIdentity": {
                  "const": "catchPlatform",
                  "type": "string"
                },
                "provider": {
                  "type": "string",
                  "enum": [
                    "sinch",
                    "gupshup"
                  ]
                },
                "senderId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "bindingRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991
                },
                "recipientEndpointId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "fallbackOwner": {
                  "type": "string",
                  "enum": [
                    "catch",
                    "provider"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "routeId",
                "transport",
                "senderIdentity",
                "provider",
                "senderId",
                "bindingRevision",
                "recipientEndpointId",
                "fallbackOwner"
              ],
              "properties": {
                "routeId": {
                  "const": "catchEventRcs",
                  "type": "string"
                },
                "transport": {
                  "const": "rcs",
                  "type": "string"
                },
                "senderIdentity": {
                  "const": "catchPlatform",
                  "type": "string"
                },
                "provider": {
                  "type": "string",
                  "enum": [
                    "sinch",
                    "gupshup"
                  ]
                },
                "senderId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "bindingRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991
                },
                "recipientEndpointId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "fallbackOwner": {
                  "type": "string",
                  "enum": [
                    "catch",
                    "provider"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "routeId",
                "transport",
                "senderIdentity",
                "provider",
                "senderId",
                "bindingRevision",
                "recipientEndpointId",
                "fallbackOwner"
              ],
              "properties": {
                "routeId": {
                  "const": "organizerEventWhatsapp",
                  "type": "string"
                },
                "transport": {
                  "const": "whatsapp",
                  "type": "string"
                },
                "senderIdentity": {
                  "const": "organizerManaged",
                  "type": "string"
                },
                "provider": {
                  "type": "string",
                  "enum": [
                    "meta"
                  ]
                },
                "senderId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "bindingRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991
                },
                "recipientEndpointId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "fallbackOwner": {
                  "type": "string",
                  "enum": [
                    "catch",
                    "provider"
                  ]
                }
              }
            }
          ]
        },
        "AttemptState": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at",
                "reconcileAfter"
              ],
              "properties": {
                "kind": {
                  "const": "reserved",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "reconcileAfter": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at",
                "providerMessageId",
                "reason",
                "reconcileAfter"
              ],
              "properties": {
                "kind": {
                  "const": "unknown",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "providerMessageId": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 512
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "timeout",
                    "connectionLost",
                    "workerInterrupted"
                  ]
                },
                "reconcileAfter": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at",
                "providerMessageId"
              ],
              "properties": {
                "kind": {
                  "const": "accepted",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "providerMessageId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at",
                "providerMessageId"
              ],
              "properties": {
                "kind": {
                  "const": "delivered",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "providerMessageId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at",
                "providerMessageId"
              ],
              "properties": {
                "kind": {
                  "const": "read",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "providerMessageId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at",
                "providerMessageId",
                "classification",
                "evidenceId"
              ],
              "properties": {
                "kind": {
                  "const": "failed",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "providerMessageId": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 512
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "classification": {
                  "type": "string",
                  "enum": [
                    "technical",
                    "invalidRecipient",
                    "policy",
                    "suppressed"
                  ]
                },
                "evidenceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at",
                "providerMessageId",
                "evidenceId"
              ],
              "properties": {
                "kind": {
                  "const": "revoked",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "providerMessageId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512
                },
                "evidenceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at",
                "reason"
              ],
              "properties": {
                "kind": {
                  "const": "notDispatched",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "superseded",
                    "eventClosed",
                    "responded",
                    "expired",
                    "permissionRevoked",
                    "hostStopped",
                    "reservationExpired",
                    "permitExpired"
                  ]
                }
              },
              "description": "No provider request was made. Reservation or permit expiry permits a fresh bounded attempt; the other reasons stop this message."
            }
          ]
        },
        "DeliveryAttempt": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "schemaVersion",
                "attemptId",
                "intentId",
                "intentRevision",
                "ordinal",
                "createdAt",
                "state",
                "mode",
                "context",
                "binding",
                "authorization"
              ],
              "properties": {
                "schemaVersion": {
                  "const": 1,
                  "type": "integer"
                },
                "attemptId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "intentId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "intentRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 1000000
                },
                "ordinal": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 6
                },
                "createdAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "state": {
                  "$ref": "#/definitions/AttemptState"
                },
                "mode": {
                  "const": "live",
                  "type": "string"
                },
                "context": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "mode",
                    "eventId",
                    "organizerId"
                  ],
                  "properties": {
                    "mode": {
                      "type": "string",
                      "const": "live"
                    },
                    "eventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "organizerId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    }
                  }
                },
                "binding": {
                  "$ref": "#/definitions/ProviderBinding"
                },
                "authorization": {
                  "$ref": "#/definitions/DispatchAuthorization"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "schemaVersion",
                "attemptId",
                "intentId",
                "intentRevision",
                "ordinal",
                "createdAt",
                "state",
                "mode",
                "context",
                "routeId",
                "authorization"
              ],
              "properties": {
                "schemaVersion": {
                  "const": 1,
                  "type": "integer"
                },
                "attemptId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "intentId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "intentRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 1000000
                },
                "ordinal": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 6
                },
                "createdAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "state": {
                  "$ref": "#/definitions/AttemptState"
                },
                "mode": {
                  "const": "rehearsal",
                  "type": "string"
                },
                "context": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "mode",
                    "rehearsalId",
                    "virtualEventId",
                    "clockId"
                  ],
                  "properties": {
                    "mode": {
                      "type": "string",
                      "const": "rehearsal"
                    },
                    "rehearsalId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "virtualEventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "clockId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    }
                  }
                },
                "routeId": {
                  "type": "string",
                  "enum": [
                    "catchEventSms",
                    "catchEventRcs",
                    "organizerEventWhatsapp"
                  ]
                },
                "authorization": {
                  "$ref": "#/definitions/DispatchAuthorization"
                }
              }
            }
          ]
        },
        "GuestResponse": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "schemaVersion",
                "responseId",
                "intentId",
                "intentRevision",
                "eventId",
                "attendeeId",
                "episodeId",
                "choiceId",
                "receivedAt",
                "value",
                "context",
                "source"
              ],
              "properties": {
                "schemaVersion": {
                  "const": 1,
                  "type": "integer"
                },
                "responseId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "intentId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "intentRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 1000000
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "choiceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "receivedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "value": {
                  "$ref": "#/definitions/ResponseValue"
                },
                "context": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "mode",
                    "eventId",
                    "organizerId"
                  ],
                  "properties": {
                    "mode": {
                      "type": "string",
                      "const": "live"
                    },
                    "eventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "organizerId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    }
                  }
                },
                "source": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "linkId"
                  ],
                  "properties": {
                    "kind": {
                      "const": "guestWeb",
                      "type": "string"
                    },
                    "linkId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "schemaVersion",
                "responseId",
                "intentId",
                "intentRevision",
                "eventId",
                "attendeeId",
                "episodeId",
                "choiceId",
                "receivedAt",
                "value",
                "context",
                "source"
              ],
              "properties": {
                "schemaVersion": {
                  "const": 1,
                  "type": "integer"
                },
                "responseId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "intentId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "intentRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 1000000
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "choiceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "receivedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "value": {
                  "$ref": "#/definitions/ResponseValue"
                },
                "context": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "mode",
                    "eventId",
                    "organizerId"
                  ],
                  "properties": {
                    "mode": {
                      "type": "string",
                      "const": "live"
                    },
                    "eventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "organizerId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    }
                  }
                },
                "source": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "attemptId",
                    "providerEventId"
                  ],
                  "properties": {
                    "kind": {
                      "const": "provider",
                      "type": "string"
                    },
                    "attemptId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                    },
                    "providerEventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 512
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "schemaVersion",
                "responseId",
                "intentId",
                "intentRevision",
                "eventId",
                "attendeeId",
                "episodeId",
                "choiceId",
                "receivedAt",
                "value",
                "context",
                "source"
              ],
              "properties": {
                "schemaVersion": {
                  "const": 1,
                  "type": "integer"
                },
                "responseId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "intentId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "intentRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 1000000
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "choiceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "receivedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "value": {
                  "$ref": "#/definitions/ResponseValue"
                },
                "context": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "mode",
                    "rehearsalId",
                    "virtualEventId",
                    "clockId"
                  ],
                  "properties": {
                    "mode": {
                      "type": "string",
                      "const": "rehearsal"
                    },
                    "rehearsalId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "virtualEventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "clockId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    }
                  }
                },
                "source": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "actionId"
                  ],
                  "properties": {
                    "kind": {
                      "const": "simulation",
                      "type": "string"
                    },
                    "actionId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                    }
                  }
                }
              }
            }
          ]
        },
        "DispatchAuthorization": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "permissionRevision",
            "checkedAt",
            "validUntil",
            "instructionRevision"
          ],
          "properties": {
            "permissionRevision": {
              "type": "string",
              "minLength": 1,
              "maxLength": 512
            },
            "checkedAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "validUntil": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "instructionRevision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          }
        },
        "LateJoinAutomation": {
          "type": "object",
          "description": "Trusted live publisher binding. Queued delivery rechecks the saved policy, current group and episode outreach budget. Absence denotes the pre-existing trusted explicit publisher path, never automatic execution authority.",
          "additionalProperties": false,
          "required": [
            "kind",
            "policyVersion",
            "groupId",
            "settingId",
            "settingRevision",
            "routes",
            "responseDeadline"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "lateJoin"
            },
            "policyVersion": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            },
            "groupId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
            },
            "settingId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
            },
            "settingRevision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "routes": {
              "type": "array",
              "minItems": 1,
              "maxItems": 3,
              "uniqueItems": true,
              "items": {
                "oneOf": [
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "routeId",
                      "senderId"
                    ],
                    "properties": {
                      "routeId": {
                        "type": "string",
                        "const": "catchEventSms"
                      },
                      "senderId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160,
                        "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "routeId",
                      "senderId"
                    ],
                    "properties": {
                      "routeId": {
                        "type": "string",
                        "const": "organizerEventWhatsapp"
                      },
                      "senderId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160,
                        "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "routeId"
                    ],
                    "properties": {
                      "routeId": {
                        "type": "string",
                        "const": "catchEventRcs"
                      }
                    }
                  }
                ]
              }
            },
            "responseDeadline": {
              "anyOf": [
                {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                {
                  "type": "null",
                  "const": null
                }
              ]
            }
          }
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/operations/event_assistance_late_join_decision.schema.json",
      "title": "EventAssistanceLateJoinDecision",
      "$ref": "../shared/event_assistance_common.schema.json#/definitions/LateJoinEvaluation"
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callable_responses/admin_record_marketing_review_decision_response.schema.json",
      "title": "Admin Record Marketing Review Decision Callable Response",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "decisionId",
        "targetType",
        "targetId",
        "decision",
        "decisionStatus",
        "decisionPath"
      ],
      "properties": {
        "decisionId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 150
        },
        "targetType": {
          "type": "string",
          "enum": [
            "source_profile",
            "query_template",
            "run_plan",
            "source_result",
            "event_candidate",
            "recommendation_item",
            "recommendation_set",
            "content_draft"
          ]
        },
        "targetId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 500
        },
        "decision": {
          "type": "string",
          "enum": [
            "approve",
            "needs_changes",
            "hold",
            "reject",
            "export_ready"
          ]
        },
        "decisionStatus": {
          "type": "string",
          "enum": [
            "approved",
            "needs_changes",
            "held",
            "rejected",
            "export_ready"
          ]
        },
        "decisionPath": {
          "type": "string",
          "pattern": "^marketingReviewDecisions/[^/]+$",
          "maxLength": 260
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callable_responses/admin_set_admin_user_roles_response.schema.json",
      "title": "Admin Set Admin User Roles Callable Response",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "user",
        "beforeRoles",
        "afterRoles"
      ],
      "properties": {
        "user": {
          "$ref": "#/definitions/user"
        },
        "beforeRoles": {
          "$ref": "#/definitions/roles"
        },
        "afterRoles": {
          "$ref": "#/definitions/roles"
        }
      },
      "definitions": {
        "adminRole": {
          "type": "string",
          "enum": [
            "admin",
            "adminOwner",
            "safetyReviewer",
            "support",
            "finance",
            "analyticsViewer"
          ]
        },
        "roles": {
          "type": "array",
          "uniqueItems": true,
          "items": {
            "$ref": "#/definitions/adminRole"
          }
        },
        "nullableText": {
          "anyOf": [
            {
              "type": "string"
            },
            {
              "type": "null"
            }
          ]
        },
        "user": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "targetUid",
            "email",
            "displayName",
            "disabled",
            "roles",
            "assignmentPath"
          ],
          "properties": {
            "targetUid": {
              "type": "string",
              "pattern": "^[A-Za-z0-9_-]{3,128}$"
            },
            "email": {
              "$ref": "#/definitions/nullableText"
            },
            "displayName": {
              "$ref": "#/definitions/nullableText"
            },
            "disabled": {
              "type": "boolean"
            },
            "roles": {
              "$ref": "#/definitions/roles"
            },
            "assignmentPath": {
              "type": "string",
              "pattern": "^adminRoleAssignments/[^/]+$"
            }
          }
        }
      }
    },
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "https://catch.app/contracts/callable_responses/admin_set_cross_paths_showcase_eligibility_response.schema.json",
      "title": "AdminSetCrossPathsShowcaseEligibilityCallableResponse",
      "description": "Validated result of one audited Cross Paths showcase eligibility decision.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "uid",
        "status",
        "reasonCodes",
        "profileFingerprint",
        "ruleVersion",
        "reviewVersion",
        "reviewedAt"
      ],
      "properties": {
        "uid": {
          "$ref": "../shared/event_common.schema.json#/definitions/documentId"
        },
        "status": {
          "type": "string",
          "enum": [
            "eligible",
            "needsReview",
            "paused"
          ]
        },
        "reasonCodes": {
          "type": "array",
          "maxItems": 12,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "enum": [
              "insufficient_photos",
              "incomplete_prompts",
              "missing_relationship_goal",
              "broken_media",
              "photo_moderation_pending",
              "photo_moderation_rejected",
              "public_profile_missing",
              "profile_changed",
              "reviewer_hold",
              "manual_pause"
            ]
          }
        },
        "profileFingerprint": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "ruleVersion": {
          "type": "integer",
          "minimum": 1
        },
        "reviewVersion": {
          "type": "integer",
          "minimum": 1
        },
        "reviewedAt": {
          "type": "string",
          "format": "date-time"
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
              },
              "operationalAttendeeCount": {
                "type": "integer",
                "minimum": 0
              },
              "operationalCheckedInCount": {
                "type": "integer",
                "minimum": 0
              },
              "attendeeSources": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "catchBooking",
                  "hostImport",
                  "hostManual",
                  "webOtp",
                  "providerSync"
                ],
                "properties": {
                  "catchBooking": {
                    "type": "integer",
                    "minimum": 0
                  },
                  "hostImport": {
                    "type": "integer",
                    "minimum": 0
                  },
                  "hostManual": {
                    "type": "integer",
                    "minimum": 0
                  },
                  "webOtp": {
                    "type": "integer",
                    "minimum": 0
                  },
                  "providerSync": {
                    "type": "integer",
                    "minimum": 0
                  }
                }
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
      "$id": "https://catch.app/contracts/admin_runtime/adminDecideOrganizerClaim_response.schema.json",
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
      "$id": "https://catch.app/contracts/admin_runtime/adminGetAccessApplicationDetails_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetAdminUserRoles_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetEventDetails_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetEventIntakeDashboard_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetEventSupplyReadiness_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetMarketingOpsDashboard_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetOrganizerClaimRequestDetails_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetOrganizerDetails_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminGetSafetyTriageDetails_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminListAdminRoleAssignments_response.schema.json",
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
      "$id": "https://catch.app/contracts/admin_runtime/adminListOrganizerClaimRequests_response.schema.json",
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
      "$id": "https://catch.app/contracts/admin_runtime/adminSetOrganizerIndexStatus_response.schema.json",
      "type": "object",
      "additionalProperties": true
    },
    {
      "$id": "https://catch.app/contracts/admin_runtime/adminTakedownExternalEvent_response.schema.json",
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
    "adminAssignSafetyTriageItem": "https://catch.app/contracts/callables/admin_assign_safety_triage_item_payload.schema.json",
    "adminCreateMarketingContentDraft": "https://catch.app/contracts/callables/admin_create_marketing_content_draft_payload.schema.json",
    "adminCreateOrganizerDraftFromCandidate": "https://catch.app/contracts/callables/admin_create_organizer_draft_from_candidate_payload.schema.json",
    "adminDecideAccessApplication": "https://catch.app/contracts/callables/admin_decide_access_application_payload.schema.json",
    "adminDecideOrganizerClaim": "https://catch.app/contracts/callables/admin_decide_club_claim_payload.schema.json",
    "adminDecideOrganizerEventCandidate": "https://catch.app/contracts/callables/admin_decide_organizer_event_candidate_payload.schema.json",
    "adminDecideOrganizerIntake": "https://catch.app/contracts/callables/admin_decide_organizer_intake_payload.schema.json",
    "adminDecideOrganizerPolicyGap": "https://catch.app/contracts/callables/admin_decide_organizer_policy_gap_payload.schema.json",
    "adminDecideSafetyTriageItem": "https://catch.app/contracts/callables/admin_decide_safety_triage_item_payload.schema.json",
    "adminGetAccessApplicationDetails": "https://catch.app/contracts/callables/admin_get_access_application_details_payload.schema.json",
    "adminGetAdminUserRoles": "https://catch.app/contracts/callables/admin_get_admin_user_roles_payload.schema.json",
    "adminGetEventDetails": "https://catch.app/contracts/callables/admin_get_event_details_payload.schema.json",
    "adminGetEventIntakeDashboard": "https://catch.app/contracts/callables/admin_get_event_intake_dashboard_payload.schema.json",
    "adminGetEventSupplyReadiness": "https://catch.app/contracts/callables/admin_get_event_supply_readiness_payload.schema.json",
    "adminGetHostAnalytics": "https://catch.app/contracts/callables/host_analytics_query_payload.schema.json",
    "adminGetMarketingOpsDashboard": "https://catch.app/contracts/callables/admin_get_marketing_ops_dashboard_payload.schema.json",
    "adminGetOrganizerClaimRequestDetails": "https://catch.app/contracts/callables/admin_get_club_claim_request_details_payload.schema.json",
    "adminGetOrganizerDetails": "https://catch.app/contracts/callables/admin_get_organizer_details_payload.schema.json",
    "adminGetOverview": "https://catch.app/contracts/callables/admin_get_overview_payload.schema.json",
    "adminGetSafetyTriageDetails": "https://catch.app/contracts/callables/admin_get_safety_triage_details_payload.schema.json",
    "adminGetUserAnalytics": "https://catch.app/contracts/callables/user_analytics_query_payload.schema.json",
    "adminListActionExecutions": "https://catch.app/contracts/callables/admin_list_action_executions_payload.schema.json",
    "adminListAdminRoleAssignments": "https://catch.app/contracts/callables/admin_list_admin_role_assignments_payload.schema.json",
    "adminListCrossPathsShowcaseCandidates": "https://catch.app/contracts/callables/admin_list_cross_paths_showcase_candidates_payload.schema.json",
    "adminListEventDetails": "https://catch.app/contracts/callables/admin_list_event_details_payload.schema.json",
    "adminListExternalEventDetails": "https://catch.app/contracts/callables/admin_list_external_event_details_payload.schema.json",
    "adminListIntakeOperations": "https://catch.app/contracts/callables/admin_list_intake_operations_payload.schema.json",
    "adminListOrganizerClaimRequests": "https://catch.app/contracts/callables/admin_list_club_claim_requests_payload.schema.json",
    "adminListOrganizerDetails": "https://catch.app/contracts/callables/admin_list_organizer_details_payload.schema.json",
    "adminPublishExternalEvent": "https://catch.app/contracts/callables/admin_publish_external_event_payload.schema.json",
    "adminRecordEventIntakeReviewDecision": "https://catch.app/contracts/callables/admin_record_event_intake_review_decision_payload.schema.json",
    "adminRecordMarketingReviewDecision": "https://catch.app/contracts/callables/admin_record_marketing_review_decision_payload.schema.json",
    "adminRecordOrganizerCuration": "https://catch.app/contracts/callables/admin_record_organizer_curation_payload.schema.json",
    "adminResolveOrganizerEventLocation": "https://catch.app/contracts/callables/admin_resolve_organizer_event_location_payload.schema.json",
    "adminSetAdminUserRoles": "https://catch.app/contracts/callables/admin_set_admin_user_roles_payload.schema.json",
    "adminSetCrossPathsShowcaseEligibility": "https://catch.app/contracts/callables/admin_set_cross_paths_showcase_eligibility_payload.schema.json",
    "adminSetOrganizerIndexStatus": "https://catch.app/contracts/callables/admin_set_club_index_status_payload.schema.json",
    "adminTakedownExternalEvent": "https://catch.app/contracts/callables/admin_takedown_external_event_payload.schema.json",
    "adminUpdateEventDetails": "https://catch.app/contracts/callables/admin_update_event_details_payload.schema.json",
    "adminUpdateOrganizerDetails": "https://catch.app/contracts/callables/admin_update_organizer_details_payload.schema.json"
  },
  "responseSchemaIds": {
    "adminAssignSafetyTriageItem": "https://catch.app/contracts/callable_responses/admin_assign_safety_triage_item_response.schema.json",
    "adminCreateMarketingContentDraft": "https://catch.app/contracts/callable_responses/admin_create_marketing_content_draft_response.schema.json",
    "adminCreateOrganizerDraftFromCandidate": "https://catch.app/contracts/callable_responses/admin_create_organizer_draft_from_candidate_response.schema.json",
    "adminDecideAccessApplication": "https://catch.app/contracts/callable_responses/admin_decide_access_application_response.schema.json",
    "adminDecideOrganizerClaim": "https://catch.app/contracts/admin_runtime/adminDecideOrganizerClaim_response.schema.json",
    "adminDecideOrganizerEventCandidate": "https://catch.app/contracts/admin_runtime/adminDecideOrganizerEventCandidate_response.schema.json",
    "adminDecideOrganizerIntake": "https://catch.app/contracts/admin_runtime/adminDecideOrganizerIntake_response.schema.json",
    "adminDecideOrganizerPolicyGap": "https://catch.app/contracts/admin_runtime/adminDecideOrganizerPolicyGap_response.schema.json",
    "adminDecideSafetyTriageItem": "https://catch.app/contracts/callable_responses/admin_decide_safety_triage_item_response.schema.json",
    "adminGetAccessApplicationDetails": "https://catch.app/contracts/admin_runtime/adminGetAccessApplicationDetails_response.schema.json",
    "adminGetAdminUserRoles": "https://catch.app/contracts/admin_runtime/adminGetAdminUserRoles_response.schema.json",
    "adminGetEventDetails": "https://catch.app/contracts/admin_runtime/adminGetEventDetails_response.schema.json",
    "adminGetEventIntakeDashboard": "https://catch.app/contracts/admin_runtime/adminGetEventIntakeDashboard_response.schema.json",
    "adminGetEventSupplyReadiness": "https://catch.app/contracts/admin_runtime/adminGetEventSupplyReadiness_response.schema.json",
    "adminGetHostAnalytics": "https://catch.app/contracts/callable_responses/host_analytics_response.schema.json",
    "adminGetMarketingOpsDashboard": "https://catch.app/contracts/admin_runtime/adminGetMarketingOpsDashboard_response.schema.json",
    "adminGetOrganizerClaimRequestDetails": "https://catch.app/contracts/admin_runtime/adminGetOrganizerClaimRequestDetails_response.schema.json",
    "adminGetOrganizerDetails": "https://catch.app/contracts/admin_runtime/adminGetOrganizerDetails_response.schema.json",
    "adminGetOverview": "https://catch.app/contracts/callable_responses/admin_get_overview_response.schema.json",
    "adminGetSafetyTriageDetails": "https://catch.app/contracts/admin_runtime/adminGetSafetyTriageDetails_response.schema.json",
    "adminGetUserAnalytics": "https://catch.app/contracts/callable_responses/user_analytics_response.schema.json",
    "adminListActionExecutions": "https://catch.app/contracts/callable_responses/admin_list_action_executions_response.schema.json",
    "adminListAdminRoleAssignments": "https://catch.app/contracts/admin_runtime/adminListAdminRoleAssignments_response.schema.json",
    "adminListCrossPathsShowcaseCandidates": "https://catch.app/contracts/callable_responses/admin_list_cross_paths_showcase_candidates_response.schema.json",
    "adminListEventDetails": "https://catch.app/contracts/admin_runtime/adminListEventDetails_response.schema.json",
    "adminListExternalEventDetails": "https://catch.app/contracts/admin_runtime/adminListExternalEventDetails_response.schema.json",
    "adminListIntakeOperations": "https://catch.app/contracts/callable_responses/admin_list_intake_operations_response.schema.json",
    "adminListOrganizerClaimRequests": "https://catch.app/contracts/admin_runtime/adminListOrganizerClaimRequests_response.schema.json",
    "adminListOrganizerDetails": "https://catch.app/contracts/admin_runtime/adminListOrganizerDetails_response.schema.json",
    "adminPublishExternalEvent": "https://catch.app/contracts/admin_runtime/adminPublishExternalEvent_response.schema.json",
    "adminRecordEventIntakeReviewDecision": "https://catch.app/contracts/admin_runtime/adminRecordEventIntakeReviewDecision_response.schema.json",
    "adminRecordMarketingReviewDecision": "https://catch.app/contracts/callable_responses/admin_record_marketing_review_decision_response.schema.json",
    "adminRecordOrganizerCuration": "https://catch.app/contracts/admin_runtime/adminRecordOrganizerCuration_response.schema.json",
    "adminResolveOrganizerEventLocation": "https://catch.app/contracts/admin_runtime/adminResolveOrganizerEventLocation_response.schema.json",
    "adminSetAdminUserRoles": "https://catch.app/contracts/callable_responses/admin_set_admin_user_roles_response.schema.json",
    "adminSetCrossPathsShowcaseEligibility": "https://catch.app/contracts/callable_responses/admin_set_cross_paths_showcase_eligibility_response.schema.json",
    "adminSetOrganizerIndexStatus": "https://catch.app/contracts/admin_runtime/adminSetOrganizerIndexStatus_response.schema.json",
    "adminTakedownExternalEvent": "https://catch.app/contracts/admin_runtime/adminTakedownExternalEvent_response.schema.json",
    "adminUpdateEventDetails": "https://catch.app/contracts/admin_runtime/adminUpdateEventDetails_response.schema.json",
    "adminUpdateOrganizerDetails": "https://catch.app/contracts/admin_runtime/adminUpdateOrganizerDetails_response.schema.json"
  },
  "strictRequests": [
    "adminAssignSafetyTriageItem",
    "adminCreateMarketingContentDraft",
    "adminCreateOrganizerDraftFromCandidate",
    "adminDecideAccessApplication",
    "adminDecideOrganizerClaim",
    "adminDecideOrganizerEventCandidate",
    "adminDecideOrganizerIntake",
    "adminDecideOrganizerPolicyGap",
    "adminDecideSafetyTriageItem",
    "adminGetAccessApplicationDetails",
    "adminGetAdminUserRoles",
    "adminGetEventDetails",
    "adminGetEventIntakeDashboard",
    "adminGetEventSupplyReadiness",
    "adminGetHostAnalytics",
    "adminGetMarketingOpsDashboard",
    "adminGetOrganizerClaimRequestDetails",
    "adminGetOrganizerDetails",
    "adminGetOverview",
    "adminGetSafetyTriageDetails",
    "adminGetUserAnalytics",
    "adminListActionExecutions",
    "adminListAdminRoleAssignments",
    "adminListCrossPathsShowcaseCandidates",
    "adminListEventDetails",
    "adminListExternalEventDetails",
    "adminListIntakeOperations",
    "adminListOrganizerClaimRequests",
    "adminListOrganizerDetails",
    "adminPublishExternalEvent",
    "adminRecordEventIntakeReviewDecision",
    "adminRecordMarketingReviewDecision",
    "adminRecordOrganizerCuration",
    "adminResolveOrganizerEventLocation",
    "adminSetAdminUserRoles",
    "adminSetCrossPathsShowcaseEligibility",
    "adminSetOrganizerIndexStatus",
    "adminTakedownExternalEvent",
    "adminUpdateEventDetails",
    "adminUpdateOrganizerDetails"
  ],
  "strictResponses": [
    "adminAssignSafetyTriageItem",
    "adminCreateMarketingContentDraft",
    "adminCreateOrganizerDraftFromCandidate",
    "adminDecideAccessApplication",
    "adminDecideSafetyTriageItem",
    "adminGetHostAnalytics",
    "adminGetOverview",
    "adminGetUserAnalytics",
    "adminListActionExecutions",
    "adminListCrossPathsShowcaseCandidates",
    "adminListIntakeOperations",
    "adminRecordMarketingReviewDecision",
    "adminSetAdminUserRoles",
    "adminSetCrossPathsShowcaseEligibility"
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
