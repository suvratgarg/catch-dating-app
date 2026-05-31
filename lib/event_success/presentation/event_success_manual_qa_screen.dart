import 'dart:async';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_activity_profile.dart';
import 'package:catch_dating_app/event_success/domain/event_success_arrival_mission.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_coach.dart';
import 'package:catch_dating_app/event_success/domain/event_success_compatibility_response.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_preference.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';
import 'package:catch_dating_app/event_success/domain/event_success_wingman_request.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_companion_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_host_screen.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/events/domain/event_private_access.dart';
import 'package:catch_dating_app/events/presentation/attendance_sheet_view_model.dart';
import 'package:catch_dating_app/events/presentation/widgets/who_is_going.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dev/staging-only manual QA harness for the live event-success loop.
///
/// This renders the production host panel and attendee companion against one
/// synthetic scenario so host-side state changes can be inspected beside the
/// attendee experience. All fixture writes flow through an in-memory store so
/// host and attendee surfaces stay synchronized without backend persistence.
class EventSuccessManualQaScreen extends StatefulWidget {
  const EventSuccessManualQaScreen({super.key});

  @override
  State<EventSuccessManualQaScreen> createState() =>
      _EventSuccessManualQaScreenState();
}

class _EventSuccessManualQaScreenState
    extends State<EventSuccessManualQaScreen> {
  _ManualQaStore? _store;

  @override
  void initState() {
    super.initState();
    _store = _ManualQaStore(onChanged: _handleStoreChanged);
  }

  @override
  void dispose() {
    _store?.dispose();
    super.dispose();
  }

  void _handleStoreChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final store = _store ??= _ManualQaStore(onChanged: _handleStoreChanged);
    final data = store.fixtures;
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        title: Text(
          'Event success manual QA',
          style: CatchTextStyles.sectionTitle(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(CatchSpacing.s5),
          children: [
            _ManualQaHero(data: data),
            gapH16,
            _ManualQaControls(
              scenario: store.scenario,
              onScenarioChanged: store.setScenario,
            ),
            gapH16,
            _ManualQaSideBySide(
              hostTab: store.hostTab,
              data: data,
              firstHelloEnabled: store.firstHelloEnabled,
              firstHelloSkipped: store.firstHelloSkipped,
              firstHelloCompleted: store.firstHelloCompleted,
              microPodsOptedOut: store.microPodsOptedOut,
              guidedRotationsOptedOut: store.guidedRotationsOptedOut,
              fixtureActions: store.fixtureActions(_showFixtureAction),
              onHostSectionChanged: store.setHostSection,
              onCompatibilityAnswersSaved: store.saveCompatibilityAnswers,
              onFirstHelloCompleted: store.completeFirstHelloMission,
              onFirstHelloSkipped: store.skipFirstHelloMission,
              onMicroPodsOptOutChanged: store.setMicroPodsOptedOut,
              onGuidedRotationsOptOutChanged: store.setGuidedRotationsOptedOut,
              onToggleAttendance: store.toggleAttendance,
            ),
          ],
        ),
      ),
    );
  }

  void _showFixtureAction(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: CatchTextStyles.supporting(context)),
      ),
    );
  }
}

class _ManualQaStore {
  _ManualQaStore({required this.onChanged});

  final VoidCallback onChanged;

  _ManualQaScenario scenario = _ManualQaScenario.racketPairs;
  EventSuccessHostTab hostTab = EventSuccessHostTab.setup;
  int activeStepIndex = 0;
  EventSuccessRevealStatus revealStatus = EventSuccessRevealStatus.idle;
  int activeRevealRoundIndex = 0;
  bool firstHelloEnabled = false;
  bool firstHelloSkipped = false;
  bool firstHelloCompleted = false;
  bool compatibilityEnabled = true;
  bool compatibilityAffectsRanking = true;
  EventSuccessQuestionnaireConfig questionnaireConfig =
      const EventSuccessQuestionnaireConfig.defaultTemplate();
  bool microPodsOptedOut = false;
  bool guidedRotationsOptedOut = false;
  List<String>? savedCompatibilityAnswerIds;
  Set<String>? checkedInOverride;
  Duration _countdownElapsed = Duration.zero;
  Timer? _countdownTimer;

  _ManualQaFixtures get fixtures => _ManualQaFixtures(
    scenario: scenario,
    moment: _momentForHostState(),
    activeStepIndex: activeStepIndex,
    revealStatus: revealStatus,
    activeRevealRoundIndex: activeRevealRoundIndex,
    firstHelloEnabled: firstHelloEnabled,
    firstHelloSkipped: firstHelloSkipped,
    firstHelloCompleted: firstHelloCompleted,
    compatibilityEnabled: compatibilityEnabled,
    compatibilityAffectsRanking: compatibilityAffectsRanking,
    questionnaireConfig: questionnaireConfig,
    microPodsOptedOut: microPodsOptedOut,
    guidedRotationsOptedOut: guidedRotationsOptedOut,
    savedCompatibilityAnswerIds: savedCompatibilityAnswerIds,
    checkedInOverride: checkedInOverride,
    countdownElapsed: _effectiveCountdownElapsed,
  );

  void dispose() {
    _countdownTimer?.cancel();
  }

  void setScenario(_ManualQaScenario value) {
    if (scenario == value) return;
    scenario = value;
    activeStepIndex = _defaultActiveStepIndex(
      scenario: value,
      hostTab: hostTab,
    );
    _resetRevealState();
    firstHelloSkipped = false;
    firstHelloCompleted = false;
    guidedRotationsOptedOut = false;
    microPodsOptedOut = false;
    savedCompatibilityAnswerIds = null;
    checkedInOverride = null;
    _syncCountdownTimer();
    _notify();
  }

  void setHostTab(EventSuccessHostTab tab) {
    hostTab = tab;
    activeStepIndex = _defaultActiveStepIndex(scenario: scenario, hostTab: tab);
    if (tab != EventSuccessHostTab.live ||
        !_activeStepHasLiveReveal(activeStepIndex)) {
      _resetRevealState();
    }
    _syncCountdownTimer();
    _notify();
  }

  void setHostSection(HostEventManageSection section) {
    setHostTab(section.eventSuccessTab);
  }

  void setCompatibilityEnabled(bool value) {
    if (compatibilityEnabled == value) return;
    compatibilityEnabled = value;
    if (!value) {
      compatibilityAffectsRanking = false;
      savedCompatibilityAnswerIds = null;
    }
    _notify();
  }

  void setFirstHelloEnabled(bool value) {
    if (firstHelloEnabled == value) return;
    firstHelloEnabled = value;
    firstHelloSkipped = false;
    firstHelloCompleted = false;
    _notify();
  }

  void setCompatibilityAffectsRanking(bool value) {
    if (!compatibilityEnabled || compatibilityAffectsRanking == value) return;
    compatibilityAffectsRanking = value;
    _notify();
  }

  void setQuestionnaireConfig(EventSuccessQuestionnaireConfig value) {
    if (questionnaireConfig == value) return;
    questionnaireConfig = value;
    savedCompatibilityAnswerIds = null;
    _notify();
  }

  Future<void> saveCompatibilityAnswers(List<String> answerIds) async {
    savedCompatibilityAnswerIds = List.of(answerIds);
    _notify();
  }

  Future<void> completeFirstHelloMission(
    EventSuccessArrivalMission mission,
    String answerId,
  ) async {
    firstHelloCompleted = true;
    firstHelloSkipped = false;
    hostTab = EventSuccessHostTab.live;
    activeStepIndex = _defaultActiveStepIndex(
      scenario: scenario,
      hostTab: hostTab,
    );
    _notify();
  }

  void skipFirstHelloMission() {
    firstHelloSkipped = true;
    firstHelloCompleted = false;
    _notify();
  }

