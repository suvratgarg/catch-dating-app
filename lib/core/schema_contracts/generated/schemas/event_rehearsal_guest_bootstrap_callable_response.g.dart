// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/event_rehearsal_guest_bootstrap_response.schema.json.

const schemaEventRehearsalGuestBootstrapCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/event_rehearsal_guest_bootstrap_response.schema.json',
  'title': 'EventRehearsalGuestBootstrapCallableResponse',
  'description': 'Sanitized anonymous guest projection for a rehearsal.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'slotToken',
    'session',
    'actor',
    'practiceBanner',
  ],
  'properties': <String, Object?>{
    'slotToken': <String, Object?>{
      'type': 'string',
    },
    'practiceBanner': <String, Object?>{
      'type': 'string',
    },
    'session': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'title',
        'locationName',
        'status',
        'activeStepIndex',
        'virtualNowMillis',
        'attendeePrompt',
        'moduleIds',
        'runtimeRevision',
        'faultId',
      ],
      'properties': <String, Object?>{
        'title': <String, Object?>{
          'type': 'string',
        },
        'locationName': <String, Object?>{
          'type': 'string',
        },
        'status': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'draft',
            'ready',
            'running',
            'paused',
            'complete',
            'expired',
          ],
        },
        'activeStepIndex': <String, Object?>{
          'type': 'integer',
        },
        'virtualNowMillis': <String, Object?>{
          'type': 'integer',
        },
        'attendeePrompt': <String, Object?>{
          'type': 'string',
        },
        'moduleIds': <String, Object?>{
          'type': 'array',
          'items': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'arrival',
              'firstHello',
              'pods',
              'rotations',
              'conversationCues',
              'reveal',
              'afterglow',
              'accountability',
            ],
          },
        },
        'runtimeRevision': <String, Object?>{
          'type': 'integer',
        },
        'faultId': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'none',
            'latency',
            'oneShotFailure',
            'listenerDisconnect',
            'staleRevision',
            'duplicateDelivery',
            'legacyFixture',
            'reducedMotion',
            'lowBandwidth',
          ],
        },
      },
    },
    'actor': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'actorId',
        'displayName',
        'status',
        'guestMoment',
        'optedOut',
        'helpRequested',
        'promptCompleted',
      ],
      'properties': <String, Object?>{
        'actorId': <String, Object?>{
          'type': 'string',
        },
        'displayName': <String, Object?>{
          'type': 'string',
        },
        'status': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'expected',
            'present',
            'late',
            'noShow',
            'departed',
            'returned',
            'disconnected',
            'walkIn',
            'ambiguousClaim',
          ],
        },
        'guestMoment': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'welcome',
            'checkIn',
            'firstHello',
            'assignment',
            'rotation',
            'pause',
            'reveal',
            'afterglow',
            'complete',
          ],
        },
        'optedOut': <String, Object?>{
          'type': 'boolean',
        },
        'helpRequested': <String, Object?>{
          'type': 'boolean',
        },
        'promptCompleted': <String, Object?>{
          'type': 'boolean',
        },
      },
    },
  },
};
