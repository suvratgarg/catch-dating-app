import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_segmented_control.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/event_success/domain/event_success_activity_profile.dart';
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
import 'package:catch_dating_app/event_success/presentation/event_success_questionnaire_config_editor.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

/// Dev/staging-only manual QA harness for the live event-success loop.
///
/// This renders the production host panel and attendee companion against one
/// synthetic scenario so host-side state changes can be inspected beside the
/// attendee experience. Use the top-level QA controls for state changes; the
/// production action buttons are present for visual review, not write-path QA.
class EventSuccessManualQaScreen extends StatefulWidget {
  const EventSuccessManualQaScreen({super.key});

  @override
  State<EventSuccessManualQaScreen> createState() =>
      _EventSuccessManualQaScreenState();
}

class _EventSuccessManualQaScreenState
    extends State<EventSuccessManualQaScreen> {
  _ManualQaScenario _scenario = _ManualQaScenario.racketPairs;
  EventSuccessHostTab _hostTab = EventSuccessHostTab.setup;
  int _activeStepIndex = 0;
  EventSuccessRevealStatus _revealStatus = EventSuccessRevealStatus.idle;
  int _activeRevealRoundIndex = 0;
  bool _compatibilityEnabled = true;
  bool _compatibilityAffectsRanking = true;
  EventSuccessQuestionnaireConfig _questionnaireConfig =
      const EventSuccessQuestionnaireConfig.defaultTemplate();
  bool _microPodsOptedOut = false;
  bool _guidedRotationsOptedOut = false;

  @override
  Widget build(BuildContext context) {
    final moment = _momentForHostState();
    final data = _ManualQaFixtures(
      scenario: _scenario,
      moment: moment,
      activeStepIndex: _activeStepIndex,
      revealStatus: _revealStatus,
      activeRevealRoundIndex: _activeRevealRoundIndex,
      compatibilityEnabled: _compatibilityEnabled,
      compatibilityAffectsRanking: _compatibilityAffectsRanking,
      questionnaireConfig: _questionnaireConfig,
      microPodsOptedOut: _microPodsOptedOut,
      guidedRotationsOptedOut: _guidedRotationsOptedOut,
    );
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        title: Text(
          'Event success manual QA',
          style: CatchTextStyles.titleM(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(CatchSpacing.s5),
          children: [
            _ManualQaHero(data: data),
            gapH16,
            _ManualQaControls(
              scenario: _scenario,
              onScenarioChanged: (value) => setState(() {
                _scenario = value;
                _activeStepIndex = _defaultActiveStepIndex(
                  scenario: value,
                  hostTab: _hostTab,
                );
                _resetRevealState();
                _guidedRotationsOptedOut = false;
                _microPodsOptedOut = false;
              }),
            ),
            gapH16,
            _ManualQaSideBySide(
              hostTab: _hostTab,
              data: data,
              compatibilityEnabled: _compatibilityEnabled,
              compatibilityAffectsRanking: _compatibilityAffectsRanking,
              questionnaireConfig: _questionnaireConfig,
              microPodsOptedOut: _microPodsOptedOut,
              guidedRotationsOptedOut: _guidedRotationsOptedOut,
              fixtureActions: _fixtureActions(),
              onHostTabChanged: _setHostTab,
              onCompatibilityEnabledChanged: (value) => setState(() {
                _compatibilityEnabled = value;
                if (!value) _compatibilityAffectsRanking = false;
              }),
              onCompatibilityRankingChanged: (value) =>
                  setState(() => _compatibilityAffectsRanking = value),
              onQuestionnaireConfigChanged: (value) =>
                  setState(() => _questionnaireConfig = value),
              onMicroPodsOptOutChanged: (value) =>
                  setState(() => _microPodsOptedOut = value),
              onGuidedRotationsOptOutChanged: (value) =>
                  setState(() => _guidedRotationsOptedOut = value),
            ),
          ],
        ),
      ),
    );
  }

  EventSuccessHostFixtureActions _fixtureActions() {
    return EventSuccessHostFixtureActions(
      onSaveSetup: () => _showFixtureAction(
        'Fixture setup saved. Use a real dev event to verify persistence.',
      ),
      onPreviousStep: () => _moveHostStep(-1),
      onNextStep: () => _moveHostStep(1),
      onCompletePlan: () => _showFixtureAction(
        'Fixture plan marked complete. Use Post-event to inspect the report.',
      ),
      onGenerateMicroPods: () => _showFixtureAction(
        'Fixture micro-pods regenerated. Toggle opt-outs to inspect stale-card behavior.',
      ),
      onGenerateGuidedRotations: () => _showFixtureAction(
        'Fixture rotations regenerated. Change event format or ranking signal to inspect variants.',
      ),
      onOverrideGuidedRotations: (_) => _showFixtureAction(
        'Fixture rotation edits accepted. Use a real dev event to verify the callable write path.',
      ),
      onStartRevealCountdown: _startRevealCountdown,
      onRevealRound: _revealRound,
      onResetReveal: _resetReveal,
    );
  }

  void _showFixtureAction(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: CatchTextStyles.bodyS(context))),
    );
  }

  void _moveHostStep(int delta) {
    setState(() {
      _hostTab = EventSuccessHostTab.live;
      _activeStepIndex = _clampActiveStepIndex(_activeStepIndex + delta);
      if (!_activeStepHasLiveReveal(_activeStepIndex)) _resetRevealState();
    });
  }

  void _setHostTab(EventSuccessHostTab tab) {
    setState(() {
      _hostTab = tab;
      _activeStepIndex = _defaultActiveStepIndex(
        scenario: _scenario,
        hostTab: tab,
      );
      if (tab != EventSuccessHostTab.live ||
          !_activeStepHasLiveReveal(_activeStepIndex)) {
        _resetRevealState();
      }
    });
  }

  void _startRevealCountdown(int roundIndex, int _) {
    setState(() {
      _hostTab = EventSuccessHostTab.live;
      _activeStepIndex = _firstRevealStepIndex(_scenario);
      _revealStatus = EventSuccessRevealStatus.countingDown;
      _activeRevealRoundIndex = roundIndex;
    });
  }

  void _revealRound(int roundIndex) {
    setState(() {
      _hostTab = EventSuccessHostTab.live;
      _activeStepIndex = _firstRevealStepIndex(_scenario);
      _revealStatus = EventSuccessRevealStatus.revealed;
      _activeRevealRoundIndex = roundIndex;
    });
  }

  void _resetReveal() {
    setState(_resetRevealState);
  }

  void _resetRevealState() {
    _revealStatus = EventSuccessRevealStatus.idle;
    _activeRevealRoundIndex = 0;
  }

  _ManualQaMoment _momentForHostState() {
    return switch (_hostTab) {
      EventSuccessHostTab.setup => _ManualQaMoment.booked,
      EventSuccessHostTab.report => _ManualQaMoment.postEvent,
      EventSuccessHostTab.live => switch (_revealStatus) {
        EventSuccessRevealStatus.countingDown => _ManualQaMoment.countdown,
        EventSuccessRevealStatus.revealed => _ManualQaMoment.revealed,
        EventSuccessRevealStatus.idle => _ManualQaMoment.checkedIn,
      },
    };
  }

  int _defaultActiveStepIndex({
    required _ManualQaScenario scenario,
    required EventSuccessHostTab hostTab,
  }) {
    return switch (hostTab) {
      EventSuccessHostTab.setup || EventSuccessHostTab.live => 0,
      EventSuccessHostTab.report => scenario.playbook.runOfShow.length - 1,
    };
  }

  int _firstRevealStepIndex(_ManualQaScenario scenario) {
    final index = scenario.playbook.runOfShow.indexWhere(
      (step) =>
          step.moduleIds.contains(EventSuccessModuleCatalog.liveReveal.id),
    );
    return index < 0 ? 0 : index;
  }

  int _clampActiveStepIndex(int index) {
    final lastIndex = _scenario.playbook.runOfShow.length - 1;
    return index.clamp(0, lastIndex).toInt();
  }

  bool _activeStepHasLiveReveal(int index) {
    final steps = _scenario.playbook.runOfShow;
    if (steps.isEmpty) return false;
    final clamped = index.clamp(0, steps.length - 1).toInt();
    return steps[clamped].moduleIds.contains(
      EventSuccessModuleCatalog.liveReveal.id,
    );
  }
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
      borderColor: Colors.transparent,
      padding: const EdgeInsets.all(CatchSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: const [
              CatchBadge(
                label: 'Manual QA',
                tone: CatchBadgeTone.live,
                icon: Icons.fact_check_outlined,
              ),
              CatchBadge(
                label: 'Fixture data',
                tone: CatchBadgeTone.solid,
                icon: Icons.data_object_rounded,
              ),
            ],
          ),
          gapH20,
          Text(
            data.event.title,
            style: CatchTextStyles.displayL(context, color: t.accentInk),
          ),
          gapH8,
          Text(
            '${data.playbook.title} · ${data.plan.structureConfig.unitKind.label} · ${data.moment.label}',
            style: CatchTextStyles.bodyL(
              context,
              color: t.accentInk.withValues(alpha: 0.86),
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
          Text('Fixture scenario', style: CatchTextStyles.titleM(context)),
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
    required this.compatibilityEnabled,
    required this.compatibilityAffectsRanking,
    required this.questionnaireConfig,
    required this.microPodsOptedOut,
    required this.guidedRotationsOptedOut,
    required this.fixtureActions,
    required this.onHostTabChanged,
    required this.onCompatibilityEnabledChanged,
    required this.onCompatibilityRankingChanged,
    required this.onQuestionnaireConfigChanged,
    required this.onMicroPodsOptOutChanged,
    required this.onGuidedRotationsOptOutChanged,
  });

  final EventSuccessHostTab hostTab;
  final _ManualQaFixtures data;
  final bool compatibilityEnabled;
  final bool compatibilityAffectsRanking;
  final EventSuccessQuestionnaireConfig questionnaireConfig;
  final bool microPodsOptedOut;
  final bool guidedRotationsOptedOut;
  final EventSuccessHostFixtureActions fixtureActions;
  final ValueChanged<EventSuccessHostTab> onHostTabChanged;
  final ValueChanged<bool> onCompatibilityEnabledChanged;
  final ValueChanged<bool> onCompatibilityRankingChanged;
  final ValueChanged<EventSuccessQuestionnaireConfig>
  onQuestionnaireConfigChanged;
  final ValueChanged<bool> onMicroPodsOptOutChanged;
  final ValueChanged<bool> onGuidedRotationsOptOutChanged;

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
                  title: 'Host config and controls',
                  subtitle:
                      '${data.plan.structureConfig.unitKind.label}, ${data.plan.structureConfig.unitSize} per ${data.plan.structureConfig.unitKind.singularLabel} · ${data.activeStepLabel}',
                  badges: [
                    data.hostTabBadge(hostTab),
                    data.activeStepProgress,
                    '${data.assignments.length} pod cards',
                    '${data.rotationAssignments.length} rotation cards',
                  ],
                  controls: _HostQaControls(
                    hostTab: hostTab,
                    compatibilityEnabled: compatibilityEnabled,
                    compatibilityAffectsRanking: compatibilityAffectsRanking,
                    questionnaireConfig: questionnaireConfig,
                    onHostTabChanged: onHostTabChanged,
                    onCompatibilityEnabledChanged:
                        onCompatibilityEnabledChanged,
                    onCompatibilityRankingChanged:
                        onCompatibilityRankingChanged,
                    onQuestionnaireConfigChanged: onQuestionnaireConfigChanged,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(CatchSpacing.s4),
                    child: EventSuccessHostPanel(
                      event: data.event,
                      plan: data.plan,
                      planIsPersisted: true,
                      roster: data.roster,
                      scorecard: EventSuccessSampleScorecards.strongSocialRun,
                      assignments: data.assignments,
                      rotationAssignments: data.rotationAssignments,
                      rotationParticipantProfiles: data.profiles,
                      preferences: data.preferences,
                      wingmanRequests: data.wingmanRequests,
                      wingmanProfiles: data.profiles,
                      initialTab: hostTab,
                      showTabs: false,
                      embedded: true,
                      fixtureActions: fixtureActions,
                    ),
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
                    now: data.now,
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
                Text(title, style: CatchTextStyles.titleM(context)),
                gapH4,
                Text(
                  subtitle,
                  style: CatchTextStyles.bodyS(context, color: t.ink2),
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
              child: SizedBox(height: 780, child: child),
            ),
          ),
        ],
      ),
    );
  }
}

