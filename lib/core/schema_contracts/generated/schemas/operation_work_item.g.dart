// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from operations/work_item.schema.json.

const schemaOperationWorkItemSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/operations/work_item.schema.json',
  'title': 'OperationWorkItem',
  'description': 'One exclusively staged unit of work. Task flags are orthogonal and may overlap.',
  'type': 'object',
  'additionalProperties': false,
  'allOf': <Object?>[
    <String, Object?>{
      'if': <String, Object?>{
        'properties': <String, Object?>{
          'normalizedPayload': <String, Object?>{
            'type': 'object',
            'required': <Object?>[
              'kind',
            ],
            'properties': <String, Object?>{
              'kind': <String, Object?>{
                'const': 'liveLateJoin',
              },
            },
          },
        },
      },
      'then': <String, Object?>{
        'properties': <String, Object?>{
          'workflowId': <String, Object?>{
            'const': 'event-assistance',
          },
          'entityKind': <String, Object?>{
            'const': 'guest_episode',
          },
          'normalizedPayload': <String, Object?>{
            'title': 'EventAssistanceLiveWork',
            'description': 'Private normalized payload for one durable live guest episode. Due times and evaluation state are explicit; publication is not provider delivery.',
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'schemaVersion',
              'kind',
              'scope',
              'options',
              'expiresAt',
              'maxEvaluations',
              'checkpoint',
            ],
            'properties': <String, Object?>{
              'schemaVersion': <String, Object?>{
                'type': 'integer',
                'const': 1,
              },
              'kind': <String, Object?>{
                'type': 'string',
                'const': 'liveLateJoin',
              },
              'scope': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'context',
                  'attendeeId',
                  'episodeId',
                ],
                'properties': <String, Object?>{
                  'context': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'mode',
                      'eventId',
                      'organizerId',
                    ],
                    'properties': <String, Object?>{
                      'mode': <String, Object?>{
                        'type': 'string',
                        'const': 'live',
                      },
                      'eventId': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 160,
                        'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                      },
                      'organizerId': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 2000,
                      },
                    },
                  },
                  'attendeeId': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 180,
                    'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                  },
                  'episodeId': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 180,
                    'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                  },
                },
              },
              'options': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'routes',
                  'responseDeadline',
                  'deliveryPolicy',
                ],
                'properties': <String, Object?>{
                  'routes': <String, Object?>{
                    'type': 'array',
                    'minItems': 1,
                    'maxItems': 3,
                    'uniqueItems': true,
                    'items': <String, Object?>{
                      'oneOf': <Object?>[
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'routeId',
                            'senderId',
                          ],
                          'properties': <String, Object?>{
                            'routeId': <String, Object?>{
                              'type': 'string',
                              'const': 'catchEventSms',
                            },
                            'senderId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 160,
                              'pattern': '^[a-zA-Z0-9][a-zA-Z0-9._:-]*\$',
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'routeId',
                            'senderId',
                          ],
                          'properties': <String, Object?>{
                            'routeId': <String, Object?>{
                              'type': 'string',
                              'const': 'organizerEventWhatsapp',
                            },
                            'senderId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 160,
                              'pattern': '^[a-zA-Z0-9][a-zA-Z0-9._:-]*\$',
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'routeId',
                          ],
                          'properties': <String, Object?>{
                            'routeId': <String, Object?>{
                              'type': 'string',
                              'const': 'catchEventRcs',
                            },
                          },
                        },
                      ],
                    },
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
                        'const': null,
                      },
                    ],
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
              },
              'expiresAt': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 9007199254740991,
              },
              'maxEvaluations': <String, Object?>{
                'type': 'integer',
                'minimum': 1,
                'maximum': 10000,
              },
              'checkpoint': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'dueAt',
                  'evaluatedAt',
                  'evaluations',
                  'sourceHash',
                  'observation',
                  'publication',
                ],
                'properties': <String, Object?>{
                  'dueAt': <String, Object?>{
                    'anyOf': <Object?>[
                      <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 9007199254740991,
                      },
                      <String, Object?>{
                        'type': 'null',
                        'const': null,
                      },
                    ],
                  },
                  'evaluatedAt': <String, Object?>{
                    'anyOf': <Object?>[
                      <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 9007199254740991,
                      },
                      <String, Object?>{
                        'type': 'null',
                        'const': null,
                      },
                    ],
                  },
                  'evaluations': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 10000,
                  },
                  'sourceHash': <String, Object?>{
                    'anyOf': <Object?>[
                      <String, Object?>{
                        'type': 'string',
                        'pattern': '^[a-f0-9]{64}\$',
                      },
                      <String, Object?>{
                        'type': 'null',
                        'const': null,
                      },
                    ],
                  },
                  'observation': <String, Object?>{
                    'anyOf': <Object?>[
                      <String, Object?>{
                        'oneOf': <Object?>[
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'decision',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'decision',
                              },
                              'decision': <String, Object?>{
                                'anyOf': <Object?>[
                                  <String, Object?>{
                                    'type': 'object',
                                    'additionalProperties': false,
                                    'required': <Object?>[
                                      'kind',
                                      'reason',
                                    ],
                                    'properties': <String, Object?>{
                                      'kind': <String, Object?>{
                                        'type': 'string',
                                        'const': 'resolved',
                                      },
                                      'reason': <String, Object?>{
                                        'type': 'string',
                                        'enum': <Object?>[
                                          'joined',
                                          'declined',
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
                                        'type': 'string',
                                        'const': 'cancelled',
                                      },
                                      'reason': <String, Object?>{
                                        'type': 'string',
                                        'enum': <Object?>[
                                          'eventClosed',
                                          'notAdmitted',
                                          'policyDisabled',
                                          'participationInactive',
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
                                        'type': 'string',
                                        'const': 'expired',
                                      },
                                      'reason': <String, Object?>{
                                        'type': 'string',
                                        'enum': <Object?>[
                                          'cutoff',
                                          'lateEntryClosed',
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
                                        'type': 'string',
                                        'const': 'wait',
                                      },
                                      'reason': <String, Object?>{
                                        'type': 'string',
                                        'enum': <Object?>[
                                          'departureUnconfirmed',
                                          'attendanceUnknown',
                                          'guidanceUnavailable',
                                          'throttled',
                                          'unchanged',
                                          'participationUnknown',
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
                                      'guidance',
                                    ],
                                    'properties': <String, Object?>{
                                      'kind': <String, Object?>{
                                        'type': 'string',
                                        'const': 'hostDecision',
                                      },
                                      'reason': <String, Object?>{
                                        'type': 'string',
                                        'enum': <Object?>[
                                          'unreachable',
                                          'entryDecision',
                                          'missingInformation',
                                        ],
                                      },
                                      'guidance': <String, Object?>{
                                        'anyOf': <Object?>[
                                          <String, Object?>{
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
                                          <String, Object?>{
                                            'type': 'null',
                                            'const': null,
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
                                      'guidance',
                                      'messageKey',
                                      'shouldSend',
                                      'nextEvaluationAt',
                                    ],
                                    'properties': <String, Object?>{
                                      'kind': <String, Object?>{
                                        'type': 'string',
                                        'const': 'update',
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
                                      'messageKey': <String, Object?>{
                                        'type': 'string',
                                        'minLength': 1,
                                        'maxLength': 2000,
                                      },
                                      'shouldSend': <String, Object?>{
                                        'type': 'boolean',
                                      },
                                      'nextEvaluationAt': <String, Object?>{
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
                                    },
                                  },
                                ],
                                'title': 'EventAssistanceLateJoinDecision',
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
                                'type': 'string',
                                'const': 'sourceNotReady',
                              },
                              'reason': <String, Object?>{
                                'type': 'string',
                                'enum': <Object?>[
                                  'episodeMissing',
                                  'guestSourceChanged',
                                  'membershipMissing',
                                  'membershipSourceChanged',
                                  'unconfigured',
                                  'disabled',
                                  'settingSourceChanged',
                                  'eventClosed',
                                  'runtimeNotLive',
                                  'progressUnconfirmed',
                                  'progressSourceChanged',
                                  'destinationUnavailable',
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
                                'type': 'string',
                                'const': 'historyUnavailable',
                              },
                              'reason': <String, Object?>{
                                'type': 'string',
                                'enum': <Object?>[
                                  'historyLimit',
                                  'deliveryConflict',
                                  'ambiguousHistory',
                                ],
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'responseDeadlineMissing',
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'episodeChanged',
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'workExpired',
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'evaluationLimit',
                              },
                            },
                          },
                        ],
                      },
                      <String, Object?>{
                        'type': 'null',
                        'const': null,
                      },
                    ],
                  },
                  'publication': <String, Object?>{
                    'anyOf': <Object?>[
                      <String, Object?>{
                        'type': 'object',
                        'additionalProperties': false,
                        'required': <Object?>[
                          'messageId',
                          'threadId',
                        ],
                        'properties': <String, Object?>{
                          'messageId': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 180,
                            'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                          },
                          'threadId': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 180,
                            'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                          },
                        },
                      },
                      <String, Object?>{
                        'type': 'null',
                        'const': null,
                      },
                    ],
                  },
                },
              },
            },
          },
        },
      },
    },
    <String, Object?>{
      'if': <String, Object?>{
        'properties': <String, Object?>{
          'lifecycleStatus': <String, Object?>{
            'const': 'terminal',
          },
        },
      },
      'then': <String, Object?>{
        'properties': <String, Object?>{
          'outcome': <String, Object?>{
            'type': 'string',
            'not': <String, Object?>{
              'const': 'published',
            },
          },
        },
      },
    },
    <String, Object?>{
      'if': <String, Object?>{
        'properties': <String, Object?>{
          'lifecycleStatus': <String, Object?>{
            'const': 'published',
          },
        },
      },
      'then': <String, Object?>{
        'properties': <String, Object?>{
          'outcome': <String, Object?>{
            'const': 'published',
          },
        },
      },
    },
    <String, Object?>{
      'if': <String, Object?>{
        'properties': <String, Object?>{
          'lifecycleStatus': <String, Object?>{
            'enum': <Object?>[
              'queued',
              'in_progress',
              'waiting',
              'ready',
            ],
          },
        },
      },
      'then': <String, Object?>{
        'properties': <String, Object?>{
          'outcome': <String, Object?>{
            'type': 'null',
          },
        },
      },
    },
    <String, Object?>{
      'if': <String, Object?>{
        'anyOf': <Object?>[
          <String, Object?>{
            'required': <Object?>[
              'blockerCodes',
            ],
            'properties': <String, Object?>{
              'blockerCodes': <String, Object?>{
                'contains': <String, Object?>{
                  'const': 'human_review_required',
                },
              },
            },
          },
          <String, Object?>{
            'required': <Object?>[
              'normalizedPayload',
            ],
            'properties': <String, Object?>{
              'normalizedPayload': <String, Object?>{
                'type': 'object',
                'required': <Object?>[
                  'owner',
                ],
                'properties': <String, Object?>{
                  'owner': <String, Object?>{
                    'const': 'human',
                  },
                },
              },
            },
          },
        ],
      },
      'then': <String, Object?>{
        'properties': <String, Object?>{
          'taskFlags': <String, Object?>{
            'contains': <String, Object?>{
              'const': 'human_review_required',
            },
          },
        },
      },
    },
    <String, Object?>{
      'if': <String, Object?>{
        'required': <Object?>[
          'lifecycleStatus',
        ],
        'properties': <String, Object?>{
          'lifecycleStatus': <String, Object?>{
            'enum': <Object?>[
              'published',
              'terminal',
            ],
          },
        },
      },
      'then': <String, Object?>{
        'properties': <String, Object?>{
          'taskFlags': <String, Object?>{
            'not': <String, Object?>{
              'contains': <String, Object?>{
                'const': 'human_review_required',
              },
            },
          },
          'blockerCodes': <String, Object?>{
            'not': <String, Object?>{
              'contains': <String, Object?>{
                'const': 'human_review_required',
              },
            },
          },
          'normalizedPayload': <String, Object?>{
            'not': <String, Object?>{
              'required': <Object?>[
                'owner',
              ],
              'properties': <String, Object?>{
                'owner': <String, Object?>{
                  'const': 'human',
                },
              },
            },
          },
        },
      },
    },
    <String, Object?>{
      'if': <String, Object?>{
        'properties': <String, Object?>{
          'normalizedPayload': <String, Object?>{
            'type': 'object',
            'required': <Object?>[
              'intake',
            ],
            'properties': <String, Object?>{
              'intake': <String, Object?>{
                'type': 'object',
                'required': <Object?>[
                  'recordType',
                ],
                'properties': <String, Object?>{
                  'recordType': <String, Object?>{
                    'const': 'organizer_publication_packet',
                  },
                },
              },
            },
          },
        },
      },
      'then': <String, Object?>{
        'properties': <String, Object?>{
          'normalizedPayload': <String, Object?>{
            'properties': <String, Object?>{
              'intake': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'recordType',
                  'packet',
                ],
                'properties': <String, Object?>{
                  'recordType': <String, Object?>{
                    'const': 'organizer_publication_packet',
                  },
                  'packet': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'packetId',
                      'entityId',
                      'canonicalHostId',
                      'displayName',
                      'status',
                      'priority',
                      'markets',
                      'blockers',
                      'dataBlockers',
                      'evidenceBlockers',
                      'approvalChecklist',
                      'evidenceSummary',
                      'publicPresence',
                      'adminDecision',
                      'nextActions',
                    ],
                    'properties': <String, Object?>{
                      'packetId': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'entityId': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'canonicalHostId': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'displayName': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'status': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'priority': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'markets': <String, Object?>{
                        'type': 'array',
                        'maxItems': 8,
                        'items': <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'slug',
                            'displayName',
                          ],
                          'properties': <String, Object?>{
                            'slug': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 500,
                            },
                            'displayName': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 500,
                            },
                          },
                        },
                      },
                      'blockers': <String, Object?>{
                        'type': 'array',
                        'maxItems': 40,
                        'items': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 500,
                        },
                      },
                      'dataBlockers': <String, Object?>{
                        'type': 'array',
                        'maxItems': 40,
                        'items': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 500,
                        },
                      },
                      'evidenceBlockers': <String, Object?>{
                        'type': 'array',
                        'maxItems': 40,
                        'items': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 500,
                        },
                      },
                      'approvalChecklist': <String, Object?>{
                        'type': 'object',
                        'additionalProperties': false,
                        'required': <Object?>[
                          'crawlDisabledReviewed',
                          'identityReviewed',
                          'marketScopeReviewed',
                          'mediaRightsReviewed',
                          'ownerSafeCopyReviewed',
                          'surfaceInventoryReviewed',
                        ],
                        'properties': <String, Object?>{
                          'crawlDisabledReviewed': <String, Object?>{
                            'type': 'boolean',
                          },
                          'identityReviewed': <String, Object?>{
                            'type': 'boolean',
                          },
                          'marketScopeReviewed': <String, Object?>{
                            'type': 'boolean',
                          },
                          'mediaRightsReviewed': <String, Object?>{
                            'type': 'boolean',
                          },
                          'ownerSafeCopyReviewed': <String, Object?>{
                            'type': 'boolean',
                          },
                          'surfaceInventoryReviewed': <String, Object?>{
                            'type': 'boolean',
                          },
                        },
                      },
                      'evidenceSummary': <String, Object?>{
                        'type': 'object',
                        'additionalProperties': false,
                        'required': <Object?>[
                          'records',
                          'manualReportsWithoutArtifacts',
                          'unresolvedLocalRefs',
                          'missingSurfaceEvidence',
                          'rawProviderArtifactRefs',
                          'firestoreForbiddenArtifactRefs',
                          'riskFlags',
                        ],
                        'properties': <String, Object?>{
                          'records': <String, Object?>{
                            'type': 'integer',
                            'minimum': 0,
                          },
                          'manualReportsWithoutArtifacts': <String, Object?>{
                            'type': 'integer',
                            'minimum': 0,
                          },
                          'unresolvedLocalRefs': <String, Object?>{
                            'type': 'integer',
                            'minimum': 0,
                          },
                          'missingSurfaceEvidence': <String, Object?>{
                            'type': 'integer',
                            'minimum': 0,
                          },
                          'rawProviderArtifactRefs': <String, Object?>{
                            'type': 'integer',
                            'minimum': 0,
                          },
                          'firestoreForbiddenArtifactRefs': <String, Object?>{
                            'type': 'integer',
                            'minimum': 0,
                          },
                          'riskFlags': <String, Object?>{
                            'type': 'array',
                            'maxItems': 12,
                            'items': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 500,
                            },
                          },
                        },
                      },
                      'publicPresence': <String, Object?>{
                        'type': 'object',
                        'additionalProperties': false,
                        'required': <Object?>[
                          'canonicalPath',
                          'claimTargetPath',
                          'publishStatus',
                          'indexStatus',
                          'appVisibility',
                          'projectionStatus',
                        ],
                        'properties': <String, Object?>{
                          'canonicalPath': <String, Object?>{
                            'anyOf': <Object?>[
                              <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 500,
                              },
                              <String, Object?>{
                                'type': 'null',
                              },
                            ],
                          },
                          'claimTargetPath': <String, Object?>{
                            'anyOf': <Object?>[
                              <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 500,
                              },
                              <String, Object?>{
                                'type': 'null',
                              },
                            ],
                          },
                          'publishStatus': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 500,
                          },
                          'indexStatus': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 500,
                          },
                          'appVisibility': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 500,
                          },
                          'projectionStatus': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 500,
                          },
                        },
                      },
                      'adminDecision': <String, Object?>{
                        'type': 'object',
                        'additionalProperties': false,
                        'required': <Object?>[
                          'allowedDecisions',
                          'defaultAppVisibility',
                          'currentDecision',
                        ],
                        'properties': <String, Object?>{
                          'allowedDecisions': <String, Object?>{
                            'type': 'array',
                            'maxItems': 40,
                            'items': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 500,
                            },
                          },
                          'defaultAppVisibility': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 500,
                          },
                          'currentDecision': <String, Object?>{
                            'anyOf': <Object?>[
                              <String, Object?>{
                                'type': 'null',
                              },
                              <String, Object?>{
                                'type': 'object',
                                'additionalProperties': false,
                                'required': <Object?>[
                                  'decision',
                                  'publishStatus',
                                  'indexStatus',
                                  'decidedAt',
                                  'appVisibility',
                                ],
                                'properties': <String, Object?>{
                                  'decision': <String, Object?>{
                                    'type': 'string',
                                    'minLength': 1,
                                    'maxLength': 500,
                                  },
                                  'publishStatus': <String, Object?>{
                                    'type': 'string',
                                    'minLength': 1,
                                    'maxLength': 500,
                                  },
                                  'indexStatus': <String, Object?>{
                                    'type': 'string',
                                    'minLength': 1,
                                    'maxLength': 500,
                                  },
                                  'decidedAt': <String, Object?>{
                                    'type': 'string',
                                    'minLength': 1,
                                    'maxLength': 500,
                                  },
                                  'appVisibility': <String, Object?>{
                                    'type': 'string',
                                    'minLength': 1,
                                    'maxLength': 500,
                                  },
                                },
                              },
                            ],
                          },
                        },
                      },
                      'nextActions': <String, Object?>{
                        'type': 'array',
                        'maxItems': 12,
                        'items': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 500,
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
    <String, Object?>{
      'if': <String, Object?>{
        'properties': <String, Object?>{
          'normalizedPayload': <String, Object?>{
            'type': 'object',
            'required': <Object?>[
              'intake',
            ],
            'properties': <String, Object?>{
              'intake': <String, Object?>{
                'type': 'object',
                'required': <Object?>[
                  'recordType',
                ],
                'properties': <String, Object?>{
                  'recordType': <String, Object?>{
                    'const': 'supply_freshness_coverage',
                  },
                },
              },
            },
          },
        },
      },
      'then': <String, Object?>{
        'properties': <String, Object?>{
          'normalizedPayload': <String, Object?>{
            'properties': <String, Object?>{
              'intake': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'recordType',
                  'coverage',
                ],
                'properties': <String, Object?>{
                  'recordType': <String, Object?>{
                    'const': 'supply_freshness_coverage',
                  },
                  'coverage': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'schemaVersion',
                      'recordType',
                      'coverageId',
                      'runId',
                      'kind',
                      'scopeKey',
                      'runKey',
                      'market',
                      'sourceProfileId',
                      'entityId',
                      'surfaceId',
                      'schedulerStatus',
                      'surfacePolicy',
                      'fetchEnabled',
                      'completedAt',
                      'policyVersion',
                      'requestHash',
                    ],
                    'properties': <String, Object?>{
                      'schemaVersion': <String, Object?>{
                        'type': 'integer',
                        'const': 1,
                      },
                      'recordType': <String, Object?>{
                        'const': 'supply_freshness_coverage',
                      },
                      'coverageId': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 180,
                        'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                      },
                      'runId': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 180,
                        'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                      },
                      'kind': <String, Object?>{
                        'type': 'string',
                        'enum': <Object?>[
                          'city_discovery_sweep',
                          'candidate_verification',
                          'known_organizer_event_refresh',
                          'event_detail_prepublication',
                        ],
                      },
                      'scopeKey': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'runKey': <String, Object?>{
                        'type': <Object?>[
                          'string',
                          'null',
                        ],
                        'maxLength': 500,
                      },
                      'market': <String, Object?>{
                        'type': <Object?>[
                          'string',
                          'null',
                        ],
                        'maxLength': 80,
                      },
                      'sourceProfileId': <String, Object?>{
                        'type': <Object?>[
                          'string',
                          'null',
                        ],
                        'maxLength': 160,
                      },
                      'entityId': <String, Object?>{
                        'type': <Object?>[
                          'string',
                          'null',
                        ],
                        'maxLength': 200,
                      },
                      'surfaceId': <String, Object?>{
                        'type': <Object?>[
                          'string',
                          'null',
                        ],
                        'maxLength': 200,
                      },
                      'schedulerStatus': <String, Object?>{
                        'type': <Object?>[
                          'string',
                          'null',
                        ],
                        'maxLength': 40,
                      },
                      'surfacePolicy': <String, Object?>{
                        'type': <Object?>[
                          'string',
                          'null',
                        ],
                        'maxLength': 80,
                      },
                      'fetchEnabled': <String, Object?>{
                        'type': 'boolean',
                      },
                      'completedAt': <String, Object?>{
                        'type': 'string',
                        'format': 'date-time',
                      },
                      'policyVersion': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 120,
                      },
                      'requestHash': <String, Object?>{
                        'type': 'string',
                        'pattern': '^[a-f0-9]{64}\$',
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
    <String, Object?>{
      'if': <String, Object?>{
        'properties': <String, Object?>{
          'normalizedPayload': <String, Object?>{
            'type': 'object',
            'required': <Object?>[
              'intake',
            ],
            'properties': <String, Object?>{
              'intake': <String, Object?>{
                'type': 'object',
                'required': <Object?>[
                  'recordType',
                ],
                'properties': <String, Object?>{
                  'recordType': <String, Object?>{
                    'const': 'orphan_event_candidate',
                  },
                },
              },
            },
          },
        },
      },
      'then': <String, Object?>{
        'properties': <String, Object?>{
          'entityKind': <String, Object?>{
            'const': 'event',
          },
          'lifecycleStatus': <String, Object?>{
            'not': <String, Object?>{
              'const': 'published',
            },
          },
          'blockerCodes': <String, Object?>{
            'contains': <String, Object?>{
              'const': 'organizer_not_in_inventory',
            },
          },
          'normalizedPayload': <String, Object?>{
            'properties': <String, Object?>{
              'intake': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'recordType',
                  'candidate',
                ],
                'properties': <String, Object?>{
                  'recordType': <String, Object?>{
                    'const': 'orphan_event_candidate',
                  },
                  'candidate': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': true,
                    'required': <Object?>[
                      'id',
                      'candidateId',
                      'publicationEligibility',
                      'blockerCodes',
                      'attribution',
                    ],
                    'properties': <String, Object?>{
                      'id': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'candidateId': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'publicationEligibility': <String, Object?>{
                        'const': 'blocked_orphan',
                      },
                      'blockerCodes': <String, Object?>{
                        'type': 'array',
                        'maxItems': 40,
                        'contains': <String, Object?>{
                          'const': 'organizer_not_in_inventory',
                        },
                        'items': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 500,
                        },
                      },
                      'attribution': <String, Object?>{
                        'type': 'object',
                        'additionalProperties': false,
                        'required': <Object?>[
                          'state',
                          'organizerEvidence',
                          'match',
                        ],
                        'properties': <String, Object?>{
                          'state': <String, Object?>{
                            'const': 'orphan',
                          },
                          'organizerEvidence': <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'name',
                              'url',
                            ],
                            'properties': <String, Object?>{
                              'name': <String, Object?>{
                                'anyOf': <Object?>[
                                  <String, Object?>{
                                    'type': 'string',
                                    'minLength': 1,
                                    'maxLength': 500,
                                  },
                                  <String, Object?>{
                                    'type': 'null',
                                  },
                                ],
                              },
                              'url': <String, Object?>{
                                'anyOf': <Object?>[
                                  <String, Object?>{
                                    'type': 'string',
                                    'minLength': 1,
                                    'maxLength': 500,
                                  },
                                  <String, Object?>{
                                    'type': 'null',
                                  },
                                ],
                              },
                            },
                          },
                          'match': <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'decision',
                              'policyId',
                              'threshold',
                              'rationale',
                              'matchedEntityId',
                              'score',
                              'matchingSignals',
                              'blockingKeys',
                            ],
                            'properties': <String, Object?>{
                              'decision': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 500,
                              },
                              'policyId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 500,
                              },
                              'threshold': <String, Object?>{
                                'type': 'number',
                                'minimum': 0,
                                'maximum': 1,
                              },
                              'rationale': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 500,
                              },
                              'matchedEntityId': <String, Object?>{
                                'type': 'null',
                              },
                              'score': <String, Object?>{
                                'type': 'number',
                                'minimum': 0,
                                'maximum': 1,
                              },
                              'matchingSignals': <String, Object?>{
                                'type': 'array',
                                'maxItems': 40,
                                'items': <String, Object?>{
                                  'type': 'string',
                                  'minLength': 1,
                                  'maxLength': 500,
                                },
                              },
                              'blockingKeys': <String, Object?>{
                                'type': 'array',
                                'maxItems': 40,
                                'items': <String, Object?>{
                                  'type': 'string',
                                  'minLength': 1,
                                  'maxLength': 500,
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
    <String, Object?>{
      'if': <String, Object?>{
        'properties': <String, Object?>{
          'normalizedPayload': <String, Object?>{
            'type': 'object',
            'required': <Object?>[
              'intake',
            ],
            'properties': <String, Object?>{
              'intake': <String, Object?>{
                'type': 'object',
                'required': <Object?>[
                  'recordType',
                ],
                'properties': <String, Object?>{
                  'recordType': <String, Object?>{
                    'const': 'event_candidate',
                  },
                },
              },
            },
          },
        },
      },
      'then': <String, Object?>{
        'properties': <String, Object?>{
          'entityKind': <String, Object?>{
            'const': 'event',
          },
          'normalizedPayload': <String, Object?>{
            'properties': <String, Object?>{
              'intake': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'recordType',
                  'candidate',
                ],
                'properties': <String, Object?>{
                  'recordType': <String, Object?>{
                    'const': 'event_candidate',
                  },
                  'candidate': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': true,
                    'required': <Object?>[
                      'id',
                      'title',
                      'startDate',
                      'sourceResultIds',
                      'reviewState',
                      'requiresVerification',
                      'warnings',
                      'blockerCodes',
                      'publicationEligibility',
                    ],
                    'properties': <String, Object?>{
                      'id': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'title': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'startDate': <String, Object?>{
                        'type': 'string',
                        'maxLength': 40,
                      },
                      'sourceResultIds': <String, Object?>{
                        'type': 'array',
                        'maxItems': 40,
                        'items': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 500,
                        },
                      },
                      'reviewState': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'requiresVerification': <String, Object?>{
                        'type': 'boolean',
                      },
                      'warnings': <String, Object?>{
                        'type': 'array',
                        'maxItems': 40,
                        'items': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 500,
                        },
                      },
                      'blockerCodes': <String, Object?>{
                        'type': 'array',
                        'maxItems': 40,
                        'items': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 500,
                        },
                      },
                      'publicationEligibility': <String, Object?>{
                        'const': 'review_gated',
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
    <String, Object?>{
      'if': <String, Object?>{
        'properties': <String, Object?>{
          'normalizedPayload': <String, Object?>{
            'type': 'object',
            'required': <Object?>[
              'intake',
            ],
            'properties': <String, Object?>{
              'intake': <String, Object?>{
                'type': 'object',
                'required': <Object?>[
                  'recordType',
                ],
                'properties': <String, Object?>{
                  'recordType': <String, Object?>{
                    'const': 'event_source_result',
                  },
                },
              },
            },
          },
        },
      },
      'then': <String, Object?>{
        'properties': <String, Object?>{
          'entityKind': <String, Object?>{
            'const': 'source_result',
          },
          'normalizedPayload': <String, Object?>{
            'properties': <String, Object?>{
              'intake': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'recordType',
                  'result',
                ],
                'properties': <String, Object?>{
                  'recordType': <String, Object?>{
                    'const': 'event_source_result',
                  },
                  'result': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'id',
                      'sourceProfileId',
                      'sourceLabel',
                      'queryTemplateId',
                      'resultType',
                      'title',
                      'url',
                      'snippet',
                      'observedAt',
                      'status',
                      'riskFlags',
                      'operatorNotes',
                    ],
                    'properties': <String, Object?>{
                      'id': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'sourceProfileId': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'sourceLabel': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'queryTemplateId': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'resultType': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'title': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'url': <String, Object?>{
                        'type': 'string',
                        'maxLength': 2000,
                      },
                      'snippet': <String, Object?>{
                        'type': 'string',
                        'maxLength': 1000,
                      },
                      'observedAt': <String, Object?>{
                        'type': 'string',
                        'maxLength': 80,
                      },
                      'status': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'riskFlags': <String, Object?>{
                        'type': 'array',
                        'maxItems': 40,
                        'items': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 500,
                        },
                      },
                      'operatorNotes': <String, Object?>{
                        'type': 'string',
                        'maxLength': 1000,
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
    <String, Object?>{
      'if': <String, Object?>{
        'properties': <String, Object?>{
          'normalizedPayload': <String, Object?>{
            'type': 'object',
            'required': <Object?>[
              'intake',
            ],
            'properties': <String, Object?>{
              'intake': <String, Object?>{
                'type': 'object',
                'required': <Object?>[
                  'recordType',
                ],
                'properties': <String, Object?>{
                  'recordType': <String, Object?>{
                    'const': 'event_source_profile',
                  },
                },
              },
            },
          },
        },
      },
      'then': <String, Object?>{
        'properties': <String, Object?>{
          'entityKind': <String, Object?>{
            'const': 'source_profile',
          },
          'normalizedPayload': <String, Object?>{
            'properties': <String, Object?>{
              'intake': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'recordType',
                  'profile',
                ],
                'properties': <String, Object?>{
                  'recordType': <String, Object?>{
                    'const': 'event_source_profile',
                  },
                  'profile': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'id',
                      'label',
                      'type',
                      'status',
                      'cadence',
                      'riskLevel',
                      'allowedUse',
                      'items',
                    ],
                    'properties': <String, Object?>{
                      'id': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'label': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'type': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'status': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'cadence': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'riskLevel': <String, Object?>{
                        'type': 'string',
                        'enum': <Object?>[
                          'low',
                          'medium',
                          'high',
                        ],
                      },
                      'allowedUse': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                      'items': <String, Object?>{
                        'type': 'array',
                        'maxItems': 40,
                        'items': <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'label',
                            'url',
                          ],
                          'properties': <String, Object?>{
                            'label': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 500,
                            },
                            'url': <String, Object?>{
                              'type': 'string',
                              'maxLength': 2000,
                            },
                          },
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
  ],
  'definitions': <String, Object?>{
    'boundedString': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 500,
    },
    'boundedStringArray': <String, Object?>{
      'type': 'array',
      'maxItems': 40,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 500,
      },
    },
    'eventCandidateIntake': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'recordType',
        'candidate',
      ],
      'properties': <String, Object?>{
        'recordType': <String, Object?>{
          'const': 'event_candidate',
        },
        'candidate': <String, Object?>{
          'type': 'object',
          'additionalProperties': true,
          'required': <Object?>[
            'id',
            'title',
            'startDate',
            'sourceResultIds',
            'reviewState',
            'requiresVerification',
            'warnings',
            'blockerCodes',
            'publicationEligibility',
          ],
          'properties': <String, Object?>{
            'id': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'title': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'startDate': <String, Object?>{
              'type': 'string',
              'maxLength': 40,
            },
            'sourceResultIds': <String, Object?>{
              'type': 'array',
              'maxItems': 40,
              'items': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 500,
              },
            },
            'reviewState': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'requiresVerification': <String, Object?>{
              'type': 'boolean',
            },
            'warnings': <String, Object?>{
              'type': 'array',
              'maxItems': 40,
              'items': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 500,
              },
            },
            'blockerCodes': <String, Object?>{
              'type': 'array',
              'maxItems': 40,
              'items': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 500,
              },
            },
            'publicationEligibility': <String, Object?>{
              'const': 'review_gated',
            },
          },
        },
      },
    },
    'eventSourceResultIntake': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'recordType',
        'result',
      ],
      'properties': <String, Object?>{
        'recordType': <String, Object?>{
          'const': 'event_source_result',
        },
        'result': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'id',
            'sourceProfileId',
            'sourceLabel',
            'queryTemplateId',
            'resultType',
            'title',
            'url',
            'snippet',
            'observedAt',
            'status',
            'riskFlags',
            'operatorNotes',
          ],
          'properties': <String, Object?>{
            'id': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'sourceProfileId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'sourceLabel': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'queryTemplateId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'resultType': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'title': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'url': <String, Object?>{
              'type': 'string',
              'maxLength': 2000,
            },
            'snippet': <String, Object?>{
              'type': 'string',
              'maxLength': 1000,
            },
            'observedAt': <String, Object?>{
              'type': 'string',
              'maxLength': 80,
            },
            'status': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'riskFlags': <String, Object?>{
              'type': 'array',
              'maxItems': 40,
              'items': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 500,
              },
            },
            'operatorNotes': <String, Object?>{
              'type': 'string',
              'maxLength': 1000,
            },
          },
        },
      },
    },
    'eventSourceProfileIntake': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'recordType',
        'profile',
      ],
      'properties': <String, Object?>{
        'recordType': <String, Object?>{
          'const': 'event_source_profile',
        },
        'profile': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'id',
            'label',
            'type',
            'status',
            'cadence',
            'riskLevel',
            'allowedUse',
            'items',
          ],
          'properties': <String, Object?>{
            'id': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'label': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'type': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'status': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'cadence': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'riskLevel': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'low',
                'medium',
                'high',
              ],
            },
            'allowedUse': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'items': <String, Object?>{
              'type': 'array',
              'maxItems': 40,
              'items': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'label',
                  'url',
                ],
                'properties': <String, Object?>{
                  'label': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 500,
                  },
                  'url': <String, Object?>{
                    'type': 'string',
                    'maxLength': 2000,
                  },
                },
              },
            },
          },
        },
      },
    },
    'orphanEventCandidateIntake': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'recordType',
        'candidate',
      ],
      'properties': <String, Object?>{
        'recordType': <String, Object?>{
          'const': 'orphan_event_candidate',
        },
        'candidate': <String, Object?>{
          'type': 'object',
          'additionalProperties': true,
          'required': <Object?>[
            'id',
            'candidateId',
            'publicationEligibility',
            'blockerCodes',
            'attribution',
          ],
          'properties': <String, Object?>{
            'id': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'candidateId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'publicationEligibility': <String, Object?>{
              'const': 'blocked_orphan',
            },
            'blockerCodes': <String, Object?>{
              'type': 'array',
              'maxItems': 40,
              'contains': <String, Object?>{
                'const': 'organizer_not_in_inventory',
              },
              'items': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 500,
              },
            },
            'attribution': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'state',
                'organizerEvidence',
                'match',
              ],
              'properties': <String, Object?>{
                'state': <String, Object?>{
                  'const': 'orphan',
                },
                'organizerEvidence': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'name',
                    'url',
                  ],
                  'properties': <String, Object?>{
                    'name': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 500,
                        },
                        <String, Object?>{
                          'type': 'null',
                        },
                      ],
                    },
                    'url': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 500,
                        },
                        <String, Object?>{
                          'type': 'null',
                        },
                      ],
                    },
                  },
                },
                'match': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'decision',
                    'policyId',
                    'threshold',
                    'rationale',
                    'matchedEntityId',
                    'score',
                    'matchingSignals',
                    'blockingKeys',
                  ],
                  'properties': <String, Object?>{
                    'decision': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 500,
                    },
                    'policyId': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 500,
                    },
                    'threshold': <String, Object?>{
                      'type': 'number',
                      'minimum': 0,
                      'maximum': 1,
                    },
                    'rationale': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 500,
                    },
                    'matchedEntityId': <String, Object?>{
                      'type': 'null',
                    },
                    'score': <String, Object?>{
                      'type': 'number',
                      'minimum': 0,
                      'maximum': 1,
                    },
                    'matchingSignals': <String, Object?>{
                      'type': 'array',
                      'maxItems': 40,
                      'items': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                    },
                    'blockingKeys': <String, Object?>{
                      'type': 'array',
                      'maxItems': 40,
                      'items': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 500,
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
    'supplyFreshnessCoverageIntake': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'recordType',
        'coverage',
      ],
      'properties': <String, Object?>{
        'recordType': <String, Object?>{
          'const': 'supply_freshness_coverage',
        },
        'coverage': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'schemaVersion',
            'recordType',
            'coverageId',
            'runId',
            'kind',
            'scopeKey',
            'runKey',
            'market',
            'sourceProfileId',
            'entityId',
            'surfaceId',
            'schedulerStatus',
            'surfacePolicy',
            'fetchEnabled',
            'completedAt',
            'policyVersion',
            'requestHash',
          ],
          'properties': <String, Object?>{
            'schemaVersion': <String, Object?>{
              'type': 'integer',
              'const': 1,
            },
            'recordType': <String, Object?>{
              'const': 'supply_freshness_coverage',
            },
            'coverageId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
              'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
            },
            'runId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
              'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
            },
            'kind': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'city_discovery_sweep',
                'candidate_verification',
                'known_organizer_event_refresh',
                'event_detail_prepublication',
              ],
            },
            'scopeKey': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'runKey': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'maxLength': 500,
            },
            'market': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'maxLength': 80,
            },
            'sourceProfileId': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'maxLength': 160,
            },
            'entityId': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'maxLength': 200,
            },
            'surfaceId': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'maxLength': 200,
            },
            'schedulerStatus': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'maxLength': 40,
            },
            'surfacePolicy': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'maxLength': 80,
            },
            'fetchEnabled': <String, Object?>{
              'type': 'boolean',
            },
            'completedAt': <String, Object?>{
              'type': 'string',
              'format': 'date-time',
            },
            'policyVersion': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 120,
            },
            'requestHash': <String, Object?>{
              'type': 'string',
              'pattern': '^[a-f0-9]{64}\$',
            },
          },
        },
      },
    },
    'organizerPublicationPacketIntake': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'recordType',
        'packet',
      ],
      'properties': <String, Object?>{
        'recordType': <String, Object?>{
          'const': 'organizer_publication_packet',
        },
        'packet': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'packetId',
            'entityId',
            'canonicalHostId',
            'displayName',
            'status',
            'priority',
            'markets',
            'blockers',
            'dataBlockers',
            'evidenceBlockers',
            'approvalChecklist',
            'evidenceSummary',
            'publicPresence',
            'adminDecision',
            'nextActions',
          ],
          'properties': <String, Object?>{
            'packetId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'entityId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'canonicalHostId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'displayName': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'status': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'priority': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 500,
            },
            'markets': <String, Object?>{
              'type': 'array',
              'maxItems': 8,
              'items': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'slug',
                  'displayName',
                ],
                'properties': <String, Object?>{
                  'slug': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 500,
                  },
                  'displayName': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 500,
                  },
                },
              },
            },
            'blockers': <String, Object?>{
              'type': 'array',
              'maxItems': 40,
              'items': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 500,
              },
            },
            'dataBlockers': <String, Object?>{
              'type': 'array',
              'maxItems': 40,
              'items': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 500,
              },
            },
            'evidenceBlockers': <String, Object?>{
              'type': 'array',
              'maxItems': 40,
              'items': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 500,
              },
            },
            'approvalChecklist': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'crawlDisabledReviewed',
                'identityReviewed',
                'marketScopeReviewed',
                'mediaRightsReviewed',
                'ownerSafeCopyReviewed',
                'surfaceInventoryReviewed',
              ],
              'properties': <String, Object?>{
                'crawlDisabledReviewed': <String, Object?>{
                  'type': 'boolean',
                },
                'identityReviewed': <String, Object?>{
                  'type': 'boolean',
                },
                'marketScopeReviewed': <String, Object?>{
                  'type': 'boolean',
                },
                'mediaRightsReviewed': <String, Object?>{
                  'type': 'boolean',
                },
                'ownerSafeCopyReviewed': <String, Object?>{
                  'type': 'boolean',
                },
                'surfaceInventoryReviewed': <String, Object?>{
                  'type': 'boolean',
                },
              },
            },
            'evidenceSummary': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'records',
                'manualReportsWithoutArtifacts',
                'unresolvedLocalRefs',
                'missingSurfaceEvidence',
                'rawProviderArtifactRefs',
                'firestoreForbiddenArtifactRefs',
                'riskFlags',
              ],
              'properties': <String, Object?>{
                'records': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                },
                'manualReportsWithoutArtifacts': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                },
                'unresolvedLocalRefs': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                },
                'missingSurfaceEvidence': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                },
                'rawProviderArtifactRefs': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                },
                'firestoreForbiddenArtifactRefs': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                },
                'riskFlags': <String, Object?>{
                  'type': 'array',
                  'maxItems': 12,
                  'items': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 500,
                  },
                },
              },
            },
            'publicPresence': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'canonicalPath',
                'claimTargetPath',
                'publishStatus',
                'indexStatus',
                'appVisibility',
                'projectionStatus',
              ],
              'properties': <String, Object?>{
                'canonicalPath': <String, Object?>{
                  'anyOf': <Object?>[
                    <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 500,
                    },
                    <String, Object?>{
                      'type': 'null',
                    },
                  ],
                },
                'claimTargetPath': <String, Object?>{
                  'anyOf': <Object?>[
                    <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 500,
                    },
                    <String, Object?>{
                      'type': 'null',
                    },
                  ],
                },
                'publishStatus': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 500,
                },
                'indexStatus': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 500,
                },
                'appVisibility': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 500,
                },
                'projectionStatus': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 500,
                },
              },
            },
            'adminDecision': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'allowedDecisions',
                'defaultAppVisibility',
                'currentDecision',
              ],
              'properties': <String, Object?>{
                'allowedDecisions': <String, Object?>{
                  'type': 'array',
                  'maxItems': 40,
                  'items': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 500,
                  },
                },
                'defaultAppVisibility': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 500,
                },
                'currentDecision': <String, Object?>{
                  'anyOf': <Object?>[
                    <String, Object?>{
                      'type': 'null',
                    },
                    <String, Object?>{
                      'type': 'object',
                      'additionalProperties': false,
                      'required': <Object?>[
                        'decision',
                        'publishStatus',
                        'indexStatus',
                        'decidedAt',
                        'appVisibility',
                      ],
                      'properties': <String, Object?>{
                        'decision': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 500,
                        },
                        'publishStatus': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 500,
                        },
                        'indexStatus': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 500,
                        },
                        'decidedAt': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 500,
                        },
                        'appVisibility': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 500,
                        },
                      },
                    },
                  ],
                },
              },
            },
            'nextActions': <String, Object?>{
              'type': 'array',
              'maxItems': 12,
              'items': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 500,
              },
            },
          },
        },
      },
    },
  },
  'required': <Object?>[
    'schemaVersion',
    'workItemId',
    'workflowId',
    'runId',
    'entityKind',
    'externalKey',
    'revision',
    'candidateHash',
    'primaryStage',
    'lifecycleStatus',
    'outcome',
    'taskFlags',
    'blockerCodes',
    'warningCodes',
    'priority',
    'attemptCount',
    'evidenceRefs',
    'fieldProvenance',
    'normalizedPayload',
    'decisionId',
    'publicationPlanId',
    'createdAt',
    'updatedAt',
    'staleAt',
    'expiresAt',
  ],
  'properties': <String, Object?>{
    'schemaVersion': <String, Object?>{
      'type': 'integer',
      'const': 1,
    },
    'workItemId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
    },
    'workflowId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'pattern': '^[a-z][a-z0-9_-]*\$',
    },
    'runId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
    },
    'entityKind': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'pattern': '^[a-z][a-z0-9_]*\$',
    },
    'externalKey': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 500,
    },
    'revision': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'candidateHash': <String, Object?>{
      'type': 'string',
      'pattern': '^[a-f0-9]{64}\$',
    },
    'primaryStage': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'pattern': '^[a-z][a-z0-9_]*\$',
    },
    'lifecycleStatus': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'queued',
        'in_progress',
        'waiting',
        'ready',
        'published',
        'terminal',
      ],
    },
    'outcome': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 120,
      'pattern': '^[a-z][a-z0-9_]*\$',
    },
    'taskFlags': <String, Object?>{
      'type': 'array',
      'maxItems': 40,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 120,
        'pattern': '^[a-z][a-z0-9_.:-]*\$',
      },
    },
    'blockerCodes': <String, Object?>{
      'type': 'array',
      'maxItems': 40,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 120,
        'pattern': '^[a-z][a-z0-9_.:-]*\$',
      },
    },
    'warningCodes': <String, Object?>{
      'type': 'array',
      'maxItems': 40,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 120,
        'pattern': '^[a-z][a-z0-9_.:-]*\$',
      },
    },
    'priority': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 1000000,
    },
    'attemptCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'evidenceRefs': <String, Object?>{
      'type': 'array',
      'maxItems': 100,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'artifactId',
          'contentHash',
          'observedAt',
          'locator',
        ],
        'properties': <String, Object?>{
          'artifactId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
            'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
          },
          'contentHash': <String, Object?>{
            'type': 'string',
            'pattern': '^[a-f0-9]{64}\$',
          },
          'observedAt': <String, Object?>{
            'type': 'string',
            'format': 'date-time',
          },
          'locator': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
            'maxLength': 1000,
          },
        },
      },
    },
    'fieldProvenance': <String, Object?>{
      'type': 'array',
      'maxItems': 200,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'field',
          'artifactId',
          'contentHash',
          'locator',
          'extractedBy',
          'extractorVersion',
          'confidence',
        ],
        'properties': <String, Object?>{
          'field': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 160,
          },
          'artifactId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
            'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
          },
          'contentHash': <String, Object?>{
            'type': 'string',
            'pattern': '^[a-f0-9]{64}\$',
          },
          'locator': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
            'maxLength': 1000,
          },
          'extractedBy': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'deterministic',
              'model',
              'human',
            ],
          },
          'extractorVersion': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 160,
          },
          'confidence': <String, Object?>{
            'type': <Object?>[
              'number',
              'null',
            ],
            'minimum': 0,
            'maximum': 1,
          },
        },
      },
    },
    'normalizedPayload': <String, Object?>{
      'type': 'object',
      'additionalProperties': true,
    },
    'decisionId': <String, Object?>{
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
    'publicationPlanId': <String, Object?>{
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
    'createdAt': <String, Object?>{
      'type': 'string',
      'format': 'date-time',
    },
    'updatedAt': <String, Object?>{
      'type': 'string',
      'format': 'date-time',
    },
    'staleAt': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'format': 'date-time',
    },
    'expiresAt': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'format': 'date-time',
    },
  },
};