  void setMicroPodsOptedOut(bool value) {
    if (microPodsOptedOut == value) return;
    microPodsOptedOut = value;
    _notify();
  }

  void setGuidedRotationsOptedOut(bool value) {
    if (guidedRotationsOptedOut == value) return;
    guidedRotationsOptedOut = value;
    _notify();
  }

  bool toggleAttendance(String uid) {
    hostTab = EventSuccessHostTab.live;
    final checkedInIds =
        checkedInOverride ?? _ManualQaFixtures.defaultCheckedInIds.toSet();
    final next = checkedInIds.toSet();
    final isAttended = !next.remove(uid);
    if (isAttended) next.add(uid);
    checkedInOverride = next;
    _notify();
    return isAttended;
  }

  EventSuccessHostFixtureActions fixtureActions(
    ValueChanged<String> showMessage,
  ) {
    return EventSuccessHostFixtureActions(
      onSaveSetup: () => showMessage(
        'Fixture setup saved. Use a real dev event to verify persistence.',
      ),
      onPreviousStep: () => _moveHostStep(-1),
      onNextStep: () => _moveHostStep(1),
      onCompletePlan: () => showMessage(
        'Fixture plan marked complete. Use Post-event to inspect the report.',
      ),
      onGenerateMicroPods: () => showMessage(
        'Fixture micro-pods regenerated. Toggle opt-outs to inspect stale-card behavior.',
      ),
      onGenerateGuidedRotations: () => showMessage(
        'Fixture rotations regenerated. Change event format or ranking signal to inspect variants.',
      ),
      onOverrideGuidedRotations: (_) => showMessage(
        'Fixture rotation edits accepted. Use a real dev event to verify the callable write path.',
      ),
      onStartRevealCountdown: _startRevealCountdown,
      onRevealRound: _revealRound,
      onResetReveal: _resetReveal,
    );
  }

  void _moveHostStep(int delta) {
    hostTab = EventSuccessHostTab.live;
    activeStepIndex = _clampActiveStepIndex(activeStepIndex + delta);
    if (!_activeStepHasLiveReveal(activeStepIndex)) _resetRevealState();
    _syncCountdownTimer();
    _notify();
  }

  void _startRevealCountdown(int roundIndex, int _) {
    hostTab = EventSuccessHostTab.live;
    activeStepIndex = _firstRevealStepIndex(scenario);
    revealStatus = EventSuccessRevealStatus.countingDown;
    activeRevealRoundIndex = roundIndex;
    _countdownElapsed = Duration.zero;
    _syncCountdownTimer();
    _notify();
  }

  void _revealRound(int roundIndex) {
    hostTab = EventSuccessHostTab.live;
    activeStepIndex = _firstRevealStepIndex(scenario);
    revealStatus = EventSuccessRevealStatus.revealed;
    activeRevealRoundIndex = roundIndex;
    _syncCountdownTimer();
    _notify();
  }

  void _resetReveal() {
    _resetRevealState();
    _syncCountdownTimer();
    _notify();
  }

  void _resetRevealState() {
    revealStatus = EventSuccessRevealStatus.idle;
    activeRevealRoundIndex = 0;
    _countdownElapsed = Duration.zero;
  }

  Duration get _effectiveCountdownElapsed =>
      revealStatus == EventSuccessRevealStatus.countingDown
      ? _countdownElapsed
      : Duration.zero;

  void _syncCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    if (revealStatus != EventSuccessRevealStatus.countingDown) return;
    const tick = Duration(milliseconds: 250);
    _countdownTimer = Timer.periodic(tick, (_) {
      _countdownElapsed += tick;
      _notify();
    });
  }

  _ManualQaMoment _momentForHostState() {
    if (firstHelloEnabled && firstHelloCompleted) {
      return _ManualQaMoment.checkedIn;
    }
    if (firstHelloEnabled &&
        !firstHelloSkipped &&
        hostTab == EventSuccessHostTab.setup) {
      return _ManualQaMoment.firstHello;
    }
    return switch (hostTab) {
      EventSuccessHostTab.setup => _ManualQaMoment.booked,
      EventSuccessHostTab.report => _ManualQaMoment.postEvent,
      EventSuccessHostTab.live => switch (revealStatus) {
        EventSuccessRevealStatus.countingDown => _ManualQaMoment.countdown,
        EventSuccessRevealStatus.revealed => _ManualQaMoment.revealed,
        EventSuccessRevealStatus.idle => _ManualQaMoment.checkedIn,
      },
    };
  }

  static int _defaultActiveStepIndex({
    required _ManualQaScenario scenario,
    required EventSuccessHostTab hostTab,
  }) {
    return switch (hostTab) {
      EventSuccessHostTab.setup || EventSuccessHostTab.live => 0,
      EventSuccessHostTab.report => scenario.playbook.runOfShow.length - 1,
    };
  }

  static int _firstRevealStepIndex(_ManualQaScenario scenario) {
    final index = scenario.playbook.runOfShow.indexWhere(
      (step) =>
          step.moduleIds.contains(EventSuccessModuleCatalog.liveReveal.id),
    );
    return index < 0 ? 0 : index;
  }

  int _clampActiveStepIndex(int index) {
    final lastIndex = scenario.playbook.runOfShow.length - 1;
    return index.clamp(0, lastIndex).toInt();
  }

  bool _activeStepHasLiveReveal(int index) {
    final steps = scenario.playbook.runOfShow;
    if (steps.isEmpty) return false;
    final clamped = index.clamp(0, steps.length - 1).toInt();
    return steps[clamped].moduleIds.contains(
      EventSuccessModuleCatalog.liveReveal.id,
    );
  }

  void _notify() => onChanged();
}

class _ManualQaHero extends StatelessWidget {
  const _ManualQaHero({required this.data});

