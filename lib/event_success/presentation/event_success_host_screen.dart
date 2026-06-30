import 'dart:async';
import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_number_stepper.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_activity_profile.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_conversation_cue.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_preference.dart';
import 'package:catch_dating_app/event_success/domain/event_success_runtime.dart';
import 'package:catch_dating_app/event_success/domain/event_success_wingman_request.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_controller.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_feature_blocks.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_effects_controller.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_reveal_card.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_setup_body.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/domain/event_check_in_qr_payload.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

part 'host_parts/event_success_host_live.dart';
part 'host_parts/event_success_host_overrides.dart';
part 'host_parts/event_success_host_report.dart';
part 'host_parts/event_success_host_setup.dart';
part 'host_parts/event_success_host_shared.dart';

const EdgeInsets _hostTabPickerPadding = EdgeInsets.fromLTRB(
  CatchSpacing.s5,
  CatchSpacing.s4,
  CatchSpacing.s5,
  CatchSpacing.s2,
);
const EdgeInsets _hostLaunchIssueGap = EdgeInsets.only(bottom: CatchSpacing.s1);
const EdgeInsets _hostWingmanRequestGap = EdgeInsets.only(
  bottom: CatchSpacing.s2,
);
const EdgeInsets _hostWingmanRequestNotePadding = EdgeInsets.only(
  left: CatchSpacing.s5,
  right: CatchSpacing.s5,
  bottom: CatchSpacing.s2,
);

enum EventSuccessHostTab { setup, live, report }

class EventSuccessHostSection extends ConsumerWidget {
  const EventSuccessHostSection({
    super.key,
    required this.event,
    this.initialTab = EventSuccessHostTab.setup,
    this.showTabs = true,
    this.liveRoster,
    this.compactLiveControls = false,
    this.fixtureActions,
  });

  final Event event;
  final EventSuccessHostTab initialTab;
  final bool showTabs;
  final Widget? liveRoster;
  final bool compactLiveControls;
  final EventSuccessHostFixtureActions? fixtureActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(watchEventSuccessPlanProvider(event.id));
    if (planAsync.isLoading) {
      return EventSuccessHostSectionSkeleton(
        initialTab: initialTab,
        showTabs: showTabs,
      );
    }
    if (planAsync.hasError) {
      return CatchInlineErrorState.fromError(
        planAsync.error!,
        context: AppErrorContext.event,
        onRetry: () => ref.invalidate(watchEventSuccessPlanProvider(event.id)),
      );
    }

