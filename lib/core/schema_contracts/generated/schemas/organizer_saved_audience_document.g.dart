// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/organizer_saved_audiences.schema.json.

const schemaOrganizerSavedAudienceDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/organizer_saved_audiences.schema.json',
  'title': 'OrganizerSavedAudienceDocument',
  'description': 'One reusable Customers-owned organizer CRM audience. Definitions use only the closed reviewed predicate vocabulary and never contain event-scoped or arbitrary Firestore queries.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'organizerSavedAudiences',
  'x-firestore-path': 'organizerSavedAudiences/{audienceId}',
  'x-document-id-field': 'audienceId',
  'x-owner': 'manager-only organizer saved-audience callables',
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
    'createdByUid',
    'updatedByUid',
    'lastPreviewMatchCount',
    'lastPreviewAt',
    'createdAt',
    'updatedAt',
    'archivedAt',
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
    'createdByUid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'updatedByUid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'lastPreviewMatchCount': <String, Object?>{
      'type': <Object?>[
        'integer',
        'null',
      ],
      'minimum': 0,
      'maximum': 2500,
    },
    'lastPreviewAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'updatedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'archivedAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
  },
  'definitions': <String, Object?>{
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
    'predicate': <String, Object?>{
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
    'computedSegmentPredicate': <String, Object?>{
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
    'manualTagPredicate': <String, Object?>{
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
    'attendanceCountPredicate': <String, Object?>{
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
    'lastSeenWithinDaysPredicate': <String, Object?>{
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
    'reachableForIntentPredicate': <String, Object?>{
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
  },
};
