// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/program_staff_grants.schema.json.

const schemaProgramStaffGrantDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/program_staff_grants.schema.json',
  'title': 'ProgramStaffGrantDocument',
  'description': 'Server-owned, expiring program staff access. Duties are named and station-scoped; a grant never confers organizer, CRM, messaging or cross-program authority.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'programStaffGrants',
  'x-firestore-path': 'programStaffGrants/{grantId}',
  'x-document-id-field': 'grantId',
  'x-owner': 'program staff access callables',
  'required': <Object?>[
    'organizerId',
    'programId',
    'uid',
    'displayName',
    'phoneLastFour',
    'duties',
    'status',
    'createdBy',
    'createdAt',
    'expiresAt',
    'revokedBy',
    'revokedAt',
    'updatedAt',
    'revision',
  ],
  'properties': <String, Object?>{
    'organizerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'programId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'uid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'displayName': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
    },
    'phoneLastFour': <String, Object?>{
      'type': 'string',
      'pattern': '^[0-9]{4}\$',
    },
    'duties': <String, Object?>{
      'type': 'array',
      'minItems': 1,
      'maxItems': 8,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'duty',
          'pickupPointIds',
          'hotelIds',
          'expiresAtMillis',
        ],
        'properties': <String, Object?>{
          'duty': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'programCoordinator',
              'airportGreeter',
              'hotelDesk',
              'transportDispatcher',
              'reconciliationViewer',
            ],
          },
          'pickupPointIds': <String, Object?>{
            'type': 'array',
            'maxItems': 32,
            'uniqueItems': true,
            'items': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            'description': 'Pickup restriction; empty means all program pickup points. Both resource restrictions must be met by the same assignment.',
          },
          'hotelIds': <String, Object?>{
            'type': 'array',
            'maxItems': 64,
            'uniqueItems': true,
            'items': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            'description': 'Destination restriction; empty means all program hotels. Restrictions from different assignments never combine into new routes.',
          },
          'expiresAtMillis': <String, Object?>{
            'type': 'integer',
            'minimum': 1,
            'maximum': 9007199254740991,
            'description': 'Exclusive expiry of this exact duty and resource scope. Independent of other assignments.',
          },
        },
      },
      'description': 'Up to eight independently expiring scope tuples. Identical tuples may be renewed; different tuples remain separate.',
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'active',
        'revoked',
      ],
    },
    'createdBy': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
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
    'expiresAt': <String, Object?>{
      'type': 'object',
      'description': 'Maximum assignment expiry for indexed grant inventory; authorization also checks each assignment expiry.',
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
    'revokedBy': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 180,
    },
    'revokedAt': <String, Object?>{
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
