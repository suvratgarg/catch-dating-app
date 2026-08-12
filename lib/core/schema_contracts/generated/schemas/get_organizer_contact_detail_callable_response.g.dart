// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/get_organizer_contact_detail_response.schema.json.

const schemaGetOrganizerContactDetailCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/get_organizer_contact_detail_response.schema.json',
  'title': 'GetOrganizerContactDetailCallableResponse',
  'description': 'Manager-only contact facts and bounded event timeline. Private feedback and Event Success inputs are excluded.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'organizerId',
    'contactId',
    'displayName',
    'phoneE164',
    'email',
    'linkedAccount',
    'identityState',
    'identityConfidence',
    'ambiguousCandidateContactIds',
    'traits',
    'events',
    'eventsTruncated',
    'revision',
  ],
  'properties': <String, Object?>{
    'organizerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'contactId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'displayName': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
    },
    'phoneE164': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'pattern': '^\\+[1-9][0-9]{7,14}\$',
    },
    'email': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'format': 'email',
      'maxLength': 320,
    },
    'linkedAccount': <String, Object?>{
      'type': 'boolean',
    },
    'identityState': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'unlinked',
        'verified',
        'ambiguous',
      ],
    },
    'identityConfidence': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'eventOnly',
        'proposed',
        'verified',
      ],
    },
    'ambiguousCandidateContactIds': <String, Object?>{
      'type': 'array',
      'uniqueItems': true,
      'maxItems': 20,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 180,
      },
    },
    'traits': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'expectedEventCount',
        'attendedEventCount',
        'cancelledEventCount',
        'noShowCount',
        'importedEventCount',
        'attendanceRate',
        'segmentIds',
        'whatsappStatus',
        'smsStatus',
        'sourceCoverage',
      ],
      'properties': <String, Object?>{
        'expectedEventCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'attendedEventCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'cancelledEventCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'noShowCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'importedEventCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'attendanceRate': <String, Object?>{
          'type': <Object?>[
            'number',
            'null',
          ],
          'minimum': 0,
          'maximum': 1,
        },
        'segmentIds': <String, Object?>{
          'type': 'array',
          'uniqueItems': true,
          'maxItems': 16,
          'items': <String, Object?>{
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
        'whatsappStatus': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'unknown',
            'optedIn',
            'optedOut',
          ],
        },
        'smsStatus': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'unknown',
            'optedIn',
            'optedOut',
          ],
        },
        'sourceCoverage': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'exact',
            'partial',
            'insufficientData',
          ],
        },
      },
    },
    'events': <String, Object?>{
      'type': 'array',
      'maxItems': 100,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'eventId',
          'attendeeId',
          'displayName',
          'source',
          'status',
          'expected',
          'registered',
          'cancelled',
          'checkedIn',
          'eventStartAtMillis',
          'eventEndAtMillis',
          'registeredAtMillis',
          'cancelledAtMillis',
          'checkedInAtMillis',
        ],
        'properties': <String, Object?>{
          'eventId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
          'attendeeId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
          'displayName': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 120,
          },
          'source': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'catchBooking',
              'hostImport',
              'hostManual',
              'webOtp',
              'providerSync',
            ],
          },
          'status': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'invited',
              'registered',
              'waitlisted',
              'checkedIn',
              'cancelled',
            ],
          },
          'expected': <String, Object?>{
            'type': 'boolean',
          },
          'registered': <String, Object?>{
            'type': 'boolean',
          },
          'cancelled': <String, Object?>{
            'type': 'boolean',
          },
          'checkedIn': <String, Object?>{
            'type': 'boolean',
          },
          'eventStartAtMillis': <String, Object?>{
            'type': <Object?>[
              'integer',
              'null',
            ],
            'minimum': 0,
          },
          'eventEndAtMillis': <String, Object?>{
            'type': <Object?>[
              'integer',
              'null',
            ],
            'minimum': 0,
          },
          'registeredAtMillis': <String, Object?>{
            'type': <Object?>[
              'integer',
              'null',
            ],
            'minimum': 0,
          },
          'cancelledAtMillis': <String, Object?>{
            'type': <Object?>[
              'integer',
              'null',
            ],
            'minimum': 0,
          },
          'checkedInAtMillis': <String, Object?>{
            'type': <Object?>[
              'integer',
              'null',
            ],
            'minimum': 0,
          },
        },
      },
    },
    'eventsTruncated': <String, Object?>{
      'type': 'boolean',
    },
    'revision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 9007199254740991,
    },
  },
  'definitions': <String, Object?>{
    'traits': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'expectedEventCount',
        'attendedEventCount',
        'cancelledEventCount',
        'noShowCount',
        'importedEventCount',
        'attendanceRate',
        'segmentIds',
        'whatsappStatus',
        'smsStatus',
        'sourceCoverage',
      ],
      'properties': <String, Object?>{
        'expectedEventCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'attendedEventCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'cancelledEventCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'noShowCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'importedEventCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'attendanceRate': <String, Object?>{
          'type': <Object?>[
            'number',
            'null',
          ],
          'minimum': 0,
          'maximum': 1,
        },
        'segmentIds': <String, Object?>{
          'type': 'array',
          'uniqueItems': true,
          'maxItems': 16,
          'items': <String, Object?>{
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
        'whatsappStatus': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'unknown',
            'optedIn',
            'optedOut',
          ],
        },
        'smsStatus': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'unknown',
            'optedIn',
            'optedOut',
          ],
        },
        'sourceCoverage': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'exact',
            'partial',
            'insufficientData',
          ],
        },
      },
    },
    'event': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'eventId',
        'attendeeId',
        'displayName',
        'source',
        'status',
        'expected',
        'registered',
        'cancelled',
        'checkedIn',
        'eventStartAtMillis',
        'eventEndAtMillis',
        'registeredAtMillis',
        'cancelledAtMillis',
        'checkedInAtMillis',
      ],
      'properties': <String, Object?>{
        'eventId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'attendeeId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'displayName': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
        },
        'source': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'catchBooking',
            'hostImport',
            'hostManual',
            'webOtp',
            'providerSync',
          ],
        },
        'status': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'invited',
            'registered',
            'waitlisted',
            'checkedIn',
            'cancelled',
          ],
        },
        'expected': <String, Object?>{
          'type': 'boolean',
        },
        'registered': <String, Object?>{
          'type': 'boolean',
        },
        'cancelled': <String, Object?>{
          'type': 'boolean',
        },
        'checkedIn': <String, Object?>{
          'type': 'boolean',
        },
        'eventStartAtMillis': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 0,
        },
        'eventEndAtMillis': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 0,
        },
        'registeredAtMillis': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 0,
        },
        'cancelledAtMillis': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 0,
        },
        'checkedInAtMillis': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 0,
        },
      },
    },
  },
};
