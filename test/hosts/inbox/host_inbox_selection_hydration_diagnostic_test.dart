import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/data/conversation_repository.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chats_list_view_model.dart';
import 'package:catch_dating_app/core/data/cursor_page.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/hosts/data/crm/host_whatsapp_repository.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_whatsapp_thread.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_catch_pages_controller.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_people.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_person_page_body.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_program_audience_controller.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_whatsapp_pages_controller.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_person_conversation_controller.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_person_conversation_page_body.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_reply_drafts.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/programs/data/program_setup_repository.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_pump_helpers.dart';
import 'host_inbox_test_fixtures.dart';

// CAT-82 diagnostic: exercise the current detail selection without changing it.
class _Whatsapp extends Fake implements HostWhatsappRepository {
  final requested = <(String, String?)>[];
  final pages = <Completer<HostWhatsappThreadPage>>[];
  int detailRequests = 0;

  @override
  Future<HostWhatsappThreadPage> listWhatsappThreads(
    String organizerId, {
    String? cursor,
    int limit = 50,
  }) {
    requested.add((organizerId, cursor));
    final next = Completer<HostWhatsappThreadPage>();
    pages.add(next);
    return next.future;
  }

  @override
  Future<HostWhatsappThreadDetail> getWhatsappThread({
    required String organizerId,
    required String threadId,
  }) {
    detailRequests++;
    return Future.value(_detail(organizerId, threadId));
  }
}

HostWhatsappThreadDetail _detail(String org, String id) =>
    HostWhatsappThreadDetail(
      organizerId: org,
      threadId: id,
      contactId: 'contact',
      displayName: 'Synthetic contact',
      lastInboundAt: DateTime(2026, 9, 1),
      serviceWindowExpiresAt: DateTime(2026, 9, 2),
      serviceWindowOpen: false,
      messagesTruncated: false,
      messages: const [],
    );

class _Programs extends Fake implements ProgramSetupRepository {
  _Programs(this.owner);
  final String owner;

  @override
  Future<OrganizerProgramDetail> getProgram(String programId) async =>
      OrganizerProgramDetail(
        program: OrganizerProgramSettings(
          programId: programId,
          organizerId: owner,
          kind: ProgramKind.wedding,
          title: 'Synthetic program',
          timezone: 'UTC',
          status: ProgramStatus.active,
          startsAt: DateTime(2026),
          endsAt: DateTime(2026, 2),
          capabilities: const [],
          revision: 1,
        ),
        functions: const [],
        pickupPoints: const [],
        hotels: const [],
        counts: const {},
      );

  @override
  Future<ProgramGuestListPage> listGuests(
    String programId, {
    int? limit,
    String? cursor,
  }) async => ProgramGuestListPage(
    programId: programId,
    guests: const [
      ProgramGuestRow(
        guestId: 'guest',
        displayName: 'Synthetic guest',
        contactId: 'contact',
        groupIds: [],
        invitationStatus: 'draft',
        rsvpStatus: 'unknown',
        revision: 1,
      ),
    ],
    households: const [],
    functionGuests: const [],
    groups: const [],
  );
}

class _Matches extends Fake implements MatchRepository {
  final pending = <String, Completer<CursorPage<Match, MatchPageCursor>>>{};

  @override
  Future<CursorPage<Match, MatchPageCursor>> fetchMatchesForUserPage({
    required String uid,
    MatchPageCursor? startAfter,
    int limit = 50,
  }) {
    final result = Completer<CursorPage<Match, MatchPageCursor>>();
    pending[uid] = result;
    return result.future;
  }
}

