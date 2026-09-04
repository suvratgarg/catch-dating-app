/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createPublicClubReviewCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/create_public_club_review_response.schema.json",
  "title": "CreatePublicClubReviewCallableResponse",
  "description": "Callable response returned by createPublicClubReview after a public organizer review is accepted.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "reviewId",
    "review"
  ],
  "properties": {
    "reviewId": {
      "type": "string",
      "minLength": 1
    },
    "review": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "id",
        "reviewerName",
        "rating",
        "comment",
        "createdAt",
        "verificationStatus",
        "source",
        "moderationStatus",
        "isAnonymous",
        "ownerResponse"
      ],
      "properties": {
        "id": {
          "type": "string",
          "minLength": 1
        },
        "reviewerName": {
          "type": "string",
          "minLength": 1
        },
        "rating": {
          "type": "number",
          "minimum": 0,
          "maximum": 5
        },
        "comment": {
          "type": "string"
        },
        "createdAt": {
          "type": "string",
          "minLength": 1
        },
        "verificationStatus": {
          "type": "string",
          "enum": [
            "verified",
            "unverified"
          ]
        },
        "source": {
          "type": "string",
          "enum": [
            "catchEvent",
            "publicListing"
          ]
        },
        "moderationStatus": {
          "type": "string",
          "enum": [
            "published",
            "pending"
          ]
        },
        "isAnonymous": {
          "type": "boolean"
        },
        "ownerResponse": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "hostName",
                "hostAvatarUrl",
                "message",
                "updatedAt"
              ],
              "properties": {
                "hostName": {
                  "type": "string",
                  "minLength": 1
                },
                "hostAvatarUrl": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "format": "uri"
                },
                "message": {
                  "type": "string"
                },
                "updatedAt": {
                  "type": "string",
                  "minLength": 1
                }
              }
            },
            {
              "type": "null"
            }
          ]
        }
      }
    }
  },
  "definitions": {
    "publicClubReview": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "id",
        "reviewerName",
        "rating",
        "comment",
        "createdAt",
        "verificationStatus",
        "source",
        "moderationStatus",
        "isAnonymous",
        "ownerResponse"
      ],
      "properties": {
        "id": {
          "type": "string",
          "minLength": 1
        },
        "reviewerName": {
          "type": "string",
          "minLength": 1
        },
        "rating": {
          "type": "number",
          "minimum": 0,
          "maximum": 5
        },
        "comment": {
          "type": "string"
        },
        "createdAt": {
          "type": "string",
          "minLength": 1
        },
        "verificationStatus": {
          "type": "string",
          "enum": [
            "verified",
            "unverified"
          ]
        },
        "source": {
          "type": "string",
          "enum": [
            "catchEvent",
            "publicListing"
          ]
        },
        "moderationStatus": {
          "type": "string",
          "enum": [
            "published",
            "pending"
          ]
        },
        "isAnonymous": {
          "type": "boolean"
        },
        "ownerResponse": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "hostName",
                "hostAvatarUrl",
                "message",
                "updatedAt"
              ],
              "properties": {
                "hostName": {
                  "type": "string",
                  "minLength": 1
                },
                "hostAvatarUrl": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "format": "uri"
                },
                "message": {
                  "type": "string"
                },
                "updatedAt": {
                  "type": "string",
                  "minLength": 1
                }
              }
            },
            {
              "type": "null"
            }
          ]
        }
      }
    },
    "ownerResponse": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "hostName",
        "hostAvatarUrl",
        "message",
        "updatedAt"
      ],
      "properties": {
        "hostName": {
          "type": "string",
          "minLength": 1
        },
        "hostAvatarUrl": {
          "type": [
            "string",
            "null"
          ],
          "format": "uri"
        },
        "message": {
          "type": "string"
        },
        "updatedAt": {
          "type": "string",
          "minLength": 1
        }
      }
    }
  }
} as const;
