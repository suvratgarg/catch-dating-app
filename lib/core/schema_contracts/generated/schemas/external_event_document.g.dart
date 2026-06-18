// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/external_events.schema.json.

const schemaExternalEventDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/external_events.schema.json',
  'title': 'ExternalEventDocument',
  'description': 'Read-only external event document stored at externalEvents/{eventId}. These records are sourced from reviewed organizer intake candidates and may link to external booking platforms, but they never enable Catch booking, payments, reservations, waitlists, attendance, or schedule locks.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'externalEvents',
  'x-firestore-path': 'externalEvents/{eventId}',
  'x-document-id-field': 'eventId',
  'x-owner': 'organizer intake import tooling after admin review; external source corrections and takedowns are admin-owned',
  'required': <Object?>[
    'schemaVersion',
    'eventId',
    'canonicalHostId',
    'compatibilityClubId',
    'title',
    'description',
    'startTime',
    'endTime',
    'timezone',
    'meetingPoint',
    'meetingLocation',
    'locationDetails',
    'photoUrl',
    'activity',
    'price',
    'status',
    'publicationStatus',
    'booking',
    'discovery',
    'dedupe',
    'externalSource',
    'review',
    'createdAt',
    'updatedAt',
  ],
  'properties': <String, Object?>{
    'schemaVersion': <String, Object?>{
      'type': 'integer',
      'const': 1,
    },
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'canonicalHostId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'compatibilityClubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'title': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 240,
    },
    'description': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 4000,
    },
    'startTime': <String, Object?>{
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
    'endTime': <String, Object?>{
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
    'timezone': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 80,
    },
    'meetingPoint': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 240,
    },
    'meetingLocation': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'name',
        'address',
        'placeId',
        'latitude',
        'longitude',
        'notes',
      ],
      'properties': <String, Object?>{
        'name': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 240,
        },
        'address': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 500,
        },
        'placeId': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'minLength': 1,
          'maxLength': 256,
        },
        'latitude': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': <Object?>[
                'number',
                'null',
              ],
              'minimum': -90,
              'maximum': 90,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'longitude': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': <Object?>[
                'number',
                'null',
              ],
              'minimum': -180,
              'maximum': 180,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'notes': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 1000,
        },
      },
    },
    'locationDetails': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 1000,
    },
    'photoUrl': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'format': 'uri',
          'maxLength': 2048,
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'activity': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'version',
        'activityKind',
        'interactionModel',
        'source',
      ],
      'properties': <String, Object?>{
        'version': <String, Object?>{
          'type': 'integer',
          'const': 1,
        },
        'activityKind': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'socialRun',
            'running',
            'walking',
            'pickleball',
            'padel',
            'tennis',
            'badminton',
            'cycling',
            'spinClass',
            'yoga',
            'strengthTraining',
            'pubQuiz',
            'barCrawl',
            'dinner',
            'singlesMixer',
            'openActivity',
          ],
        },
        'interactionModel': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'pacePods',
            'pairedRotations',
            'teamRotations',
            'seatedTable',
            'freeFormMixer',
            'hostLedProgram',
            'openFormat',
          ],
        },
        'source': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'heuristic',
            'admin',
            'source',
          ],
        },
      },
    },
    'price': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'displayText',
        'parsedPriceInPaise',
        'currency',
      ],
      'properties': <String, Object?>{
        'displayText': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 120,
        },
        'parsedPriceInPaise': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 0,
          'maximum': 100000000,
        },
        'currency': <String, Object?>{
          'type': 'string',
          'pattern': '^[A-Z]{3}\$',
        },
      },
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'active',
        'cancelled',
      ],
    },
    'publicationStatus': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'draft',
        'public',
        'archived',
        'removed',
      ],
    },
    'booking': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'mode',
        'catchBookingEnabled',
        'catchPaymentsEnabled',
        'catchReservationsEnabled',
        'catchWaitlistEnabled',
        'externalLinks',
      ],
      'properties': <String, Object?>{
        'mode': <String, Object?>{
          'type': 'string',
          'const': 'external_outbound_only',
        },
        'catchBookingEnabled': <String, Object?>{
          'type': 'boolean',
          'const': false,
        },
        'catchPaymentsEnabled': <String, Object?>{
          'type': 'boolean',
          'const': false,
        },
        'catchReservationsEnabled': <String, Object?>{
          'type': 'boolean',
          'const': false,
        },
        'catchWaitlistEnabled': <String, Object?>{
          'type': 'boolean',
          'const': false,
        },
        'externalLinks': <String, Object?>{
          'type': 'array',
          'minItems': 1,
          'maxItems': 12,
          'items': <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'platform',
              'url',
              'linkType',
              'sourceEventKey',
              'candidateId',
              'primary',
            ],
            'properties': <String, Object?>{
              'platform': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'bookMyShow',
                  'district',
                  'luma',
                  'partiful',
                  'sortMyScene',
                ],
              },
              'url': <String, Object?>{
                'type': 'string',
                'format': 'uri',
                'maxLength': 2048,
              },
              'linkType': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'booking_or_event_page',
                  'source_surface',
                ],
              },
              'sourceEventKey': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 240,
              },
              'candidateId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 240,
              },
              'primary': <String, Object?>{
                'type': 'boolean',
              },
            },
          },
        },
      },
    },
    'discovery': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'citySlug',
        'countryCode',
        'availability',
        'manualApprovalRequired',
      ],
      'properties': <String, Object?>{
        'citySlug': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'minLength': 1,
              'maxLength': 80,
              'pattern': '^[a-z0-9-]+\$',
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'countryCode': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'minLength': 2,
          'maxLength': 2,
        },
        'availability': <String, Object?>{
          'type': 'string',
          'const': 'read_only_external',
        },
        'manualApprovalRequired': <String, Object?>{
          'type': 'boolean',
          'const': true,
        },
      },
    },
    'dedupe': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'normalizedEventKey',
        'primaryCandidateId',
        'duplicateCandidateIds',
        'conflictPolicy',
      ],
      'properties': <String, Object?>{
        'normalizedEventKey': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 500,
        },
        'primaryCandidateId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 240,
        },
        'duplicateCandidateIds': <String, Object?>{
          'type': 'array',
          'maxItems': 24,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 240,
          },
        },
        'conflictPolicy': <String, Object?>{
          'type': 'string',
          'const': 'single_read_only_event_with_multiple_outbound_links',
        },
      },
    },
    'externalSource': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'candidateId',
        'sourceEventKey',
        'sourceEventId',
        'platform',
        'eventUrl',
        'sourceUrl',
      ],
      'properties': <String, Object?>{
        'candidateId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 240,
        },
        'sourceEventKey': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 240,
        },
        'sourceEventId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'platform': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'bookMyShow',
            'district',
            'luma',
            'partiful',
            'sortMyScene',
          ],
        },
        'eventUrl': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'format': 'uri',
              'maxLength': 2048,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'sourceUrl': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'format': 'uri',
              'maxLength': 2048,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
      },
    },
    'review': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'eventReviewBatchId',
        'reviewer',
        'decidedAt',
        'note',
        'importPolicyAcknowledged',
        'ownerSafeCopyReviewed',
      ],
      'properties': <String, Object?>{
        'eventReviewBatchId': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 180,
        },
        'reviewer': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 180,
        },
        'decidedAt': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'pattern': '^\\d{4}-\\d{2}-\\d{2}\$',
        },
        'note': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 1000,
        },
        'importPolicyAcknowledged': <String, Object?>{
          'type': 'boolean',
        },
        'ownerSafeCopyReviewed': <String, Object?>{
          'type': 'boolean',
        },
      },
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
  },
};
