// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/admin_record_event_intake_review_decision_payload.schema.json.

const schemaAdminRecordEventIntakeReviewDecisionCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/admin_record_event_intake_review_decision_payload.schema.json',
  'title': 'AdminRecordEventIntakeReviewDecisionCallablePayload',
  'description': 'Callable payload accepted by adminRecordEventIntakeReviewDecision. This records a manual admin decision for private event-intake artifacts without publishing marketing content or creating canonical events.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'targetType',
    'targetId',
    'decision',
    'checklist',
    'note',
  ],
  'properties': <String, Object?>{
    'targetType': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'source_profile',
        'query_template',
        'run_plan',
        'source_result',
        'event_candidate',
      ],
    },
    'targetId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 240,
    },
    'decision': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'approve',
        'needs_changes',
        'hold',
        'reject',
      ],
    },
    'runId': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 180,
    },
    'note': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 2000,
    },
    'edits': <String, Object?>{
      'type': 'object',
      'additionalProperties': true,
    },
    'checklist': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'sourceReviewed',
        'dateReviewed',
        'venueReviewed',
        'copyReviewed',
        'rightsReviewed',
        'noCatchHostingImplied',
      ],
      'properties': <String, Object?>{
        'sourceReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'dateReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'venueReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'copyReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'rightsReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'noCatchHostingImplied': <String, Object?>{
          'type': 'boolean',
        },
      },
    },
  },
};
