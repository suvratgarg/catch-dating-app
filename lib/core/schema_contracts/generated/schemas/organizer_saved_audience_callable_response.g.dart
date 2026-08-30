// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/organizer_saved_audience_response.schema.json.

const schemaOrganizerSavedAudienceCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/organizer_saved_audience_response.schema.json',
  'title': 'OrganizerSavedAudienceCallableResponse',
  'description': 'Sanitized reusable organizer CRM audience definition.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'organizerId',
    'audienceId',
    'scope',
    'name',
    'status',
    'definition',
    'definitionHash',
    'definitionVersion',
    'revision',
    'lastPreviewMatchCount',
    'lastPreviewReachSummary',
    'lastPreviewAtMillis',
    'createdAtMillis',
    'updatedAtMillis',
  ],
  'properties': <String, Object?>{
    'organizerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'audienceId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'scope': <String, Object?>{
      'const': 'organizerCrm',
    },
    'name': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'active',
        'archived',
      ],
    },
    'definition': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'join',
        'predicates',
      ],
      'properties': <String, Object?>{
        'join': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'all',
            'any',
          ],
        },
        'predicates': <String, Object?>{
          'type': 'array',
          'minItems': 1,
          'maxItems': 8,
          'items': <String, Object?>{
            'oneOf': <Object?>[
              <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'kind',
                  'segmentId',
                ],
                'properties': <String, Object?>{
                  'kind': <String, Object?>{
                    'const': 'computedSegment',
                  },
                  'segmentId': <String, Object?>{
                    'type': 'string',
                    'enum': <Object?>[
                      'new_to_organizer',
                      'first_time_attendee',
                      'repeat_attendee',
                      'regular',
                      'lapsed_regular',
                      'reliable_attendee',
                      'needs_confirmation',
                      'advocate',
                      'high_impact_advocate',
                      'whatsapp_reachable',
                      'sms_reachable',
                    ],
                  },
                },
              },
              <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'kind',
                  'manualTagId',
                ],
                'properties': <String, Object?>{
                  'kind': <String, Object?>{
                    'const': 'manualTag',
                  },
                  'manualTagId': <String, Object?>{
                    'type': 'string',
                    'pattern': '^[a-f0-9]{32}\$',
                  },
                },
              },
              <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'kind',
                  'operator',
                  'eventCount',
                ],
                'properties': <String, Object?>{
                  'kind': <String, Object?>{
                    'const': 'attendanceCount',
                  },
                  'operator': <String, Object?>{
                    'type': 'string',
                    'enum': <Object?>[
                      'atLeast',
                      'atMost',
                    ],
                  },
                  'eventCount': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 10000,
                  },
                },
              },
              <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'kind',
                  'days',
                ],
                'properties': <String, Object?>{
                  'kind': <String, Object?>{
                    'const': 'lastSeenWithinDays',
                  },
                  'days': <String, Object?>{
                    'type': 'integer',
                    'minimum': 1,
                    'maximum': 3650,
                  },
                },
              },
              <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'kind',
                  'intent',
                ],
                'properties': <String, Object?>{
                  'kind': <String, Object?>{
                    'const': 'reachableForIntent',
                  },
                  'intent': <String, Object?>{
                    'const': 'organizerWhatsappCampaign',
                  },
                },
              },
            ],
          },
        },
      },
    },
    'definitionHash': <String, Object?>{
      'type': 'string',
      'pattern': '^[a-f0-9]{64}\$',
    },
    'definitionVersion': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 1000,
    },
    'revision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 9007199254740991,
    },
    'lastPreviewMatchCount': <String, Object?>{
      'type': <Object?>[
        'integer',
        'null',
      ],
      'minimum': 0,
      'maximum': 2500,
    },
    'lastPreviewReachSummary': <String, Object?>{
      'oneOf': <Object?>[
        <String, Object?>{
          'type': 'null',
        },
        <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'inCatch',
            'automatic',
            'byHand',
            'unavailable',
          ],
          'properties': <String, Object?>{
            'inCatch': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 2500,
            },
            'automatic': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 2500,
            },
            'byHand': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 2500,
            },
            'unavailable': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 2500,
            },
          },
        },
      ],
    },
    'lastPreviewAtMillis': <String, Object?>{
      'type': <Object?>[
        'integer',
        'null',
      ],
      'minimum': 0,
    },
    'createdAtMillis': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'updatedAtMillis': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
  },
};
