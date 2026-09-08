// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/control_event_rehearsal_payload.schema.json.

const schemaControlEventRehearsalCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/control_event_rehearsal_payload.schema.json',
  'title': 'ControlEventRehearsalCallablePayload',
  'description': 'Revision-fenced Host lifecycle or virtual-clock control.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'sessionId',
    'expectedRevision',
    'clientActionId',
    'action',
  ],
  'properties': <String, Object?>{
    'sessionId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'expectedRevision': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 2147483647,
    },
    'clientActionId': <String, Object?>{
      'type': 'string',
      'pattern': '^[A-Za-z0-9_-]{8,120}\$',
    },
    'action': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'markReady',
        'start',
        'pause',
        'resume',
        'advance',
        'previous',
        'advanceClock',
        'complete',
        'assistance',
      ],
    },
    'minutes': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 120,
    },
    'assistance': <String, Object?>{
      'oneOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'kind',
            'actorId',
            'plan',
          ],
          'properties': <String, Object?>{
            'kind': <String, Object?>{
              'const': 'publish',
            },
            'actorId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            'plan': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'policy',
                'guidance',
                'departureConfirmed',
                'responseDeadline',
                'routes',
                'deliveryPolicy',
              ],
              'properties': <String, Object?>{
                'policy': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'destination',
                    'cutoff',
                    'maxMessagesPerEpisode',
                    'minimumMinutesBetweenMessages',
                    'updateOn',
                    'unanswered',
                  ],
                  'properties': <String, Object?>{
                    'destination': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'placeId',
                            'lateEntry',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'type': 'string',
                              'const': 'fixedPlace',
                            },
                            'placeId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 160,
                              'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                            },
                            'lateEntry': <String, Object?>{
                              'type': 'string',
                              'enum': <Object?>[
                                'allowed',
                                'hostDecision',
                                'closed',
                              ],
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'itineraryId',
                            'permittedStopIds',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'type': 'string',
                              'const': 'itineraryStop',
                            },
                            'itineraryId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 2000,
                            },
                            'permittedStopIds': <String, Object?>{
                              'type': 'array',
                              'minItems': 1,
                              'maxItems': 1000,
                              'items': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                              'uniqueItems': true,
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'routeId',
                            'groupId',
                            'permittedCheckpointIds',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'type': 'string',
                              'const': 'groupCheckpoint',
                            },
                            'routeId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 2000,
                            },
                            'groupId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 160,
                              'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                            },
                            'permittedCheckpointIds': <String, Object?>{
                              'type': 'array',
                              'minItems': 1,
                              'maxItems': 1000,
                              'items': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                              'uniqueItems': true,
                            },
                          },
                        },
                      ],
                    },
                    'cutoff': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'type': 'string',
                              'const': 'eventEnd',
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'at',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'type': 'string',
                              'const': 'time',
                            },
                            'at': <String, Object?>{
                              'type': 'integer',
                              'minimum': 0,
                              'maximum': 9007199254740991,
                              'description': 'UTC milliseconds.',
                            },
                          },
                        },
                      ],
                    },
                    'maxMessagesPerEpisode': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 100,
                    },
                    'minimumMinutesBetweenMessages': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 1440,
                    },
                    'updateOn': <String, Object?>{
                      'type': 'string',
                      'const': 'materialGuidanceChange',
                    },
                    'unanswered': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'keepUnknownUntilCutoff',
                        'hostReviewAtDeadline',
                      ],
                    },
                  },
                },
                'guidance': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'revision',
                    'destination',
                    'materialKey',
                    'text',
                    'validUntil',
                  ],
                  'properties': <String, Object?>{
                    'revision': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 9007199254740991,
                      'description': 'Nonnegative safe integer revision.',
                    },
                    'destination': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'placeId',
                            'lateEntry',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'type': 'string',
                              'const': 'fixedPlace',
                            },
                            'placeId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 160,
                              'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                            },
                            'lateEntry': <String, Object?>{
                              'type': 'string',
                              'enum': <Object?>[
                                'allowed',
                                'hostDecision',
                                'closed',
                              ],
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'itineraryId',
                            'stopId',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'type': 'string',
                              'const': 'itineraryStop',
                            },
                            'itineraryId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 2000,
                            },
                            'stopId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 2000,
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'routeId',
                            'groupId',
                            'checkpointId',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'type': 'string',
                              'const': 'groupCheckpoint',
                            },
                            'routeId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 2000,
                            },
                            'groupId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 160,
                              'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                            },
                            'checkpointId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 2000,
                            },
                          },
                        },
                      ],
                    },
                    'materialKey': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 2000,
                    },
                    'text': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 2000,
                    },
                    'validUntil': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 9007199254740991,
                      'description': 'UTC milliseconds.',
                    },
                  },
                },
                'departureConfirmed': <String, Object?>{
                  'type': 'boolean',
                },
                'responseDeadline': <String, Object?>{
                  'anyOf': <Object?>[
                    <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 9007199254740991,
                    },
                    <String, Object?>{
                      'type': 'null',
                    },
                  ],
                },
                'routes': <String, Object?>{
                  'type': 'array',
                  'minItems': 1,
                  'maxItems': 3,
                  'uniqueItems': true,
                  'items': <String, Object?>{
                    'type': 'string',
                    'enum': <Object?>[
                      'catchEventSms',
                      'catchEventRcs',
                      'organizerEventWhatsapp',
                    ],
                  },
                },
                'deliveryPolicy': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'maxAttempts',
                    'maxAttemptsPerRoute',
                    'minimumRetrySeconds',
                  ],
                  'properties': <String, Object?>{
                    'maxAttempts': <String, Object?>{
                      'type': 'integer',
                      'minimum': 1,
                      'maximum': 6,
                    },
                    'maxAttemptsPerRoute': <String, Object?>{
                      'type': 'integer',
                      'minimum': 1,
                      'maximum': 3,
                    },
                    'minimumRetrySeconds': <String, Object?>{
                      'type': 'integer',
                      'minimum': 1,
                      'maximum': 3600,
                    },
                  },
                },
                'laterChoices': <String, Object?>{
                  'type': 'array',
                  'maxItems': 17,
                  'items': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'label',
                      'target',
                    ],
                    'properties': <String, Object?>{
                      'label': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 80,
                      },
                      'target': <String, Object?>{
                        'anyOf': <Object?>[
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'placeId',
                              'lateEntry',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'fixedPlace',
                              },
                              'placeId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 160,
                                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                              },
                              'lateEntry': <String, Object?>{
                                'type': 'string',
                                'enum': <Object?>[
                                  'allowed',
                                  'hostDecision',
                                  'closed',
                                ],
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'itineraryId',
                              'stopId',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'itineraryStop',
                              },
                              'itineraryId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                              'stopId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'routeId',
                              'groupId',
                              'checkpointId',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'groupCheckpoint',
                              },
                              'routeId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                              'groupId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 160,
                                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                              },
                              'checkpointId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                            },
                          },
                        ],
                      },
                    },
                  },
                },
              },
              'if': <String, Object?>{
                'properties': <String, Object?>{
                  'policy': <String, Object?>{
                    'properties': <String, Object?>{
                      'unanswered': <String, Object?>{
                        'const': 'hostReviewAtDeadline',
                      },
                    },
                  },
                },
              },
              'then': <String, Object?>{
                'properties': <String, Object?>{
                  'responseDeadline': <String, Object?>{
                    'type': 'integer',
                  },
                },
              },
            },
          },
        },
        <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'kind',
            'actorId',
            'messageId',
            'outcome',
          ],
          'properties': <String, Object?>{
            'kind': <String, Object?>{
              'const': 'dispatch',
            },
            'actorId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            'messageId': <String, Object?>{
              'type': 'string',
              'pattern': '^outbox:[a-f0-9]{64}\$',
            },
            'outcome': <String, Object?>{
              'oneOf': <Object?>[
                <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'kind',
                  ],
                  'properties': <String, Object?>{
                    'kind': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'accepted',
                        'delivered',
                        'read',
                        'revoked',
                      ],
                    },
                  },
                },
                <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'kind',
                    'classification',
                  ],
                  'properties': <String, Object?>{
                    'kind': <String, Object?>{
                      'const': 'failed',
                    },
                    'classification': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'technical',
                        'policy',
                        'suppressed',
                        'invalidRecipient',
                      ],
                    },
                  },
                },
                <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'kind',
                    'reason',
                  ],
                  'properties': <String, Object?>{
                    'kind': <String, Object?>{
                      'const': 'unknown',
                    },
                    'reason': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'timeout',
                        'connectionLost',
                        'workerInterrupted',
                      ],
                    },
                  },
                },
              ],
            },
          },
        },
        <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'kind',
            'actorId',
            'messageId',
            'attemptId',
            'outcome',
          ],
          'properties': <String, Object?>{
            'kind': <String, Object?>{
              'const': 'receipt',
            },
            'actorId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            'messageId': <String, Object?>{
              'type': 'string',
              'pattern': '^outbox:[a-f0-9]{64}\$',
            },
            'attemptId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 160,
            },
            'outcome': <String, Object?>{
              'oneOf': <Object?>[
                <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'kind',
                  ],
                  'properties': <String, Object?>{
                    'kind': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'accepted',
                        'delivered',
                        'read',
                        'revoked',
                      ],
                    },
                  },
                },
                <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'kind',
                    'classification',
                  ],
                  'properties': <String, Object?>{
                    'kind': <String, Object?>{
                      'const': 'failed',
                    },
                    'classification': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'technical',
                        'policy',
                        'suppressed',
                        'invalidRecipient',
                      ],
                    },
                  },
                },
              ],
            },
          },
        },
      ],
      'type': 'object',
    },
  },
  'if': <String, Object?>{
    'properties': <String, Object?>{
      'action': <String, Object?>{
        'const': 'assistance',
      },
    },
  },
  'then': <String, Object?>{
    'required': <Object?>[
      'assistance',
    ],
    'not': <String, Object?>{
      'required': <Object?>[
        'minutes',
      ],
    },
  },
  'else': <String, Object?>{
    'not': <String, Object?>{
      'required': <Object?>[
        'assistance',
      ],
    },
  },
};
