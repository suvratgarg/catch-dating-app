// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/organizer_contact_merge_receipts.schema.json.

const schemaOrganizerContactMergeReceiptDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/organizer_contact_merge_receipts.schema.json',
  'title': 'OrganizerContactMergeReceiptDocument',
  'description': 'Immutable evidence for a manager-confirmed organizer contact merge or its reversal.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'organizerContactMergeReceipts',
  'x-firestore-path': 'organizerContactMergeReceipts/{receiptId}',
  'x-document-id-field': 'receiptId',
  'x-owner': 'organizer contact merge and unmerge callables',
  'required': <Object?>[
    'organizerId',
    'operation',
    'survivorContactId',
    'sourceContactId',
    'evidence',
    'conflicts',
    'actorUid',
    'survivorRevision',
    'sourceRevision',
    'reversalOfReceiptId',
    'createdAt',
  ],
  'properties': <String, Object?>{
    'organizerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'operation': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'merge',
        'unmerge',
      ],
    },
    'survivorContactId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'sourceContactId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'evidence': <String, Object?>{
      'type': 'array',
      'maxItems': 20,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'enum': <Object?>[
          'sameVerifiedUid',
          'sameVerifiedPhone',
          'sameImportedPhone',
          'sameEmail',
          'managerConfirmed',
        ],
      },
    },
    'conflicts': <String, Object?>{
      'type': 'array',
      'maxItems': 20,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'maxLength': 120,
      },
    },
    'actorUid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'survivorRevision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 9007199254740991,
    },
    'sourceRevision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 9007199254740991,
    },
    'reversalOfReceiptId': <String, Object?>{
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
  },
};
