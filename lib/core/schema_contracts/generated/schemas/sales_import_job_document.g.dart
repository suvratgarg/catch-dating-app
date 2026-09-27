// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/sales_import_jobs.schema.json.

const schemaSalesImportJobDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/sales_import_jobs.schema.json',
  'title': 'SalesImportJobDocument',
  'description': 'Reviewed 25-row maximum import receipt; row details live in a private subcollection.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'salesImportJobs',
  'x-firestore-path': 'salesImportJobs/{importId}',
  'x-owner': 'private Sales import service',
  'required': <Object?>[
    'schemaVersion',
    'classification',
    'importId',
    'sourceId',
    'contentHash',
    'mappingVersion',
    'previewHash',
    'rowCount',
    'counts',
    'status',
    'createdAt',
    'createdBy',
  ],
  'properties': <String, Object?>{
    'schemaVersion': <String, Object?>{
      'const': 1,
    },
    'classification': <String, Object?>{
      'const': 'sales_private',
    },
    'importId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
    },
    'sourceId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
    },
    'contentHash': <String, Object?>{
      'type': 'string',
      'pattern': '^[a-f0-9]{64}\$',
    },
    'mappingVersion': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
    },
    'previewHash': <String, Object?>{
      'type': 'string',
      'pattern': '^[a-f0-9]{64}\$',
    },
    'rowCount': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 25,
    },
    'counts': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'created',
        'matched',
        'duplicate',
        'unresolved',
        'rejected',
      ],
      'properties': <String, Object?>{
        'created': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 25,
        },
        'matched': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 25,
        },
        'duplicate': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 25,
        },
        'unresolved': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 25,
        },
        'rejected': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 25,
        },
      },
    },
    'status': <String, Object?>{
      'const': 'applied',
    },
    'createdAt': <String, Object?>{
      'type': 'string',
      'format': 'date-time',
      'maxLength': 48,
    },
    'createdBy': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
  },
  'x-document-id-field': 'importId',
};