  final _ManualQaFixtures data;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [t.accent, t.ink],
      ),
      borderColor: t.surface.withValues(alpha: CatchOpacity.none),
      padding: const EdgeInsets.all(CatchSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchBadge(
                label: 'Manual QA',
                tone: CatchBadgeTone.live,
                icon: CatchIcons.factCheckOutlined,
              ),
              CatchBadge(
                label: 'Fixture data',
                tone: CatchBadgeTone.solid,
                icon: CatchIcons.dataObjectRounded,
              ),
            ],
          ),
          gapH20,
          Text(
            data.event.title,
            style: CatchTextStyles.headline(context, color: t.accentInk),
          ),
          gapH8,
          Text(
            '${data.playbook.title} · ${data.plan.structureConfig.unitKind.label} · ${data.moment.label}',
            style: CatchTextStyles.bodyL(
              context,
              color: t.accentInk.withValues(
                alpha: CatchOpacity.manualQaHeroMeta,
              ),
            ),
          ),
          gapH20,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              _DarkPill(label: '${data.roster.bookedCount} booked'),
              _DarkPill(label: '${data.roster.checkedInCount} checked in'),
              _DarkPill(
                label:
                    '${data.plan.structureConfig.revealCountdownSeconds}s reveal',
              ),
              _DarkPill(
                label:
                    !data.plan.hasModule(
                      EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
                    )
                    ? 'Questionnaire off'
                    : data.plan.compatibilityAffectsRanking
                    ? '${data.plan.questionnaireConfig.pack.title} · ranking'
                    : '${data.plan.questionnaireConfig.pack.title} · clues',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ManualQaControls extends StatelessWidget {
  const _ManualQaControls({
    required this.scenario,
    required this.onScenarioChanged,
  });

  final _ManualQaScenario scenario;
  final ValueChanged<_ManualQaScenario> onScenarioChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fixture scenario',
            style: CatchTextStyles.sectionTitle(context),
          ),
          gapH12,
          _ControlLabel('Event format'),
          gapH8,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final value in _ManualQaScenario.values)
                CatchChip(
                  label: value.label,
                  active: scenario == value,
                  icon: Icon(value.icon),
                  onTap: () => onScenarioChanged(value),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ManualQaSideBySide extends StatelessWidget {
  const _ManualQaSideBySide({
    required this.hostTab,
    required this.data,
    required this.firstHelloEnabled,
    required this.firstHelloSkipped,
    required this.firstHelloCompleted,
    required this.microPodsOptedOut,
    required this.guidedRotationsOptedOut,
    required this.fixtureActions,
    required this.onHostSectionChanged,
    required this.onCompatibilityAnswersSaved,
    required this.onFirstHelloCompleted,
    required this.onFirstHelloSkipped,
    required this.onMicroPodsOptOutChanged,
    required this.onGuidedRotationsOptOutChanged,
    required this.onToggleAttendance,
  });

  final EventSuccessHostTab hostTab;
  final _ManualQaFixtures data;
  final bool firstHelloEnabled;
  final bool firstHelloSkipped;
  final bool firstHelloCompleted;
  final bool microPodsOptedOut;
  final bool guidedRotationsOptedOut;
  final EventSuccessHostFixtureActions fixtureActions;
  final ValueChanged<HostEventManageSection> onHostSectionChanged;
  final Future<void> Function(List<String> answerIds)
  onCompatibilityAnswersSaved;
  final Future<void> Function(
    EventSuccessArrivalMission mission,
    String answerId,
  )
  onFirstHelloCompleted;
  final VoidCallback onFirstHelloSkipped;
  final ValueChanged<bool> onMicroPodsOptOutChanged;
  final ValueChanged<bool> onGuidedRotationsOptOutChanged;
  final bool Function(String uid) onToggleAttendance;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const minimumPaneWidth = 560.0;
        final availablePaneWidth = (constraints.maxWidth - CatchSpacing.s4) / 2;
        final paneWidth = availablePaneWidth >= minimumPaneWidth
            ? availablePaneWidth
            : minimumPaneWidth;
        final totalWidth = (paneWidth * 2) + CatchSpacing.s4;

        final content = SizedBox(
          width: totalWidth,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: paneWidth,
                child: _QaDeviceFrame(
                  title: 'Host Manage',
                  subtitle:
                      'Production host workspace · ${data.activeStepLabel}',
                  badges: [
                    data.hostTabBadge(hostTab),
                    data.activeStepProgress,
                    '${data.roster.bookedCount} booked',
                    '${data.roster.checkedInCount} checked in',
                    '${data.assignments.length} pod cards',
                    '${data.rotationAssignments.length} rotation cards',
                  ],
                  child: _ManualQaHostManagePane(
                    data: data,
                    selectedTab: hostTab,
                    fixtureActions: fixtureActions,
                    onSectionChanged: onHostSectionChanged,
                    onToggleAttendance: onToggleAttendance,
                  ),
                ),
              ),
              gapW16,
              SizedBox(
                width: paneWidth,
                child: _QaDeviceFrame(
                  title: 'Attendee experience',
                  subtitle:
                      '${data.viewer.publicDisplayName} · ${data.participation.status.name} · ${data.activeStepLabel}',
                  badges: [
                    data.moment.label,
                    data.activeStepProgress,
                    data.plan.revealStatus.name,
                    if (microPodsOptedOut) 'pods opted out',
                    if (guidedRotationsOptedOut) 'rotations opted out',
                  ],
                  controls: _AttendeeQaControls(
                    microPodsOptedOut: microPodsOptedOut,
                    guidedRotationsOptedOut: guidedRotationsOptedOut,
                    firstHelloEnabled: firstHelloEnabled,
                    firstHelloSkipped: firstHelloSkipped,
                    firstHelloCompleted: firstHelloCompleted,
                    onMicroPodsOptOutChanged: onMicroPodsOptOutChanged,
                    onGuidedRotationsOptOutChanged:
                        onGuidedRotationsOptOutChanged,
                  ),
                  child: EventSuccessCompanionScreen(
                    event: data.event,
                    plan: data.plan,
                    userProfile: data.viewer,
                    participation: data.participation,
                    wingmanRequestCandidates: data.profiles,
                    wingmanRequest: data.viewerWingmanRequest,
                    compatibilityResponse: data.compatibilityResponse,
                    existingFeedback: data.viewerFeedback,
                    assignment: data.viewerAssignment,
                    assignmentPeerProfiles: data.assignmentPeerProfiles,
                    microPodsOptedOut: microPodsOptedOut,
                    rotationAssignment: data.viewerRotationAssignment,
                    rotationPeerProfiles: data.rotationPeerProfiles,
                    guidedRotationsOptedOut: guidedRotationsOptedOut,
                    arrivalMission: data.viewerArrivalMission,
                    now: data.now,
                    onSaveCompatibilityAnswers: onCompatibilityAnswersSaved,
                    onCompleteArrivalMission: onFirstHelloCompleted,
                    onSkipArrivalMission: onFirstHelloSkipped,
                  ),
                ),
              ),
            ],
          ),
        );

        if (totalWidth <= constraints.maxWidth) {
          return content;
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: content,
        );
      },
    );
  }
}

class _QaDeviceFrame extends StatelessWidget {
  const _QaDeviceFrame({
    required this.title,
    required this.subtitle,
    required this.badges,
    required this.child,
    this.controls,
  });

  final String title;
  final String subtitle;
  final List<String> badges;
  final Widget child;
  final Widget? controls;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(CatchSpacing.s2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: CatchTextStyles.sectionTitle(context)),
                gapH4,
                Text(
                  subtitle,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
                gapH10,
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  children: [
                    for (final badge in badges)
                      CatchBadge(label: badge, tone: CatchBadgeTone.neutral),
                  ],
                ),
              ],
            ),
          ),
          if (controls != null) ...[
            gapH8,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s2),
              child: controls!,
            ),
          ],
          gapH8,
          ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.lg),
            child: CatchSurface(
              radius: CatchRadius.lg,
              borderColor: t.line,
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: CatchLayout.manualQaEditorHeight,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualQaHostManagePane extends StatelessWidget {
  const _ManualQaHostManagePane({
    required this.data,
    required this.selectedTab,
    required this.fixtureActions,
    required this.onSectionChanged,
    required this.onToggleAttendance,
  });

  final _ManualQaFixtures data;
  final EventSuccessHostTab selectedTab;
  final EventSuccessHostFixtureActions fixtureActions;
  final ValueChanged<HostEventManageSection> onSectionChanged;
  final bool Function(String uid) onToggleAttendance;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      key: ValueKey(data.hostManageScopeKey),
      overrides: data.hostManageProviderOverrides(
        onToggleAttendance: onToggleAttendance,
      ),
      child: HostEventManageScreen(
        club: data.club,
        event: data.event,
        onBackToSuccess: () {},
        initialSection: selectedTab.hostManageSection,
        onSectionChanged: onSectionChanged,
        eventSuccessFixtureActions: fixtureActions,
      ),
    );
  }
}

class _AttendeeQaControls extends StatelessWidget {
  const _AttendeeQaControls({
    required this.microPodsOptedOut,
    required this.guidedRotationsOptedOut,
    required this.firstHelloEnabled,
    required this.firstHelloSkipped,
    required this.firstHelloCompleted,
    required this.onMicroPodsOptOutChanged,
    required this.onGuidedRotationsOptOutChanged,
  });

