// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/payments.schema.json.

const schemaPaymentDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/payments.schema.json',
  'title': 'PaymentDocument',
  'description': 'Canonical payment record stored at payments/{paymentId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'payments',
  'x-firestore-path': 'payments/{paymentId}',
  'x-document-id-field': 'id',
  'x-owner': 'payments callables',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'userId',
    'orderId',
    'paymentId',
    'eventId',
    'amount',
    'currency',
    'status',
    'signUpFailed',
    'createdAt',
  ],
  'properties': <String, Object?>{
    'userId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'x-catch-ownership': 'callable-owned',
    },
    'orderId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 240,
      'x-catch-ownership': 'callable-owned',
    },
    'paymentId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 240,
      'x-catch-ownership': 'callable-owned',
    },
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'x-catch-ownership': 'callable-owned',
    },
    'amount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 100000000,
      'x-catch-ownership': 'callable-owned',
    },
    'currency': <String, Object?>{
      'type': 'string',
      'minLength': 3,
      'maxLength': 3,
      'x-catch-ownership': 'callable-owned',
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'pending',
        'completed',
        'failed',
        'refunded',
      ],
      'x-catch-ownership': 'callable-owned',
    },
    'signUpFailed': <String, Object?>{
      'type': 'boolean',
      'x-catch-ownership': 'callable-owned',
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
      'x-catch-ownership': 'callable-owned',
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};