class _HostQaControls extends StatelessWidget {
  const _HostQaControls({
    required this.hostTab,
    required this.compatibilityEnabled,
    required this.compatibilityAffectsRanking,
    required this.questionnaireConfig,
    required this.onHostTabChanged,
    required this.onCompatibilityEnabledChanged,
    required this.onCompatibilityRankingChanged,
    required this.onQuestionnaireConfigChanged,
  });

  final EventSuccessHostTab hostTab;
  final bool compatibilityEnabled;
  final bool compatibilityAffectsRanking;
  final EventSuccessQuestionnaireConfig questionnaireConfig;
  final ValueChanged<EventSuccessHostTab> onHostTabChanged;
  final ValueChanged<bool> onCompatibilityEnabledChanged;
  final ValueChanged<bool> onCompatibilityRankingChanged;
  final ValueChanged<EventSuccessQuestionnaireConfig>
  onQuestionnaireConfigChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ControlLabel('Host surface'),
        gapH8,
        CatchSegmentedControl<EventSuccessHostTab>(
          selected: hostTab,
          expanded: true,
          style: CatchSegmentedControlStyle.surface,
          onChanged: onHostTabChanged,
          segments: const [
            CatchSegment(
              value: EventSuccessHostTab.setup,
              label: 'Setup',
              icon: Icons.tune_rounded,
            ),
            CatchSegment(
              value: EventSuccessHostTab.live,
              label: 'Live',
              icon: Icons.play_circle_outline_rounded,
            ),
            CatchSegment(
              value: EventSuccessHostTab.report,
              label: 'Report',
              icon: Icons.insights_outlined,
            ),
          ],
        ),
        gapH12,
        _ControlLabel('Compatibility layer'),
        gapH8,
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            CatchChip(
              label: 'Questionnaire',
              active: compatibilityEnabled,
              icon: const Icon(Icons.quiz_outlined),
              onTap: () => onCompatibilityEnabledChanged(!compatibilityEnabled),
            ),
            CatchChip(
              label: 'Pairing signal',
              active: compatibilityEnabled && compatibilityAffectsRanking,
              enabled: compatibilityEnabled,
              icon: const Icon(Icons.auto_awesome_rounded),
              onTap: () =>
                  onCompatibilityRankingChanged(!compatibilityAffectsRanking),
            ),
          ],
        ),
        if (compatibilityEnabled) ...[
          gapH12,
          EventSuccessQuestionnaireConfigEditor(
            value: questionnaireConfig,
            onChanged: onQuestionnaireConfigChanged,
          ),
        ],
      ],
    );
  }
}

