// ignore_for_file: scoped_providers_should_specify_dependencies

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chats_list_view_model.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_screen.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_view_model.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../clubs/clubs_test_helpers.dart' as club_test;
import '../events/events_test_helpers.dart' as event_test;
import '../test_pump_helpers.dart';

void main() {
  final now = DateTime(2026, 7, 10, 18);

  setUp(() => AppConfig.configureEntrypointRole(AppRole.host));
  tearDown(AppConfig.resetEntrypointRoleOverrideForTesting);

  testWidgets('renders selected-event segments and roster-backed broadcast', (
    tester,
  ) async {
    final event = event_test.buildEvent(
      startTime: now.add(const Duration(hours: 1)),
      endTime: now.add(const Duration(hours: 2)),
    );
    final booked = _preview(
      uid: 'booked-1',
      name: 'Asha Guest',
      eventIds: [event.id],
    );
    final prospective = _preview(
      uid: 'waitlist-1',
      name: 'Mira Guest',
      eventIds: [event.id],
    );

    await tester.pumpWidget(
      _app(
        event: event,
        previews: [booked, prospective],
        participations: [
          event_test.buildEventParticipation(event: event, uid: 'booked-1'),
          event_test.buildEventParticipation(
            event: event,
            uid: 'waitlist-1',
            status: EventParticipationStatus.waitlisted,
            hostApprovalStatus: EventJoinRequestStatus.pending,
          ),
        ],
        now: now,
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Inbox'), findsOneWidget);
    expect(find.byType(HostInboxScopeSelector), findsOneWidget);
    expect(find.text('BOOKED · 1'), findsOneWidget);
    expect(find.text('PROSPECTIVE · 1'), findsOneWidget);
    expect(find.text('Message 1 booked attendee'), findsOneWidget);
    expect(find.text('Asha Guest'), findsOneWidget);
    expect(find.text('Booked · Can you help?'), findsOneWidget);
    expect(find.text('Mira Guest'), findsNothing);

    await tester.tap(find.text('PROSPECTIVE · 1'));
    await pumpFeatureUi(tester);

    expect(find.text('Message 1 prospective attendee'), findsOneWidget);
    expect(find.text('Mira Guest'), findsOneWidget);
    expect(find.text('Requested · Can you help?'), findsOneWidget);
    expect(find.text('Asha Guest'), findsNothing);
  });

  testWidgets('keeps broadcast card when roster exists without threads', (
    tester,
  ) async {
    final event = event_test.buildEvent(
      startTime: now.add(const Duration(hours: 1)),
      endTime: now.add(const Duration(hours: 2)),
    );

    await tester.pumpWidget(
      _app(
        event: event,
        previews: const [],
        participations: [
          event_test.buildEventParticipation(event: event, uid: 'booked-1'),
          event_test.buildEventParticipation(event: event, uid: 'booked-2'),
        ],
        now: now,
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Message 2 booked attendees'), findsOneWidget);
    expect(find.text('No booked attendees have written yet'), findsOneWidget);
    expect(
      find.textContaining(
        'Broadcast audience size is based on the event roster',
      ),
      findsOneWidget,
    );
  });

  testWidgets('compact scope label opens the shared event menu', (
    tester,
  ) async {
    final event = event_test.buildEvent(
      startTime: now.add(const Duration(hours: 1)),
      endTime: now.add(const Duration(hours: 2)),
    );

    await tester.pumpWidget(
      _app(
        event: event,
        previews: const [],
        participations: const [],
        now: now,
      ),
    );
    await pumpFeatureUi(tester);

    await tester.tap(find.bySemanticsLabel(RegExp('Inbox scope')));
    await tester.pumpAndSettle();

    expect(find.byType(CatchMenu<HostInboxScope>), findsOneWidget);
    expect(find.text('General inquiries'), findsOneWidget);

    await tester.tap(find.text('General inquiries'));
    await tester.pumpAndSettle();

    expect(find.text('GENERAL INQUIRIES'), findsOneWidget);
    expect(find.byType(HostInboxAudienceRail), findsNothing);
  });

  testWidgets('General scope excludes event-specific inquiries', (
    tester,
  ) async {
    final event = event_test.buildEvent(
      startTime: now.add(const Duration(hours: 1)),
      endTime: now.add(const Duration(hours: 2)),
    );
    final general = _preview(
      uid: 'general-1',
      name: 'General Guest',
      eventIds: const [],
    );
    final scoped = _preview(
      uid: 'event-1',
      name: 'Event Guest',
      eventIds: [event.id],
    );

    await tester.pumpWidget(
      _app(
        event: event,
        previews: [general, scoped],
        participations: const [],
        initialScope: const HostInboxScope.general(),
        now: now,
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('GENERAL INQUIRIES'), findsOneWidget);
    expect(find.text('General Guest'), findsOneWidget);
    expect(find.text('General inquiry · Can you help?'), findsOneWidget);
    expect(find.text('Event Guest'), findsNothing);
    expect(find.textContaining('Message '), findsNothing);
    expect(find.textContaining('Booked ·'), findsNothing);
  });

  testWidgets(
    'singleton general scope centers the canonical empty state without a header',
    (tester) async {
      await tester.pumpWidget(
        _app(
          event: null,
          previews: const [],
          participations: const [],
          now: now,
        ),
      );
      await pumpFeatureUi(tester);

      expect(find.byType(HostInboxScopeSelector), findsNothing);
      expect(find.text('GENERAL INQUIRIES'), findsNothing);
      expect(find.text('No general inquiries'), findsOneWidget);

      final emptyState = find.byType(CatchEmptyState);
      final content = find.byType(CatchEmptyStateContent);
      expect(
        find.ancestor(of: emptyState, matching: find.byType(Center)),
        findsNothing,
      );
      final fill = tester.widget<SliverFillRemaining>(
        find.ancestor(
          of: emptyState,
          matching: find.byType(SliverFillRemaining),
        ),
      );
      expect(fill.hasScrollBody, isTrue);
      expect(
        tester.getCenter(content).dx,
        closeTo(tester.getCenter(emptyState).dx, 0.5),
      );
      expect(
        tester.getCenter(content).dy,
        closeTo(tester.getCenter(emptyState).dy, 0.5),
      );
    },
  );
}

Widget _app({
  required Event? event,
  required List<ChatThreadPreview> previews,
  required List<EventParticipation> participations,
  required DateTime now,
  HostInboxScope? initialScope,
}) {
  final club = club_test.buildClub(id: event?.clubId ?? 'club-1');
  final inbox = ChatsListViewModel(
    newMatches: const [],
    conversations: previews,
    totalThreadCount: previews.length,
  );
  final eventsQuery = EventsForClubsQuery([club.id]);
  return ProviderScope(
    overrides: [
      uidProvider.overrideWith((ref) => Stream.value('host-1')),
      hostOperableClubsProvider('host-1').overrideWithValue(AsyncData([club])),
      watchEventsForClubsProvider(
        eventsQuery,
      ).overrideWith((ref) => Stream.value([?event])),
      chatsListViewModelProvider.overrideWithValue(AsyncData(inbox)),
      if (event != null)
        watchEventParticipationsForEventProvider(
          event.id,
        ).overrideWith((ref) => Stream.value(participations)),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: HostInboxScreen(
        initialScope: initialScope,
        syncSelectionToRoute: false,
        now: now,
      ),
    ),
  );
}

ChatThreadPreview _preview({
  required String uid,
  required String name,
  required List<String> eventIds,
}) {
  final match = Match(
    id: 'match-$uid',
    user1Id: uid,
    user2Id: 'host-1',
    eventIds: eventIds,
    createdAt: DateTime(2026, 7, 10),
    lastMessageAt: DateTime(2026, 7, 10, 17),
    lastMessagePreview: 'Can you help?',
    lastMessageSenderId: uid,
    conversationType: MatchConversationType.clubHostInquiry,
    clubId: 'club-1',
  );
  return ChatThreadPreview(
    match: match,
    matchId: match.id,
    otherUid: uid,
    displayName: name,
    photoUrl: null,
    previewText: match.lastMessagePreview!,
    timestamp: match.lastMessageAt!,
    unreadCount: 0,
    hasConversation: true,
    eventIds: eventIds,
  );
}
