/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listOrganizerCampaignsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/list_organizer_campaigns_response.schema.json",
  "title": "ListOrganizerCampaignsCallableResponse",
  "description": "Reverse-chronological organizer Sends rows mixing WhatsApp campaigns, event announcements, and follower updates.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "sends",
    "nextCursor"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "sends": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "oneOf": [
          {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "kind",
              "campaignId",
              "name",
              "status",
              "savedAudienceId",
              "savedAudienceName",
              "segmentIds",
              "templateId",
              "templateName",
              "audienceCounts",
              "deliveryCounts",
              "scheduledAtMillis",
              "dispatchedAtMillis",
              "activityAtMillis"
            ],
            "properties": {
              "kind": {
                "const": "campaign"
              },
              "campaignId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              "name": {
                "type": "string",
                "minLength": 1,
                "maxLength": 120
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
              "savedAudienceId": {
                "type": [
                  "string",
                  "null"
                ],
                "minLength": 1,
                "maxLength": 180
              },
              "savedAudienceName": {
                "type": [
                  "string",
                  "null"
                ],
                "minLength": 1,
                "maxLength": 80
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
              "templateId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              "templateName": {
                "type": [
                  "string",
                  "null"
                ],
                "minLength": 1,
                "maxLength": 120
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
              "scheduledAtMillis": {
                "type": [
                  "integer",
                  "null"
                ],
                "minimum": 0
              },
              "dispatchedAtMillis": {
                "type": [
                  "integer",
                  "null"
                ],
                "minimum": 0
              },
              "activityAtMillis": {
                "type": "integer",
                "minimum": 0
              }
            }
          },
          {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "kind",
              "broadcastId",
              "eventId",
              "eventName",
              "audience",
              "recipientCount",
              "sentAtMillis",
              "partialFailure",
              "activityAtMillis"
            ],
            "properties": {
              "kind": {
                "const": "announcement"
              },
              "broadcastId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              "eventId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              "eventName": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              },
              "audience": {
                "type": "string",
                "enum": [
                  "booked",
                  "prospective",
                  "everyone"
                ]
              },
              "recipientCount": {
                "type": "integer",
                "minimum": 0,
                "maximum": 500
              },
              "sentAtMillis": {
                "type": "integer",
                "minimum": 0
              },
              "partialFailure": {
                "type": "boolean"
              },
              "activityAtMillis": {
                "type": "integer",
                "minimum": 0
              }
            }
          },
          {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "kind",
              "postId",
              "eventId",
              "audience",
              "status",
              "deliveryStatus",
              "recipientCount",
              "excludedCount",
              "activityAvailableCount",
              "pushAttemptedCount",
              "pushAcceptedCount",
              "pushFailedCount",
              "pushUnknownCount",
              "createdAtMillis",
              "activityAtMillis"
            ],
            "properties": {
              "kind": {
                "const": "followerUpdate"
              },
              "postId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              "eventId": {
                "type": [
                  "string",
                  "null"
                ],
                "minLength": 1,
                "maxLength": 180
              },
              "audience": {
                "const": "followers"
              },
              "status": {
                "type": "string",
                "enum": [
                  "active",
                  "removed"
                ],
                "x-catch-ownership": "callable-owned"
              },
              "deliveryStatus": {
                "type": "string",
                "enum": [
                  "pending",
                  "completed",
                  "partial",
                  "unknown"
                ]
              },
              "recipientCount": {
                "type": "integer",
                "minimum": 0
              },
              "excludedCount": {
                "type": "integer",
                "minimum": 0
              },
              "activityAvailableCount": {
                "type": "integer",
                "minimum": 0
              },
              "pushAttemptedCount": {
                "type": "integer",
                "minimum": 0
              },
              "pushAcceptedCount": {
                "type": "integer",
                "minimum": 0
              },
              "pushFailedCount": {
                "type": "integer",
                "minimum": 0
              },
              "pushUnknownCount": {
                "type": "integer",
                "minimum": 0
              },
              "createdAtMillis": {
                "type": "integer",
                "minimum": 0
              },
              "activityAtMillis": {
                "type": "integer",
                "minimum": 0
              }
            }
          }
        ]
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
    "send": {
      "oneOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "campaignId",
            "name",
            "status",
            "savedAudienceId",
            "savedAudienceName",
            "segmentIds",
            "templateId",
            "templateName",
            "audienceCounts",
            "deliveryCounts",
            "scheduledAtMillis",
            "dispatchedAtMillis",
            "activityAtMillis"
          ],
          "properties": {
            "kind": {
              "const": "campaign"
            },
            "campaignId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "name": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
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
            "savedAudienceId": {
              "type": [
                "string",
                "null"
              ],
              "minLength": 1,
              "maxLength": 180
            },
            "savedAudienceName": {
              "type": [
                "string",
                "null"
              ],
              "minLength": 1,
              "maxLength": 80
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
            "templateId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "templateName": {
              "type": [
                "string",
                "null"
              ],
              "minLength": 1,
              "maxLength": 120
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
            "scheduledAtMillis": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 0
            },
            "dispatchedAtMillis": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 0
            },
            "activityAtMillis": {
              "type": "integer",
              "minimum": 0
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "broadcastId",
            "eventId",
            "eventName",
            "audience",
            "recipientCount",
            "sentAtMillis",
            "partialFailure",
            "activityAtMillis"
          ],
          "properties": {
            "kind": {
              "const": "announcement"
            },
            "broadcastId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "eventName": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            },
            "audience": {
              "type": "string",
              "enum": [
                "booked",
                "prospective",
                "everyone"
              ]
            },
            "recipientCount": {
              "type": "integer",
              "minimum": 0,
              "maximum": 500
            },
            "sentAtMillis": {
              "type": "integer",
              "minimum": 0
            },
            "partialFailure": {
              "type": "boolean"
            },
            "activityAtMillis": {
              "type": "integer",
              "minimum": 0
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "postId",
            "eventId",
            "audience",
            "status",
            "deliveryStatus",
            "recipientCount",
            "excludedCount",
            "activityAvailableCount",
            "pushAttemptedCount",
            "pushAcceptedCount",
            "pushFailedCount",
            "pushUnknownCount",
            "createdAtMillis",
            "activityAtMillis"
          ],
          "properties": {
            "kind": {
              "const": "followerUpdate"
            },
            "postId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "eventId": {
              "type": [
                "string",
                "null"
              ],
              "minLength": 1,
              "maxLength": 180
            },
            "audience": {
              "const": "followers"
            },
            "status": {
              "type": "string",
              "enum": [
                "active",
                "removed"
              ],
              "x-catch-ownership": "callable-owned"
            },
            "deliveryStatus": {
              "type": "string",
              "enum": [
                "pending",
                "completed",
                "partial",
                "unknown"
              ]
            },
            "recipientCount": {
              "type": "integer",
              "minimum": 0
            },
            "excludedCount": {
              "type": "integer",
              "minimum": 0
            },
            "activityAvailableCount": {
              "type": "integer",
              "minimum": 0
            },
            "pushAttemptedCount": {
              "type": "integer",
              "minimum": 0
            },
            "pushAcceptedCount": {
              "type": "integer",
              "minimum": 0
            },
            "pushFailedCount": {
              "type": "integer",
              "minimum": 0
            },
            "pushUnknownCount": {
              "type": "integer",
              "minimum": 0
            },
            "createdAtMillis": {
              "type": "integer",
              "minimum": 0
            },
            "activityAtMillis": {
              "type": "integer",
              "minimum": 0
            }
          }
        }
      ]
    },
    "campaign": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "campaignId",
        "name",
        "status",
        "savedAudienceId",
        "savedAudienceName",
        "segmentIds",
        "templateId",
        "templateName",
        "audienceCounts",
        "deliveryCounts",
        "scheduledAtMillis",
        "dispatchedAtMillis",
        "activityAtMillis"
      ],
      "properties": {
        "kind": {
          "const": "campaign"
        },
        "campaignId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
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
        "savedAudienceId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 180
        },
        "savedAudienceName": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 80
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
        "templateId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "templateName": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 120
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
        "scheduledAtMillis": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 0
        },
        "dispatchedAtMillis": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 0
        },
        "activityAtMillis": {
          "type": "integer",
          "minimum": 0
        }
      }
    },
    "announcement": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "broadcastId",
        "eventId",
        "eventName",
        "audience",
        "recipientCount",
        "sentAtMillis",
        "partialFailure",
        "activityAtMillis"
      ],
      "properties": {
        "kind": {
          "const": "announcement"
        },
        "broadcastId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "eventName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160
        },
        "audience": {
          "type": "string",
          "enum": [
            "booked",
            "prospective",
            "everyone"
          ]
        },
        "recipientCount": {
          "type": "integer",
          "minimum": 0,
          "maximum": 500
        },
        "sentAtMillis": {
          "type": "integer",
          "minimum": 0
        },
        "partialFailure": {
          "type": "boolean"
        },
        "activityAtMillis": {
          "type": "integer",
          "minimum": 0
        }
      }
    },
    "followerUpdate": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "postId",
        "eventId",
        "audience",
        "status",
        "deliveryStatus",
        "recipientCount",
        "excludedCount",
        "activityAvailableCount",
        "pushAttemptedCount",
        "pushAcceptedCount",
        "pushFailedCount",
        "pushUnknownCount",
        "createdAtMillis",
        "activityAtMillis"
      ],
      "properties": {
        "kind": {
          "const": "followerUpdate"
        },
        "postId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "eventId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 180
        },
        "audience": {
          "const": "followers"
        },
        "status": {
          "type": "string",
          "enum": [
            "active",
            "removed"
          ],
          "x-catch-ownership": "callable-owned"
        },
        "deliveryStatus": {
          "type": "string",
          "enum": [
            "pending",
            "completed",
            "partial",
            "unknown"
          ]
        },
        "recipientCount": {
          "type": "integer",
          "minimum": 0
        },
        "excludedCount": {
          "type": "integer",
          "minimum": 0
        },
        "activityAvailableCount": {
          "type": "integer",
          "minimum": 0
        },
        "pushAttemptedCount": {
          "type": "integer",
          "minimum": 0
        },
        "pushAcceptedCount": {
          "type": "integer",
          "minimum": 0
        },
        "pushFailedCount": {
          "type": "integer",
          "minimum": 0
        },
        "pushUnknownCount": {
          "type": "integer",
          "minimum": 0
        },
        "createdAtMillis": {
          "type": "integer",
          "minimum": 0
        },
        "activityAtMillis": {
          "type": "integer",
          "minimum": 0
        }
      }
    }
  }
} as const;