class _AttendeeQaControls extends StatelessWidget {
  const _AttendeeQaControls({
    required this.microPodsOptedOut,
    required this.guidedRotationsOptedOut,
    required this.onMicroPodsOptOutChanged,
    required this.onGuidedRotationsOptOutChanged,
  });

  final bool microPodsOptedOut;
  final bool guidedRotationsOptedOut;
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
              icon: const Icon(Icons.visibility_off_outlined),
              onTap: () => onMicroPodsOptOutChanged(!microPodsOptedOut),
            ),
            CatchChip(
              label: 'Rotations opt-out',
              active: guidedRotationsOptedOut,
              icon: const Icon(Icons.block_outlined),
              onTap: () =>
                  onGuidedRotationsOptOutChanged(!guidedRotationsOptedOut),
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
      backgroundColor: t.accentInk.withValues(alpha: 0.14),
      borderColor: t.accentInk.withValues(alpha: 0.22),
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
    _ManualQaScenario.socialRun => Icons.directions_run_rounded,
    _ManualQaScenario.racketPairs => Icons.sports_tennis_rounded,
    _ManualQaScenario.quizTeams => Icons.quiz_outlined,
    _ManualQaScenario.singlesMixer => Icons.favorite_border_rounded,
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
  checkedIn,
  countdown,
  revealed,
  postEvent;

  String get label => switch (this) {
    _ManualQaMoment.booked => 'Booked',
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
    required this.compatibilityEnabled,
    required this.compatibilityAffectsRanking,
    required this.questionnaireConfig,
    required this.microPodsOptedOut,
    required this.guidedRotationsOptedOut,
  }) {
    playbook = scenario.playbook;
    event = _eventForScenario();
    final draft =
        EventSuccessHostDraft.fromPlaybook(
          playbook,
          targetAttendeeCount: scenario.targetCount,
        ).copyWith(
          selectedModuleIds: _selectedModuleIds(
            playbook,
            compatibilityEnabled: compatibilityEnabled,
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
          frozenAt: moment == _ManualQaMoment.booked ? null : event.startTime,
          completedAt: moment == _ManualQaMoment.postEvent ? now : null,
        ).copyWith(
          revealStatus: _resolvedRevealStatus,
          activeRevealRoundIndex: _resolvedActiveRevealRoundIndex,
          revealStartedAt: _revealStartedAt,
        );
    roster = const EventParticipationRoster(
      bookedIds: [
        'runner-1',
        'runner-2',
        'runner-3',
        'runner-4',
        'runner-5',
        'runner-6',
        'runner-7',
        'runner-8',
      ],
      checkedInIds: [
        'runner-1',
        'runner-2',
        'runner-3',
        'runner-4',
        'runner-5',
      ],
      waitlistedIds: ['runner-9'],
    );
    viewer = _userProfile();
    profiles = _publicProfiles();
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
  final bool compatibilityEnabled;
  final bool compatibilityAffectsRanking;
  final EventSuccessQuestionnaireConfig questionnaireConfig;
  final bool microPodsOptedOut;
  final bool guidedRotationsOptedOut;

  static final _baseStart = DateTime(2026, 5, 21, 18);
  static final _createdAt = _baseStart.subtract(const Duration(days: 4));

  late final EventSuccessPlaybook playbook;
  late final Event event;
  late final EventSuccessPlan plan;
  late final EventParticipationRoster roster;
  late final UserProfile viewer;
  late final List<PublicProfile> profiles;
  late final EventParticipation participation;
  late final List<EventSuccessAssignment> assignments;
  late final List<EventSuccessAssignment> rotationAssignments;
  late final List<EventSuccessPreference> preferences;
  late final List<EventSuccessWingmanRequest> wingmanRequests;
  late final List<EventSuccessFeedback> feedback;
  late final EventSuccessCompatibilityResponse? compatibilityResponse;

  DateTime get now => switch (moment) {
    _ManualQaMoment.booked => _baseStart.subtract(const Duration(minutes: 25)),
    _ManualQaMoment.checkedIn => _baseStart.add(const Duration(minutes: 5)),
    _ManualQaMoment.countdown => _baseStart.add(const Duration(minutes: 18)),
    _ManualQaMoment.revealed => _baseStart.add(const Duration(minutes: 24)),
    _ManualQaMoment.postEvent => _baseStart.add(const Duration(hours: 2)),
  };

  EventSuccessAssignment? get viewerAssignment => assignments
      .where((assignment) => assignment.uid == viewer.uid)
      .firstOrNull;

  EventSuccessAssignment? get viewerRotationAssignment => rotationAssignments
      .where((assignment) => assignment.uid == viewer.uid)
      .firstOrNull;

  List<PublicProfile> get assignmentPeerProfiles =>
      _profilesFor(viewerAssignment?.peerUids ?? const []);

  List<PublicProfile> get rotationPeerProfiles =>
      _profilesFor(viewerRotationAssignment?.peerUids ?? const []);

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

  Event _eventForScenario() {
    return Event(
      id: 'event-success-manual-qa',
      clubId: 'club-event-success-manual-qa',
      startTime: _baseStart,
      endTime: _baseStart.add(const Duration(minutes: 90)),
      meetingPoint: scenario.meetingPoint,
      eventFormat: EventFormatSnapshot.fromActivityKind(scenario.activityKind),
      distanceKm: scenario.activityKind.isDistanceBased ? 5 : 0,
      pace: PaceLevel.easy,
      capacityLimit: scenario.targetCount,
      description: 'Manual QA fixture for event-success host and attendee UI.',
      priceInPaise: 0,
      bookedCount: 8,
      checkedInCount: 5,
      waitlistedCount: 1,
      genderCounts: const {'man': 4, 'woman': 4},
    );
  }

  EventParticipation _participation() {
    final attended = moment != _ManualQaMoment.booked;
    return EventParticipation(
      id: eventParticipationId(eventId: event.id, uid: viewer.uid),
      eventId: event.id,
      clubId: event.clubId,
      uid: viewer.uid,
      status: attended
          ? EventParticipationStatus.attended
          : EventParticipationStatus.signedUp,
      createdAt: _createdAt,
      updatedAt: now,
      signedUpAt: _createdAt,
      attendedAt: attended ? event.startTime : null,
      genderAtSignup: viewer.gender,
      cohortAtSignup: 'womenInterestedInMen',
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
    if (moment == _ManualQaMoment.booked ||
        moment == _ManualQaMoment.checkedIn ||
        moment == _ManualQaMoment.postEvent) {
      return null;
    }
    return EventSuccessCompatibilityResponse(
      id: eventSuccessCompatibilityResponseId(
        eventId: event.id,
        uid: viewer.uid,
      ),
      eventId: event.id,
      clubId: event.clubId,
      uid: viewer.uid,
      answerIds: const [
        'event_energy_playful_competition',
        'first_conversation_question',
        'shared_connection_ideas',
        'after_event_activity',
      ],
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
      preferredDistances: const [PreferredDistance.fiveK],
      runningReasons: const [RunReason.social],
      preferredRunTimes: const [PreferredRunTime.evening],
      runPreferencesVersion: currentRunPreferencesVersion,
    );
  }

  List<PublicProfile> _publicProfiles() {
    return const [
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
    ];
  }

  List<PublicProfile> _profilesFor(List<String> uids) {
    final wanted = uids.toSet();
    return profiles
        .where((profile) => wanted.contains(profile.uid))
        .toList(growable: false);
  }

  EventSuccessPlanStatus get _planStatus => switch (moment) {
    _ManualQaMoment.booked => EventSuccessPlanStatus.setup,
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
    EventSuccessRevealStatus.countingDown => now.subtract(
      const Duration(seconds: 5),
    ),
    EventSuccessRevealStatus.revealed => now.subtract(
      const Duration(minutes: 1),
    ),
    EventSuccessRevealStatus.idle => null,
  };

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

Set<String> _selectedModuleIds(
  EventSuccessPlaybook playbook, {
  required bool compatibilityEnabled,
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
  return ids;
}