    final persistedPlan = planAsync.asData?.value;
    final plan = persistedPlan ?? EventSuccessPlan.defaultForEvent(event);
    final hasSavedGuide = persistedPlan != null;
    final shouldLoadRoster =
        hasSavedGuide && (showTabs || initialTab == EventSuccessHostTab.live);
    final shouldLoadScorecard =
        hasSavedGuide && (showTabs || initialTab == EventSuccessHostTab.report);
    final shouldLoadAssignments =
        hasSavedGuide && (showTabs || initialTab == EventSuccessHostTab.live);
    final shouldLoadPreferences = shouldLoadAssignments;
    final shouldLoadWingmanRequests = shouldLoadAssignments;
    final AsyncValue<EventParticipationRoster> rosterAsync = shouldLoadRoster
        ? ref.watch(watchEventParticipationRosterProvider(event.id))
        : AsyncData(EventParticipationRoster.empty());
    final AsyncValue<EventSuccessScorecard?> scorecardAsync =
        shouldLoadScorecard
        ? ref.watch(watchEventSuccessScorecardProvider(event.id))
        : const AsyncData<EventSuccessScorecard?>(null);
    final AsyncValue<List<EventSuccessAssignment>> assignmentsAsync =
        shouldLoadAssignments
        ? ref.watch(watchEventSuccessAssignmentsProvider(event.id))
        : const AsyncData(<EventSuccessAssignment>[]);
    final assignmentsPreview =
        assignmentsAsync.asData?.value ?? const <EventSuccessAssignment>[];
    final assignmentParticipantUidsKey = eventSuccessPeerUidsKey(
      _rotationParticipantUids(assignmentsPreview),
    );
    final AsyncValue<List<PublicProfile>> assignmentParticipantProfilesAsync =
        shouldLoadAssignments && assignmentParticipantUidsKey.isNotEmpty
        ? ref.watch(
            eventSuccessAssignmentPeerProfilesProvider(
              assignmentParticipantUidsKey,
            ),
          )
        : const AsyncData(<PublicProfile>[]);
    final AsyncValue<List<EventSuccessAssignment>> rotationAssignmentsAsync =
        shouldLoadAssignments
        ? ref.watch(watchEventSuccessRotationAssignmentsProvider(event.id))
        : const AsyncData(<EventSuccessAssignment>[]);
    final rotationAssignmentsPreview =
        rotationAssignmentsAsync.asData?.value ??
        const <EventSuccessAssignment>[];
    final rotationParticipantUidsKey = eventSuccessPeerUidsKey(
      _rotationParticipantUids(rotationAssignmentsPreview),
    );
    final AsyncValue<List<PublicProfile>> rotationParticipantProfilesAsync =
        shouldLoadAssignments && rotationParticipantUidsKey.isNotEmpty
        ? ref.watch(
            eventSuccessAssignmentPeerProfilesProvider(
              rotationParticipantUidsKey,
            ),
          )
        : const AsyncData(<PublicProfile>[]);
    final AsyncValue<List<EventSuccessPreference>> preferencesAsync =
        shouldLoadPreferences
        ? ref.watch(watchEventSuccessPreferencesProvider(event.id))
        : const AsyncData(<EventSuccessPreference>[]);
    final AsyncValue<List<EventSuccessWingmanRequest>> wingmanRequestsAsync =
        shouldLoadWingmanRequests
        ? ref.watch(watchEventSuccessWingmanRequestsProvider(event.id))
        : const AsyncData(<EventSuccessWingmanRequest>[]);
    final wingmanProfilesKey = eventSuccessPeerUidsKey(
      _wingmanRequestProfileUids(
        wingmanRequestsAsync.asData?.value ??
            const <EventSuccessWingmanRequest>[],
      ),
    );
    final AsyncValue<List<PublicProfile>> wingmanProfilesAsync =
        shouldLoadWingmanRequests && wingmanProfilesKey.isNotEmpty
        ? ref.watch(
            eventSuccessAssignmentPeerProfilesProvider(wingmanProfilesKey),
          )
        : const AsyncData(<PublicProfile>[]);

    if (rosterAsync.isLoading ||
        scorecardAsync.isLoading ||
        assignmentsAsync.isLoading ||
        assignmentParticipantProfilesAsync.isLoading ||
        rotationAssignmentsAsync.isLoading ||
        rotationParticipantProfilesAsync.isLoading ||
        preferencesAsync.isLoading ||
        wingmanRequestsAsync.isLoading ||
        wingmanProfilesAsync.isLoading) {
      return EventSuccessHostSectionSkeleton(
        initialTab: initialTab,
        showTabs: showTabs,
      );
    }
    if (rosterAsync.hasError) {
      return CatchInlineErrorState.fromError(
        rosterAsync.error!,
        context: AppErrorContext.event,
        onRetry: () =>
            ref.invalidate(watchEventParticipationRosterProvider(event.id)),
      );
    }
    if (assignmentsAsync.hasError) {
      return CatchInlineErrorState.fromError(
        assignmentsAsync.error!,
        context: AppErrorContext.event,
        onRetry: () =>
            ref.invalidate(watchEventSuccessAssignmentsProvider(event.id)),
      );
    }
    if (rotationAssignmentsAsync.hasError) {
      return CatchInlineErrorState.fromError(
        rotationAssignmentsAsync.error!,
        context: AppErrorContext.event,
        onRetry: () => ref.invalidate(
          watchEventSuccessRotationAssignmentsProvider(event.id),
        ),
      );
    }
    if (assignmentParticipantProfilesAsync.hasError) {
      return CatchInlineErrorState.fromError(
        assignmentParticipantProfilesAsync.error!,
        context: AppErrorContext.profile,
        onRetry: () => ref.invalidate(
          eventSuccessAssignmentPeerProfilesProvider(
            assignmentParticipantUidsKey,
          ),
        ),
      );
    }
    if (rotationParticipantProfilesAsync.hasError) {
      return CatchInlineErrorState.fromError(
        rotationParticipantProfilesAsync.error!,
        context: AppErrorContext.profile,
        onRetry: () => ref.invalidate(
          eventSuccessAssignmentPeerProfilesProvider(
            rotationParticipantUidsKey,
          ),
        ),
      );
    }
    if (preferencesAsync.hasError) {
      return CatchInlineErrorState.fromError(
        preferencesAsync.error!,
        context: AppErrorContext.event,
        onRetry: () =>
            ref.invalidate(watchEventSuccessPreferencesProvider(event.id)),
      );
    }
    if (wingmanRequestsAsync.hasError) {
      return CatchInlineErrorState.fromError(
        wingmanRequestsAsync.error!,
        context: AppErrorContext.event,
        onRetry: () =>
            ref.invalidate(watchEventSuccessWingmanRequestsProvider(event.id)),
      );
    }
    if (wingmanProfilesAsync.hasError) {
      return CatchInlineErrorState.fromError(
        wingmanProfilesAsync.error!,
        context: AppErrorContext.profile,
        onRetry: () => ref.invalidate(
          eventSuccessAssignmentPeerProfilesProvider(wingmanProfilesKey),
        ),
      );
    }
    if (scorecardAsync.hasError) {
      return CatchInlineErrorState.fromError(
        scorecardAsync.error!,
        context: AppErrorContext.event,
        onRetry: () =>
            ref.invalidate(watchEventSuccessScorecardProvider(event.id)),
      );
    }

