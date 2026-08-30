// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/get_organizer_contact_detail_response.schema.json.

const schemaGetOrganizerContactDetailCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/get_organizer_contact_detail_response.schema.json',
  'title': 'GetOrganizerContactDetailCallableResponse',
  'description': 'Manager-only contact facts, permission provenance, and a bounded cross-surface activity timeline. Private feedback and Event Success inputs are excluded.',
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
    'whatsappPermission',
    'origins',
    'originsTruncated',
    'traits',
    'revenue',
    'events',
    'eventsTruncated',
    'timeline',
    'timelineTruncated',
    'timelineCoverage',
    'activeMerges',
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
    'contactDetailsEditable': <String, Object?>{
      'type': 'boolean',
      'description': 'True only for an unlinked organizer-created contact whose proposed phone/email evidence the manager may edit.',
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
    'whatsappPermission': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'status',
        'evidenceStatus',
        'receiptId',
        'source',
        'sourceFormId',
        'sourceFormTitle',
        'decisionAtMillis',
        'identityStrength',
      ],
      'properties': <String, Object?>{
        'status': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'unknown',
            'optedIn',
            'optedOut',
          ],
        },
        'evidenceStatus': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'unavailable',
            'notApplicable',
            'complete',
            'incomplete',
          ],
        },
        'receiptId': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'source': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'enum': <Object?>[
            null,
            'publicEventRegistration',
            'hostFormResponse',
            'participantSettings',
            'unsubscribeLink',
            'inboundStop',
            'providerWebhook',
            'legacyIncomplete',
          ],
        },
        'sourceFormId': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'sourceFormTitle': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'minLength': 1,
          'maxLength': 160,
        },
        'decisionAtMillis': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 0,
        },
        'identityStrength': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'enum': <Object?>[
            null,
            'unknown',
            'emailVerified',
            'phoneVerified',
            'catchAccount',
          ],
        },
      },
    },
    'origins': <String, Object?>{
      'type': 'array',
      'maxItems': 50,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'originId',
          'sourceKind',
          'sourceEntityKind',
          'formId',
          'formTitle',
          'eventId',
          'eventTitle',
          'observedAtMillis',
        ],
        'properties': <String, Object?>{
          'originId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
          'sourceKind': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'catchBooking',
              'hostImport',
              'hostManual',
              'webOtp',
              'providerSync',
              'hostForm',
            ],
          },
          'sourceEntityKind': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'eventAttendee',
              'manualEntry',
              'hostFormResponse',
              'providerRecord',
              'importBatch',
              'webRegistration',
            ],
          },
          'formId': <String, Object?>{
            'anyOf': <Object?>[
              <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 180,
              },
              <String, Object?>{
                'type': 'null',
              },
            ],
          },
          'formTitle': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
            'minLength': 1,
            'maxLength': 160,
          },
          'eventId': <String, Object?>{
            'anyOf': <Object?>[
              <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 180,
              },
              <String, Object?>{
                'type': 'null',
              },
            ],
          },
          'eventTitle': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
            'minLength': 1,
            'maxLength': 160,
          },
          'observedAtMillis': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
          },
        },
      },
    },
    'originsTruncated': <String, Object?>{
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
              'past_attendee',
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
              'factCount',
              'sources',
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
              'factCount': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 1000000,
              },
              'sources': <String, Object?>{
                'type': 'array',
                'maxItems': 4,
                'items': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'source',
                    'amountMinor',
                    'factCount',
                  ],
                  'properties': <String, Object?>{
                    'source': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'catchPayment',
                        'hostImport',
                        'hostEstimate',
                        'providerOrder',
                      ],
                    },
                    'amountMinor': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 9007199254740991,
                    },
                    'factCount': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 1000000,
                    },
                  },
                },
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
          'eventOriginMode',
          'eventProvider',
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
          'revenues',
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
          'eventOriginMode': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'catchNative',
              'externalCompanion',
              'unknown',
            ],
          },
          'eventProvider': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
            'enum': <Object?>[
              'catch',
              'generic',
              'luma',
              'eventbrite',
              'partiful',
              'posh',
              'bookmyshow',
              'district',
              'sortmyscene',
              'airbnb',
              null,
            ],
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
          'revenues': <String, Object?>{
            'type': 'array',
            'maxItems': 8,
            'items': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'currency',
                'amountMinor',
                'source',
                'factCount',
                'allocation',
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
                'source': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'catchPayment',
                    'hostImport',
                    'hostEstimate',
                    'providerOrder',
                  ],
                },
                'factCount': <String, Object?>{
                  'type': 'integer',
                  'minimum': 1,
                  'maximum': 1000000,
                },
                'allocation': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'perAttendee',
                    'sharedOrder',
                  ],
                },
              },
            },
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
    'notesCoverage': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'exact',
        'unavailable',
      ],
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
    'sendsCoverage': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'exact',
        'unavailable',
      ],
    },
    'timeline': <String, Object?>{
      'type': 'array',
      'maxItems': 100,
      'items': <String, Object?>{
        'oneOf': <Object?>[
          <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'kind',
              'timelineId',
              'responseId',
              'formId',
              'formTitle',
              'action',
              'answeredQuestionCount',
              'occurredAtMillis',
            ],
            'properties': <String, Object?>{
              'kind': <String, Object?>{
                'const': 'form',
              },
              'timelineId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 240,
              },
              'responseId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 180,
              },
              'formId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 180,
              },
              'formTitle': <String, Object?>{
                'type': <Object?>[
                  'string',
                  'null',
                ],
                'minLength': 1,
                'maxLength': 160,
              },
              'action': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'submitted',
                  'withdrawn',
                ],
              },
              'answeredQuestionCount': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 4000,
              },
              'occurredAtMillis': <String, Object?>{
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
              'timelineId',
              'eventId',
              'eventName',
              'status',
              'checkedIn',
              'eventOriginMode',
              'eventProvider',
              'occurredAtMillis',
            ],
            'properties': <String, Object?>{
              'kind': <String, Object?>{
                'const': 'event',
              },
              'timelineId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 240,
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
              'checkedIn': <String, Object?>{
                'type': 'boolean',
              },
              'eventOriginMode': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'catchNative',
                  'externalCompanion',
                  'unknown',
                ],
              },
              'eventProvider': <String, Object?>{
                'type': <Object?>[
                  'string',
                  'null',
                ],
                'enum': <Object?>[
                  'catch',
                  'generic',
                  'luma',
                  'eventbrite',
                  'partiful',
                  'posh',
                  'bookmyshow',
                  'district',
                  'sortmyscene',
                  'airbnb',
                  null,
                ],
              },
              'occurredAtMillis': <String, Object?>{
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
              'timelineId',
              'sendKind',
              'name',
              'status',
              'deliveryMode',
              'observation',
              'referenceId',
              'occurredAtMillis',
            ],
            'properties': <String, Object?>{
              'kind': <String, Object?>{
                'const': 'send',
              },
              'timelineId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 240,
              },
              'sendKind': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'campaign',
                  'announcement',
                  'manualHandoff',
                ],
              },
              'name': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 160,
              },
              'status': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'available',
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
                  'queued',
                  'handoffOpened',
                  'hostMarkedSent',
                  'skipped',
                  'cancelled',
                  'superseded',
                  'expired',
                ],
              },
              'deliveryMode': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'inCatch',
                  'api',
                  'byHand',
                ],
              },
              'observation': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'providerReceipt',
                  'catchActivity',
                  'hostOpened',
                  'hostAssertion',
                  'notSent',
                ],
              },
              'referenceId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 180,
              },
              'occurredAtMillis': <String, Object?>{
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
              'timelineId',
              'transport',
              'direction',
              'bodyPreview',
              'threadId',
              'occurredAtMillis',
            ],
            'properties': <String, Object?>{
              'kind': <String, Object?>{
                'const': 'reply',
              },
              'timelineId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 240,
              },
              'transport': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'catchChat',
                  'managedWhatsapp',
                ],
              },
              'direction': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'inbound',
                  'outbound',
                ],
              },
              'bodyPreview': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 300,
              },
              'threadId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 180,
              },
              'occurredAtMillis': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
              },
            },
          },
        ],
      },
    },
    'timelineTruncated': <String, Object?>{
      'type': 'boolean',
    },
    'timelineCoverage': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'forms',
        'events',
        'sends',
        'replies',
        'replyObservation',
      ],
      'properties': <String, Object?>{
        'forms': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'exact',
            'partial',
            'unavailable',
          ],
        },
        'events': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'exact',
            'partial',
            'unavailable',
          ],
        },
        'sends': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'exact',
            'partial',
            'unavailable',
          ],
        },
        'replies': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'exact',
            'partial',
            'unavailable',
          ],
        },
        'replyObservation': <String, Object?>{
          'const': 'catchAndManagedWhatsappOnly',
        },
      },
    },
    'activeMerges': <String, Object?>{
      'type': 'array',
      'maxItems': 50,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'mergeReceiptId',
          'sourceContactId',
          'sourceDisplayName',
          'evidence',
          'conflicts',
          'movedFactCount',
          'mergedAtMillis',
        ],
        'properties': <String, Object?>{
          'mergeReceiptId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
          'sourceContactId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
          'sourceDisplayName': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 120,
          },
          'evidence': <String, Object?>{
            'type': 'array',
            'maxItems': 20,
            'uniqueItems': true,
            'items': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'sameVerifiedUid',
                'sameVerifiedPhone',
                'sameImportedPhone',
                'sameEmail',
                'managerConfirmed',
              ],
            },
          },
          'conflicts': <String, Object?>{
            'type': 'array',
            'maxItems': 20,
            'uniqueItems': true,
            'items': <String, Object?>{
              'type': 'string',
              'maxLength': 120,
            },
          },
          'movedFactCount': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
            'maximum': 400,
          },
          'mergedAtMillis': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
          },
        },
      },
    },
    'revision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 9007199254740991,
    },
  },
  'definitions': <String, Object?>{
    'permission': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'status',
        'evidenceStatus',
        'receiptId',
        'source',
        'sourceFormId',
        'sourceFormTitle',
        'decisionAtMillis',
        'identityStrength',
      ],
      'properties': <String, Object?>{
        'status': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'unknown',
            'optedIn',
            'optedOut',
          ],
        },
        'evidenceStatus': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'unavailable',
            'notApplicable',
            'complete',
            'incomplete',
          ],
        },
        'receiptId': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'source': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'enum': <Object?>[
            null,
            'publicEventRegistration',
            'hostFormResponse',
            'participantSettings',
            'unsubscribeLink',
            'inboundStop',
            'providerWebhook',
            'legacyIncomplete',
          ],
        },
        'sourceFormId': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'sourceFormTitle': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'minLength': 1,
          'maxLength': 160,
        },
        'decisionAtMillis': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 0,
        },
        'identityStrength': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'enum': <Object?>[
            null,
            'unknown',
            'emailVerified',
            'phoneVerified',
            'catchAccount',
          ],
        },
      },
    },
    'origin': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'originId',
        'sourceKind',
        'sourceEntityKind',
        'formId',
        'formTitle',
        'eventId',
        'eventTitle',
        'observedAtMillis',
      ],
      'properties': <String, Object?>{
        'originId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'sourceKind': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'catchBooking',
            'hostImport',
            'hostManual',
            'webOtp',
            'providerSync',
            'hostForm',
          ],
        },
        'sourceEntityKind': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'eventAttendee',
            'manualEntry',
            'hostFormResponse',
            'providerRecord',
            'importBatch',
            'webRegistration',
          ],
        },
        'formId': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'formTitle': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'minLength': 1,
          'maxLength': 160,
        },
        'eventId': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'eventTitle': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'minLength': 1,
          'maxLength': 160,
        },
        'observedAtMillis': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
      },
    },
    'timelineCoverageValue': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'exact',
        'partial',
        'unavailable',
      ],
    },
    'timelineCoverage': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'forms',
        'events',
        'sends',
        'replies',
        'replyObservation',
      ],
      'properties': <String, Object?>{
        'forms': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'exact',
            'partial',
            'unavailable',
          ],
        },
        'events': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'exact',
            'partial',
            'unavailable',
          ],
        },
        'sends': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'exact',
            'partial',
            'unavailable',
          ],
        },
        'replies': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'exact',
            'partial',
            'unavailable',
          ],
        },
        'replyObservation': <String, Object?>{
          'const': 'catchAndManagedWhatsappOnly',
        },
      },
    },
    'timelineEntry': <String, Object?>{
      'oneOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'kind',
            'timelineId',
            'responseId',
            'formId',
            'formTitle',
            'action',
            'answeredQuestionCount',
            'occurredAtMillis',
          ],
          'properties': <String, Object?>{
            'kind': <String, Object?>{
              'const': 'form',
            },
            'timelineId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 240,
            },
            'responseId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            'formId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            'formTitle': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'minLength': 1,
              'maxLength': 160,
            },
            'action': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'submitted',
                'withdrawn',
              ],
            },
            'answeredQuestionCount': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 4000,
            },
            'occurredAtMillis': <String, Object?>{
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
            'timelineId',
            'eventId',
            'eventName',
            'status',
            'checkedIn',
            'eventOriginMode',
            'eventProvider',
            'occurredAtMillis',
          ],
          'properties': <String, Object?>{
            'kind': <String, Object?>{
              'const': 'event',
            },
            'timelineId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 240,
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
            'checkedIn': <String, Object?>{
              'type': 'boolean',
            },
            'eventOriginMode': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'catchNative',
                'externalCompanion',
                'unknown',
              ],
            },
            'eventProvider': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'enum': <Object?>[
                'catch',
                'generic',
                'luma',
                'eventbrite',
                'partiful',
                'posh',
                'bookmyshow',
                'district',
                'sortmyscene',
                'airbnb',
                null,
              ],
            },
            'occurredAtMillis': <String, Object?>{
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
            'timelineId',
            'sendKind',
            'name',
            'status',
            'deliveryMode',
            'observation',
            'referenceId',
            'occurredAtMillis',
          ],
          'properties': <String, Object?>{
            'kind': <String, Object?>{
              'const': 'send',
            },
            'timelineId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 240,
            },
            'sendKind': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'campaign',
                'announcement',
                'manualHandoff',
              ],
            },
            'name': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 160,
            },
            'status': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'available',
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
                'queued',
                'handoffOpened',
                'hostMarkedSent',
                'skipped',
                'cancelled',
                'superseded',
                'expired',
              ],
            },
            'deliveryMode': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'inCatch',
                'api',
                'byHand',
              ],
            },
            'observation': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'providerReceipt',
                'catchActivity',
                'hostOpened',
                'hostAssertion',
                'notSent',
              ],
            },
            'referenceId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            'occurredAtMillis': <String, Object?>{
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
            'timelineId',
            'transport',
            'direction',
            'bodyPreview',
            'threadId',
            'occurredAtMillis',
          ],
          'properties': <String, Object?>{
            'kind': <String, Object?>{
              'const': 'reply',
            },
            'timelineId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 240,
            },
            'transport': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'catchChat',
                'managedWhatsapp',
              ],
            },
            'direction': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'inbound',
                'outbound',
              ],
            },
            'bodyPreview': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 300,
            },
            'threadId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            'occurredAtMillis': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
            },
          },
        },
      ],
    },
    'formTimelineEntry': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'kind',
        'timelineId',
        'responseId',
        'formId',
        'formTitle',
        'action',
        'answeredQuestionCount',
        'occurredAtMillis',
      ],
      'properties': <String, Object?>{
        'kind': <String, Object?>{
          'const': 'form',
        },
        'timelineId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 240,
        },
        'responseId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'formId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'formTitle': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'minLength': 1,
          'maxLength': 160,
        },
        'action': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'submitted',
            'withdrawn',
          ],
        },
        'answeredQuestionCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 4000,
        },
        'occurredAtMillis': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
      },
    },
    'eventTimelineEntry': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'kind',
        'timelineId',
        'eventId',
        'eventName',
        'status',
        'checkedIn',
        'eventOriginMode',
        'eventProvider',
        'occurredAtMillis',
      ],
      'properties': <String, Object?>{
        'kind': <String, Object?>{
          'const': 'event',
        },
        'timelineId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 240,
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
        'checkedIn': <String, Object?>{
          'type': 'boolean',
        },
        'eventOriginMode': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'catchNative',
            'externalCompanion',
            'unknown',
          ],
        },
        'eventProvider': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'enum': <Object?>[
            'catch',
            'generic',
            'luma',
            'eventbrite',
            'partiful',
            'posh',
            'bookmyshow',
            'district',
            'sortmyscene',
            'airbnb',
            null,
          ],
        },
        'occurredAtMillis': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
      },
    },
    'sendTimelineEntry': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'kind',
        'timelineId',
        'sendKind',
        'name',
        'status',
        'deliveryMode',
        'observation',
        'referenceId',
        'occurredAtMillis',
      ],
      'properties': <String, Object?>{
        'kind': <String, Object?>{
          'const': 'send',
        },
        'timelineId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 240,
        },
        'sendKind': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'campaign',
            'announcement',
            'manualHandoff',
          ],
        },
        'name': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 160,
        },
        'status': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'available',
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
            'queued',
            'handoffOpened',
            'hostMarkedSent',
            'skipped',
            'cancelled',
            'superseded',
            'expired',
          ],
        },
        'deliveryMode': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'inCatch',
            'api',
            'byHand',
          ],
        },
        'observation': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'providerReceipt',
            'catchActivity',
            'hostOpened',
            'hostAssertion',
            'notSent',
          ],
        },
        'referenceId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'occurredAtMillis': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
      },
    },
    'replyTimelineEntry': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'kind',
        'timelineId',
        'transport',
        'direction',
        'bodyPreview',
        'threadId',
        'occurredAtMillis',
      ],
      'properties': <String, Object?>{
        'kind': <String, Object?>{
          'const': 'reply',
        },
        'timelineId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 240,
        },
        'transport': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'catchChat',
            'managedWhatsapp',
          ],
        },
        'direction': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'inbound',
            'outbound',
          ],
        },
        'bodyPreview': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 300,
        },
        'threadId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'occurredAtMillis': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
      },
    },
    'activeMerge': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'mergeReceiptId',
        'sourceContactId',
        'sourceDisplayName',
        'evidence',
        'conflicts',
        'movedFactCount',
        'mergedAtMillis',
      ],
      'properties': <String, Object?>{
        'mergeReceiptId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'sourceContactId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'sourceDisplayName': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
        },
        'evidence': <String, Object?>{
          'type': 'array',
          'maxItems': 20,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'sameVerifiedUid',
              'sameVerifiedPhone',
              'sameImportedPhone',
              'sameEmail',
              'managerConfirmed',
            ],
          },
        },
        'conflicts': <String, Object?>{
          'type': 'array',
          'maxItems': 20,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'maxLength': 120,
          },
        },
        'movedFactCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 400,
        },
        'mergedAtMillis': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
      },
    },
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
              'factCount',
              'sources',
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
              'factCount': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 1000000,
              },
              'sources': <String, Object?>{
                'type': 'array',
                'maxItems': 4,
                'items': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'source',
                    'amountMinor',
                    'factCount',
                  ],
                  'properties': <String, Object?>{
                    'source': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'catchPayment',
                        'hostImport',
                        'hostEstimate',
                        'providerOrder',
                      ],
                    },
                    'amountMinor': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 9007199254740991,
                    },
                    'factCount': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 1000000,
                    },
                  },
                },
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
        'factCount',
        'sources',
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
        'factCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 1000000,
        },
        'sources': <String, Object?>{
          'type': 'array',
          'maxItems': 4,
          'items': <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'source',
              'amountMinor',
              'factCount',
            ],
            'properties': <String, Object?>{
              'source': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'catchPayment',
                  'hostImport',
                  'hostEstimate',
                  'providerOrder',
                ],
              },
              'amountMinor': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 9007199254740991,
              },
              'factCount': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 1000000,
              },
            },
          },
        },
      },
    },
    'revenueSourceAmount': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'source',
        'amountMinor',
        'factCount',
      ],
      'properties': <String, Object?>{
        'source': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'catchPayment',
            'hostImport',
            'hostEstimate',
            'providerOrder',
          ],
        },
        'amountMinor': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 9007199254740991,
        },
        'factCount': <String, Object?>{
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
              'past_attendee',
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
        'eventOriginMode',
        'eventProvider',
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
        'revenues',
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
        'eventOriginMode': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'catchNative',
            'externalCompanion',
            'unknown',
          ],
        },
        'eventProvider': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'enum': <Object?>[
            'catch',
            'generic',
            'luma',
            'eventbrite',
            'partiful',
            'posh',
            'bookmyshow',
            'district',
            'sortmyscene',
            'airbnb',
            null,
          ],
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
        'revenues': <String, Object?>{
          'type': 'array',
          'maxItems': 8,
          'items': <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'currency',
              'amountMinor',
              'source',
              'factCount',
              'allocation',
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
              'source': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'catchPayment',
                  'hostImport',
                  'hostEstimate',
                  'providerOrder',
                ],
              },
              'factCount': <String, Object?>{
                'type': 'integer',
                'minimum': 1,
                'maximum': 1000000,
              },
              'allocation': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'perAttendee',
                  'sharedOrder',
                ],
              },
            },
          },
        },
      },
    },
    'eventRevenue': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'currency',
        'amountMinor',
        'source',
        'factCount',
        'allocation',
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
        'source': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'catchPayment',
            'hostImport',
            'hostEstimate',
            'providerOrder',
          ],
        },
        'factCount': <String, Object?>{
          'type': 'integer',
          'minimum': 1,
          'maximum': 1000000,
        },
        'allocation': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'perAttendee',
            'sharedOrder',
          ],
        },
      },
    },
  },
};