void main() {
  testWidgets('an older Catch ID needs its page before detail can resolve', (
    tester,
  ) async {
    final recent = preview('recent-catch', 'recent');
    final older = preview('older-catch', 'older');
    Future<void> show(List<ChatThreadPreview> rows, String selected) =>
        _pumpDetail(tester, selection: selected, catchRows: rows);

    await show([recent], older.matchId);
    expect(
      find.text(
        'This conversation is no longer available in the selected organizer and scope.',
      ),
      findsOneWidget,
    );
    expect(find.byType(HostPersonConversationPageBody), findsNothing);
    await show([recent, older], older.matchId);
    expect(find.byType(HostPersonConversationPageBody), findsOneWidget);
    await show([recent, older], 'unknown-catch');
    expect(
      find.text(
        'This conversation is no longer available in the selected organizer and scope.',
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('an older WhatsApp ID needs its page despite an exact detail API', (
    tester,
  ) async {
    final repo = _Whatsapp();
    Future<void> show(List<HostWhatsappThreadSummary> rows, String selected) =>
        _pumpDetail(
          tester,
          selection: selected,
          whatsappRows: rows,
          whatsappRepository: repo,
        );

    await show([wa('recent-wa', 'recent')], 'older-wa');
    expect(
      find.text(
        'This conversation is no longer available in the selected organizer and scope.',
      ),
      findsOneWidget,
    );
    expect(repo.detailRequests, 0);
    await show([
      wa('recent-wa', 'recent'),
      wa('older-wa', 'contact'),
    ], 'older-wa');
    expect(find.byType(HostPersonConversationPageBody), findsOneWidget);
    expect(repo.detailRequests, greaterThan(0));
    await show([wa('recent-wa', 'recent')], 'unknown-wa');
    expect(
      find.text(
        'This conversation is no longer available in the selected organizer and scope.',
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  test(
    'composition denies wrong organizer, scope, and incomplete program membership',
    () {
      HostInboxPeople people({
        required String organizer,
        required HostInboxScope scope,
        HostInboxProgramAudience? audience,
      }) => composeHostInboxPeople(
        organizerId: organizer,
        scope: scope,
        segment: HostInboxAudienceSegment.booked,
        catchThreads: [
          preview('catch', 'guest', events: ['event-a']),
        ],
        whatsappThreads: [
          wa('wa', 'contact', events: ['event-a']),
        ],
        participations: null,
        programAudience: audience,
      );

      expect(
        people(
          organizer: 'other',
          scope: const HostInboxScope.event('event-a'),
        ).people.where((person) => person.catchThreads.isNotEmpty),
        isEmpty,
      );
      expect(
        people(organizer: 'org', scope: const HostInboxScope.general()).people,
        isEmpty,
      );
      expect(
        people(
          organizer: 'org',
          scope: const HostInboxScope.program('p'),
        ).people,
        isEmpty,
      );
      expect(
        people(
          organizer: 'org',
          scope: const HostInboxScope.program('p'),
          audience: const HostInboxProgramAudience(
            contactIds: {'contact'},
            linkedUids: {'guest'},
          ),
        ).people.length,
        2,
      );
    },
  );

  test('program owner check precedes selected guest resolution', () async {
    final container = ProviderContainer(
      overrides: [
        programSetupRepositoryProvider.overrideWithValue(_Programs('foreign')),
      ],
    );
    addTearDown(container.dispose);
    final provider = hostInboxProgramAudiencePagesProvider('org', 'program');
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    await expectLater(container.read(provider.future), throwsStateError);
  });

  test('wrong organizer WhatsApp page is rejected before selection', () async {
    final container = ProviderContainer(
      overrides: [
        hostWhatsappThreadsProvider('org').overrideWith(
          (ref) async => HostWhatsappThreadPage(
            organizerId: 'foreign',
            threads: [wa('foreign-wa', 'contact')],
            nextCursor: null,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = hostInboxWhatsappPagesProvider('org');
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    await expectLater(container.read(provider.future), throwsStateError);
  });

  test(
    'account-scoped Catch pages ignore a stale prior-account result',
    () async {
      final repository = _Matches();
      final container = ProviderContainer(
        overrides: [matchRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final oldAccount = hostInboxCatchPagesProvider('account-a');
      final newAccount = hostInboxCatchPagesProvider('account-b');
      final oldSub = container.listen(oldAccount, (_, _) {});
      final newSub = container.listen(newAccount, (_, _) {});
      addTearDown(oldSub.close);
      addTearDown(newSub.close);
      final oldPending = container.read(oldAccount.notifier).loadMore();
      final newPending = container.read(newAccount.notifier).loadMore();
      container.invalidate(oldAccount);
      repository.pending['account-a']!.complete(
        CursorPage(
          items: [preview('stale-catch', 'guest').match],
          hasMore: false,
        ),
      );
      repository.pending['account-b']!.complete(
        CursorPage(
          items: [preview('new-catch', 'guest').match],
          hasMore: false,
        ),
      );
      await Future.wait([oldPending, newPending]);
      expect(container.read(oldAccount).matches, isEmpty);
      expect(container.read(newAccount).matches.single.id, 'new-catch');
    },
  );

  test(
    'organizer-scoped pages and refresh fence stale async results',
    () async {
      final repo = _Whatsapp();
      var first = HostWhatsappThreadPage(
        organizerId: 'org-a',
        threads: [wa('recent', 'recent')],
        nextCursor: 'cursor-a',
      );
      final container = ProviderContainer(
        overrides: [
          hostWhatsappRepositoryProvider.overrideWithValue(repo),
          hostWhatsappThreadsProvider(
            'org-a',
          ).overrideWith((ref) async => first),
          hostWhatsappThreadsProvider('org-b').overrideWith(
            (ref) async => HostWhatsappThreadPage(
              organizerId: 'org-b',
              threads: [wa('other', 'other')],
              nextCursor: null,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final a = hostInboxWhatsappPagesProvider('org-a');
      final b = hostInboxWhatsappPagesProvider('org-b');
      final aSub = container.listen(a, (_, _) {});
      final bSub = container.listen(b, (_, _) {});
      addTearDown(aSub.close);
      addTearDown(bSub.close);
      await container.read(a.future);
      await container.read(b.future);
      final pending = container.read(a.notifier).loadMore();
      expect(repo.requested, [('org-a', 'cursor-a')]);
      first = HostWhatsappThreadPage(
        organizerId: 'org-a',
        threads: [wa('replacement', 'replacement')],
        nextCursor: null,
      );
      container.invalidate(hostWhatsappThreadsProvider('org-a'));
      await container.read(a.future);
      repo.pages.single.complete(
        HostWhatsappThreadPage(
          organizerId: 'org-a',
          threads: [wa('stale', 'stale')],
          nextCursor: null,
        ),
      );
      await pending;
      expect(
        (await container.read(a.future)).threads.single.threadId,
        'replacement',
      );
      expect((await container.read(b.future)).threads.single.threadId, 'other');
    },
  );
}

Future<void> _pumpDetail(
  WidgetTester tester, {
  required String selection,
  List<ChatThreadPreview> catchRows = const [],
  List<HostWhatsappThreadSummary> whatsappRows = const [],
  _Whatsapp? whatsappRepository,
}) async {
  final drafts = HostReplyDrafts();
  addTearDown(drafts.dispose);
  final repo = whatsappRepository ?? _Whatsapp();
  final container = ProviderContainer(
    overrides: [
      uidProvider.overrideWithValue(const AsyncData('host')),
      watchEventsForClubProvider('org').overrideWithValue(const AsyncData([])),
      organizerProgramListProvider(
        'org',
      ).overrideWithValue(const AsyncData([])),
      hostInboxCatchViewModelProvider.overrideWithValue(
        AsyncData(
          ChatsListViewModel(
            newMatches: const [],
            conversations: catchRows,
            totalThreadCount: catchRows.length,
          ),
        ),
      ),
      hostWhatsappRepositoryProvider.overrideWithValue(repo),
      hostWhatsappThreadsProvider('org').overrideWith(
        (ref) async => HostWhatsappThreadPage(
          organizerId: 'org',
          threads: whatsappRows,
          nextCursor: null,
        ),
      ),
      for (final source in catchRows)
        matchStreamProvider(
          source.matchId,
        ).overrideWithValue(AsyncData(source.match)),
      for (final source in catchRows)
        watchConversationMessagesProvider(
          source.matchId,
        ).overrideWithValue(const AsyncData([])),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: HostInboxPersonPageBody(
            organizerId: 'org',
            selection: selection,
            scope: const HostInboxScope.general(),
            now: DateTime(2026, 10, 21),
            segment: HostInboxAudienceSegment.booked,
            drafts: drafts,
            onBack: () {},
          ),
        ),
      ),
    ),
  );
  await pumpFeatureUi(tester);
}