    final roster =
        rosterAsync.asData?.value ?? EventParticipationRoster.empty();
    final scorecard = scorecardAsync.asData?.value;
    final assignments =
        assignmentsAsync.asData?.value ?? const <EventSuccessAssignment>[];
    final assignmentParticipantProfiles =
        assignmentParticipantProfilesAsync.asData?.value ??
        const <PublicProfile>[];
    final rotationAssignments =
        rotationAssignmentsAsync.asData?.value ??
        const <EventSuccessAssignment>[];
    final rotationParticipantProfiles =
        rotationParticipantProfilesAsync.asData?.value ??
        const <PublicProfile>[];
    final preferences =
        preferencesAsync.asData?.value ?? const <EventSuccessPreference>[];
    final wingmanRequests =
        wingmanRequestsAsync.asData?.value ??
        const <EventSuccessWingmanRequest>[];
    final wingmanProfiles =
        wingmanProfilesAsync.asData?.value ?? const <PublicProfile>[];

    return EventSuccessHostPanel(
      event: event,
      plan: plan,
      planIsPersisted: persistedPlan != null,
      roster: roster,
      scorecard: scorecard,
      assignments: assignments,
      assignmentParticipantProfiles: assignmentParticipantProfiles,
      rotationAssignments: rotationAssignments,
      rotationParticipantProfiles: rotationParticipantProfiles,
      preferences: preferences,
      wingmanRequests: wingmanRequests,
      wingmanProfiles: wingmanProfiles,
      initialTab: initialTab,
      showTabs: showTabs,
      liveRoster: liveRoster,
      compactLiveControls: compactLiveControls,
      fixtureActions: fixtureActions,
    );
  }
}

class EventSuccessHostSectionSkeleton extends StatelessWidget {
  const EventSuccessHostSectionSkeleton({
    super.key,
    this.initialTab = EventSuccessHostTab.setup,
    this.showTabs = true,
  });

  final EventSuccessHostTab initialTab;
  final bool showTabs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTabs) ...[const EventSuccessTabPickerSkeleton(), gapH16],
        switch (initialTab) {
          EventSuccessHostTab.setup => const EventSuccessSetupTabSkeleton(),
          EventSuccessHostTab.live => const EventSuccessLiveTabSkeleton(),
          EventSuccessHostTab.report => const EventSuccessReportTabSkeleton(),
        },
      ],
    );
  }
}

class EventSuccessTabPickerSkeleton extends StatelessWidget {
  const EventSuccessTabPickerSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(
            child: CatchSkeleton.box(
              height: CatchLayout.controlCompactMinHeight,
              radius: CatchRadius.sm,
            ),
          ),
          if (i < 2) gapW8,
        ],
      ],
    );
  }
}

class EventSuccessSetupTabSkeleton extends StatelessWidget {
  const EventSuccessSetupTabSkeleton();

  @override
  Widget build(BuildContext context) {
    return const CatchSectionStack(
      padding: EdgeInsets.zero,
      gap: CatchSpacing.s3,
      children: [
        EventSuccessSkeletonSurface(
          titleWidth: 170,
          textLines: 3,
          trailingChips: 3,
        ),
        EventSuccessSetupControlsSkeleton(),
        EventSuccessSkeletonSurface(
          titleWidth: 150,
          textLines: 2,
          trailingChips: 2,
        ),
      ],
    );
  }
}

