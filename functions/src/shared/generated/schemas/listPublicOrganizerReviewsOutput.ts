/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listPublicOrganizerReviewsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/list_public_organizer_reviews_response.schema.json",
  "title": "ListPublicOrganizerReviewsCallableResponse",
  "description": "Callable response returned by listPublicOrganizerReviews for public organizer listing review hydration.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "reviews"
  ],
  "properties": {
    "reviews": {
      "type": "array",
      "maxItems": 50,
      "items": {
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
    }
  },
  "definitions": {
    "publicOrganizerReview": {
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
