// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/organizer_moment_sends.schema.json.

const schemaOrganizerMomentSendDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/organizer_moment_sends.schema.json',
  'title': 'OrganizerMomentSendDocument',
  'description': 'Per-recipient send decision for a moment run; document id is {runId}_{recipientKey} so retries never double-send and every suppression carries its audited reason.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'organizerMomentSends',
  'x-firestore-path': 'organizerMomentSends/{sendId}',
  'x-document-id-field': 'sendId',
  'x-owner': 'moment runner',
  'required': <Object?>[
    'momentId',
    'recipientKey',
    'decision',
    'dayKey',
    'createdAtMillis',
  ],
  'properties': <String, Object?>{
    'momentId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'recipientKey': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 220,
      'description': 'Stable recipient idempotency key: household:|guest:|uid:|contact: prefixed.',
    },
    'decision': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'sent',
        'suppressed',
      ],
    },
    'reason': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'enum': <Object?>[
        'noEndpoint',
        'preferenceOff',
        'noConsent',
        'optedOut',
        'endpointSuppressed',
        'dailyCap',
        null,
      ],
      'description': 'Suppression reason; null on sent.',
    },
    'dayKey': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 40,
      'description': 'Scope-local calendar day (YYYY-MM-DD) for per-endpoint daily caps.',
    },
    'createdAtMillis': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 9007199254740991,
    },
  },
};