class EventSuccessLiveTabSkeleton extends StatelessWidget {
  const EventSuccessLiveTabSkeleton();

  @override
  Widget build(BuildContext context) {
    return const CatchSectionStack(
      padding: EdgeInsets.zero,
      gap: CatchSpacing.s3,
      children: [
        EventSuccessSkeletonSurface(
          titleWidth: 148,
          textLines: 2,
          trailingChips: 2,
        ),
        EventSuccessLiveRosterSkeleton(),
        EventSuccessSkeletonSurface(
          titleWidth: 190,
          textLines: 3,
          trailingChips: 0,
        ),
      ],
    );
  }
}

class EventSuccessReportTabSkeleton extends StatelessWidget {
  const EventSuccessReportTabSkeleton();

  @override
  Widget build(BuildContext context) {
    return const CatchSectionStack(
      padding: EdgeInsets.zero,
      gap: CatchSpacing.s3,
      children: [
        EventSuccessReportMetricsSkeleton(),
        EventSuccessSkeletonSurface(
          titleWidth: 180,
          textLines: 3,
          trailingChips: 2,
        ),
        EventSuccessSkeletonSurface(
          titleWidth: 140,
          textLines: 2,
          trailingChips: 0,
        ),
      ],
    );
  }
}

class EventSuccessSkeletonSurface extends StatelessWidget {
  const EventSuccessSkeletonSurface({
    required this.titleWidth,
    required this.textLines,
    required this.trailingChips,
  });

  final double titleWidth;
  final int textLines;
  final int trailingChips;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: titleWidth),
          gapH12,
          CatchSkeleton.textBlock(lines: textLines),
          if (trailingChips > 0) ...[
            gapH16,
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                for (var i = 0; i < trailingChips; i++)
                  CatchSkeleton.box(
                    width: i == 0 ? 104 : 86,
                    height: CatchLayout.badgeActionHeight,
                    radius: CatchRadius.pill,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class EventSuccessSetupControlsSkeleton extends StatelessWidget {
  const EventSuccessSetupControlsSkeleton();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        children: [
          for (var i = 0; i < 4; i++) ...[
            Row(
              children: [
                CatchSkeleton.box(
                  width: CatchLayout.toggleTrackWidth,
                  height: CatchLayout.toggleTrackHeight,
                  radius: CatchRadius.pill,
                ),
                gapW12,
                Expanded(child: CatchSkeleton.text()),
              ],
            ),
            if (i < 3) gapH14,
          ],
        ],
      ),
    );
  }
}

class EventSuccessLiveRosterSkeleton extends StatelessWidget {
  const EventSuccessLiveRosterSkeleton();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
          gapH14,
          for (var i = 0; i < 3; i++) ...[
            Row(
              children: [
                CatchSkeleton.circle(
                  size: CatchLayout.skeletonAvatarCompactExtent,
                ),
                gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CatchSkeleton.text(
                        width: i == 0
                            ? CatchLayout.skeletonTextTertiaryWidth
                            : CatchLayout.skeletonTextCompactWidth,
                      ),
                      gapH6,
                      CatchSkeleton.text(
                        width: i == 2
                            ? CatchLayout.skeletonTextDetailWideWidth
                            : CatchLayout.skeletonTextBodyLongWidth,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (i < 2) gapH16,
          ],
        ],
      ),
    );
  }
}

