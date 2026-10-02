import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event_viewer_state.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_cta.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'event_viewer_state_fixtures.dart';
import 'events_test_helpers.dart';

void main() {
  testWidgets('unresolved current facts never fall back to local approval', (
    tester,
  ) async {
    final pending = Completer<EventViewerState>();
    await pumpEventsTestApp(
      tester,
      Scaffold(
        bottomNavigationBar: EventDetailCta(
          event: buildEvent(),
          userProfile: buildUser(),
          clubId: 'club-1',
          participation: null,
          isClubMember: true,
        ),
      ),
      overrides: [
        eventPaidBookingSupportProvider('INR').overrideWithValue(true),
        eventViewerStateProvider(
          'event-1',
          'runner-1',
        ).overrideWith((ref) => pending.future),
      ],
    );
    expect(
      tester.widget<EventBookingDock>(find.byType(EventBookingDock)).isLoading,
      isTrue,
    );
    expect(
      tester.widget<CatchButton>(find.byType(CatchButton)).onPressed,
      isNull,
    );
    pending.complete(
      viewerFixture(
        reason: 'membershipRequired',
        membership: 'revoked',
        review: 'approved',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Members only'), findsOneWidget);
    expect(
      tester.widget<CatchButton>(find.byType(CatchButton)).onPressed,
      isNull,
    );
  });

  testWidgets('failed viewer reads expose retry rather than booking', (
    tester,
  ) async {
    await pumpEventsTestApp(
      tester,
      Scaffold(
        bottomNavigationBar: EventDetailCta(
          event: buildEvent(),
          userProfile: buildUser(),
          clubId: 'club-1',
          participation: null,
        ),
      ),
      overrides: [
        eventPaidBookingSupportProvider('INR').overrideWithValue(true),
        eventViewerStateProvider('event-1', 'runner-1').overrideWith(
          (ref) async => throw StateError('Synthetic unavailable read'),
        ),
      ],
    );
    await tester.pump();
    expect(find.text('Retry booking availability'), findsOneWidget);
    expect(find.text('Join event — 20 spots left'), findsNothing);
  });

  testWidgets('an old profile cannot consume another account viewer state', (
    tester,
  ) async {
    await pumpEventsTestApp(
      tester,
      Scaffold(
        bottomNavigationBar: EventDetailCta(
          event: buildEvent(),
          userProfile: buildUser(),
          clubId: 'club-1',
          participation: null,
        ),
      ),
      signedInUid: 'runner-2',
      overrides: [
        eventPaidBookingSupportProvider('INR').overrideWithValue(true),
        eventViewerStateProvider(
          'event-1',
          'runner-2',
        ).overrideWith((ref) async => viewerFixture()),
      ],
    );
    await tester.pump();
    expect(find.text('Join event — 20 spots left'), findsNothing);
    expect(
      tester.widget<CatchButton>(find.byType(CatchButton)).onPressed,
      isNull,
    );
  });

  test(
    'a foreign local account key fails before reading the repository',
    () async {
      final repository = _ViewerRepository();
      final container = ProviderContainer(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('runner-2')),
          eventRepositoryProvider.overrideWithValue(repository),
        ],
        retry: (count, error) => null,
      );
      addTearDown(container.dispose);
      final auth = container.listen(uidProvider, (_, _) {});
      addTearDown(auth.close);
      await container.read(uidProvider.future);
      final viewer = eventViewerStateProvider('event-1', 'runner-1');
      final subscription = container.listen(viewer, (_, _) {});
      addTearDown(subscription.close);
      await expectLater(container.read(viewer.future), throwsStateError);
      expect(repository.reads, 0);
    },
  );
}

class _ViewerRepository extends FakeEventRepository {
  int reads = 0;
  @override
  Future<EventViewerState> fetchViewerState({
    required String eventId,
    String? inviteCode,
    String? publicPaymentId,
  }) async {
    reads++;
    return viewerFixture(eventId: eventId);
  }
}
