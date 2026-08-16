// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/get_organizer_contact_detail_response.schema.json.

const schemaGetOrganizerContactDetailCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/get_organizer_contact_detail_response.schema.json',
  'title': 'GetOrganizerContactDetailCallableResponse',
  'description': 'Manager-only contact facts and bounded event timeline. Private feedback and Event Success inputs are excluded.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'organizerId',
    'contactId',
    'displayName',
    'sourceDisplayName',
    'displayNameOverride',
    'phoneE164',
    'email',
    'linkedAccount',
    'identityState',
    'identityConfidence',
    'ambiguousCandidateContactIds',
    'whatsappAdminSuppressed',
    'traits',
    'revenue',
    'events',
    'eventsTruncated',
    'revision',
  ],
  'properties': <String, Object?>{
    'organizerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'contactId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'displayName': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
    },
    'sourceDisplayName': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
    },
    'displayNameOverride': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 120,
    },
    'phoneE164': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'pattern': '^\\+[1-9][0-9]{7,14}\$',
    },
    'email': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'format': 'email',
      'maxLength': 320,
    },
    'linkedAccount': <String, Object?>{
      'type': 'boolean',
    },
    'identityState': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'unlinked',
        'verified',
        'ambiguous',
      ],
    },
    'identityConfidence': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'eventOnly',
        'proposed',
        'verified',
      ],
    },
    'ambiguousCandidateContactIds': <String, Object?>{
      'type': 'array',
      'uniqueItems': true,
      'maxItems': 20,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 180,
      },
    },
    'whatsappAdminSuppressed': <String, Object?>{
      'type': 'boolean',
    },
    'traits': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'expectedEventCount',
        'attendedEventCount',
        'cancelledEventCount',
        'noShowCount',
        'importedEventCount',
        'attendanceRate',
        'segmentIds',
        'whatsappStatus',
        'smsStatus',
        'sourceCoverage',
      ],
      'properties': <String, Object?>{
        'expectedEventCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'attendedEventCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'cancelledEventCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'noShowCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'importedEventCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'attendanceRate': <String, Object?>{
          'type': <Object?>[
            'number',
            'null',
          ],
          'minimum': 0,
          'maximum': 1,
        },
        'segmentIds': <String, Object?>{
          'type': 'array',
          'uniqueItems': true,
          'maxItems': 16,
          'items': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'new_to_organizer',
              'first_time_attendee',
              'repeat_attendee',
              'regular',
              'lapsed_regular',
              'reliable_attendee',
              'needs_confirmation',
              'advocate',
              'high_impact_advocate',
              'whatsapp_reachable',
              'sms_reachable',
            ],
          },
        },
        'whatsappStatus': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'unknown',
            'optedIn',
            'optedOut',
          ],
        },
        'smsStatus': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'unknown',
            'optedIn',
            'optedOut',
          ],
        },
        'sourceCoverage': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'exact',
            'partial',
            'insufficientData',
          ],
        },
      },
    },
    'revenue': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'coverage',
        'amounts',
      ],
      'properties': <String, Object?>{
        'coverage': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'exact',
            'partial',
            'unavailable',
          ],
        },
        'amounts': <String, Object?>{
          'type': 'array',
          'maxItems': 8,
          'items': <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'currency',
              'amountMinor',
              'paidOrderCount',
            ],
            'properties': <String, Object?>{
              'currency': <String, Object?>{
                'type': 'string',
                'pattern': '^[A-Z]{3}\$',
              },
              'amountMinor': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 9007199254740991,
              },
              'paidOrderCount': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 1000000,
              },
            },
          },
        },
      },
    },
    'events': <String, Object?>{
      'type': 'array',
      'maxItems': 100,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'eventId',
          'attendeeId',
          'displayName',
          'source',
          'status',
          'expected',
          'registered',
          'cancelled',
          'checkedIn',
          'eventStartAtMillis',
          'eventEndAtMillis',
          'registeredAtMillis',
          'cancelledAtMillis',
          'checkedInAtMillis',
        ],
        'properties': <String, Object?>{
          'eventId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
          'attendeeId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
          'displayName': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 120,
          },
          'source': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'catchBooking',
              'hostImport',
              'hostManual',
              'webOtp',
              'providerSync',
            ],
          },
          'status': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'invited',
              'registered',
              'waitlisted',
              'checkedIn',
              'cancelled',
            ],
          },
          'expected': <String, Object?>{
            'type': 'boolean',
          },
          'registered': <String, Object?>{
            'type': 'boolean',
          },
          'cancelled': <String, Object?>{
            'type': 'boolean',
          },
          'checkedIn': <String, Object?>{
            'type': 'boolean',
          },
          'eventStartAtMillis': <String, Object?>{
            'type': <Object?>[
              'integer',
              'null',
            ],
            'minimum': 0,
          },
          'eventEndAtMillis': <String, Object?>{
            'type': <Object?>[
              'integer',
              'null',
            ],
            'minimum': 0,
          },
          'registeredAtMillis': <String, Object?>{
            'type': <Object?>[
              'integer',
              'null',
            ],
            'minimum': 0,
          },
          'cancelledAtMillis': <String, Object?>{
            'type': <Object?>[
              'integer',
              'null',
            ],
            'minimum': 0,
          },
          'checkedInAtMillis': <String, Object?>{
            'type': <Object?>[
              'integer',
              'null',
            ],
            'minimum': 0,
          },
        },
      },
    },
    'eventsTruncated': <String, Object?>{
      'type': 'boolean',
    },
    'manualTags': <String, Object?>{
      'type': 'array',
      'maxItems': 5,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'tagId',
          'label',
        ],
        'properties': <String, Object?>{
          'tagId': <String, Object?>{
            'type': 'string',
            'pattern': '^[a-f0-9]{32}\$',
          },
          'label': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 40,
          },
        },
      },
    },
    'manualTagVocabulary': <String, Object?>{
      'type': 'array',
      'maxItems': 20,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'tagId',
          'label',
        ],
        'properties': <String, Object?>{
          'tagId': <String, Object?>{
            'type': 'string',
            'pattern': '^[a-f0-9]{32}\$',
          },
          'label': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 40,
          },
        },
      },
    },
    'notes': <String, Object?>{
      'type': 'array',
      'maxItems': 100,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'noteId',
          'body',
          'authorUid',
          'createdAtMillis',
          'updatedAtMillis',
          'revision',
        ],
        'properties': <String, Object?>{
          'noteId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
          'body': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 2000,
          },
          'authorUid': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
          'createdAtMillis': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
          },
          'updatedAtMillis': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
          },
          'revision': <String, Object?>{
            'type': 'integer',
            'minimum': 1,
            'maximum': 9007199254740991,
          },
        },
      },
    },
    'notesTruncated': <String, Object?>{
      'type': 'boolean',
    },
    'sends': <String, Object?>{
      'type': 'array',
      'maxItems': 100,
      'items': <String, Object?>{
        'oneOf': <Object?>[
          <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'kind',
              'campaignId',
              'name',
              'messageClass',
              'deliveryStatus',
              'createdAtMillis',
              'sentAtMillis',
              'updatedAtMillis',
            ],
            'properties': <String, Object?>{
              'kind': <String, Object?>{
                'const': 'campaign',
              },
              'campaignId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 180,
              },
              'name': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 120,
              },
              'messageClass': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'eventFollowUp',
                  'organizerUpdate',
                  'organizerPromotion',
                ],
              },
              'deliveryStatus': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'pending',
                  'sending',
                  'suppressed',
                  'accepted',
                  'sent',
                  'delivered',
                  'read',
                  'failed',
                  'replied',
                  'optedOut',
                ],
              },
              'createdAtMillis': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
              },
              'sentAtMillis': <String, Object?>{
                'type': <Object?>[
                  'integer',
                  'null',
                ],
                'minimum': 0,
              },
              'updatedAtMillis': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
              },
            },
          },
          <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'kind',
              'broadcastId',
              'eventId',
              'eventName',
              'audience',
              'deliveryStatus',
              'sentAtMillis',
              'partialFailure',
            ],
            'properties': <String, Object?>{
              'kind': <String, Object?>{
                'const': 'announcement',
              },
              'broadcastId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 180,
              },
              'eventId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 180,
              },
              'eventName': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 160,
              },
              'audience': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'booked',
                  'prospective',
                  'everyone',
                ],
              },
              'deliveryStatus': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'available',
                  'failed',
                ],
              },
              'sentAtMillis': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
              },
              'partialFailure': <String, Object?>{
                'type': 'boolean',
              },
            },
          },
        ],
      },
    },
    'sendsTruncated': <String, Object?>{
      'type': 'boolean',
    },
    'revision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 9007199254740991,
    },
  },
  'definitions': <String, Object?>{
    'manualTag': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'tagId',
        'label',
      ],
      'properties': <String, Object?>{
        'tagId': <String, Object?>{
          'type': 'string',
          'pattern': '^[a-f0-9]{32}\$',
        },
        'label': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 40,
        },
      },
    },
    'note': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'noteId',
        'body',
        'authorUid',
        'createdAtMillis',
        'updatedAtMillis',
        'revision',
      ],
      'properties': <String, Object?>{
        'noteId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'body': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 2000,
        },
        'authorUid': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'createdAtMillis': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
        'updatedAtMillis': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
        'revision': <String, Object?>{
          'type': 'integer',
          'minimum': 1,
          'maximum': 9007199254740991,
        },
      },
    },
    'send': <String, Object?>{
      'oneOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'kind',
            'campaignId',
            'name',
            'messageClass',
            'deliveryStatus',
            'createdAtMillis',
            'sentAtMillis',
            'updatedAtMillis',
          ],
          'properties': <String, Object?>{
            'kind': <String, Object?>{
              'const': 'campaign',
            },
            'campaignId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            'name': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 120,
            },
            'messageClass': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'eventFollowUp',
                'organizerUpdate',
                'organizerPromotion',
              ],
            },
            'deliveryStatus': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'pending',
                'sending',
                'suppressed',
                'accepted',
                'sent',
                'delivered',
                'read',
                'failed',
                'replied',
                'optedOut',
              ],
            },
            'createdAtMillis': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
            },
            'sentAtMillis': <String, Object?>{
              'type': <Object?>[
                'integer',
                'null',
              ],
              'minimum': 0,
            },
            'updatedAtMillis': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
            },
          },
        },
        <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'kind',
            'broadcastId',
            'eventId',
            'eventName',
            'audience',
            'deliveryStatus',
            'sentAtMillis',
            'partialFailure',
          ],
          'properties': <String, Object?>{
            'kind': <String, Object?>{
              'const': 'announcement',
            },
            'broadcastId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            'eventId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            'eventName': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 160,
            },
            'audience': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'booked',
                'prospective',
                'everyone',
              ],
            },
            'deliveryStatus': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'available',
                'failed',
              ],
            },
            'sentAtMillis': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
            },
            'partialFailure': <String, Object?>{
              'type': 'boolean',
            },
          },
        },
      ],
    },
    'campaignSend': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'kind',
        'campaignId',
        'name',
        'messageClass',
        'deliveryStatus',
        'createdAtMillis',
        'sentAtMillis',
        'updatedAtMillis',
      ],
      'properties': <String, Object?>{
        'kind': <String, Object?>{
          'const': 'campaign',
        },
        'campaignId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'name': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
        },
        'messageClass': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'eventFollowUp',
            'organizerUpdate',
            'organizerPromotion',
          ],
        },
        'deliveryStatus': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'pending',
            'sending',
            'suppressed',
            'accepted',
            'sent',
            'delivered',
            'read',
            'failed',
            'replied',
            'optedOut',
          ],
        },
        'createdAtMillis': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
        'sentAtMillis': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 0,
        },
        'updatedAtMillis': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
      },
    },
    'announcementSend': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'kind',
        'broadcastId',
        'eventId',
        'eventName',
        'audience',
        'deliveryStatus',
        'sentAtMillis',
        'partialFailure',
      ],
      'properties': <String, Object?>{
        'kind': <String, Object?>{
          'const': 'announcement',
        },
        'broadcastId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'eventId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'eventName': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 160,
        },
        'audience': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'booked',
            'prospective',
            'everyone',
          ],
        },
        'deliveryStatus': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'available',
            'failed',
          ],
        },
        'sentAtMillis': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
        'partialFailure': <String, Object?>{
          'type': 'boolean',
        },
      },
    },
    'revenue': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'coverage',
        'amounts',
      ],
      'properties': <String, Object?>{
        'coverage': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'exact',
            'partial',
            'unavailable',
          ],
        },
        'amounts': <String, Object?>{
          'type': 'array',
          'maxItems': 8,
          'items': <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'currency',
              'amountMinor',
              'paidOrderCount',
            ],
            'properties': <String, Object?>{
              'currency': <String, Object?>{
                'type': 'string',
                'pattern': '^[A-Z]{3}\$',
              },
              'amountMinor': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 9007199254740991,
              },
              'paidOrderCount': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 1000000,
              },
            },
          },
        },
      },
    },
    'revenueAmount': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'currency',
        'amountMinor',
        'paidOrderCount',
      ],
      'properties': <String, Object?>{
        'currency': <String, Object?>{
          'type': 'string',
          'pattern': '^[A-Z]{3}\$',
        },
        'amountMinor': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 9007199254740991,
        },
        'paidOrderCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
      },
    },
    'traits': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'expectedEventCount',
        'attendedEventCount',
        'cancelledEventCount',
        'noShowCount',
        'importedEventCount',
        'attendanceRate',
        'segmentIds',
        'whatsappStatus',
        'smsStatus',
        'sourceCoverage',
      ],
      'properties': <String, Object?>{
        'expectedEventCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'attendedEventCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'cancelledEventCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'noShowCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'importedEventCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'attendanceRate': <String, Object?>{
          'type': <Object?>[
            'number',
            'null',
          ],
          'minimum': 0,
          'maximum': 1,
        },
        'segmentIds': <String, Object?>{
          'type': 'array',
          'uniqueItems': true,
          'maxItems': 16,
          'items': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'new_to_organizer',
              'first_time_attendee',
              'repeat_attendee',
              'regular',
              'lapsed_regular',
              'reliable_attendee',
              'needs_confirmation',
              'advocate',
              'high_impact_advocate',
              'whatsapp_reachable',
              'sms_reachable',
            ],
          },
        },
        'whatsappStatus': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'unknown',
            'optedIn',
            'optedOut',
          ],
        },
        'smsStatus': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'unknown',
            'optedIn',
            'optedOut',
          ],
        },
        'sourceCoverage': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'exact',
            'partial',
            'insufficientData',
          ],
        },
      },
    },
    'event': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'eventId',
        'attendeeId',
        'displayName',
        'source',
        'status',
        'expected',
        'registered',
        'cancelled',
        'checkedIn',
        'eventStartAtMillis',
        'eventEndAtMillis',
        'registeredAtMillis',
        'cancelledAtMillis',
        'checkedInAtMillis',
      ],
      'properties': <String, Object?>{
        'eventId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'attendeeId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'displayName': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
        },
        'source': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'catchBooking',
            'hostImport',
            'hostManual',
            'webOtp',
            'providerSync',
          ],
        },
        'status': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'invited',
            'registered',
            'waitlisted',
            'checkedIn',
            'cancelled',
          ],
        },
        'expected': <String, Object?>{
          'type': 'boolean',
        },
        'registered': <String, Object?>{
          'type': 'boolean',
        },
        'cancelled': <String, Object?>{
          'type': 'boolean',
        },
        'checkedIn': <String, Object?>{
          'type': 'boolean',
        },
        'eventStartAtMillis': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 0,
        },
        'eventEndAtMillis': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 0,
        },
        'registeredAtMillis': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 0,
        },
        'cancelledAtMillis': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 0,
        },
        'checkedInAtMillis': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 0,
        },
      },
    },
  },
};
