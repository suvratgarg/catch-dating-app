// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/organizer_moments.schema.json.

const schemaOrganizerMomentDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/organizer_moments.schema.json',
  'title': 'OrganizerMomentDocument',
  'description': 'Unified send definition: initiation x sense x action over an event or program scope. Server-owned; managed through the organizer moment callables. Edits reset status to draft and clear approval (approve-the-rule-once).',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'organizerMoments',
  'x-firestore-path': 'organizerMoments/{momentId}',
  'x-document-id-field': 'momentId',
  'x-owner': 'organizer moment callables + moment sweep',
  'required': <Object?>[
    'momentId',
    'scope',
    'scopeKind',
    'scopeId',
    'name',
    'initiation',
    'sense',
    'audience',
    'action',
    'status',
    'approval',
    'origin',
    'revision',
    'createdAtMillis',
    'updatedAtMillis',
  ],
  'properties': <String, Object?>{
    'momentId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'scope': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'kind',
      ],
      'properties': <String, Object?>{
        'kind': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'event',
            'program',
          ],
        },
        'eventId': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'minLength': 1,
          'maxLength': 180,
          'description': 'Required when kind=event; must be null otherwise.',
        },
        'programId': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'minLength': 1,
          'maxLength': 180,
          'description': 'Required when kind=program; must be null otherwise.',
        },
      },
    },
    'scopeKind': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'event',
        'program',
      ],
      'description': 'Denormalized scope.kind for list queries.',
    },
    'scopeId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Denormalized scope id (eventId or programId) for list queries.',
    },
    'name': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 140,
    },
    'initiation': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'kind',
      ],
      'properties': <String, Object?>{
        'kind': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'manual',
            'scheduled',
            'anchored',
            'triggered',
          ],
        },
        'atMillis': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 0,
          'maximum': 9007199254740991,
          'description': 'Scheduled fire time; required when kind=scheduled.',
        },
        'anchorKind': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'scopeStart',
                'scopeEnd',
                'functionStart',
                'functionEnd',
                'rsvpDeadline',
                'travelLegTime',
              ],
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
          'description': 'Required when kind=anchored.',
        },
        'anchorId': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 180,
          'description': 'Function/leg id for scoped anchors; null anchors to the scope itself.',
        },
        'offsetMinutes': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': -43200,
          'maximum': 43200,
          'description': 'Minutes relative to the anchor; negative is before.',
        },
        'triggerKind': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'lateArrivalAtHotel',
                'flightDisrupted',
              ],
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
          'description': 'Required when kind=triggered.',
        },
        'functionId': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 180,
          'description': 'Optional function scope for triggered moments.',
        },
      },
    },
    'sense': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'individual',
        'audience',
      ],
    },
    'audience': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'kind',
      ],
      'properties': <String, Object?>{
        'kind': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'subject',
            'eventParticipants',
            'functionGuests',
            'households',
            'staffDuty',
          ],
        },
        'statuses': <String, Object?>{
          'type': <Object?>[
            'array',
            'null',
          ],
          'maxItems': 4,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'signedUp',
            ],
          },
          'description': 'eventParticipants: participation statuses included.',
        },
        'functionId': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 180,
          'description': 'functionGuests: the function whose guests resolve.',
        },
        'rsvp': <String, Object?>{
          'type': <Object?>[
            'array',
            'null',
          ],
          'maxItems': 4,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'attending',
              'maybe',
            ],
          },
          'description': 'functionGuests: RSVP states included.',
        },
        'householdDedupe': <String, Object?>{
          'type': <Object?>[
            'boolean',
            'null',
          ],
          'description': 'functionGuests: one send per household when true (default).',
        },
        'rsvpPendingOnly': <String, Object?>{
          'type': <Object?>[
            'boolean',
            'null',
          ],
          'description': 'households: restrict to households with a pending member.',
        },
        'duty': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 80,
          'description': 'staffDuty: duty whose grant holders resolve.',
        },
        'scopeIds': <String, Object?>{
          'type': <Object?>[
            'array',
            'null',
          ],
          'maxItems': 50,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'maxLength': 180,
          },
          'description': 'staffDuty: optional function/pickupPoint/hotel ids; null means all.',
        },
      },
    },
    'action': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'kind',
      ],
      'properties': <String, Object?>{
        'kind': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'sendTemplate',
            'push',
            'staffAttention',
          ],
        },
        'connectionId': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 180,
          'description': 'sendTemplate: organizerSenderConnections doc id.',
        },
        'templateId': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 180,
          'description': 'sendTemplate: organizerMessageTemplates doc id.',
        },
        'variables': <String, Object?>{
          'type': <Object?>[
            'object',
            'null',
          ],
          'additionalProperties': <String, Object?>{
            'type': 'string',
            'maxLength': 1000,
          },
          'description': 'sendTemplate: template variable substitutions.',
        },
        'notificationType': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 80,
          'description': 'push: activity/push type written to the feed.',
        },
        'preferenceKey': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 80,
          'description': 'push: user notification preference gating FCM.',
        },
        'duty': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 80,
          'description': 'staffAttention: duty the attention item targets.',
        },
        'severity': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'enum': <Object?>[
            'info',
            'warning',
            'urgent',
            null,
          ],
          'description': 'staffAttention: attention severity.',
        },
        'titleTemplate': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 200,
          'description': 'staffAttention: rendered attention title.',
        },
      },
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'draft',
        'armed',
        'paused',
        'done',
      ],
    },
    'approval': <String, Object?>{
      'type': <Object?>[
        'object',
        'null',
      ],
      'additionalProperties': false,
      'required': <Object?>[
        'approvedByUid',
        'approvedAtMillis',
      ],
      'properties': <String, Object?>{
        'approvedByUid': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'approvedAtMillis': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 9007199254740991,
        },
      },
      'description': 'Approve-the-rule-once record; required while armed.',
    },
    'origin': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'organizer',
        'systemDefault',
      ],
      'description': 'systemDefault moments (e.g. the T-15m event reminder) are seeded by the server and cannot be deleted.',
    },
    'revision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 9007199254740991,
    },
    'createdAtMillis': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 9007199254740991,
    },
    'updatedAtMillis': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 9007199254740991,
    },
  },
};