  final bool microPodsOptedOut;
  final bool guidedRotationsOptedOut;
  final bool firstHelloEnabled;
  final bool firstHelloSkipped;
  final bool firstHelloCompleted;
  final ValueChanged<bool> onMicroPodsOptOutChanged;
  final ValueChanged<bool> onGuidedRotationsOptOutChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ControlLabel('Attendee choices'),
        gapH8,
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            CatchChip(
              label: 'Micro-pods opt-out',
              active: microPodsOptedOut,
              icon: Icon(CatchIcons.visibilityOffOutlined),
              onTap: () => onMicroPodsOptOutChanged(!microPodsOptedOut),
            ),
            CatchChip(
              label: 'Rotations opt-out',
              active: guidedRotationsOptedOut,
              icon: Icon(CatchIcons.blockOutlined),
              onTap: () =>
                  onGuidedRotationsOptOutChanged(!guidedRotationsOptedOut),
            ),
            if (firstHelloEnabled)
              CatchBadge(
                label: firstHelloCompleted
                    ? 'first hello complete'
                    : firstHelloSkipped
                    ? 'first hello skipped'
                    : 'first hello pending',
                tone: firstHelloCompleted
                    ? CatchBadgeTone.success
                    : CatchBadgeTone.live,
                icon: CatchIcons.wavingHandOutlined,
              ),
          ],
        ),
      ],
    );
  }
}

class _ControlLabel extends StatelessWidget {
  const _ControlLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: CatchTextStyles.labelL(context));
  }
}

class _DarkPill extends StatelessWidget {
  const _DarkPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      backgroundColor: t.accentInk.withValues(
        alpha: CatchOpacity.manualQaPillFill,
      ),
      borderColor: t.accentInk.withValues(
        alpha: CatchOpacity.manualQaPillBorder,
      ),
      radius: CatchRadius.pill,
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s3,
        vertical: CatchSpacing.s2,
      ),
      child: Text(
        label,
        style: CatchTextStyles.labelL(context, color: t.accentInk),
      ),
    );
  }
}

enum _ManualQaScenario {
  socialRun,
  racketPairs,
  quizTeams,
  singlesMixer;

  String get label => switch (this) {
    _ManualQaScenario.socialRun => 'Social run',
    _ManualQaScenario.racketPairs => 'Racket pairs',
    _ManualQaScenario.quizTeams => 'Quiz teams',
    _ManualQaScenario.singlesMixer => 'Singles mixer',
  };

  IconData get icon => switch (this) {
    _ManualQaScenario.socialRun => CatchIcons.directionsRunRounded,
    _ManualQaScenario.racketPairs => CatchIcons.sportsTennisRounded,
    _ManualQaScenario.quizTeams => CatchIcons.quizOutlined,
    _ManualQaScenario.singlesMixer => CatchIcons.favoriteBorderRounded,
  };

  ActivityKind get activityKind => switch (this) {
    _ManualQaScenario.socialRun => ActivityKind.socialRun,
    _ManualQaScenario.racketPairs => ActivityKind.pickleball,
    _ManualQaScenario.quizTeams => ActivityKind.pubQuiz,
    _ManualQaScenario.singlesMixer => ActivityKind.singlesMixer,
  };

  EventSuccessPlaybook get playbook => switch (this) {
    _ManualQaScenario.socialRun => EventSuccessPlaybookLibrary.socialRun,
    _ManualQaScenario.racketPairs => EventSuccessPlaybookLibrary.pickleball,
    _ManualQaScenario.quizTeams => EventSuccessPlaybookLibrary.pubQuiz,
    _ManualQaScenario.singlesMixer =>
      EventSuccessPlaybookLibrary.algorithmicMixer,
  };

  int get targetCount => switch (this) {
    _ManualQaScenario.socialRun => 22,
    _ManualQaScenario.racketPairs => 12,
    _ManualQaScenario.quizTeams => 18,
    _ManualQaScenario.singlesMixer => 32,
  };

  EventSuccessStructureConfig get structureConfig => switch (this) {
    _ManualQaScenario.socialRun => const EventSuccessStructureConfig(
      unitKind: EventSuccessUnitKind.wholeGroup,
      unitSize: 22,
      unitCount: 1,
      revealCountdownSeconds: 10,
    ),
    _ManualQaScenario.racketPairs => const EventSuccessStructureConfig(
      unitKind: EventSuccessUnitKind.pairs,
      unitSize: 2,
      rotationIntervalMinutes: 15,
      revealCountdownSeconds: 15,
    ),
    _ManualQaScenario.quizTeams => const EventSuccessStructureConfig(
      unitKind: EventSuccessUnitKind.teams,
      unitSize: 5,
      unitCount: 3,
      rotationIntervalMinutes: 20,
      revealCountdownSeconds: 10,
    ),
    _ManualQaScenario.singlesMixer => const EventSuccessStructureConfig(
      unitKind: EventSuccessUnitKind.pairs,
      unitSize: 2,
      rotationIntervalMinutes: 12,
      revealCountdownSeconds: 10,
    ),
  };

  String get meetingPoint => switch (this) {
    _ManualQaScenario.socialRun => 'Race Course Road main gate',
    _ManualQaScenario.racketPairs => 'Court 2 by the clubhouse',
    _ManualQaScenario.quizTeams => 'Upstairs quiz room',
    _ManualQaScenario.singlesMixer => 'Main lounge check-in desk',
  };
}

enum _ManualQaMoment {
  booked,
  firstHello,
  checkedIn,
  countdown,
  revealed,
  postEvent;

  String get label => switch (this) {
    _ManualQaMoment.booked => 'Booked',
    _ManualQaMoment.firstHello => 'First hello',
    _ManualQaMoment.checkedIn => 'Checked in',
    _ManualQaMoment.countdown => 'Countdown',
    _ManualQaMoment.revealed => 'Revealed',
    _ManualQaMoment.postEvent => 'Post-event',
  };
}

class _ManualQaFixtures {
  _ManualQaFixtures({
    required this.scenario,
    required this.moment,
    required this.activeStepIndex,
    required this.revealStatus,
    required this.activeRevealRoundIndex,
    required this.firstHelloEnabled,
    required this.firstHelloSkipped,
    required this.firstHelloCompleted,
    required this.compatibilityEnabled,
    required this.compatibilityAffectsRanking,
    required this.questionnaireConfig,
    required this.microPodsOptedOut,
    required this.guidedRotationsOptedOut,
    required this.savedCompatibilityAnswerIds,
    required this.checkedInOverride,
    required this.countdownElapsed,
  }) {
    playbook = scenario.playbook;
    event = _eventForScenario();
    club = _clubForScenario();
    final draft =
        EventSuccessHostDraft.fromPlaybook(
          playbook,
          targetAttendeeCount: scenario.targetCount,
        ).copyWith(
          selectedModuleIds: _selectedModuleIds(
            playbook,
            compatibilityEnabled: compatibilityEnabled,
            firstHelloEnabled: firstHelloEnabled,
          ),
          structureConfig: scenario.structureConfig,
          compatibilityAffectsRanking:
              compatibilityEnabled && compatibilityAffectsRanking,
          questionnaireConfig: questionnaireConfig,
          hostGoal:
              'Create clear introductions and one memorable reveal moment.',
        );
    final normalizedActiveStepIndex = activeStepIndex
        .clamp(0, playbook.runOfShow.length - 1)
        .toInt();
    plan =
        EventSuccessPlan.fromDraft(
          id: event.id,
          eventId: event.id,
          clubId: event.clubId,
          draft: draft,
          activeStepIndex: normalizedActiveStepIndex,
          status: _planStatus,
          attendeePrompt: _attendeePrompt,
          createdAt: _createdAt,
          updatedAt: now,
          frozenAt:
              moment == _ManualQaMoment.booked ||
                  moment == _ManualQaMoment.firstHello
              ? null
              : event.startTime,
          completedAt: moment == _ManualQaMoment.postEvent ? now : null,
        ).copyWith(
          revealStatus: _resolvedRevealStatus,
          activeRevealRoundIndex: _resolvedActiveRevealRoundIndex,
          revealStartedAt: _revealStartedAt,
        );
    roster = EventParticipationRoster(
      bookedIds: defaultBookedIds,
      checkedInIds: _checkedInIds,
      waitlistedIds: defaultWaitlistedIds,
    );
    viewer = _userProfile();
    profiles = _publicProfiles();
    participations = _participations();
    attendanceViewModel = _attendanceViewModel();
    attendeeProfileRows = _attendeeProfileRows();
    participation = _participation();
    assignments = _microPodAssignments();
    rotationAssignments = _rotationAssignments();
    preferences = _preferences();
    wingmanRequests = _wingmanRequests();
    feedback = _feedback();
    compatibilityResponse = _compatibilityResponse();
  }

