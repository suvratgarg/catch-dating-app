// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/admin_decide_organizer_event_candidate_payload.schema.json.

const schemaAdminDecideOrganizerEventCandidateCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/admin_decide_organizer_event_candidate_payload.schema.json',
  'title': 'AdminDecideOrganizerEventCandidateCallablePayload',
  'description': 'Callable payload accepted by adminDecideOrganizerEventCandidate. This records a manual admin review decision for a private external event candidate without importing the event.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'candidateId',
    'decision',
    'checklist',
    'note',
  ],
  'properties': <String, Object?>{
    'candidateId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 240,
    },
    'decision': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'approve_for_import',
        'hold',
        'reject',
      ],
    },
    'checklist': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'identityReviewed',
        'sourceEventReviewed',
        'timeReviewed',
        'locationReviewed',
        'dedupeReviewed',
        'ownerSafeCopyReviewed',
        'importPolicyAcknowledged',
      ],
      'properties': <String, Object?>{
        'identityReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'sourceEventReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'timeReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'locationReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'dedupeReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'ownerSafeCopyReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'importPolicyAcknowledged': <String, Object?>{
          'type': 'boolean',
        },
      },
    },
    'note': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 1000,
    },
  },
};
