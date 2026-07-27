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
    'blockerResolutions',
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
  },
};
