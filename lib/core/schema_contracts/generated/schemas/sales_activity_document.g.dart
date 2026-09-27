// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/sales_activities.schema.json.

const schemaSalesActivityDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/sales_activities.schema.json',
  'title': 'SalesActivityDocument',
  'description': 'Private timeline. Manual outbound is actor-attested only; claim transitions originate only from canonical server workflows.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'salesActivities',
  'x-firestore-path': 'salesActivities/{activityId}',
  'x-owner': 'private Sales service and canonical claim projection',
  'required': <Object?>[
    'schemaVersion',
    'classification',
    'activityId',
    'organizerId',
    'opportunityId',
    'type',
    'channel',
    'outcome',
    'providerConfirmed',
    'occurredAt',
    'recordedAt',
    'note',
    'actorUid',
  ],
  'properties': <String, Object?>{
    'schemaVersion': <String, Object?>{
      'const': 1,
    },
    'classification': <String, Object?>{
      'const': 'sales_private',
    },
    'activityId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
    },
    'organizerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
    },
    'opportunityId': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
          'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'type': <String, Object?>{
      'enum': <Object?>[
        'note',
        'reply',
        'call',
        'demo',
        'pilot',
        'correction',
        'outreach_sent_manual',
        'claim_requested',
        'claim_approved',
        'claim_rejected',
      ],
    },
    'channel': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'enum': <Object?>[
            'email',
            'whatsapp',
            'other',
          ],
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'outcome': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'const': 'actor_attested_sent',
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'providerConfirmed': <String, Object?>{
      'const': false,
    },
    'occurredAt': <String, Object?>{
      'type': 'string',
      'format': 'date-time',
      'maxLength': 48,
    },
    'recordedAt': <String, Object?>{
      'type': 'string',
      'format': 'date-time',
      'maxLength': 48,
    },
    'note': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 2000,
    },
    'actorUid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'source': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'kind',
        'claimRequestId',
        'transitionId',
      ],
      'properties': <String, Object?>{
        'kind': <String, Object?>{
          'const': 'organizer_claim',
        },
        'claimRequestId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
          'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
        },
        'transitionId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
          'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
        },
      },
    },
  },
  'x-document-id-field': 'activityId',
  'allOf': <Object?>[
    <String, Object?>{
      'if': <String, Object?>{
        'properties': <String, Object?>{
          'type': <String, Object?>{
            'enum': <Object?>[
              'claim_requested',
              'claim_approved',
              'claim_rejected',
            ],
          },
        },
      },
      'then': <String, Object?>{
        'required': <Object?>[
          'source',
        ],
        'properties': <String, Object?>{
          'channel': <String, Object?>{
            'type': 'null',
          },
          'outcome': <String, Object?>{
            'type': 'null',
          },
        },
      },
      'else': <String, Object?>{
        'not': <String, Object?>{
          'required': <Object?>[
            'source',
          ],
        },
      },
    },
    <String, Object?>{
      'if': <String, Object?>{
        'properties': <String, Object?>{
          'type': <String, Object?>{
            'const': 'outreach_sent_manual',
          },
        },
      },
      'then': <String, Object?>{
        'properties': <String, Object?>{
          'channel': <String, Object?>{
            'enum': <Object?>[
              'email',
              'whatsapp',
              'other',
            ],
          },
          'outcome': <String, Object?>{
            'const': 'actor_attested_sent',
          },
        },
      },
      'else': <String, Object?>{
        'properties': <String, Object?>{
          'channel': <String, Object?>{
            'type': 'null',
          },
          'outcome': <String, Object?>{
            'type': 'null',
          },
        },
      },
    },
  ],
};