class EventSuccessReportMetricsSkeleton extends StatelessWidget {
  const EventSuccessReportMetricsSkeleton();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: CatchLayout.skeletonTextSectionWideWidth),
          gapH14,
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CatchSkeleton.text(
                        width: CatchLayout.skeletonTextValueWidth,
                      ),
                      gapH8,
                      CatchSkeleton.text(
                        width: CatchLayout.skeletonTextStatusWidth,
                      ),
                    ],
                  ),
                ),
                if (i < 2) gapW12,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class EventSuccessHostPanel extends StatefulWidget {
  const EventSuccessHostPanel({
    super.key,
    required this.event,
    required this.plan,
    required this.planIsPersisted,
    required this.roster,
    this.scorecard,
    this.assignments = const [],
    this.assignmentParticipantProfiles = const [],
    this.rotationAssignments = const [],
    this.rotationParticipantProfiles = const [],
    this.preferences = const [],
    this.wingmanRequests = const [],
    this.wingmanProfiles = const [],
    this.initialTab = EventSuccessHostTab.setup,
    this.showTabs = true,
    this.embedded = true,
    this.liveRoster,
    this.compactLiveControls = false,
    this.fixtureActions,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool planIsPersisted;
  final EventParticipationRoster roster;
  final EventSuccessScorecard? scorecard;
  final List<EventSuccessAssignment> assignments;
  final List<PublicProfile> assignmentParticipantProfiles;
  final List<EventSuccessAssignment> rotationAssignments;
  final List<PublicProfile> rotationParticipantProfiles;
  final List<EventSuccessPreference> preferences;
  final List<EventSuccessWingmanRequest> wingmanRequests;
  final List<PublicProfile> wingmanProfiles;
  final EventSuccessHostTab initialTab;
  final bool showTabs;
  final bool embedded;
  final Widget? liveRoster;
  final bool compactLiveControls;
  final EventSuccessHostFixtureActions? fixtureActions;

  @override
  State<EventSuccessHostPanel> createState() => _EventSuccessHostPanelState();
}

class _EventSuccessHostPanelState extends State<EventSuccessHostPanel> {
  late EventSuccessHostTab _selectedTab = widget.initialTab;

  @override
  void didUpdateWidget(covariant EventSuccessHostPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _selectedTab = widget.initialTab;
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _selectedBody();
    if (!widget.showTabs) return body;

    final tabs = EventSuccessTabPicker(
      selectedTab: _selectedTab,
      onChanged: (tab) => setState(() => _selectedTab = tab),
    );

    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [tabs, gapH16, body],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(padding: _hostTabPickerPadding, child: tabs),
        Expanded(child: body),
      ],
    );
  }

  Widget _selectedBody() {
    final shrinkWrap = widget.embedded;
    final physics = widget.embedded
        ? const NeverScrollableScrollPhysics()
        : const AlwaysScrollableScrollPhysics();
    final padding = widget.embedded
        ? EdgeInsets.zero
        : CatchInsets.contentRelaxed;

    return switch (_selectedTab) {
      EventSuccessHostTab.setup => SetupTab(
        event: widget.event,
        plan: widget.plan,
        planIsPersisted: widget.planIsPersisted,
        fixtureActions: widget.fixtureActions,
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
      ),
      EventSuccessHostTab.live => LiveTab(
        event: widget.event,
        plan: widget.plan,
        planIsPersisted: widget.planIsPersisted,
        roster: widget.roster,
        assignments: widget.assignments,
        assignmentParticipantProfiles: widget.assignmentParticipantProfiles,
        rotationAssignments: widget.rotationAssignments,
        rotationParticipantProfiles: widget.rotationParticipantProfiles,
        preferences: widget.preferences,
        wingmanRequests: widget.wingmanRequests,
        wingmanProfiles: widget.wingmanProfiles,
        liveRoster: widget.liveRoster,
        compactLiveControls: widget.compactLiveControls,
        fixtureActions: widget.fixtureActions,
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
      ),
      EventSuccessHostTab.report => ReportTab(
        event: widget.event,
        plan: widget.plan,
        planIsPersisted: widget.planIsPersisted,
        scorecard: widget.scorecard,
        assignments: widget.assignments,
        rotationAssignments: widget.rotationAssignments,
        preferences: widget.preferences,
        wingmanRequests: widget.wingmanRequests,
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
      ),
    };
  }
}

class EventSuccessHostFixtureActions {
  const EventSuccessHostFixtureActions({
    this.onSaveSetup,
    this.onPreviousStep,
    this.onNextStep,
    this.onCompletePlan,
    this.onGenerateMicroPods,
    this.onOverrideGroupAssignments,
    this.onGenerateGuidedRotations,
    this.onOverrideGuidedRotations,
    this.onStartRevealCountdown,
    this.onRevealRound,
    this.onResetReveal,
  });

  final VoidCallback? onSaveSetup;
  final VoidCallback? onPreviousStep;
  final VoidCallback? onNextStep;
  final VoidCallback? onCompletePlan;
  final VoidCallback? onGenerateMicroPods;
  final ValueChanged<List<EventSuccessGroupOverrideRound>>?
  onOverrideGroupAssignments;
  final VoidCallback? onGenerateGuidedRotations;
  final ValueChanged<List<EventSuccessRotationOverrideRound>>?
  onOverrideGuidedRotations;
  final void Function(int roundIndex, int countdownSeconds)?
  onStartRevealCountdown;
  final ValueChanged<int>? onRevealRound;
  final VoidCallback? onResetReveal;
}
