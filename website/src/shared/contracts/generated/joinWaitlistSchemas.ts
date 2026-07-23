/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const joinWaitlistRequestSchema: Record<string, unknown> =
  {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/http/join_waitlist_request.schema.json",
  "title": "Join Waitlist HTTP Request",
  "description": "Version 1 request body for member waitlist and optional Host operating-application submissions.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "fullName",
    "email",
    "city",
    "role"
  ],
  "properties": {
    "fullName": {
      "type": "string",
      "minLength": 2,
      "maxLength": 100
    },
    "email": {
      "type": "string",
      "format": "email",
      "maxLength": 320
    },
    "city": {
      "type": "string",
      "minLength": 2,
      "maxLength": 80
    },
    "role": {
      "type": "string",
      "enum": [
        "member",
        "runner",
        "host",
        "both"
      ]
    },
    "instagram": {
      "type": "string",
      "maxLength": 240
    },
    "website": {
      "type": "string",
      "maxLength": 512
    },
    "hostApplication": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "organizationName": {
          "type": "string",
          "maxLength": 140
        },
        "organizationType": {
          "type": "string",
          "maxLength": 80
        },
        "operatingCity": {
          "type": "string",
          "maxLength": 80
        },
        "communityLink": {
          "type": "string",
          "maxLength": 512
        },
        "formats": {
          "type": "array",
          "maxItems": 10,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "maxLength": 80
          }
        },
        "eventCadence": {
          "type": "string",
          "maxLength": 80
        },
        "nextEventName": {
          "type": "string",
          "maxLength": 160
        },
        "nextEventDate": {
          "type": "string",
          "maxLength": 80
        },
        "eventLocation": {
          "type": "string",
          "maxLength": 180
        },
        "expectedCapacity": {
          "type": "string",
          "maxLength": 40
        },
        "priceRange": {
          "type": "string",
          "maxLength": 80
        },
        "admissionModel": {
          "type": "string",
          "maxLength": 80
        },
        "waitlistPlan": {
          "type": "string",
          "maxLength": 80
        },
        "paymentReadiness": {
          "type": "string",
          "maxLength": 120
        },
        "eventSuccessModules": {
          "type": "array",
          "maxItems": 16,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "maxLength": 120
          }
        },
        "hostGoals": {
          "type": "string",
          "maxLength": 1000
        },
        "operatingNotes": {
          "type": "string",
          "maxLength": 1000
        }
      }
    },
    "attribution": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "firstTouch",
            "lastTouch"
          ],
          "properties": {
            "firstTouch": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "capturedAt",
                "landingPath",
                "landingUrl",
                "referrer",
                "values"
              ],
              "properties": {
                "capturedAt": {
                  "type": "string",
                  "format": "date-time",
                  "maxLength": 80
                },
                "landingPath": {
                  "type": "string",
                  "maxLength": 512
                },
                "landingUrl": {
                  "type": "string",
                  "maxLength": 1024
                },
                "referrer": {
                  "anyOf": [
                    {
                      "type": "string",
                      "maxLength": 1024
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "values": {
                  "type": "object",
                  "additionalProperties": false,
                  "properties": {
                    "utm_source": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "utm_medium": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "utm_campaign": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "utm_content": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "utm_term": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "gclid": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "gbraid": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "wbraid": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "fbclid": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "ttclid": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "msclkid": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "li_fat_id": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "rdt_cid": {
                      "type": "string",
                      "maxLength": 240
                    }
                  }
                }
              }
            },
            "lastTouch": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "capturedAt",
                "landingPath",
                "landingUrl",
                "referrer",
                "values"
              ],
              "properties": {
                "capturedAt": {
                  "type": "string",
                  "format": "date-time",
                  "maxLength": 80
                },
                "landingPath": {
                  "type": "string",
                  "maxLength": 512
                },
                "landingUrl": {
                  "type": "string",
                  "maxLength": 1024
                },
                "referrer": {
                  "anyOf": [
                    {
                      "type": "string",
                      "maxLength": 1024
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "values": {
                  "type": "object",
                  "additionalProperties": false,
                  "properties": {
                    "utm_source": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "utm_medium": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "utm_campaign": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "utm_content": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "utm_term": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "gclid": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "gbraid": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "wbraid": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "fbclid": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "ttclid": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "msclkid": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "li_fat_id": {
                      "type": "string",
                      "maxLength": 240
                    },
                    "rdt_cid": {
                      "type": "string",
                      "maxLength": 240
                    }
                  }
                }
              }
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "analytics": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "consent",
        "eventId",
        "formVariant",
        "pagePath",
        "pageTitle",
        "submittedAt"
      ],
      "properties": {
        "consent": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "choice",
                "analytics",
                "marketing",
                "updatedAt"
              ],
              "properties": {
                "choice": {
                  "type": "string",
                  "enum": [
                    "accepted",
                    "essential"
                  ]
                },
                "analytics": {
                  "type": "boolean"
                },
                "marketing": {
                  "type": "boolean"
                },
                "updatedAt": {
                  "type": "string",
                  "format": "date-time",
                  "maxLength": 80
                }
              }
            },
            {
              "type": "null"
            }
          ]
        },
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160
        },
        "formVariant": {
          "type": "string",
          "enum": [
            "member",
            "host"
          ]
        },
        "pagePath": {
          "type": "string",
          "maxLength": 512
        },
        "pageTitle": {
          "type": "string",
          "maxLength": 240
        },
        "submittedAt": {
          "type": "string",
          "format": "date-time",
          "maxLength": 80
        }
      }
    }
  },
  "definitions": {
    "hostApplication": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "organizationName": {
          "type": "string",
          "maxLength": 140
        },
        "organizationType": {
          "type": "string",
          "maxLength": 80
        },
        "operatingCity": {
          "type": "string",
          "maxLength": 80
        },
        "communityLink": {
          "type": "string",
          "maxLength": 512
        },
        "formats": {
          "type": "array",
          "maxItems": 10,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "maxLength": 80
          }
        },
        "eventCadence": {
          "type": "string",
          "maxLength": 80
        },
        "nextEventName": {
          "type": "string",
          "maxLength": 160
        },
        "nextEventDate": {
          "type": "string",
          "maxLength": 80
        },
        "eventLocation": {
          "type": "string",
          "maxLength": 180
        },
        "expectedCapacity": {
          "type": "string",
          "maxLength": 40
        },
        "priceRange": {
          "type": "string",
          "maxLength": 80
        },
        "admissionModel": {
          "type": "string",
          "maxLength": 80
        },
        "waitlistPlan": {
          "type": "string",
          "maxLength": 80
        },
        "paymentReadiness": {
          "type": "string",
          "maxLength": 120
        },
        "eventSuccessModules": {
          "type": "array",
          "maxItems": 16,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "maxLength": 120
          }
        },
        "hostGoals": {
          "type": "string",
          "maxLength": 1000
        },
        "operatingNotes": {
          "type": "string",
          "maxLength": 1000
        }
      }
    },
    "attribution": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "firstTouch",
        "lastTouch"
      ],
      "properties": {
        "firstTouch": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "capturedAt",
            "landingPath",
            "landingUrl",
            "referrer",
            "values"
          ],
          "properties": {
            "capturedAt": {
              "type": "string",
              "format": "date-time",
              "maxLength": 80
            },
            "landingPath": {
              "type": "string",
              "maxLength": 512
            },
            "landingUrl": {
              "type": "string",
              "maxLength": 1024
            },
            "referrer": {
              "anyOf": [
                {
                  "type": "string",
                  "maxLength": 1024
                },
                {
                  "type": "null"
                }
              ]
            },
            "values": {
              "type": "object",
              "additionalProperties": false,
              "properties": {
                "utm_source": {
                  "type": "string",
                  "maxLength": 240
                },
                "utm_medium": {
                  "type": "string",
                  "maxLength": 240
                },
                "utm_campaign": {
                  "type": "string",
                  "maxLength": 240
                },
                "utm_content": {
                  "type": "string",
                  "maxLength": 240
                },
                "utm_term": {
                  "type": "string",
                  "maxLength": 240
                },
                "gclid": {
                  "type": "string",
                  "maxLength": 240
                },
                "gbraid": {
                  "type": "string",
                  "maxLength": 240
                },
                "wbraid": {
                  "type": "string",
                  "maxLength": 240
                },
                "fbclid": {
                  "type": "string",
                  "maxLength": 240
                },
                "ttclid": {
                  "type": "string",
                  "maxLength": 240
                },
                "msclkid": {
                  "type": "string",
                  "maxLength": 240
                },
                "li_fat_id": {
                  "type": "string",
                  "maxLength": 240
                },
                "rdt_cid": {
                  "type": "string",
                  "maxLength": 240
                }
              }
            }
          }
        },
        "lastTouch": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "capturedAt",
            "landingPath",
            "landingUrl",
            "referrer",
            "values"
          ],
          "properties": {
            "capturedAt": {
              "type": "string",
              "format": "date-time",
              "maxLength": 80
            },
            "landingPath": {
              "type": "string",
              "maxLength": 512
            },
            "landingUrl": {
              "type": "string",
              "maxLength": 1024
            },
            "referrer": {
              "anyOf": [
                {
                  "type": "string",
                  "maxLength": 1024
                },
                {
                  "type": "null"
                }
              ]
            },
            "values": {
              "type": "object",
              "additionalProperties": false,
              "properties": {
                "utm_source": {
                  "type": "string",
                  "maxLength": 240
                },
                "utm_medium": {
                  "type": "string",
                  "maxLength": 240
                },
                "utm_campaign": {
                  "type": "string",
                  "maxLength": 240
                },
                "utm_content": {
                  "type": "string",
                  "maxLength": 240
                },
                "utm_term": {
                  "type": "string",
                  "maxLength": 240
                },
                "gclid": {
                  "type": "string",
                  "maxLength": 240
                },
                "gbraid": {
                  "type": "string",
                  "maxLength": 240
                },
                "wbraid": {
                  "type": "string",
                  "maxLength": 240
                },
                "fbclid": {
                  "type": "string",
                  "maxLength": 240
                },
                "ttclid": {
                  "type": "string",
                  "maxLength": 240
                },
                "msclkid": {
                  "type": "string",
                  "maxLength": 240
                },
                "li_fat_id": {
                  "type": "string",
                  "maxLength": 240
                },
                "rdt_cid": {
                  "type": "string",
                  "maxLength": 240
                }
              }
            }
          }
        }
      }
    },
    "attributionTouch": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "capturedAt",
        "landingPath",
        "landingUrl",
        "referrer",
        "values"
      ],
      "properties": {
        "capturedAt": {
          "type": "string",
          "format": "date-time",
          "maxLength": 80
        },
        "landingPath": {
          "type": "string",
          "maxLength": 512
        },
        "landingUrl": {
          "type": "string",
          "maxLength": 1024
        },
        "referrer": {
          "anyOf": [
            {
              "type": "string",
              "maxLength": 1024
            },
            {
              "type": "null"
            }
          ]
        },
        "values": {
          "type": "object",
          "additionalProperties": false,
          "properties": {
            "utm_source": {
              "type": "string",
              "maxLength": 240
            },
            "utm_medium": {
              "type": "string",
              "maxLength": 240
            },
            "utm_campaign": {
              "type": "string",
              "maxLength": 240
            },
            "utm_content": {
              "type": "string",
              "maxLength": 240
            },
            "utm_term": {
              "type": "string",
              "maxLength": 240
            },
            "gclid": {
              "type": "string",
              "maxLength": 240
            },
            "gbraid": {
              "type": "string",
              "maxLength": 240
            },
            "wbraid": {
              "type": "string",
              "maxLength": 240
            },
            "fbclid": {
              "type": "string",
              "maxLength": 240
            },
            "ttclid": {
              "type": "string",
              "maxLength": 240
            },
            "msclkid": {
              "type": "string",
              "maxLength": 240
            },
            "li_fat_id": {
              "type": "string",
              "maxLength": 240
            },
            "rdt_cid": {
              "type": "string",
              "maxLength": 240
            }
          }
        }
      }
    },
    "analytics": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "consent",
        "eventId",
        "formVariant",
        "pagePath",
        "pageTitle",
        "submittedAt"
      ],
      "properties": {
        "consent": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "choice",
                "analytics",
                "marketing",
                "updatedAt"
              ],
              "properties": {
                "choice": {
                  "type": "string",
                  "enum": [
                    "accepted",
                    "essential"
                  ]
                },
                "analytics": {
                  "type": "boolean"
                },
                "marketing": {
                  "type": "boolean"
                },
                "updatedAt": {
                  "type": "string",
                  "format": "date-time",
                  "maxLength": 80
                }
              }
            },
            {
              "type": "null"
            }
          ]
        },
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160
        },
        "formVariant": {
          "type": "string",
          "enum": [
            "member",
            "host"
          ]
        },
        "pagePath": {
          "type": "string",
          "maxLength": 512
        },
        "pageTitle": {
          "type": "string",
          "maxLength": 240
        },
        "submittedAt": {
          "type": "string",
          "format": "date-time",
          "maxLength": 80
        }
      }
    },
    "consent": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "choice",
        "analytics",
        "marketing",
        "updatedAt"
      ],
      "properties": {
        "choice": {
          "type": "string",
          "enum": [
            "accepted",
            "essential"
          ]
        },
        "analytics": {
          "type": "boolean"
        },
        "marketing": {
          "type": "boolean"
        },
        "updatedAt": {
          "type": "string",
          "format": "date-time",
          "maxLength": 80
        }
      }
    }
  }
} as const;

export const joinWaitlistResponseSchema: Record<string, unknown> =
  {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/http/join_waitlist_response.schema.json",
  "title": "Join Waitlist HTTP Response",
  "description": "Version 1 JSON response returned by the member waitlist and Host operating-application endpoint.",
  "oneOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "ok",
        "alreadyJoined"
      ],
      "properties": {
        "ok": {
          "const": true
        },
        "alreadyJoined": {
          "type": "boolean"
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "error"
      ],
      "properties": {
        "error": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        }
      }
    }
  ]
} as const;
