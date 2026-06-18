// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/admin_decide_organizer_intake_payload.schema.json.

const schemaAdminDecideOrganizerIntakeCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/admin_decide_organizer_intake_payload.schema.json',
  'title': 'AdminDecideOrganizerIntakeCallablePayload',
  'description': 'Callable payload accepted by adminDecideOrganizerIntake. This records a manual admin review decision for a private organizer-intake candidate.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'entityId',
    'decision',
    'appVisibility',
    'checklist',
    'note',
  ],
  'properties': <String, Object?>{
    'entityId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'decision': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'approve_public',
        'hold',
        'suppress',
      ],
    },
    'appVisibility': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'hidden',
        'discoverable',
      ],
    },
    'checklist': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'identityReviewed',
        'surfaceInventoryReviewed',
        'ownerSafeCopyReviewed',
        'marketScopeReviewed',
        'mediaRightsReviewed',
        'crawlDisabledReviewed',
      ],
      'properties': <String, Object?>{
        'identityReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'surfaceInventoryReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'ownerSafeCopyReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'marketScopeReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'mediaRightsReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'crawlDisabledReviewed': <String, Object?>{
          'type': 'boolean',
        },
        'manualReportsReviewed': <String, Object?>{
          'type': 'boolean',
          'description': 'True when the reviewer explicitly inspected manual reports that have no local raw artifact. Raw evidence remains outside Firestore; replay validation decides when this acknowledgement is required.',
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
