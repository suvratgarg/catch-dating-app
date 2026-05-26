// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/event_success_scorecards.schema.json.

const schemaEventSuccessScorecardDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/event_success_scorecards.schema.json',
  'title': 'EventSuccessScorecardDocument',
  'description': 'Server-owned aggregate event coaching metrics stored at eventSuccessScorecards/{eventId}. Raw attendee feedback remains private.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'eventSuccessScorecards',
  'x-firestore-path': 'eventSuccessScorecards/{eventId}',
  'x-document-id-field': 'id',
  'x-owner': 'onEventSuccessFeedbackWritten trigger',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'eventId',
    'clubId',
    'bookedCount',
    'checkedInCount',
    'feedbackCount',
    'attendeesWhoMetTwoPlusPeople',
    'mutualMatchCount',
    'chatStartedCount',
    'averageWelcomeRating',
    'averageStructureRating',
    'safetyIncidentCount',
    'updatedAt',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'x-catch-ownership': 'trigger-owned',
    },
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'x-catch-ownership': 'trigger-owned',
    },
    'bookedCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'x-catch-ownership': 'trigger-owned',
    },
    'checkedInCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'x-catch-ownership': 'trigger-owned',
    },
    'feedbackCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'x-catch-ownership': 'trigger-owned',
    },
    'attendeesWhoMetTwoPlusPeople': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'x-catch-ownership': 'trigger-owned',
    },
    'mutualMatchCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'x-catch-ownership': 'trigger-owned',
    },
    'chatStartedCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'x-catch-ownership': 'trigger-owned',
    },
    'averageWelcomeRating': <String, Object?>{
      'type': 'number',
      'minimum': 0,
      'maximum': 5,
      'x-catch-ownership': 'trigger-owned',
    },
    'averageStructureRating': <String, Object?>{
      'type': 'number',
      'minimum': 0,
      'maximum': 5,
      'x-catch-ownership': 'trigger-owned',
    },
    'safetyIncidentCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'x-catch-ownership': 'trigger-owned',
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
      'x-catch-ownership': 'trigger-owned',
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
