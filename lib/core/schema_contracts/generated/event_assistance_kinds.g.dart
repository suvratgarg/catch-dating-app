// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements
enum EventAssistanceWorkflowKind {
  venueReadiness,
  routeReadiness,
  formatReadiness,
  rosterReadiness,
  requiredGuestData,
  resourceReadiness,
  staffingReadiness,
  messagingReadiness,
  admissionReview,
  financialReadiness,
  joiningInstructions,
  identityResolution,
  guestAdmission,
  guestCheckIn,
  lateJoin,
  participationChange,
  guestPrerequisite,
  allocationRepair,
  placementConfirmation,
  resourceRecovery,
  fairParticipation,
  roundPublication,
  unitProgress,
  outcomeRecording,
  programmeRecovery,
  departure,
  checkpoint,
  groupTransfer,
  routeRecovery,
  locationFreshness,
  accountability,
  planChangeCommunication,
  deliveryRecovery,
  replyOwnership,
  guestAssistance,
  comfortSafety,
  attendanceSync,
  concurrencyRecovery,
  operationRecovery,
  contextBoundary,
  overrideReview,
  eventClosure,
  attendanceReconciliation,
  financialReconciliation,
  postEventFollowUp,
  eventLearning,
}

enum EventAssistanceCommandKind {
  confirmDeparture,
  setJoinIntent,
  checkInGuest,
  publishGuidance,
  sendOperationalMessage,
  openHostCase,
  setParticipation,
  proposeAllocation,
  publishAllocation,
  confirmPlacement,
  changeResource,
  transferGroup,
  recordCheckpoint,
  changeProgramme,
  recordOutcome,
  changeRoute,
  resolveAccountability,
  resolveClaim,
  admitGuest,
  assignResponsibility,
  resolveAssistance,
  reconcileAttendance,
  requestRequiredData,
  reconcileRoster,
  reconcileFinance,
  repairDelivery,
  resumeOperation,
  completeEvent,
  controlUnitProgress,
  controlReveal,
  applyOverride,
  setLocationSharing,
  requestCheckpointReport,
  recordNoShow,
  routeRestrictedCase,
  resolveRestrictedCase,
  reassignCheckpointReporter,
  setCheckpointCloseout,
}

enum EventAssistanceWorkflowFamily {
  preparation,
  arrival,
  live,
  communication,
  care,
  recovery,
  closing,
  followUp,
}

enum EventAssistanceApplicability {
  all,
  moving,
  requiredData,
  resources,
  roles,
  admission,
  paid,
  groupsOrResources,
  rounds,
  independentUnits,
  outcomes,
  movingSubgroups,
  tracking,
  accountability,
}

enum EventAssistanceWorkflowScope { any, guest, resource, unit, group }

enum EventAssistanceOverridePolicy { none, scopedReasonedExpiring }

enum EventAssistanceHostSurface {
  today,
  eventSetup,
  liveGuests,
  liveNow,
  liveRoom,
  eventReport,
}

enum EventAssistanceHostPresentation {
  readinessTask,
  atomicAction,
  exceptionQueue,
  statusControl,
  reportInsight,
}

final class EventAssistanceHostProjection {
  const EventAssistanceHostProjection({
    required this.surfaces,
    required this.presentation,
  });

  final List<EventAssistanceHostSurface> surfaces;
  final EventAssistanceHostPresentation presentation;
}

final class EventAssistanceWorkflowDescriptor {
  const EventAssistanceWorkflowDescriptor({
    required this.kind,
    required this.version,
    required this.family,
    required this.applicability,
    required this.scope,
    required this.automaticCommands,
    required this.hostCommands,
    required this.guestCommands,
    required this.overridePolicy,
    required this.hostProjection,
  });

  final EventAssistanceWorkflowKind kind;
  final int version;
  final EventAssistanceWorkflowFamily family;
  final EventAssistanceApplicability applicability;
  final EventAssistanceWorkflowScope scope;
  final List<EventAssistanceCommandKind> automaticCommands;
  final List<EventAssistanceCommandKind> hostCommands;
  final List<EventAssistanceCommandKind> guestCommands;
  final EventAssistanceOverridePolicy overridePolicy;
  final EventAssistanceHostProjection hostProjection;

  bool get hasCommandContract =>
      automaticCommands.isNotEmpty ||
      hostCommands.isNotEmpty ||
      guestCommands.isNotEmpty;
}

