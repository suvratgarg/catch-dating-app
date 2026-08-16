// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/organizer_messaging_webhook_events.schema.json.

const schemaOrganizerMessagingWebhookEventDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/organizer_messaging_webhook_events.schema.json',
  'title': 'OrganizerMessagingWebhookEventDocument',
  'description': 'Sanitized durable provider event queued after signature verification. Inbound text is retained here for at most 30 days and copied into the organizer thread store for at most 12 months.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'organizerMessagingWebhookEvents',
  'x-firestore-path': 'organizerMessagingWebhookEvents/{eventId}',
  'x-document-id-field': 'eventId',
  'x-owner': 'WhatsApp webhook ingress and receipt processor',
  'required': <Object?>[
    'provider',
    'providerEventId',
    'organizerId',
    'connectionId',
    'eventKind',
    'providerMessageId',
    'contextProviderMessageId',
    'deliveryStatus',
    'endpointHash',
    'isStop',
    'hasReply',
    'inboundBody',
    'providerErrorCode',
    'providerOccurredAt',
    'processingStatus',
    'attemptCount',
    'createdAt',
    'processedAt',
    'expiresAt',
  ],
  'properties': <String, Object?>{
    'provider': <String, Object?>{
      'const': 'metaCloudApi',
    },
    'providerEventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 240,
    },
    'organizerId': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 180,
    },
    'connectionId': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 180,
    },
    'eventKind': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'status',
        'inbound',
        'template',
        'quality',
        'account',
        'unmatched',
      ],
    },
    'providerMessageId': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 240,
    },
    'contextProviderMessageId': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 240,
    },
    'deliveryStatus': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'enum': <Object?>[
        null,
        'sent',
        'delivered',
        'read',
        'failed',
      ],
    },
    'endpointHash': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'pattern': '^[a-f0-9]{64}\$',
    },
    'isStop': <String, Object?>{
      'type': 'boolean',
    },
    'hasReply': <String, Object?>{
      'type': 'boolean',
    },
    'inboundBody': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 4096,
    },
    'providerErrorCode': <String, Object?>{
      'type': <Object?>[
        'integer',
        'null',
      ],
      'minimum': 0,
      'maximum': 999999999,
    },
    'providerOccurredAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
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
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'processingStatus': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'pending',
        'processed',
        'unmatched',
        'failed',
      ],
    },
    'attemptCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 100,
    },
    'createdAt': <String, Object?>{
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
    'processedAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
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
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'expiresAt': <String, Object?>{
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
      'x-firestore-ttl': true,
    },
  },
};
