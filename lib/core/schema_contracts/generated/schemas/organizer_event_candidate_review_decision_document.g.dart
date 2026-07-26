// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/organizer_event_candidate_review_decisions.schema.json.

const schemaOrganizerEventCandidateReviewDecisionDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/organizer_event_candidate_review_decisions.schema.json',
  'title': 'OrganizerEventCandidateReviewDecisionDocument',
  'description': 'Latest admin event-candidate review decision stored at organizerEventCandidateReviewDecisions/{decisionId}. Raw provider event evidence and imported events are not stored here.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'organizerEventCandidateReviewDecisions',
  'x-firestore-path': 'organizerEventCandidateReviewDecisions/{decisionId}',
  'x-document-id-field': 'decisionId',
  'x-owner': 'adminDecideOrganizerEventCandidate callable',
  'required': <Object?>[
    'schemaVersion',
    'decisionId',
    'candidateId',
    'decision',
    'decisionStatus',
    'checklist',
    'note',
    'reviewedByUid',
    'reviewedAt',
    'updatedAt',
    'importState',
  ],
  'properties': <String, Object?>{
    'schemaVersion': <String, Object?>{
      'type': 'integer',
      'const': 1,
    },
    'decisionId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
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
    'decisionStatus': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'approved_for_import',
        'held',
        'rejected',
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
    'blockerResolutions': <String, Object?>{
      'type': 'array',
      'maxItems': 6,
      'items': <String, Object?>{
        'title': 'ExternalEventBlockerResolution',
        'description': 'One explicit, event-scoped resolution or policy-backed waiver for a governed external-event import blocker.',
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'blockerCode',
          'outcome',
          'policyGapDecisionId',
          'note',
        ],
        'properties': <String, Object?>{
          'blockerCode': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'missing_exact_coordinates',
              'missing_end_time',
              'missing_location_detail',
              'requires_event_defaults_policy',
              'requires_owner_safe_copy_review',
              'duplicate_normalized_event_key',
            ],
          },
          'outcome': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'resolved',
              'waived',
            ],
          },
          'policyGapDecisionId': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
            'minLength': 1,
            'maxLength': 180,
          },
          'note': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 1000,
          },
        },
        'allOf': <Object?>[
          <String, Object?>{
            'if': <String, Object?>{
              'properties': <String, Object?>{
                'outcome': <String, Object?>{
                  'const': 'waived',
                },
              },
            },
            'then': <String, Object?>{
              'properties': <String, Object?>{
                'policyGapDecisionId': <String, Object?>{
                  'type': 'string',
                },
              },
            },
          },
          <String, Object?>{
            'if': <String, Object?>{
              'properties': <String, Object?>{
                'outcome': <String, Object?>{
                  'const': 'resolved',
                },
              },
            },
            'then': <String, Object?>{
              'properties': <String, Object?>{
                'policyGapDecisionId': <String, Object?>{
                  'type': 'null',
                },
              },
            },
          },
        ],
      },
    },
    'note': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 1000,
    },
    'reviewedByUid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'reviewedAt': <String, Object?>{
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
    'importState': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'blocked_by_policy',
        'not_importable',
        'pending_import',
      ],
    },
  },
};
