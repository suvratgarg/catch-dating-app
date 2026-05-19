import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_companion_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_host_screen.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart'
    show buildEvent, buildEventParticipation, buildPublicProfile, buildUser;

void main() {
  testWidgets('host screen exposes setup live mode and report tabs', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 3000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final event = buildEvent(bookedCount: 10, checkedInCount: 6);
    final plan = EventSuccessPlan.defaultForEvent(event);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EventSuccessHostPanel(
                  event: event,
                  plan: plan,
                  planIsPersisted: true,
                  roster: const EventParticipationRoster(
                    bookedIds: ['a', 'b', 'c'],
                    checkedInIds: ['a', 'b'],
                    waitlistedIds: [],
                  ),
                  feedback: const [],
                  embedded: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Setup'), findsWidgets);
    expect(find.text('Target attendees'), findsOneWidget);
    expect(find.text('Host goal'), findsOneWidget);
    expect(find.text('Attendee prompt'), findsOneWidget);
    expect(find.text('Private follow-up'), findsOneWidget);
    expect(find.text('Contextual openers'), findsWidgets);
    expect(find.text('Save setup'), findsOneWidget);

    await tester.tap(find.text('Live'));
    await tester.pumpAndSettle();
    expect(find.text('Live host mode'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    expect(find.text('Post-event host report'), findsOneWidget);
  });

  testWidgets(
    'companion screen shows private follow-up and feedback after attendance',
    (tester) async {
      final firestore = FakeFirebaseFirestore();
      final start = DateTime(2026, 5, 18, 7);
      final event = buildEvent(
        startTime: start,
        endTime: start.add(const Duration(hours: 1)),
      );
      final plan = EventSuccessPlan.defaultForEvent(event);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            eventSuccessRepositoryProvider.overrideWithValue(
              EventSuccessRepository(
                firestore,
                EventParticipationRepository(firestore),
                PublicProfileRepository(firestore),
                SwipeRepository(firestore),
              ),
            ),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              ref.watch(uidProvider);
              return MaterialApp(
                theme: AppTheme.light,
                home: EventSuccessCompanionScreen(
                  event: event,
                  plan: plan,
                  userProfile: buildUser(uid: 'runner-1'),
                  participation: buildEventParticipation(
                    event: event,
                    uid: 'runner-1',
                    status: EventParticipationStatus.attended,
                  ),
                  privateCrushCandidates: [
                    buildPublicProfile(uid: 'runner-2', name: 'Rhea'),
                  ],
                  now: start.add(const Duration(hours: 2)),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Event companion'), findsOneWidget);
      expect(find.text('Social prompt'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Private follow-up'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Rhea'), findsOneWidget);
      await tester.tap(find.text('Mark'));
      await tester.pumpAndSettle();
      expect(find.text('Marked'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Event feedback'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Submit feedback'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Submit feedback'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -180));
      await tester.pump();
      await tester.tap(find.text('Submit feedback'));
      await tester.pumpAndSettle();

      final feedback = await firestore
          .collection('eventSuccessFeedback')
          .doc('event-1_runner-1')
          .get();
      expect(feedback.data()?['markedPrivateCrush'], isTrue);
    },
  );

  testWidgets('companion route is unavailable until host saves setup', (
    tester,
  ) async {
    final event = buildEvent(id: 'event-no-plan');
    final participation = buildEventParticipation(
      event: event,
      uid: 'runner-1',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          watchEventProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(event)),
          watchUserProfileProvider.overrideWith(
            (ref) => Stream.value(buildUser(uid: 'runner-1')),
          ),
          watchEventParticipationProvider(
            event.id,
            'runner-1',
          ).overrideWith((ref) => Stream.value(participation)),
          watchEventSuccessPlanProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(null)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventSuccessCompanionRouteScreen(
            clubId: event.clubId,
            eventId: event.id,
            initialEvent: event,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Companion not available'), findsOneWidget);
    expect(
      find.text(
        'The host has not enabled event companion tools for this event yet.',
      ),
      findsOneWidget,
    );
    expect(find.text('Social prompt'), findsNothing);
  });
}
