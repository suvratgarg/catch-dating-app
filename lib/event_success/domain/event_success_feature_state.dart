import 'package:catch_dating_app/event_success/domain/event_success_coach.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';

enum EventSuccessSetupStatus {
  needsWork('Needs work'),
  readyForPilot('Ready for pilot');

  const EventSuccessSetupStatus(this.label);

  final String label;
}

class EventSuccessHostDraft {
  const EventSuccessHostDraft({
    required this.playbook,
    required this.selectedModuleIds,
    required this.targetAttendeeCount,
    this.hostGoal = 'Help attendees meet at least two new people.',
    this.privateCrushEnabled = true,
    this.contextualOpenersEnabled = true,
  }) : assert(targetAttendeeCount > 0);

  factory EventSuccessHostDraft.fromPlaybook(
    EventSuccessPlaybook playbook, {
    int? targetAttendeeCount,
  }) {
    return EventSuccessHostDraft(
      playbook: playbook,
      selectedModuleIds: playbook.modules
          .where((module) => module.enabledByDefault)
          .map((module) => module.id)
          .toSet(),
      targetAttendeeCount:
          targetAttendeeCount ??
          ((playbook.capacity.min + playbook.capacity.max) / 2).round(),
    );
  }

  final EventSuccessPlaybook playbook;
  final Set<String> selectedModuleIds;
  final int targetAttendeeCount;
  final String hostGoal;
  final bool privateCrushEnabled;
  final bool contextualOpenersEnabled;

  List<EventSuccessModule> get selectedModules => playbook.modules
      .where((module) => selectedModuleIds.contains(module.id))
      .toList(growable: false);

  List<EventSuccessModule> get livePhoneModules => selectedModules
      .where((module) => module.requiresLivePhoneUse)
      .toList(growable: false);

  EventSuccessSetupStatus get status => readinessIssues.isEmpty
      ? EventSuccessSetupStatus.readyForPilot
      : EventSuccessSetupStatus.needsWork;

  bool isModuleSelected(String moduleId) =>
      selectedModuleIds.contains(moduleId);

  EventSuccessHostDraft toggleModule(String moduleId) {
    final nextIds = {...selectedModuleIds};
    if (!nextIds.remove(moduleId)) nextIds.add(moduleId);
    return copyWith(selectedModuleIds: nextIds);
  }

  EventSuccessHostDraft copyWith({
    EventSuccessPlaybook? playbook,
    Set<String>? selectedModuleIds,
    int? targetAttendeeCount,
    String? hostGoal,
    bool? privateCrushEnabled,
    bool? contextualOpenersEnabled,
  }) {
    final resolvedPlaybook = playbook ?? this.playbook;
    final resolvedIds = selectedModuleIds ?? this.selectedModuleIds;
    return EventSuccessHostDraft(
      playbook: resolvedPlaybook,
      selectedModuleIds: resolvedIds
          .where(resolvedPlaybook.moduleIds.contains)
          .toSet(),
      targetAttendeeCount: targetAttendeeCount ?? this.targetAttendeeCount,
      hostGoal: hostGoal ?? this.hostGoal,
      privateCrushEnabled: privateCrushEnabled ?? this.privateCrushEnabled,
      contextualOpenersEnabled:
          contextualOpenersEnabled ?? this.contextualOpenersEnabled,
    );
  }

  List<String> get readinessIssues {
    final issues = <String>[];
    if (!playbook.capacity.contains(targetAttendeeCount)) {
      issues.add(
        'Target attendance should stay within ${playbook.capacity.min}-${playbook.capacity.max} for this format.',
      );
    }
    if (!selectedModuleIds.contains(EventSuccessModuleCatalog.checkIn.id)) {
      issues.add('Add check-in before using attendance for follow-up.');
    }
    if (!selectedModuleIds.contains(
      EventSuccessModuleCatalog.safetyControls.id,
    )) {
      issues.add('Add safety controls before any live pilot.');
    }
    if (privateCrushEnabled &&
        !selectedModuleIds.contains(
          EventSuccessModuleCatalog.privateCrush.id,
        )) {
      issues.add('Private crush is enabled, but the module is not selected.');
    }
    if (contextualOpenersEnabled &&
        !selectedModuleIds.contains(
          EventSuccessModuleCatalog.contextualOpeners.id,
        )) {
      issues.add(
        'Contextual openers are enabled, but the module is not selected.',
      );
    }
    return issues;
  }
}