  final _ManualQaScenario scenario;
  final _ManualQaMoment moment;
  final int activeStepIndex;
  final EventSuccessRevealStatus revealStatus;
  final int activeRevealRoundIndex;
  final bool firstHelloEnabled;
  final bool firstHelloSkipped;
  final bool firstHelloCompleted;
  final bool compatibilityEnabled;
  final bool compatibilityAffectsRanking;
  final EventSuccessQuestionnaireConfig questionnaireConfig;
  final bool microPodsOptedOut;
  final bool guidedRotationsOptedOut;
  final List<String>? savedCompatibilityAnswerIds;
  final Set<String>? checkedInOverride;
  final Duration countdownElapsed;

  static final _clockNow = DateTime.now();
  static final _createdAt = _clockNow.subtract(const Duration(days: 4));
  static const hostUid = 'manual-qa-host';
  static const defaultBookedIds = [
    'runner-1',
    'runner-2',
    'runner-3',
    'runner-4',
    'runner-5',
    'runner-6',
    'runner-7',
    'runner-8',
  ];
  static const defaultCheckedInIds = [
    'runner-1',
    'runner-2',
    'runner-3',
    'runner-4',
    'runner-5',
  ];
  static const defaultWaitlistedIds = ['runner-9'];
  static const defaultProfileIds = [
    'runner-1',
    'runner-2',
    'runner-3',
    'runner-4',
    'runner-5',
    'runner-6',
    'runner-7',
    'runner-8',
    'runner-9',
  ];

  late final EventSuccessPlaybook playbook;
  late final Event event;
  late final Club club;
  late final EventSuccessPlan plan;
  late final EventParticipationRoster roster;
  late final List<EventParticipation> participations;
  late final AttendanceSheetViewModel attendanceViewModel;
  late final Map<String, (String, String?)> attendeeProfileRows;
  late final UserProfile viewer;
  late final List<PublicProfile> profiles;
  late final EventParticipation participation;
  late final List<EventSuccessAssignment> assignments;
  late final List<EventSuccessAssignment> rotationAssignments;
  late final List<EventSuccessPreference> preferences;
  late final List<EventSuccessWingmanRequest> wingmanRequests;
  late final List<EventSuccessFeedback> feedback;
  late final EventSuccessCompatibilityResponse? compatibilityResponse;

  EventSuccessArrivalMission? get viewerArrivalMission {
    if (!firstHelloEnabled ||
        firstHelloSkipped ||
        firstHelloCompleted ||
        moment != _ManualQaMoment.firstHello) {
      return null;
    }
    return EventSuccessArrivalMission(
      id: eventSuccessArrivalMissionId(eventId: event.id, uid: viewer.uid),
      eventId: event.id,
      clubId: event.clubId,
      observerUid: viewer.uid,
      targetUid: 'runner-2',
      targetDisplayName: 'Arjun',
      targetContext:
          'Look for Arjun near the host table. He is checked in for this fixture.',
      question: 'Ask what kind of partner makes an event feel easy to join.',
      answerOptions: const [
        EventSuccessArrivalMissionAnswerOption(
          id: 'warm_intro',
          label: 'Warm intro',
        ),
        EventSuccessArrivalMissionAnswerOption(
          id: 'playful_energy',
          label: 'Playful energy',
        ),
        EventSuccessArrivalMissionAnswerOption(
          id: 'clear_plan',
          label: 'Clear plan',
        ),
      ],
      status: EventSuccessArrivalMissionStatus.active,
      createdAt: now.subtract(const Duration(minutes: 1)),
      updatedAt: now.subtract(const Duration(minutes: 1)),
    );
  }

  DateTime get _eventStart => switch (moment) {
    _ManualQaMoment.booked => _clockNow.add(const Duration(minutes: 25)),
    _ManualQaMoment.firstHello => _clockNow.add(const Duration(minutes: 5)),
    _ManualQaMoment.checkedIn => _clockNow.subtract(const Duration(minutes: 5)),
    _ManualQaMoment.countdown => _clockNow.subtract(
      const Duration(minutes: 18),
    ),
    _ManualQaMoment.revealed => _clockNow.subtract(const Duration(minutes: 24)),
    _ManualQaMoment.postEvent => _clockNow.subtract(const Duration(hours: 2)),
  };

  DateTime get now => switch (moment) {
    _ManualQaMoment.booked => _eventStart.subtract(const Duration(minutes: 25)),
    _ManualQaMoment.firstHello => _eventStart.subtract(
      const Duration(minutes: 5),
    ),
    _ManualQaMoment.checkedIn => _eventStart.add(const Duration(minutes: 5)),
    _ManualQaMoment.countdown => _countdownStartReference.add(countdownElapsed),
    _ManualQaMoment.revealed => _eventStart.add(const Duration(minutes: 24)),
    _ManualQaMoment.postEvent => _eventStart.add(const Duration(hours: 2)),
  };

  EventSuccessAssignment? get viewerAssignment => assignments
      .where((assignment) => assignment.uid == viewer.uid)
      .firstOrNull;

  EventSuccessAssignment? get viewerRotationAssignment => rotationAssignments
      .where((assignment) => assignment.uid == viewer.uid)
      .firstOrNull;

  List<PublicProfile> get assignmentPeerProfiles =>
      _profilesFor(viewerAssignment?.allPeerUids ?? const []);

  List<PublicProfile> get rotationPeerProfiles =>
      _profilesFor(viewerRotationAssignment?.allPeerUids ?? const []);

  EventSuccessWingmanRequest? get viewerWingmanRequest => wingmanRequests
      .where((request) => request.requesterUid == viewer.uid)
      .firstOrNull;

  EventSuccessFeedback? get viewerFeedback =>
      feedback.where((item) => item.uid == viewer.uid).firstOrNull;

  EventRunOfShowStep get activeStep =>
      playbook.runOfShow[plan.activeStepIndex
          .clamp(0, playbook.runOfShow.length - 1)
          .toInt()];

  String get activeStepProgress =>
      'Step ${plan.activeStepIndex + 1}/${playbook.runOfShow.length}';

  String get activeStepLabel => '$activeStepProgress: ${activeStep.title}';

  String hostTabBadge(EventSuccessHostTab tab) => switch (tab) {
    EventSuccessHostTab.setup => 'Setup',
    EventSuccessHostTab.live => 'Live',
    EventSuccessHostTab.report => 'Report',
  };

  String get hostManageScopeKey =>
      '${scenario.name}:${moment.name}:$activeStepIndex:'
      '${roster.checkedInIds.join(',')}:${roster.waitlistedIds.join(',')}:'
      '${revealStatus.name}:$activeRevealRoundIndex';

