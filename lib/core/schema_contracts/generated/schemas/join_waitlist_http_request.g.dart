// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from http/join_waitlist_request.schema.json.

const schemaJoinWaitlistHTTPRequestSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/http/join_waitlist_request.schema.json',
  'title': 'Join Waitlist HTTP Request',
  'description': 'Version 1 request body for member waitlist and optional Host operating-application submissions.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'fullName',
    'email',
    'city',
    'role',
  ],
  'properties': <String, Object?>{
    'fullName': <String, Object?>{
      'type': 'string',
      'minLength': 2,
      'maxLength': 100,
    },
    'email': <String, Object?>{
      'type': 'string',
      'format': 'email',
      'maxLength': 320,
    },
    'city': <String, Object?>{
      'type': 'string',
      'minLength': 2,
      'maxLength': 80,
    },
    'role': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'member',
        'runner',
        'host',
        'both',
      ],
    },
    'instagram': <String, Object?>{
      'type': 'string',
      'maxLength': 240,
    },
    'website': <String, Object?>{
      'type': 'string',
      'maxLength': 512,
    },
    'hostApplication': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'properties': <String, Object?>{
        'organizationName': <String, Object?>{
          'type': 'string',
          'maxLength': 140,
        },
        'organizationType': <String, Object?>{
          'type': 'string',
          'maxLength': 80,
        },
        'operatingCity': <String, Object?>{
          'type': 'string',
          'maxLength': 80,
        },
        'communityLink': <String, Object?>{
          'type': 'string',
          'maxLength': 512,
        },
        'formats': <String, Object?>{
          'type': 'array',
          'maxItems': 10,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'maxLength': 80,
          },
        },
        'eventCadence': <String, Object?>{
          'type': 'string',
          'maxLength': 80,
        },
        'nextEventName': <String, Object?>{
          'type': 'string',
          'maxLength': 160,
        },
        'nextEventDate': <String, Object?>{
          'type': 'string',
          'maxLength': 80,
        },
        'eventLocation': <String, Object?>{
          'type': 'string',
          'maxLength': 180,
        },
        'expectedCapacity': <String, Object?>{
          'type': 'string',
          'maxLength': 40,
        },
        'priceRange': <String, Object?>{
          'type': 'string',
          'maxLength': 80,
        },
        'admissionModel': <String, Object?>{
          'type': 'string',
          'maxLength': 80,
        },
        'waitlistPlan': <String, Object?>{
          'type': 'string',
          'maxLength': 80,
        },
        'paymentReadiness': <String, Object?>{
          'type': 'string',
          'maxLength': 120,
        },
        'eventSuccessModules': <String, Object?>{
          'type': 'array',
          'maxItems': 16,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'maxLength': 120,
          },
        },
        'hostGoals': <String, Object?>{
          'type': 'string',
          'maxLength': 1000,
        },
        'operatingNotes': <String, Object?>{
          'type': 'string',
          'maxLength': 1000,
        },
      },
    },
    'attribution': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'firstTouch',
            'lastTouch',
          ],
          'properties': <String, Object?>{
            'firstTouch': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'capturedAt',
                'landingPath',
                'landingUrl',
                'referrer',
                'values',
              ],
              'properties': <String, Object?>{
                'capturedAt': <String, Object?>{
                  'type': 'string',
                  'format': 'date-time',
                  'maxLength': 80,
                },
                'landingPath': <String, Object?>{
                  'type': 'string',
                  'maxLength': 512,
                },
                'landingUrl': <String, Object?>{
                  'type': 'string',
                  'maxLength': 1024,
                },
                'referrer': <String, Object?>{
                  'anyOf': <Object?>[
                    <String, Object?>{
                      'type': 'string',
                      'maxLength': 1024,
                    },
                    <String, Object?>{
                      'type': 'null',
                    },
                  ],
                },
                'values': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'properties': <String, Object?>{
                    'utm_source': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'utm_medium': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'utm_campaign': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'utm_content': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'utm_term': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'gclid': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'gbraid': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'wbraid': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'fbclid': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'ttclid': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'msclkid': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'li_fat_id': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'rdt_cid': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                  },
                },
              },
            },
            'lastTouch': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'capturedAt',
                'landingPath',
                'landingUrl',
                'referrer',
                'values',
              ],
              'properties': <String, Object?>{
                'capturedAt': <String, Object?>{
                  'type': 'string',
                  'format': 'date-time',
                  'maxLength': 80,
                },
                'landingPath': <String, Object?>{
                  'type': 'string',
                  'maxLength': 512,
                },
                'landingUrl': <String, Object?>{
                  'type': 'string',
                  'maxLength': 1024,
                },
                'referrer': <String, Object?>{
                  'anyOf': <Object?>[
                    <String, Object?>{
                      'type': 'string',
                      'maxLength': 1024,
                    },
                    <String, Object?>{
                      'type': 'null',
                    },
                  ],
                },
                'values': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'properties': <String, Object?>{
                    'utm_source': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'utm_medium': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'utm_campaign': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'utm_content': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'utm_term': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'gclid': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'gbraid': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'wbraid': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'fbclid': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'ttclid': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'msclkid': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'li_fat_id': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                    'rdt_cid': <String, Object?>{
                      'type': 'string',
                      'maxLength': 240,
                    },
                  },
                },
              },
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'analytics': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'consent',
        'eventId',
        'formVariant',
        'pagePath',
        'pageTitle',
        'submittedAt',
      ],
      'properties': <String, Object?>{
        'consent': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'choice',
                'analytics',
                'marketing',
                'updatedAt',
              ],
              'properties': <String, Object?>{
                'choice': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'accepted',
                    'essential',
                  ],
                },
                'analytics': <String, Object?>{
                  'type': 'boolean',
                },
                'marketing': <String, Object?>{
                  'type': 'boolean',
                },
                'updatedAt': <String, Object?>{
                  'type': 'string',
                  'format': 'date-time',
                  'maxLength': 80,
                },
              },
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'eventId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 160,
        },
        'formVariant': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'member',
            'host',
          ],
        },
        'pagePath': <String, Object?>{
          'type': 'string',
          'maxLength': 512,
        },
        'pageTitle': <String, Object?>{
          'type': 'string',
          'maxLength': 240,
        },
        'submittedAt': <String, Object?>{
          'type': 'string',
          'format': 'date-time',
          'maxLength': 80,
        },
      },
    },
  },
  'definitions': <String, Object?>{
    'hostApplication': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'properties': <String, Object?>{
        'organizationName': <String, Object?>{
          'type': 'string',
          'maxLength': 140,
        },
        'organizationType': <String, Object?>{
          'type': 'string',
          'maxLength': 80,
        },
        'operatingCity': <String, Object?>{
          'type': 'string',
          'maxLength': 80,
        },
        'communityLink': <String, Object?>{
          'type': 'string',
          'maxLength': 512,
        },
        'formats': <String, Object?>{
          'type': 'array',
          'maxItems': 10,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'maxLength': 80,
          },
        },
        'eventCadence': <String, Object?>{
          'type': 'string',
          'maxLength': 80,
        },
        'nextEventName': <String, Object?>{
          'type': 'string',
          'maxLength': 160,
        },
        'nextEventDate': <String, Object?>{
          'type': 'string',
          'maxLength': 80,
        },
        'eventLocation': <String, Object?>{
          'type': 'string',
          'maxLength': 180,
        },
        'expectedCapacity': <String, Object?>{
          'type': 'string',
          'maxLength': 40,
        },
        'priceRange': <String, Object?>{
          'type': 'string',
          'maxLength': 80,
        },
        'admissionModel': <String, Object?>{
          'type': 'string',
          'maxLength': 80,
        },
        'waitlistPlan': <String, Object?>{
          'type': 'string',
          'maxLength': 80,
        },
        'paymentReadiness': <String, Object?>{
          'type': 'string',
          'maxLength': 120,
        },
        'eventSuccessModules': <String, Object?>{
          'type': 'array',
          'maxItems': 16,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'maxLength': 120,
          },
        },
        'hostGoals': <String, Object?>{
          'type': 'string',
          'maxLength': 1000,
        },
        'operatingNotes': <String, Object?>{
          'type': 'string',
          'maxLength': 1000,
        },
      },
    },
    'attribution': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'firstTouch',
        'lastTouch',
      ],
      'properties': <String, Object?>{
        'firstTouch': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'capturedAt',
            'landingPath',
            'landingUrl',
            'referrer',
            'values',
          ],
          'properties': <String, Object?>{
            'capturedAt': <String, Object?>{
              'type': 'string',
              'format': 'date-time',
              'maxLength': 80,
            },
            'landingPath': <String, Object?>{
              'type': 'string',
              'maxLength': 512,
            },
            'landingUrl': <String, Object?>{
              'type': 'string',
              'maxLength': 1024,
            },
            'referrer': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'maxLength': 1024,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'values': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'properties': <String, Object?>{
                'utm_source': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'utm_medium': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'utm_campaign': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'utm_content': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'utm_term': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'gclid': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'gbraid': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'wbraid': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'fbclid': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'ttclid': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'msclkid': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'li_fat_id': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'rdt_cid': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
              },
            },
          },
        },
        'lastTouch': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'capturedAt',
            'landingPath',
            'landingUrl',
            'referrer',
            'values',
          ],
          'properties': <String, Object?>{
            'capturedAt': <String, Object?>{
              'type': 'string',
              'format': 'date-time',
              'maxLength': 80,
            },
            'landingPath': <String, Object?>{
              'type': 'string',
              'maxLength': 512,
            },
            'landingUrl': <String, Object?>{
              'type': 'string',
              'maxLength': 1024,
            },
            'referrer': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'maxLength': 1024,
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'values': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'properties': <String, Object?>{
                'utm_source': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'utm_medium': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'utm_campaign': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'utm_content': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'utm_term': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'gclid': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'gbraid': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'wbraid': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'fbclid': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'ttclid': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'msclkid': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'li_fat_id': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
                'rdt_cid': <String, Object?>{
                  'type': 'string',
                  'maxLength': 240,
                },
              },
            },
          },
        },
      },
    },
    'attributionTouch': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'capturedAt',
        'landingPath',
        'landingUrl',
        'referrer',
        'values',
      ],
      'properties': <String, Object?>{
        'capturedAt': <String, Object?>{
          'type': 'string',
          'format': 'date-time',
          'maxLength': 80,
        },
        'landingPath': <String, Object?>{
          'type': 'string',
          'maxLength': 512,
        },
        'landingUrl': <String, Object?>{
          'type': 'string',
          'maxLength': 1024,
        },
        'referrer': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'maxLength': 1024,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'values': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'properties': <String, Object?>{
            'utm_source': <String, Object?>{
              'type': 'string',
              'maxLength': 240,
            },
            'utm_medium': <String, Object?>{
              'type': 'string',
              'maxLength': 240,
            },
            'utm_campaign': <String, Object?>{
              'type': 'string',
              'maxLength': 240,
            },
            'utm_content': <String, Object?>{
              'type': 'string',
              'maxLength': 240,
            },
            'utm_term': <String, Object?>{
              'type': 'string',
              'maxLength': 240,
            },
            'gclid': <String, Object?>{
              'type': 'string',
              'maxLength': 240,
            },
            'gbraid': <String, Object?>{
              'type': 'string',
              'maxLength': 240,
            },
            'wbraid': <String, Object?>{
              'type': 'string',
              'maxLength': 240,
            },
            'fbclid': <String, Object?>{
              'type': 'string',
              'maxLength': 240,
            },
            'ttclid': <String, Object?>{
              'type': 'string',
              'maxLength': 240,
            },
            'msclkid': <String, Object?>{
              'type': 'string',
              'maxLength': 240,
            },
            'li_fat_id': <String, Object?>{
              'type': 'string',
              'maxLength': 240,
            },
            'rdt_cid': <String, Object?>{
              'type': 'string',
              'maxLength': 240,
            },
          },
        },
      },
    },
    'analytics': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'consent',
        'eventId',
        'formVariant',
        'pagePath',
        'pageTitle',
        'submittedAt',
      ],
      'properties': <String, Object?>{
        'consent': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'choice',
                'analytics',
                'marketing',
                'updatedAt',
              ],
              'properties': <String, Object?>{
                'choice': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'accepted',
                    'essential',
                  ],
                },
                'analytics': <String, Object?>{
                  'type': 'boolean',
                },
                'marketing': <String, Object?>{
                  'type': 'boolean',
                },
                'updatedAt': <String, Object?>{
                  'type': 'string',
                  'format': 'date-time',
                  'maxLength': 80,
                },
              },
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'eventId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 160,
        },
        'formVariant': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'member',
            'host',
          ],
        },
        'pagePath': <String, Object?>{
          'type': 'string',
          'maxLength': 512,
        },
        'pageTitle': <String, Object?>{
          'type': 'string',
          'maxLength': 240,
        },
        'submittedAt': <String, Object?>{
          'type': 'string',
          'format': 'date-time',
          'maxLength': 80,
        },
      },
    },
    'consent': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'choice',
        'analytics',
        'marketing',
        'updatedAt',
      ],
      'properties': <String, Object?>{
        'choice': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'accepted',
            'essential',
          ],
        },
        'analytics': <String, Object?>{
          'type': 'boolean',
        },
        'marketing': <String, Object?>{
          'type': 'boolean',
        },
        'updatedAt': <String, Object?>{
          'type': 'string',
          'format': 'date-time',
          'maxLength': 80,
        },
      },
    },
  },
};