class EventSuccessLivePlan {
  const EventSuccessLivePlan({
    required this.playbook,
    required this.steps,
    required this.activeStepIndex,
    required this.checkedInCount,
    required this.bookedCount,
  }) : assert(activeStepIndex >= 0),
       assert(checkedInCount >= 0),
       assert(bookedCount >= 0);

  factory EventSuccessLivePlan.fromDraft(
    EventSuccessHostDraft draft, {
    int activeStepIndex = 1,
    int checkedInCount = 18,
    int bookedCount = 24,
  }) {
    return EventSuccessLivePlan(
      playbook: draft.playbook,
      steps: draft.playbook.runOfShow,
      activeStepIndex: activeStepIndex.clamp(
        0,
        draft.playbook.runOfShow.length - 1,
      ),
      checkedInCount: checkedInCount,
      bookedCount: bookedCount,
    );
  }

  final EventSuccessPlaybook playbook;
  final List<EventRunOfShowStep> steps;
  final int activeStepIndex;
  final int checkedInCount;
  final int bookedCount;

  EventRunOfShowStep get activeStep => steps[activeStepIndex];

  double get checkInProgress {
    if (bookedCount == 0) return 0;
    return (checkedInCount / bookedCount).clamp(0, 1);
  }

  double get runOfShowProgress {
    if (steps.isEmpty) return 0;
    return ((activeStepIndex + 1) / steps.length).clamp(0, 1);
  }
}

class EventSuccessAttendeeState {
  const EventSuccessAttendeeState({
    required this.eventTitle,
    required this.attendeeName,
    required this.podLabel,
    required this.prompt,
    required this.privateCrushCandidates,
    this.checkedIn = true,
    this.followUpOpen = true,
  });

  final String eventTitle;
  final String attendeeName;
  final String podLabel;
  final String prompt;
  final List<PrivateCrushCandidate> privateCrushCandidates;
  final bool checkedIn;
  final bool followUpOpen;
}

class PrivateCrushCandidate {
  const PrivateCrushCandidate({
    required this.displayName,
    required this.context,
    this.marked = false,
  });

  final String displayName;
  final String context;
  final bool marked;
}

abstract final class EventSuccessFeatureSamples {
  static final hostDraft = EventSuccessHostDraft.fromPlaybook(
    EventSuccessPlaybookLibrary.socialRun,
    targetAttendeeCount: 28,
  );

  static final livePlan = EventSuccessLivePlan.fromDraft(
    hostDraft,
    activeStepIndex: 2,
    checkedInCount: 22,
    bookedCount: 28,
  );

  static const attendeeState = EventSuccessAttendeeState(
    eventTitle: 'Saturday Social 5K',
    attendeeName: 'Aarav',
    podLabel: 'Pace pod B · 6:15-6:45/km',
    prompt:
        'Find someone training for a race and ask what they are building toward.',
    privateCrushCandidates: [
      PrivateCrushCandidate(
        displayName: 'Naina',
        context: 'Ran in your pace pod',
        marked: true,
      ),
      PrivateCrushCandidate(
        displayName: 'Rhea',
        context: 'Met during cooldown coffee',
      ),
      PrivateCrushCandidate(
        displayName: 'Meera',
        context: 'Answered the same race prompt',
      ),
    ],
  );

  static final postEventBrief = const EventSuccessCoach().analyze(
    playbook: EventSuccessPlaybookLibrary.socialRun,
    scorecard: EventSuccessSampleScorecards.needsStructure,
  );
}
