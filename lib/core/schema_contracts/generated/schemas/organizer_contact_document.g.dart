// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/organizer_contacts.schema.json.

const schemaOrganizerContactDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/organizer_contacts.schema.json',
  'title': 'OrganizerContactDocument',
  'description': 'Server-owned organizer-scoped contact projection. It is not a Consumer profile and may contain restricted operational contact data.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'organizerContacts',
  'x-firestore-path': 'organizerContacts/{contactId}',
  'x-document-id-field': 'contactId',
  'x-owner': 'organizer audience projection and manager-only CRM callables',
  'required': <Object?>[
    'organizerId',
    'displayName',
    'searchName',
    'linkedUid',
    'phoneE164',
    'email',
    'identityState',
    'identityConfidence',
    'primarySource',
    'ambiguousCandidateContactIds',
    'firstSeenAt',
    'lastSeenAt',
    'sourceCount',
    'whatsappStatus',
    'smsStatus',
    'revision',
    'mergedIntoContactId',
    'createdAt',
    'updatedAt',
    'deletedAt',
  ],
  'properties': <String, Object?>{
    'organizerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'x-catch-ownership': 'server-only',
    },
    'displayName': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'x-catch-ownership': 'server-only',
    },
    'searchName': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'x-catch-ownership': 'server-only',
    },
    'linkedUid': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 180,
      'x-catch-ownership': 'server-only',
    },
    'phoneE164': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'pattern': '^\\+[1-9][0-9]{7,14}\$',
      'x-catch-ownership': 'server-only',
    },
    'email': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'format': 'email',
      'maxLength': 320,
      'x-catch-ownership': 'server-only',
    },
    'identityState': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'unlinked',
        'verified',
        'ambiguous',
        'merged',
      ],
      'x-catch-ownership': 'server-only',
    },
    'identityConfidence': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'eventOnly',
        'proposed',
        'verified',
      ],
      'x-catch-ownership': 'server-only',
    },
    'primarySource': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'catchBooking',
        'hostImport',
        'hostManual',
        'webOtp',
      ],
      'x-catch-ownership': 'server-only',
    },
    'ambiguousCandidateContactIds': <String, Object?>{
      'type': 'array',
      'maxItems': 20,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 180,
      },
      'x-catch-ownership': 'server-only',
    },
    'firstSeenAt': <String, Object?>{
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
      'x-catch-ownership': 'server-only',
    },
    'lastSeenAt': <String, Object?>{
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
      'x-catch-ownership': 'server-only',
    },
    'sourceCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 1000000,
      'x-catch-ownership': 'server-only',
    },
    'whatsappStatus': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'unknown',
        'optedIn',
        'optedOut',
      ],
      'x-catch-ownership': 'server-only',
    },
    'smsStatus': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'unknown',
        'optedIn',
        'optedOut',
      ],
      'x-catch-ownership': 'server-only',
    },
    'revision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 9007199254740991,
      'x-catch-ownership': 'server-only',
    },
    'mergedIntoContactId': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
      'x-catch-ownership': 'server-only',
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
      'x-catch-ownership': 'server-only',
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
      'x-catch-ownership': 'server-only',
    },
    'deletedAt': <String, Object?>{
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
      'x-catch-ownership': 'server-only',
    },
  },
  'definitions': <String, Object?>{
    'channelStatus': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'unknown',
        'optedIn',
        'optedOut',
      ],
      'x-catch-ownership': 'server-only',
    },
  },
};
