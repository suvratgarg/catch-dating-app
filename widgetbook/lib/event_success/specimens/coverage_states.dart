import 'package:catch_dating_app/design_fixtures/event_success_companion_fixtures.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_host_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_reveal_card.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class HostCoverageStates extends StatelessWidget {
  const HostCoverageStates({super.key});

  @override
  Widget build(BuildContext context) {
    final event = EventSuccessCompanionFixtures.socialEvent;
    final plan = EventSuccessCompanionFixtures.revealUnlockedPlan;
    final roster = EventParticipationRoster.fromParticipations([
      EventSuccessCompanionFixtures.attendedParticipation(),
    ]);
    final actions = EventSuccessHostFixtureActions(
      onSaveSetup: () {},
      onPreviousStep: () {},
      onNextStep: () {},
      onCompletePlan: () {},
      onGenerateMicroPods: () {},
      onGenerateGuidedRotations: () {},
      onOverrideGroupAssignments: (_) {},
      onOverrideGuidedRotations: (_) {},
      onStartRevealCountdown: (_, _) {},
      onRevealRound: (_) {},
      onResetReveal: () {},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EventSuccessHostSectionSkeleton(),
        gapH16,
        for (final tab in EventSuccessHostTab.values) ...[
          EventSuccessHostPanel(
            event: event,
            plan: plan,
            planIsPersisted: true,
            roster: roster,
            assignments: [
              EventSuccessCompanionFixtures.microPodAssignment,
              EventSuccessCompanionFixtures.tableAssignment,
            ],
            assignmentParticipantProfiles: EventSuccessCompanionFixtures.peers,
            rotationAssignments: [
              EventSuccessCompanionFixtures.rotationAssignment,
            ],
            rotationParticipantProfiles: EventSuccessCompanionFixtures.peers,
            wingmanRequests: [EventSuccessCompanionFixtures.wingmanRequest],
            wingmanProfiles: const [EventSuccessCompanionFixtures.peer],
            initialTab: tab,
            showTabs: false,
            fixtureActions: actions,
          ),
          if (tab != EventSuccessHostTab.values.last) gapH16,
        ],
      ],
    );
  }
}

class LiveRevealCoverageStates extends StatelessWidget {
  const LiveRevealCoverageStates({super.key});

  @override
  Widget build(BuildContext context) {
    final event = EventSuccessCompanionFixtures.racketEvent;
    final plan = EventSuccessCompanionFixtures.revealCountingDownPlan;
    final now = EventSuccessCompanionFixtures.racketStart.subtract(
      const Duration(seconds: 1),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EventSuccessLiveRevealHostCard(
          event: event,
          plan: plan,
          podAssignments: const [],
          rotationAssignments: [
            EventSuccessCompanionFixtures.rotationAssignment,
          ],
          preferences: const [],
          participantProfiles: EventSuccessCompanionFixtures.peers,
          now: now,
          onStartCountdown: (_, _) async {},
          onRevealRound: (_) async {},
          onResetReveal: () async {},
        ),
        gapH16,
        EventSuccessLiveRevealAttendeeCard(
          event: event,
          plan: EventSuccessCompanionFixtures.revealUnlockedPlan,
          kind: EventSuccessRevealAssignmentKind.rotations,
          assignment: EventSuccessCompanionFixtures.rotationAssignment,
          peerProfiles: const [EventSuccessCompanionFixtures.peer],
          peersLoading: false,
          optedOut: false,
          onIncludeChanged: (_) {},
          now: now,
        ),
      ],
    );
  }
}
