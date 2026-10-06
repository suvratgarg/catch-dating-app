// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/native_refund_recovery_cursor.schema.json.

const schemaNativeRefundRecoveryCursorDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/native_refund_recovery_cursor.schema.json',
  'title': 'NativeRefundRecoveryCursorDocument',
  'description': 'Server-only, project-bound progress for the bounded native cancellation-refund due queue. Revision compare-and-set prevents stale concurrent invocations from moving discovery backward; a null cursor means wrap to the oldest due row.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'stateId',
    'projectId',
    'schema',
    'revision',
    'cursor',
    'updatedAtMillis',
  ],
  'properties': <String, Object?>{
    'stateId': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'pendingRefunds',
        'cancelledRazorpayPayments',
      ],
      'x-catch-ownership': 'server-only',
    },
    'projectId': <String, Object?>{
      'type': 'string',
      'pattern': '^[a-z][a-z0-9-]{4,28}[a-z0-9]\$',
      'minLength': 6,
      'maxLength': 30,
      'x-catch-ownership': 'server-only',
    },
    'schema': <String, Object?>{
      'type': 'string',
      'const': '1',
      'x-catch-ownership': 'server-only',
    },
    'revision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 9007199254740991,
      'x-catch-ownership': 'server-only',
    },
    'cursor': <String, Object?>{
      'oneOf': <Object?>[
        <String, Object?>{
          'type': 'null',
        },
        <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'nextAttemptOrderKey',
            'paymentId',
          ],
          'properties': <String, Object?>{
            'nextAttemptOrderKey': <String, Object?>{
              'oneOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'double:nan',
                    'double:negativeInfinity',
                    'double:positiveInfinity',
                  ],
                },
                <String, Object?>{
                  'type': 'string',
                  'pattern': '^integer:-?(?:0|[1-9][0-9]*)\$',
                  'maxLength': 28,
                },
                <String, Object?>{
                  'type': 'string',
                  'pattern': '^double:(?:-0|-?(?:0|[1-9][0-9]*)(?:\\.[0-9]+)?(?:e[+-]?[0-9]+)?)\$',
                  'maxLength': 32,
                },
              ],
            },
            'paymentId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 1500,
            },
          },
        },
      ],
      'x-catch-ownership': 'server-only',
    },
    'updatedAtMillis': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 9007199254740991,
      'x-catch-ownership': 'server-only',
    },
  },
  'x-firestore-collection': 'nativeRefundRecoveryCursors',
  'x-firestore-path': 'nativeRefundRecoveryCursors/{stateId}',
  'x-document-id-field': 'stateId',
  'x-owner': 'native cancellation refund recovery scheduler',
};
