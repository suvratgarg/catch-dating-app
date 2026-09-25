// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/organizer_moment_runs.schema.json.

const schemaOrganizerMomentRunDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/organizer_moment_runs.schema.json',
  'title': 'OrganizerMomentRunDocument',
  'description': 'Server-owned planned/fired run for a moment. Deterministic runId encodes moment + anchor revision + due time (or subject/requestKey for triggered/manual), making replans, retries, and sweep overlap idempotent.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'organizerMomentRuns',
  'x-firestore-path': 'organizerMomentRuns/{runId}',
  'x-document-id-field': 'runId',
  'x-owner': 'moment runner',
  'required': <Object?>[
    'runId',
    'momentId',
    'dueAtMillis',
    'anchorRevision',
    'status',
  ],
  'properties': <String, Object?>{
    'runId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 300,
    },
    'momentId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'dueAtMillis': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 9007199254740991,
    },
    'anchorRevision': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 9007199254740991,
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'planned',
        'resolving',
        'dispatched',
        'skipped',
        'superseded',
        'failed',
      ],
    },
    'targetFunctionId': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 180,
    },
    'subjectId': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 300,
      'description': 'Triggered runs: the fact\'s subject (e.g. travel leg id).',
    },
    'reason': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 120,
      'description': 'Skip/failure reason written at run transition.',
    },
    'recipients': <String, Object?>{
      'type': <Object?>[
        'integer',
        'null',
      ],
      'minimum': 0,
    },
    'sent': <String, Object?>{
      'type': <Object?>[
        'integer',
        'null',
      ],
      'minimum': 0,
    },
    'suppressed': <String, Object?>{
      'type': <Object?>[
        'object',
        'null',
      ],
      'additionalProperties': <String, Object?>{
        'type': 'integer',
        'minimum': 0,
      },
      'description': 'Suppression reason -> recipient count rollup.',
    },
    'suppressedNoEndpoint': <String, Object?>{
      'type': <Object?>[
        'integer',
        'null',
      ],
      'minimum': 0,
    },
  },
};