  // ignore: strict_top_level_inference, inference preserves Riverpod's private override type.
  hostManageProviderOverrides({
    required bool Function(String uid) onToggleAttendance,
  }) {
    final assignmentParticipantUids = _assignmentParticipantUids(assignments);
    final assignmentParticipantKey = eventSuccessPeerUidsKey(
      assignmentParticipantUids,
    );
    final rotationParticipantUids = _assignmentParticipantUids(
      rotationAssignments,
    );
    final rotationParticipantKey = eventSuccessPeerUidsKey(
      rotationParticipantUids,
    );
    final wingmanProfileUids = _wingmanProfileUids(wingmanRequests);
    final wingmanProfileKey = eventSuccessPeerUidsKey(wingmanProfileUids);

    return [
      uidProvider.overrideWith((ref) => Stream.value(hostUid)),
      eventRepositoryProvider.overrideWith(
        (ref) => _ManualQaEventRepository(
          event: event,
          onToggleAttendance: onToggleAttendance,
        ),
      ),
      publicProfileRepositoryProvider.overrideWith(
        (ref) => _ManualQaPublicProfileRepository(profiles),
      ),
      watchEventProvider(event.id).overrideWith((ref) => Stream.value(event)),
      watchEventPrivateAccessProvider(
        event.id,
      ).overrideWith((ref) => Stream<EventPrivateAccess?>.value(null)),
      watchEventParticipationsForEventProvider(
        event.id,
      ).overrideWith((ref) => Stream.value(participations)),
      attendanceSheetViewModelProvider(
        event.id,
      ).overrideWithValue(AsyncData(attendanceViewModel)),
      attendeeProfilesProvider(
        attendanceViewModel.profileIds,
      ).overrideWith((ref) async => attendeeProfileRows),
      watchEventParticipationRosterProvider(
        event.id,
      ).overrideWith((ref) => Stream.value(roster)),
      watchEventSuccessPlanProvider(
        event.id,
      ).overrideWith((ref) => Stream.value(plan)),
      watchEventSuccessScorecardProvider(event.id).overrideWith(
        (ref) => Stream.value(EventSuccessSampleScorecards.strongSocialRun),
      ),
      watchEventSuccessAssignmentsProvider(
        event.id,
      ).overrideWith((ref) => Stream.value(assignments)),
      if (assignmentParticipantKey.isNotEmpty)
        eventSuccessAssignmentPeerProfilesProvider(
          assignmentParticipantKey,
        ).overrideWith((ref) async => _profilesFor(assignmentParticipantUids)),
      watchEventSuccessRotationAssignmentsProvider(
        event.id,
      ).overrideWith((ref) => Stream.value(rotationAssignments)),
      if (rotationParticipantKey.isNotEmpty &&
          rotationParticipantKey != assignmentParticipantKey)
        eventSuccessAssignmentPeerProfilesProvider(
          rotationParticipantKey,
        ).overrideWith((ref) async => _profilesFor(rotationParticipantUids)),
      watchEventSuccessPreferencesProvider(
        event.id,
      ).overrideWith((ref) => Stream.value(preferences)),
      watchEventSuccessWingmanRequestsProvider(
        event.id,
      ).overrideWith((ref) => Stream.value(wingmanRequests)),
      if (wingmanProfileKey.isNotEmpty &&
          wingmanProfileKey != assignmentParticipantKey &&
          wingmanProfileKey != rotationParticipantKey)
        eventSuccessAssignmentPeerProfilesProvider(
          wingmanProfileKey,
        ).overrideWith((ref) async => _profilesFor(wingmanProfileUids)),
    ];
  }

  List<String> get _checkedInIds =>
      (checkedInOverride ?? defaultCheckedInIds.toSet()).toList(
        growable: false,
      );

  Event _eventForScenario() {
    return Event(
      id: 'event-success-manual-qa',
      clubId: 'club-event-success-manual-qa',
      startTime: _eventStart,
      endTime: _eventStart.add(const Duration(minutes: 90)),
      meetingPoint: scenario.meetingPoint,
      eventFormat: EventFormatSnapshot.fromActivityKind(scenario.activityKind),
      distanceKm: scenario.activityKind.isDistanceBased ? 5 : 0,
      pace: PaceLevel.easy,
      capacityLimit: scenario.targetCount,
      description: 'Manual QA fixture for event-success host and attendee UI.',
      priceInPaise: 0,
      bookedCount: 8,
      checkedInCount: _checkedInIds.length,
      waitlistedCount: 1,
      genderCounts: const {'man': 4, 'woman': 4},
    );
  }

  Club _clubForScenario() {
    return Club(
      id: event.clubId,
      name: 'Manual QA Club',
      description: 'Fixture club for Host Manage and attendee QA.',
      location: 'Bengaluru',
      area: scenario.meetingPoint,
      hostUserId: hostUid,
      hostName: 'Catch QA Host',
      hostUserIds: const [hostUid],
      createdAt: _createdAt,
    );
  }

  List<EventParticipation> _participations() {
    final profilesByUid = {
      for (final profile in profiles) profile.uid: profile,
    };
    return [
      for (final uid in roster.bookedIds)
        _participationFor(
          uid: uid,
          status: roster.checkedInIds.contains(uid)
              ? EventParticipationStatus.attended
              : EventParticipationStatus.signedUp,
          gender: profilesByUid[uid]?.gender,
        ),
      for (final uid in roster.waitlistedIds)
        _participationFor(
          uid: uid,
          status: EventParticipationStatus.waitlisted,
          gender: profilesByUid[uid]?.gender,
        ),
    ];
  }

  AttendanceSheetViewModel _attendanceViewModel() {
    return AttendanceSheetViewModel(
      event: event,
      attendeeIds: roster.bookedIds,
      attendedIds: Set.unmodifiable(roster.checkedInIds),
      waitlistedIds: roster.waitlistedIds,
      profileIds: defaultProfileIds,
      participationsByUid: Map.unmodifiable({
        for (final participation in participations)
          participation.uid: participation,
      }),
    );
  }

  Map<String, (String, String?)> _attendeeProfileRows() {
    return {
      for (final profile in profiles)
        profile.uid: (profile.name, profile.primaryPhotoThumbnailUrl),
    };
  }

  EventParticipation _participation() {
    final attended = roster.checkedInIds.contains(viewer.uid);
    return _participationFor(
      uid: viewer.uid,
      status: attended
          ? EventParticipationStatus.attended
          : EventParticipationStatus.signedUp,
      gender: viewer.gender,
    );
  }

  EventParticipation _participationFor({
    required String uid,
    required EventParticipationStatus status,
    required Gender? gender,
  }) {
    return EventParticipation(
      id: eventParticipationId(eventId: event.id, uid: uid),
      eventId: event.id,
      clubId: event.clubId,
      uid: uid,
      status: status,
      createdAt: _createdAt,
      updatedAt: now,
      signedUpAt:
          status == EventParticipationStatus.signedUp ||
              status == EventParticipationStatus.attended
          ? _createdAt
          : null,
      attendedAt: status == EventParticipationStatus.attended
          ? event.startTime
          : null,
      waitlistedAt: status == EventParticipationStatus.waitlisted
          ? _createdAt
          : null,
      genderAtSignup: gender,
      cohortAtSignup: gender == Gender.woman
          ? 'womenInterestedInMen'
          : 'menInterestedInWomen',
    );
  }

  List<EventSuccessAssignment> _microPodAssignments() {
    if (!playbook.moduleIds.contains(EventSuccessModuleCatalog.microPods.id)) {
      return const [];
    }
    return [
      _assignment(
        uid: 'runner-1',
        label: scenario.structureConfig.unitKind == EventSuccessUnitKind.teams
            ? 'Team 1'
            : 'Pod A',
        title: scenario.structureConfig.unitKind == EventSuccessUnitKind.teams
            ? 'Quiz Team 1'
            : 'Pace Pod A',
        peerUids: const ['runner-2', 'runner-3', 'runner-4'],
      ),
      _assignment(
        uid: 'runner-2',
        label: scenario.structureConfig.unitKind == EventSuccessUnitKind.teams
            ? 'Team 1'
            : 'Pod A',
        title: scenario.structureConfig.unitKind == EventSuccessUnitKind.teams
            ? 'Quiz Team 1'
            : 'Pace Pod A',
        peerUids: const ['runner-1', 'runner-3', 'runner-4'],
      ),
      _assignment(
        uid: 'runner-3',
        label: 'Team 2',
        title: 'Team 2',
        peerUids: const ['runner-5', 'runner-6'],
      ),
    ];
  }