const eventAssistanceWorkflowCatalog = <EventAssistanceWorkflowDescriptor>[
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.venueReadiness,
    version: 1,
    family: EventAssistanceWorkflowFamily.preparation,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.today,
        EventAssistanceHostSurface.eventSetup,
      ],
      presentation: EventAssistanceHostPresentation.readinessTask,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.routeReadiness,
    version: 1,
    family: EventAssistanceWorkflowFamily.preparation,
    applicability: EventAssistanceApplicability.moving,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.today,
        EventAssistanceHostSurface.eventSetup,
      ],
      presentation: EventAssistanceHostPresentation.readinessTask,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.formatReadiness,
    version: 1,
    family: EventAssistanceWorkflowFamily.preparation,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.today,
        EventAssistanceHostSurface.eventSetup,
      ],
      presentation: EventAssistanceHostPresentation.readinessTask,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.rosterReadiness,
    version: 1,
    family: EventAssistanceWorkflowFamily.preparation,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.reconcileRoster,
    ],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.reconcileRoster,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.today,
        EventAssistanceHostSurface.eventSetup,
      ],
      presentation: EventAssistanceHostPresentation.readinessTask,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.requiredGuestData,
    version: 1,
    family: EventAssistanceWorkflowFamily.preparation,
    applicability: EventAssistanceApplicability.requiredData,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.requestRequiredData,
      EventAssistanceCommandKind.openHostCase,
    ],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.applyOverride,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.scopedReasonedExpiring,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.today,
        EventAssistanceHostSurface.eventSetup,
      ],
      presentation: EventAssistanceHostPresentation.readinessTask,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.resourceReadiness,
    version: 1,
    family: EventAssistanceWorkflowFamily.preparation,
    applicability: EventAssistanceApplicability.resources,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.changeResource,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.today,
        EventAssistanceHostSurface.eventSetup,
      ],
      presentation: EventAssistanceHostPresentation.readinessTask,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.staffingReadiness,
    version: 1,
    family: EventAssistanceWorkflowFamily.preparation,
    applicability: EventAssistanceApplicability.roles,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.assignResponsibility,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.today,
        EventAssistanceHostSurface.eventSetup,
      ],
      presentation: EventAssistanceHostPresentation.readinessTask,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.messagingReadiness,
    version: 1,
    family: EventAssistanceWorkflowFamily.preparation,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.today,
        EventAssistanceHostSurface.eventSetup,
      ],
      presentation: EventAssistanceHostPresentation.readinessTask,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.admissionReview,
    version: 1,
    family: EventAssistanceWorkflowFamily.preparation,
    applicability: EventAssistanceApplicability.admission,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.admitGuest,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.today,
        EventAssistanceHostSurface.eventSetup,
      ],
      presentation: EventAssistanceHostPresentation.readinessTask,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.financialReadiness,
    version: 1,
    family: EventAssistanceWorkflowFamily.preparation,
    applicability: EventAssistanceApplicability.paid,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.today,
        EventAssistanceHostSurface.eventSetup,
      ],
      presentation: EventAssistanceHostPresentation.readinessTask,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.joiningInstructions,
    version: 1,
    family: EventAssistanceWorkflowFamily.preparation,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.publishGuidance,
      EventAssistanceCommandKind.sendOperationalMessage,
    ],
    hostCommands: <EventAssistanceCommandKind>[],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.today,
        EventAssistanceHostSurface.eventSetup,
      ],
      presentation: EventAssistanceHostPresentation.readinessTask,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.identityResolution,
    version: 1,
    family: EventAssistanceWorkflowFamily.arrival,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.guest,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.resolveClaim,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveGuests,
      ],
      presentation: EventAssistanceHostPresentation.atomicAction,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.guestAdmission,
    version: 1,
    family: EventAssistanceWorkflowFamily.arrival,
    applicability: EventAssistanceApplicability.admission,
    scope: EventAssistanceWorkflowScope.guest,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.admitGuest,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveGuests,
      ],
      presentation: EventAssistanceHostPresentation.atomicAction,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.guestCheckIn,
    version: 1,
    family: EventAssistanceWorkflowFamily.arrival,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.guest,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.checkInGuest,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveGuests,
      ],
      presentation: EventAssistanceHostPresentation.atomicAction,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.lateJoin,
    version: 1,
    family: EventAssistanceWorkflowFamily.arrival,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.guest,
    automaticCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.publishGuidance,
      EventAssistanceCommandKind.sendOperationalMessage,
      EventAssistanceCommandKind.openHostCase,
    ],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.confirmDeparture,
      EventAssistanceCommandKind.recordNoShow,
      EventAssistanceCommandKind.resolveAccountability,
    ],
    guestCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.setJoinIntent,
    ],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveNow,
        EventAssistanceHostSurface.liveGuests,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.participationChange,
    version: 1,
    family: EventAssistanceWorkflowFamily.live,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.guest,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.setParticipation,
    ],
    guestCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.setParticipation,
    ],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveGuests,
      ],
      presentation: EventAssistanceHostPresentation.atomicAction,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.guestPrerequisite,
    version: 1,
    family: EventAssistanceWorkflowFamily.arrival,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.guest,
    automaticCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.requestRequiredData,
      EventAssistanceCommandKind.openHostCase,
    ],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.applyOverride,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.scopedReasonedExpiring,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveGuests,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.allocationRepair,
    version: 1,
    family: EventAssistanceWorkflowFamily.live,
    applicability: EventAssistanceApplicability.groupsOrResources,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.proposeAllocation,
    ],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.proposeAllocation,
      EventAssistanceCommandKind.publishAllocation,
      EventAssistanceCommandKind.applyOverride,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.scopedReasonedExpiring,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveRoom,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.placementConfirmation,
    version: 1,
    family: EventAssistanceWorkflowFamily.live,
    applicability: EventAssistanceApplicability.resources,
    scope: EventAssistanceWorkflowScope.guest,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.confirmPlacement,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveRoom,
      ],
      presentation: EventAssistanceHostPresentation.atomicAction,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.resourceRecovery,
    version: 1,
    family: EventAssistanceWorkflowFamily.live,
    applicability: EventAssistanceApplicability.resources,
    scope: EventAssistanceWorkflowScope.resource,
    automaticCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.proposeAllocation,
    ],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.changeResource,
      EventAssistanceCommandKind.proposeAllocation,
      EventAssistanceCommandKind.publishAllocation,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveRoom,
        EventAssistanceHostSurface.liveNow,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.fairParticipation,
    version: 1,
    family: EventAssistanceWorkflowFamily.live,
    applicability: EventAssistanceApplicability.groupsOrResources,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.proposeAllocation,
    ],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.publishAllocation,
      EventAssistanceCommandKind.applyOverride,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.scopedReasonedExpiring,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveRoom,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.roundPublication,
    version: 1,
    family: EventAssistanceWorkflowFamily.live,
    applicability: EventAssistanceApplicability.rounds,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.controlReveal,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveNow,
      ],
      presentation: EventAssistanceHostPresentation.statusControl,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.unitProgress,
    version: 1,
    family: EventAssistanceWorkflowFamily.live,
    applicability: EventAssistanceApplicability.independentUnits,
    scope: EventAssistanceWorkflowScope.unit,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.controlUnitProgress,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveNow,
        EventAssistanceHostSurface.liveRoom,
      ],
      presentation: EventAssistanceHostPresentation.statusControl,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.outcomeRecording,
    version: 1,
    family: EventAssistanceWorkflowFamily.live,
    applicability: EventAssistanceApplicability.outcomes,
    scope: EventAssistanceWorkflowScope.unit,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.recordOutcome,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveNow,
      ],
      presentation: EventAssistanceHostPresentation.atomicAction,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.programmeRecovery,
    version: 1,
    family: EventAssistanceWorkflowFamily.live,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.changeProgramme,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveNow,
      ],
      presentation: EventAssistanceHostPresentation.statusControl,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.departure,
    version: 1,
    family: EventAssistanceWorkflowFamily.live,
    applicability: EventAssistanceApplicability.moving,
    scope: EventAssistanceWorkflowScope.group,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.confirmDeparture,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveNow,
        EventAssistanceHostSurface.liveGuests,
      ],
      presentation: EventAssistanceHostPresentation.atomicAction,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.checkpoint,
    version: 1,
    family: EventAssistanceWorkflowFamily.live,
    applicability: EventAssistanceApplicability.moving,
    scope: EventAssistanceWorkflowScope.group,
    automaticCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.requestCheckpointReport,
      EventAssistanceCommandKind.openHostCase,
    ],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.recordCheckpoint,
      EventAssistanceCommandKind.reassignCheckpointReporter,
      EventAssistanceCommandKind.setCheckpointCloseout,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveNow,
        EventAssistanceHostSurface.liveGuests,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.groupTransfer,
    version: 1,
    family: EventAssistanceWorkflowFamily.live,
    applicability: EventAssistanceApplicability.movingSubgroups,
    scope: EventAssistanceWorkflowScope.group,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.transferGroup,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveGuests,
        EventAssistanceHostSurface.liveRoom,
      ],
      presentation: EventAssistanceHostPresentation.atomicAction,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.routeRecovery,
    version: 1,
    family: EventAssistanceWorkflowFamily.live,
    applicability: EventAssistanceApplicability.moving,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.changeRoute,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveNow,
        EventAssistanceHostSurface.liveRoom,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.locationFreshness,
    version: 1,
    family: EventAssistanceWorkflowFamily.live,
    applicability: EventAssistanceApplicability.tracking,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.requestCheckpointReport,
    ],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.setLocationSharing,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveNow,
        EventAssistanceHostSurface.liveRoom,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.accountability,
    version: 1,
    family: EventAssistanceWorkflowFamily.live,
    applicability: EventAssistanceApplicability.accountability,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.openHostCase,
    ],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.resolveAccountability,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveNow,
        EventAssistanceHostSurface.liveGuests,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.planChangeCommunication,
    version: 1,
    family: EventAssistanceWorkflowFamily.communication,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.sendOperationalMessage,
    ],
    hostCommands: <EventAssistanceCommandKind>[],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveNow,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.deliveryRecovery,
    version: 1,
    family: EventAssistanceWorkflowFamily.communication,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.repairDelivery,
    ],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.repairDelivery,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveNow,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.replyOwnership,
    version: 1,
    family: EventAssistanceWorkflowFamily.communication,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.openHostCase,
    ],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.resolveAssistance,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveNow,
        EventAssistanceHostSurface.liveGuests,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.guestAssistance,
    version: 1,
    family: EventAssistanceWorkflowFamily.care,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.guest,
    automaticCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.openHostCase,
    ],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.resolveAssistance,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveNow,
        EventAssistanceHostSurface.liveGuests,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.comfortSafety,
    version: 1,
    family: EventAssistanceWorkflowFamily.care,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.guest,
    automaticCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.routeRestrictedCase,
    ],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.resolveRestrictedCase,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveNow,
        EventAssistanceHostSurface.liveGuests,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.attendanceSync,
    version: 1,
    family: EventAssistanceWorkflowFamily.recovery,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.reconcileAttendance,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveGuests,
        EventAssistanceHostSurface.liveNow,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.concurrencyRecovery,
    version: 1,
    family: EventAssistanceWorkflowFamily.recovery,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.resumeOperation,
    ],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.resumeOperation,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveNow,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.operationRecovery,
    version: 1,
    family: EventAssistanceWorkflowFamily.recovery,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.resumeOperation,
    ],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.resumeOperation,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveNow,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.contextBoundary,
    version: 1,
    family: EventAssistanceWorkflowFamily.recovery,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveNow,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.overrideReview,
    version: 1,
    family: EventAssistanceWorkflowFamily.recovery,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.applyOverride,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.scopedReasonedExpiring,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveNow,
      ],
      presentation: EventAssistanceHostPresentation.atomicAction,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.eventClosure,
    version: 1,
    family: EventAssistanceWorkflowFamily.closing,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.completeEvent,
      EventAssistanceCommandKind.applyOverride,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.scopedReasonedExpiring,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.liveNow,
        EventAssistanceHostSurface.eventReport,
      ],
      presentation: EventAssistanceHostPresentation.statusControl,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.attendanceReconciliation,
    version: 1,
    family: EventAssistanceWorkflowFamily.closing,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.reconcileAttendance,
      EventAssistanceCommandKind.recordNoShow,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.eventReport,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.financialReconciliation,
    version: 1,
    family: EventAssistanceWorkflowFamily.followUp,
    applicability: EventAssistanceApplicability.paid,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.reconcileFinance,
    ],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.reconcileFinance,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.today,
        EventAssistanceHostSurface.eventReport,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.postEventFollowUp,
    version: 1,
    family: EventAssistanceWorkflowFamily.followUp,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.sendOperationalMessage,
      EventAssistanceCommandKind.repairDelivery,
    ],
    hostCommands: <EventAssistanceCommandKind>[
      EventAssistanceCommandKind.repairDelivery,
    ],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.today,
        EventAssistanceHostSurface.eventReport,
      ],
      presentation: EventAssistanceHostPresentation.exceptionQueue,
    ),
  ),
  EventAssistanceWorkflowDescriptor(
    kind: EventAssistanceWorkflowKind.eventLearning,
    version: 1,
    family: EventAssistanceWorkflowFamily.followUp,
    applicability: EventAssistanceApplicability.all,
    scope: EventAssistanceWorkflowScope.any,
    automaticCommands: <EventAssistanceCommandKind>[],
    hostCommands: <EventAssistanceCommandKind>[],
    guestCommands: <EventAssistanceCommandKind>[],
    overridePolicy: EventAssistanceOverridePolicy.none,
    hostProjection: EventAssistanceHostProjection(
      surfaces: <EventAssistanceHostSurface>[
        EventAssistanceHostSurface.eventReport,
      ],
      presentation: EventAssistanceHostPresentation.reportInsight,
    ),
  ),
];

extension EventAssistanceWorkflowCatalogLookup on EventAssistanceWorkflowKind {
  EventAssistanceWorkflowDescriptor get descriptor =>
      eventAssistanceWorkflowCatalog[index];
}
