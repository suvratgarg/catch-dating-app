// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/program_guests.schema.json.

const schemaProgramGuestDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/program_guests.schema.json',
  'title': 'ProgramGuestDocument',
  'description': 'Server-owned person-level wedding/corporate guest record. One document per invited person; household membership and optional CRM contact links are explicit. A shared phone number never merges two guests.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'programGuests',
  'x-firestore-path': 'programGuests/{guestId}',
  'x-document-id-field': 'guestId',
  'x-owner': 'program guest management and reviewed conversion callables',
  'required': <Object?>[
    'programId',
    'organizerId',
    'displayName',
    'householdId',
    'contactId',
    'phoneE164',
    'email',
    'externalReference',
    'invitationStatus',
    'rsvpStatus',
    'source',
    'createdAt',
    'updatedAt',
    'revision',
  ],
  'properties': <String, Object?>{
    'programId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'organizerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'displayName': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 140,
    },
    'householdId': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 180,
    },
    'contactId': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 180,
      'description': 'Optional link to organizerContacts. Absence never blocks guest operations.',
    },
    'phoneE164': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 20,
      'description': 'Optional reachable phone for this person. Shared family phones do not merge identities.',
    },
    'email': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 320,
    },
    'externalReference': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 180,
      'description': 'Planner-side reference such as a spreadsheet id or invitation code.',
    },
    'invitationStatus': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'notInvited',
        'invited',
        'delivered',
        'responded',
      ],
    },
    'rsvpStatus': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'pending',
        'attending',
        'declined',
        'maybe',
      ],
    },
    'source': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'manual',
        'import',
        'formResponse',
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
    'revision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 9007199254740991,
    },
  },
};