  List<EventSuccessAssignment> _rotationAssignments() {
    if (!playbook.moduleIds.contains(
      EventSuccessModuleCatalog.guidedRotations.id,
    )) {
      return const [];
    }
    final round0 = event.startTime.add(const Duration(minutes: 15));
    final round1 = round0.add(
      Duration(minutes: plan.structureConfig.rotationIntervalMinutes ?? 15),
    );
    return [
      _rotationAssignment(
        uid: 'runner-1',
        peerUids: const ['runner-2', 'runner-5'],
        slots: [
          _rotationSlot(0, round0, 'runner-2', 'mutual_interest'),
          _rotationSlot(1, round1, 'runner-5', 'questionnaire_match'),
        ],
      ),
      _rotationAssignment(
        uid: 'runner-2',
        peerUids: const ['runner-1', 'runner-4'],
        slots: [
          _rotationSlot(0, round0, 'runner-1', 'mutual_interest'),
          _rotationSlot(1, round1, 'runner-4', 'one_way_interest'),
        ],
      ),
      _rotationAssignment(
        uid: 'runner-3',
        peerUids: const ['runner-4'],
        slots: [_rotationSlot(0, round0, 'runner-4', 'social')],
      ),
    ];
  }

  EventSuccessAssignment _assignment({
    required String uid,
    required String label,
    required String title,
    required List<String> peerUids,
  }) {
    return EventSuccessAssignment(
      id: eventSuccessAssignmentId(
        eventId: event.id,
        moduleId: EventSuccessModuleCatalog.microPods.id,
        uid: uid,
      ),
      eventId: event.id,
      clubId: event.clubId,
      uid: uid,
      moduleId: EventSuccessModuleCatalog.microPods.id,
      label: label,
      displayTitle: title,
      displaySubtitle: 'Start here, then follow the host cue.',
      peerUids: peerUids,
      source: 'manual_qa_fixture',
      createdAt: _createdAt,
      updatedAt: now,
    );
  }

  EventSuccessAssignment _rotationAssignment({
    required String uid,
    required List<String> peerUids,
    required List<EventSuccessRotationSlot> slots,
  }) {
    return EventSuccessAssignment(
      id: eventSuccessAssignmentId(
        eventId: event.id,
        moduleId: EventSuccessModuleCatalog.guidedRotations.id,
        uid: uid,
      ),
      eventId: event.id,
      clubId: event.clubId,
      uid: uid,
      moduleId: EventSuccessModuleCatalog.guidedRotations.id,
      label: 'Rotation schedule',
      displayTitle: 'Guided rotation schedule',
      displaySubtitle: 'Host-edited preview schedule',
      peerUids: peerUids,
      rotationSlots: slots,
      source: 'host_override_v1',
      createdAt: _createdAt,
      updatedAt: now,
    );
  }

  EventSuccessRotationSlot _rotationSlot(
    int index,
    DateTime startsAt,
    String peerUid,
    String compatibility,
  ) {
    final interval = plan.structureConfig.rotationIntervalMinutes ?? 15;
    return EventSuccessRotationSlot(
      roundIndex: index,
      label: 'Round ${index + 1}',
      startsAt: startsAt,
      endsAt: startsAt.add(Duration(minutes: interval)),
      peerUid: peerUid,
      compatibility: compatibility,
    );
  }

  List<EventSuccessPreference> _preferences() {
    if (!microPodsOptedOut && !guidedRotationsOptedOut) return const [];
    return [
      EventSuccessPreference(
        id: eventSuccessPreferenceId(eventId: event.id, uid: viewer.uid),
        eventId: event.id,
        clubId: event.clubId,
        uid: viewer.uid,
        microPodsOptedOut: microPodsOptedOut,
        guidedRotationsOptedOut: guidedRotationsOptedOut,
        createdAt: _createdAt,
        updatedAt: now,
      ),
    ];
  }

  List<EventSuccessWingmanRequest> _wingmanRequests() {
    if (moment == _ManualQaMoment.booked ||
        moment == _ManualQaMoment.postEvent) {
      return const [];
    }
    return [
      EventSuccessWingmanRequest(
        id: eventSuccessWingmanRequestId(eventId: event.id, uid: viewer.uid),
        eventId: event.id,
        clubId: event.clubId,
        requesterUid: viewer.uid,
        targetUid: 'runner-2',
        status: EventSuccessWingmanRequestStatus.active,
        hostVisibleConsent: true,
        note: 'Pair me if it feels natural.',
        createdAt: _createdAt,
        updatedAt: now,
      ),
    ];
  }

  List<EventSuccessFeedback> _feedback() {
    if (moment != _ManualQaMoment.postEvent) return const [];
    return [
      _feedbackFor(uid: 'runner-1', metNewPeopleCount: 4),
      _feedbackFor(uid: 'runner-2', metNewPeopleCount: 3),
      _feedbackFor(uid: 'runner-3', metNewPeopleCount: 1),
    ];
  }

  EventSuccessFeedback _feedbackFor({
    required String uid,
    required int metNewPeopleCount,
  }) {
    return EventSuccessFeedback(
      id: eventSuccessFeedbackId(eventId: event.id, uid: uid),
      eventId: event.id,
      clubId: event.clubId,
      uid: uid,
      metNewPeopleCount: metNewPeopleCount,
      welcomeRating: 4,
      structureRating: 5,
      safetyConcern: false,
      privateNote: 'QA fixture feedback',
      createdAt: now,
      updatedAt: now,
    );
  }

  EventSuccessCompatibilityResponse? _compatibilityResponse() {
    if (!plan.hasModule(
      EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
    )) {
      return null;
    }
    if (savedCompatibilityAnswerIds == null &&
        (moment == _ManualQaMoment.booked ||
            moment == _ManualQaMoment.firstHello ||
            moment == _ManualQaMoment.checkedIn ||
            moment == _ManualQaMoment.postEvent)) {
      return null;
    }
    final answerIds =
        savedCompatibilityAnswerIds ??
        const [
          'event_energy_playful_competition',
          'first_conversation_question',
          'shared_connection_ideas',
          'after_event_activity',
        ];
    return EventSuccessCompatibilityResponse(
      id: eventSuccessCompatibilityResponseId(
        eventId: event.id,
        uid: viewer.uid,
      ),
      eventId: event.id,
      clubId: event.clubId,
      uid: viewer.uid,
      answerIds: answerIds,
      createdAt: _createdAt,
      updatedAt: now,
    );
  }

  UserProfile _userProfile() {
    return UserProfile(
      uid: 'runner-1',
      name: 'Maya Sharma',
      firstName: 'Maya',
      displayName: 'Maya',
      dateOfBirth: DateTime(1998, 2, 14),
      gender: Gender.woman,
      phoneNumber: '+919999999991',
      profileComplete: true,
      interestedInGenders: const [Gender.man],
      city: 'Bengaluru',
      occupation: 'Product designer',
      relationshipGoal: RelationshipGoal.relationship,
      activityPreferences: ActivityPreferences(
        running: RunningPreferences(
          preferredDistances: [PreferredDistance.fiveK],
          runningReasons: [RunReason.social],
          preferredRunTimes: [PreferredRunTime.evening],
          version: currentRunPreferencesVersion,
        ),
      ),
    );
  }

