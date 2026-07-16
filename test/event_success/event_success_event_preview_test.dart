import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/event_success/domain/event_success_event_preview.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_event_preview_screen.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart'
    show buildClub, buildEvent, buildUser;
import '../test_pump_helpers.dart';

void main() {
  test('maps a real event into the Social Event Lite preview context', () {
    final start = DateTime(2026, 5, 17, 7);
    final event = buildEvent(
      capacityLimit: 28,
      bookedCount: 18,
      checkedInCount: 9,
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
    );

    final preview = EventSuccessEventPreview.fromEvent(
      event: event,
      club: buildClub(name: 'Sunday Strides'),
      now: start.add(const Duration(minutes: 14)),
    );

    expect(preview.playbook.title, 'Social Event Lite');
    expect(preview.hostDraft.targetAttendeeCount, 28);
    expect(preview.livePlan.bookedCount, 18);
    expect(preview.livePlan.checkedInCount, 9);
    expect(preview.livePlan.activeStep.title, 'Run in pace pods');
    expect(preview.attendeeState.eventTitle, event.title);
    expect(preview.integrationNotes, isNotEmpty);
  });

  test('prefers loaded roster counts over denormalized event counts', () {
    final event = buildEvent(bookedCount: 1, checkedInCount: 0);
    const roster = EventParticipationRoster(
      bookedIds: ['a', 'b', 'c'],
      checkedInIds: ['a', 'b'],
      waitlistedIds: ['d'],
    );

    final preview = EventSuccessEventPreview.fromEvent(
      event: event,
      roster: roster,
      now: DateTime(2026, 5, 17, 7, 20),
    );

    expect(preview.livePlan.bookedCount, 3);
    expect(preview.livePlan.checkedInCount, 2);
    expect(preview.scorecard.bookedCount, 3);
    expect(preview.scorecard.checkedInCount, 2);
  });

  test('uses format primitives instead of raw open activity in preview', () {
    final event = buildEvent(
      capacityLimit: 40,
      eventFormat: const EventFormatSnapshot(
        activityKind: ActivityKind.openActivity,
        interactionModel: EventInteractionModel.openFormat,
        customActivityLabel: 'Trivia night',
        eventSuccessPrimitives: {
          'assignmentAlgorithm': 'teamBalancer',
          'rotationSuitability': 'plannedBreaks',
          'compatibilityPolicy': 'questionnaireClueOnly',
        },
      ),
    );

    final preview = EventSuccessEventPreview.fromEvent(
      event: event,
      now: DateTime(2026, 5, 17, 7, 20),
    );

    expect(preview.playbook.id, EventSuccessPlaybookLibrary.pubQuiz.id);
    expect(
      preview.hostDraft.structureConfig.unitKind,
      EventSuccessUnitKind.teams,
    );
    expect(preview.attendeeState.podLabel, 'Team rotations');
    expect(
      preview.attendeeState.prompt,
      'Find someone on your team and ask what brought them here.',
    );
  });

  testWidgets('renders the contextual event preview blocks', (tester) async {
    final start = DateTime(2026, 5, 17, 7);
    final event = buildEvent(
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
      bookedCount: 12,
      checkedInCount: 8,
    );

    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 2200);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: EventSuccessEventPreviewScreen(
          event: event,
          club: buildClub(name: 'Sunday Strides'),
          userProfile: buildUser(firstName: 'Aarav'),
          now: start.add(const Duration(minutes: 5)),
        ),
      ),
    );

    expect(find.text('Event success preview'), findsOneWidget);
    expect(find.text('Sunday Strides · Social Event Lite'), findsOneWidget);
    expect(find.text('How this maps to the live app'), findsOneWidget);
    expect(find.text('Host setup flow'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Live host mode'),
      700,
      scrollable: findPrimaryScrollable(),
    );
    expect(find.text('Live host mode'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Attendee companion'),
      700,
      scrollable: findPrimaryScrollable(),
    );
    expect(find.text('Attendee companion'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Post-event host report'),
      700,
      scrollable: findPrimaryScrollable(),
    );
    expect(find.text('Post-event host report'), findsOneWidget);
  });

  testWidgets('route renders preview-shaped skeleton while event loads', (
    tester,
  ) async {
    final event = buildEvent(id: 'event-preview-loading');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchEventProvider(
            event.id,
          ).overrideWithValue(const AsyncLoading<Event?>()),
          fetchClubProvider(
            event.clubId,
          ).overrideWithValue(const AsyncData<Club?>(null)),
          watchEventParticipationRosterProvider(
            event.id,
          ).overrideWithValue(AsyncData(EventParticipationRoster.empty())),
          watchUserProfileProvider.overrideWithValue(
            const AsyncData<UserProfile?>(null),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventSuccessEventPreviewRouteScreen(
            clubId: event.clubId,
            eventId: event.id,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(EventSuccessEventPreviewLoadingScreen), findsOneWidget);
    expect(find.byType(CatchSkeleton), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