  List<PublicProfile> _publicProfiles() {
    return const [
      PublicProfile(
        uid: 'runner-1',
        name: 'Maya',
        age: 28,
        gender: Gender.woman,
        city: 'Bengaluru',
        occupation: 'Product designer',
        relationshipGoal: RelationshipGoal.relationship,
      ),
      PublicProfile(
        uid: 'runner-2',
        name: 'Arjun',
        age: 30,
        gender: Gender.man,
        city: 'Bengaluru',
        occupation: 'Founder',
        relationshipGoal: RelationshipGoal.relationship,
      ),
      PublicProfile(
        uid: 'runner-3',
        name: 'Kabir',
        age: 31,
        gender: Gender.man,
        city: 'Bengaluru',
        occupation: 'Architect',
      ),
      PublicProfile(
        uid: 'runner-4',
        name: 'Nisha',
        age: 28,
        gender: Gender.woman,
        city: 'Bengaluru',
        occupation: 'Chef',
      ),
      PublicProfile(
        uid: 'runner-5',
        name: 'Rohan',
        age: 32,
        gender: Gender.man,
        city: 'Bengaluru',
        occupation: 'Engineer',
      ),
      PublicProfile(
        uid: 'runner-6',
        name: 'Ira',
        age: 27,
        gender: Gender.woman,
        city: 'Bengaluru',
        occupation: 'Consultant',
      ),
      PublicProfile(
        uid: 'runner-7',
        name: 'Dev',
        age: 29,
        gender: Gender.man,
        city: 'Bengaluru',
        occupation: 'Product manager',
      ),
      PublicProfile(
        uid: 'runner-8',
        name: 'Tara',
        age: 26,
        gender: Gender.woman,
        city: 'Bengaluru',
        occupation: 'Writer',
      ),
      PublicProfile(
        uid: 'runner-9',
        name: 'Vihaan',
        age: 33,
        gender: Gender.man,
        city: 'Bengaluru',
        occupation: 'Analyst',
      ),
    ];
  }

  List<PublicProfile> _profilesFor(List<String> uids) {
    final wanted = uids.toSet();
    return profiles
        .where((profile) => wanted.contains(profile.uid))
        .toList(growable: false);
  }

  EventSuccessPlanStatus get _planStatus => switch (moment) {
    _ManualQaMoment.booked ||
    _ManualQaMoment.firstHello => EventSuccessPlanStatus.setup,
    _ManualQaMoment.checkedIn ||
    _ManualQaMoment.countdown ||
    _ManualQaMoment.revealed => EventSuccessPlanStatus.live,
    _ManualQaMoment.postEvent => EventSuccessPlanStatus.complete,
  };

  EventSuccessRevealStatus get _resolvedRevealStatus =>
      moment == _ManualQaMoment.postEvent
      ? EventSuccessRevealStatus.revealed
      : revealStatus;

  int get _resolvedActiveRevealRoundIndex =>
      moment == _ManualQaMoment.postEvent ? 0 : activeRevealRoundIndex;

  DateTime? get _revealStartedAt => switch (_resolvedRevealStatus) {
    EventSuccessRevealStatus.countingDown => _countdownStartReference,
    EventSuccessRevealStatus.revealed => now.subtract(
      const Duration(minutes: 1),
    ),
    EventSuccessRevealStatus.idle => null,
  };

  DateTime get _countdownStartReference =>
      _eventStart.add(const Duration(minutes: 18));

  String get _attendeePrompt => switch (scenario) {
    _ManualQaScenario.socialRun =>
      'Find someone at your pace and ask about their favorite running route.',
    _ManualQaScenario.racketPairs =>
      'Ask your next partner what makes a great doubles teammate.',
    _ManualQaScenario.quizTeams =>
      'Ask your team for one niche thing they know too much about.',
    _ManualQaScenario.singlesMixer =>
      'Ask your next match what kind of event night they secretly love.',
  };
}

class _ManualQaEventRepository implements EventRepository {
  const _ManualQaEventRepository({
    required this.event,
    required this.onToggleAttendance,
  });

  final Event event;
  final bool Function(String uid) onToggleAttendance;

  @override
  Future<Event?> fetchEvent(String id) async => id == event.id ? event : null;

  @override
  Stream<Event?> watchEvent(String id) =>
      Stream.value(id == event.id ? event : null);

  @override
  Stream<EventPrivateAccess?> watchPrivateAccess(String eventId) =>
      Stream.value(null);

  @override
  Future<bool> markAttendance({
    required String eventId,
    required String userId,
  }) async {
    if (eventId != event.id) return false;
    return onToggleAttendance(userId);
  }

  @override
  Future<void> cancelEvent({required String eventId, String? reason}) async {}

  @override
  Future<void> deleteEvent({required String eventId}) async {}

  @override
  Future<void> updateEventDetails({
    required Event event,
    bool includePolicy = false,
    String? inviteCode,
  }) async {}

  @override
  Future<void> decideJoinRequest({
    required String eventId,
    required String userId,
    required String decision,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ManualQaPublicProfileRepository implements PublicProfileRepository {
  _ManualQaPublicProfileRepository(List<PublicProfile> profiles)
    : _profilesByUid = {for (final profile in profiles) profile.uid: profile};

  final Map<String, PublicProfile> _profilesByUid;

  @override
  Stream<PublicProfile?> watchPublicProfile({required String uid}) =>
      Stream.value(_profilesByUid[uid]);

  @override
  Future<PublicProfile?> fetchPublicProfile({required String uid}) async =>
      _profilesByUid[uid];

  @override
  Future<List<PublicProfile>> fetchPublicProfiles(List<String> uids) async {
    final seen = <String>{};
    return [
      for (final uid in uids)
        if (seen.add(uid) && _profilesByUid[uid] != null) _profilesByUid[uid]!,
    ];
  }
}

extension on EventSuccessHostTab {
  HostEventManageSection get hostManageSection {
    return switch (this) {
      EventSuccessHostTab.setup => HostEventManageSection.setup,
      EventSuccessHostTab.live => HostEventManageSection.live,
      EventSuccessHostTab.report => HostEventManageSection.report,
    };
  }
}

extension on HostEventManageSection {
  EventSuccessHostTab get eventSuccessTab {
    return switch (this) {
      HostEventManageSection.setup => EventSuccessHostTab.setup,
      HostEventManageSection.live => EventSuccessHostTab.live,
      HostEventManageSection.report => EventSuccessHostTab.report,
    };
  }
}

Set<String> _selectedModuleIds(
  EventSuccessPlaybook playbook, {
  required bool compatibilityEnabled,
  required bool firstHelloEnabled,
}) {
  final profile = EventSuccessActivityProfile.forActivity(
    playbook.activityType,
  );
  final ids = profile.defaultModuleIds
      .where(playbook.moduleIds.contains)
      .toSet();
  if (compatibilityEnabled &&
      playbook.moduleIds.contains(
        EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
      )) {
    ids.add(EventSuccessModuleCatalog.compatibilityQuestionnaire.id);
  }
  if (firstHelloEnabled &&
      playbook.moduleIds.contains(
        EventSuccessModuleCatalog.firstHelloCheckIn.id,
      )) {
    ids.add(EventSuccessModuleCatalog.firstHelloCheckIn.id);
  }
  return ids;
}

List<String> _assignmentParticipantUids(
  List<EventSuccessAssignment> assignments,
) {
  final uids = <String>{};
  for (final assignment in assignments) {
    uids
      ..add(assignment.uid)
      ..addAll(assignment.allPeerUids);
  }
  return uids.toList()..sort();
}

List<String> _wingmanProfileUids(List<EventSuccessWingmanRequest> requests) {
  final uids = <String>{};
  for (final request in requests) {
    if (!request.isActive) continue;
    uids
      ..add(request.requesterUid)
      ..add(request.targetUid);
  }
  return uids.toList()..sort();
}
