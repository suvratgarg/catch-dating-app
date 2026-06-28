import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/data/conversation_repository.dart';
import 'package:catch_dating_app/chats/data/suvbot_repository.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/presentation/chat_read_marker_state.dart';
import 'package:catch_dating_app/chats/presentation/chat_route_state.dart';
import 'package:catch_dating_app/chats/presentation/chat_screen.dart';
import 'package:catch_dating_app/chats/presentation/chat_thread_lookup_state.dart';
import 'package:catch_dating_app/chats/presentation/host_chat_screen_state.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';
import '../test_pump_helpers.dart';

class FakeMatchRepository implements MatchRepository {
  FakeMatchRepository({this.match, this.matchStream});

  Match? match;
  final Stream<Match?> Function()? matchStream;
  int watchMatchCalls = 0;

  @override
  Future<void> resetUnread({
    required String matchId,
    required String uid,
  }) async {}

  @override
  Stream<Match?> watchMatch({required String matchId}) {
    watchMatchCalls += 1;
    return matchStream?.call() ?? Stream.value(match);
  }

  @override
  Stream<List<Match>> watchMatchesForUser({required String uid}) =>
      const Stream.empty();
}

class FakeConversationRepository implements ConversationRepository {
  FakeConversationRepository({this.failSends = false, this.messageStream});

  final bool failSends;
  final Stream<List<ChatMessage>>? messageStream;
  final Map<String, List<ChatMessage>> messagesByMatch = {};
  final List<(String matchId, String senderId, String text)> sendCalls = [];
  final List<(String matchId, String uid)> markReadCalls = [];

  @override
  Future<void> sendTextMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    sendCalls.add((conversationId, senderId, text));
    if (failSends) {
      throw Exception('send failed');
    }
  }

  @override
  Stream<List<ChatMessage>> watchMessages({required String conversationId}) {
    return messageStream ??
        Stream.value(messagesByMatch[conversationId] ?? const []);
  }

  @override
  String createMessageId({required String conversationId}) => 'message-1';

  @override
  Future<void> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String messageId,
    required String imageUrl,
  }) async {}

  @override
  Future<void> markRead({
    required String conversationId,
    required String uid,
  }) async {
    markReadCalls.add((conversationId, uid));
  }
}

class FakeSuvbotRepository implements SuvbotRepository {
  final calls = <({String actionId, String? text})>[];
  final actions = const [
    SuvbotActionItem(
      id: 'refreshDemoState',
      label: 'Refresh demo state',
      description: 'Clear demo state and warm it again.',
      icon: 'refresh',
      destructive: true,
    ),
    SuvbotActionItem(
      id: 'checkDemoState',
      label: 'Check setup',
      description: 'Show seeded state.',
      icon: 'check',
    ),
    SuvbotActionItem(
      id: 'help',
      label: 'Help',
      description: 'Explain Suvbot controls.',
      icon: 'help',
    ),
    SuvbotActionItem(
      id: 'warmSignupState',
      label: 'Warm signups',
      description: 'Create signup state.',
      icon: 'event',
    ),
    SuvbotActionItem(
      id: 'warmPostEventState',
      label: 'Warm post-event',
      description: 'Create post-event state.',
      icon: 'flag',
    ),
    SuvbotActionItem(
      id: 'warmChatState',
      label: 'Warm chats',
      description: 'Create chat state.',
      icon: 'chat',
    ),
    SuvbotActionItem(
      id: 'warmPaymentState',
      label: 'Warm payments',
      description: 'Create payment state.',
      icon: 'payment',
    ),
    SuvbotActionItem(
      id: 'matchTesterByPhone',
      label: 'Match tester',
      description: 'Create a tester match.',
      icon: 'personAdd',
      requiresText: true,
    ),
    SuvbotActionItem(
      id: 'resetChats',
      label: 'Reset chats',
      description: 'Delete demo chat state.',
      icon: 'chatReset',
      destructive: true,
    ),
    SuvbotActionItem(
      id: 'resetBookings',
      label: 'Reset bookings',
      description: 'Delete demo bookings.',
      icon: 'eventReset',
      destructive: true,
    ),
    SuvbotActionItem(
      id: 'resetNotifications',
      label: 'Reset alerts',
      description: 'Delete demo alerts.',
      icon: 'notifications',
      destructive: true,
    ),
    SuvbotActionItem(
      id: 'clearDemoState',
      label: 'Fresh start',
      description: 'Delete demo state.',
      icon: 'clean',
      destructive: true,
    ),
  ];

  @override
  Future<List<SuvbotActionItem>> fetchActions() async => actions;

  @override
  Future<void> requestAction({required String actionId, String? text}) async {
    calls.add((actionId: actionId, text: text));
  }
}

class FakeSafetyRepository extends Fake implements SafetyRepository {
  FakeSafetyRepository({this.failReports = false, this.failBlocks = false});

  final bool failReports;
  final bool failBlocks;
  final reportCalls = <({String targetUserId, String? contextId})>[];
  final blockCalls = <String>[];

  @override
  Future<void> reportUser({
    required String targetUserId,
    String source = 'profile',
    String? reasonCode,
    String? contextId,
    String? notes,
  }) async {
    reportCalls.add((targetUserId: targetUserId, contextId: contextId));
    if (failReports) {
      throw StateError('report failed');
    }
  }

  @override
  Future<void> blockUser({
    required String targetUserId,
    String source = 'profile',
  }) async {
    blockCalls.add(targetUserId);
    if (failBlocks) {
      throw StateError('block failed');
    }
  }
}

Match buildMatch({
  String id = 'match-1',
  String user1Id = 'runner-1',
  String user2Id = 'runner-2',
  DateTime? createdAt,
  DateTime? lastMessageAt,
  String? lastMessagePreview,
  String? lastMessageSenderId,
  List<String> eventIds = const ['event-1'],
  Map<String, int> unreadCounts = const {},
  MatchStatus status = MatchStatus.active,
  MatchConversationType conversationType = MatchConversationType.match,
  String? clubId,
}) {
  return Match(
    id: id,
    user1Id: user1Id,
    user2Id: user2Id,
    eventIds: eventIds,
    createdAt: createdAt ?? DateTime(2026, 4, 23, 9),
    lastMessageAt: lastMessageAt,
    lastMessagePreview: lastMessagePreview,
    lastMessageSenderId: lastMessageSenderId,
    unreadCounts: unreadCounts,
    status: status,
    conversationType: conversationType,
    clubId: clubId,
  );
}

ChatMessage buildMessage({
  String id = 'msg-1',
  String senderId = 'runner-1',
  String text = 'Hello there',
  DateTime? sentAt,
}) {
  return ChatMessage(
    id: id,
    senderId: senderId,
    text: text,
    sentAt: sentAt ?? DateTime(2026, 4, 23, 10),
  );
}

const _emptyMessagesAsync = AsyncData<List<ChatMessage>>(<ChatMessage>[]);
const _emptySuvbotActionsAsync = AsyncData<List<SuvbotActionItem>>(
  <SuvbotActionItem>[],
);

void main() {
  group('ChatReadMarkerState', () {
    test('marks a uid once and exposes the last known uid for dispose', () {
      final state = ChatReadMarkerState();

      expect(state.markForUid(null), isNull);
      expect(state.markForUid('runner-1'), 'runner-1');
      expect(state.markForUid('runner-1'), isNull);
      expect(state.disposeMarkUid, 'runner-1');
      expect(state.markForUid('runner-1', force: true), 'runner-1');
    });

    test('marks read for incoming latest messages only', () {
      final state = ChatReadMarkerState();

      expect(
        state.markForIncomingLatest(uid: 'runner-1', messages: const []),
        isNull,
      );
      expect(
        state.markForIncomingLatest(
          uid: 'runner-1',
          messages: [buildMessage()],
        ),
        isNull,
      );
      expect(
        state.markForIncomingLatest(
          uid: 'runner-1',
          messages: [buildMessage(senderId: 'runner-2')],
        ),
        'runner-1',
      );
    });
  });

  group('ChatThreadLookupState', () {
    test('derives consumer chat profile and event lookup keys', () {
      final routeProfile = buildPublicProfile(uid: 'runner-2', name: 'Taylor');
      final match = buildMatch();

      final state = ChatThreadLookupState.resolve(
        matchId: match.id,
        uid: 'runner-1',
        match: match,
        routeProfile: routeProfile,
      );

      expect(state.otherUid, 'runner-2');
      expect(state.isSuvbot, isFalse);
      expect(state.isHostInquiry, isFalse);
      expect(state.hostInquiryClubId, isNull);
      expect(state.hostProfile, isNull);
      expect(state.publicProfileUid, 'runner-2');
      expect(state.initialProfile, same(routeProfile));
      expect(state.latestEventId, 'event-1');
    });

    test(
      'waits for host inquiry club context before reading attendee profile',
      () {
        final routeProfile = buildPublicProfile(uid: 'guest-1', name: 'Aarav');
        final match = buildMatch(
          id: 'host-inquiry-1',
          user1Id: 'guest-1',
          user2Id: 'host-1',
          conversationType: MatchConversationType.clubHostInquiry,
          clubId: 'club-1',
        );
        final club = Club(
          id: 'club-1',
          name: 'Sea Face Social',
          description: 'Small social runs and conversation-led evenings.',
          location: 'Mumbai',
          area: 'Bandra',
          hostUserId: 'host-1',
          ownerUserId: 'host-1',
          hostUserIds: const ['host-1'],
          createdAt: DateTime(2026),
        );

        final withoutClub = ChatThreadLookupState.resolve(
          matchId: match.id,
          uid: 'host-1',
          match: match,
          routeProfile: routeProfile,
        );
        final withClub = ChatThreadLookupState.resolve(
          matchId: match.id,
          uid: 'host-1',
          match: match,
          routeProfile: routeProfile,
          hostInquiryClub: club,
        );

        expect(withoutClub.hostInquiryClubId, 'club-1');
        expect(withoutClub.publicProfileUid, isNull);
        expect(withoutClub.initialProfile, isNull);
        expect(withClub.otherUid, 'guest-1');
        expect(withClub.publicProfileUid, 'guest-1');
        expect(withClub.initialProfile, isNull);
      },
    );

    test('uses club host profile instead of public profile for host peer', () {
      final match = buildMatch(
        id: 'host-inquiry-1',
        user1Id: 'guest-1',
        user2Id: 'host-1',
        conversationType: MatchConversationType.clubHostInquiry,
        clubId: 'club-1',
      );
      final club = Club(
        id: 'club-1',
        name: 'Sea Face Social',
        description: 'Small social runs and conversation-led evenings.',
        location: 'Mumbai',
        area: 'Bandra',
        hostUserId: 'host-1',
        ownerUserId: 'host-1',
        hostUserIds: const ['host-1'],
        hostProfiles: const [
          ClubHostProfile(
            uid: 'host-1',
            displayName: 'Mira from Sea Face',
            role: ClubHostRole.owner,
          ),
        ],
        createdAt: DateTime(2026),
      );

      final state = ChatThreadLookupState.resolve(
        matchId: match.id,
        uid: 'guest-1',
        match: match,
        routeProfile: null,
        hostInquiryClub: club,
      );

      expect(state.otherUid, 'host-1');
      expect(state.hostProfile?.displayName, 'Mira from Sea Face');
      expect(state.publicProfileUid, isNull);
    });

    test('suppresses profile and event lookups for Suvbot', () {
      final routeProfile = buildPublicProfile(uid: suvbotUid, name: 'Suvbot');
      final match = buildMatch(
        id: 'suvbot_runner-1',
        user1Id: suvbotUid,
        user2Id: 'runner-1',
      );

      final state = ChatThreadLookupState.resolve(
        matchId: match.id,
        uid: 'runner-1',
        match: match,
        routeProfile: routeProfile,
      );

      expect(state.isSuvbot, isTrue);
      expect(state.otherUid, isNull);
      expect(state.publicProfileUid, isNull);
      expect(state.latestEventId, isNull);
    });
  });

  group('HostChatScreenState', () {
    test('maps host inquiry identity and action availability', () {
      final match = buildMatch(
        user1Id: 'guest-1',
        user2Id: 'host-1',
        conversationType: MatchConversationType.clubHostInquiry,
        clubId: 'club-1',
      );
      final profile = buildPublicProfile(uid: 'guest-1', name: 'Aarav');

      final state = HostChatScreenState.resolve(
        matchId: match.id,
        uid: 'host-1',
        matchAsync: AsyncData<Match?>(match),
        messagesAsync: _emptyMessagesAsync,
        suvbotActionsAsync: _emptySuvbotActionsAsync,
        profile: profile,
        hostProfile: null,
      );

      expect(state.routeError, isNull);
      expect(state.isHostInquiry, isTrue);
      expect(state.name, 'Aarav');
      expect(state.otherUid, 'guest-1');
      expect(state.profileNavigationEnabled, isFalse);
      expect(state.shareCardEnabled, isFalse);
      expect(state.safetyActionsEnabled, isTrue);
      expect(state.threadActions, [
        ChatThreadAction.report,
        ChatThreadAction.block,
      ]);
      expect(state.disabledThreadActions, isEmpty);
      expect(state.safetyTargetName, 'Aarav');
      expect(state.messageOtherName, 'Aarav');
      expect(state.messagesRetryIntent, isNull);
      expect(state.suvbotActionsRetryIntent, isNull);
      expect(state.composerDisabledReason, isNull);
    });

    test('names host fallback and disabled composer states', () {
      final hostInquiry = buildMatch(
        user1Id: 'guest-1',
        user2Id: 'host-1',
        conversationType: MatchConversationType.clubHostInquiry,
        clubId: 'club-1',
      );

      final fallback = HostChatScreenState.resolve(
        matchId: hostInquiry.id,
        uid: 'host-1',
        matchAsync: AsyncData<Match?>(hostInquiry),
        messagesAsync: _emptyMessagesAsync,
        suvbotActionsAsync: _emptySuvbotActionsAsync,
        profile: null,
        hostProfile: null,
      );
      final loading = HostChatScreenState.resolve(
        matchId: hostInquiry.id,
        uid: 'host-1',
        matchAsync: const AsyncLoading<Match?>(),
        messagesAsync: _emptyMessagesAsync,
        suvbotActionsAsync: _emptySuvbotActionsAsync,
        profile: null,
        hostProfile: null,
      );
      final blocked = HostChatScreenState.resolve(
        matchId: hostInquiry.id,
        uid: 'host-1',
        matchAsync: AsyncData<Match?>(
          hostInquiry.copyWith(status: MatchStatus.blocked),
        ),
        messagesAsync: _emptyMessagesAsync,
        suvbotActionsAsync: _emptySuvbotActionsAsync,
        profile: null,
        hostProfile: null,
      );

      expect(fallback.name, 'Host conversation');
      expect(fallback.safetyTargetName, 'this person');
      expect(loading.composerDisabledReason, 'Loading chat...');
      expect(blocked.composerDisabledReason, 'This chat is closed.');
    });

    test('marks safety actions disabled while their mutations are pending', () {
      final match = buildMatch(
        user1Id: 'guest-1',
        user2Id: 'host-1',
        conversationType: MatchConversationType.clubHostInquiry,
        clubId: 'club-1',
      );

      final state = HostChatScreenState.resolve(
        matchId: match.id,
        uid: 'host-1',
        matchAsync: AsyncData<Match?>(match),
        messagesAsync: _emptyMessagesAsync,
        suvbotActionsAsync: _emptySuvbotActionsAsync,
        profile: buildPublicProfile(uid: 'guest-1', name: 'Aarav'),
        hostProfile: null,
        reportUserPending: true,
        blockUserPending: true,
      );

      expect(state.disabledThreadActions, {
        ChatThreadAction.report,
        ChatThreadAction.block,
      });
    });

    test('resolves typed top-bar action intents', () {
      final match = buildMatch();
      final profile = buildPublicProfile(uid: 'runner-2', name: 'Taylor');

      final state = HostChatScreenState.resolve(
        matchId: match.id,
        uid: 'runner-1',
        matchAsync: AsyncData<Match?>(match),
        messagesAsync: _emptyMessagesAsync,
        suvbotActionsAsync: _emptySuvbotActionsAsync,
        profile: profile,
        hostProfile: null,
      );
      final disabledReport = HostChatScreenState.resolve(
        matchId: match.id,
        uid: 'runner-1',
        matchAsync: AsyncData<Match?>(match),
        messagesAsync: _emptyMessagesAsync,
        suvbotActionsAsync: _emptySuvbotActionsAsync,
        profile: profile,
        hostProfile: null,
        reportUserPending: true,
      );

      expect(
        state.intentForThreadAction(ChatThreadAction.shareCard)?.type,
        HostChatActionIntentType.shareCard,
      );
      final reportIntent = state.intentForThreadAction(ChatThreadAction.report);
      expect(reportIntent?.type, HostChatActionIntentType.reportUser);
      expect(reportIntent?.targetUserId, 'runner-2');
      expect(reportIntent?.targetName, 'Taylor');
      final blockIntent = state.intentForThreadAction(ChatThreadAction.block);
      expect(blockIntent?.type, HostChatActionIntentType.blockUser);
      expect(blockIntent?.targetUserId, 'runner-2');
      expect(blockIntent?.targetName, 'Taylor');
      expect(
        disabledReport.intentForThreadAction(ChatThreadAction.report),
        isNull,
      );
      expect(
        disabledReport.intentForThreadAction(ChatThreadAction.block)?.type,
        HostChatActionIntentType.blockUser,
      );
    });

    test(
      'does not resolve unavailable host inquiry or Suvbot action intents',
      () {
        final hostInquiry = buildMatch(
          id: 'host-inquiry-1',
          user1Id: 'guest-1',
          user2Id: 'host-1',
          conversationType: MatchConversationType.clubHostInquiry,
          clubId: 'club-1',
        );
        final suvbotMatch = buildMatch(
          id: 'suvbot_runner-1',
          user1Id: suvbotUid,
          user2Id: 'runner-1',
        );

        final hostState = HostChatScreenState.resolve(
          matchId: hostInquiry.id,
          uid: 'host-1',
          matchAsync: AsyncData<Match?>(hostInquiry),
          messagesAsync: _emptyMessagesAsync,
          suvbotActionsAsync: _emptySuvbotActionsAsync,
          profile: buildPublicProfile(uid: 'guest-1', name: 'Aarav'),
          hostProfile: null,
        );
        final suvbotState = HostChatScreenState.resolve(
          matchId: suvbotMatch.id,
          uid: 'runner-1',
          matchAsync: AsyncData<Match?>(suvbotMatch),
          messagesAsync: _emptyMessagesAsync,
          suvbotActionsAsync: _emptySuvbotActionsAsync,
          profile: null,
          hostProfile: null,
        );

        expect(
          hostState.intentForThreadAction(ChatThreadAction.shareCard),
          isNull,
        );
        expect(
          hostState.intentForThreadAction(ChatThreadAction.report)?.type,
          HostChatActionIntentType.reportUser,
        );
        expect(
          hostState.intentForThreadAction(ChatThreadAction.block)?.type,
          HostChatActionIntentType.blockUser,
        );
        expect(
          suvbotState.intentForThreadAction(ChatThreadAction.shareCard),
          isNull,
        );
        expect(
          suvbotState.intentForThreadAction(ChatThreadAction.report),
          isNull,
        );
        expect(
          suvbotState.intentForThreadAction(ChatThreadAction.block),
          isNull,
        );
      },
    );

    test('names retry targets for route, message, and Suvbot failures', () {
      final match = buildMatch();
      final routeError = StateError('match failed');
      final messageError = StateError('messages failed');
      final suvbotError = StateError('controls failed');

      final failedRoute = HostChatScreenState.resolve(
        matchId: match.id,
        uid: 'runner-1',
        matchAsync: AsyncError<Match?>(routeError, StackTrace.empty),
        messagesAsync: _emptyMessagesAsync,
        suvbotActionsAsync: _emptySuvbotActionsAsync,
        profile: null,
        hostProfile: null,
      );
      expect(failedRoute.routeError?.error, same(routeError));
      expect(
        failedRoute.routeError?.retryIntent,
        HostChatRetryIntent.reloadMatch,
      );

      final failedMessages = HostChatScreenState.resolve(
        matchId: match.id,
        uid: 'runner-1',
        matchAsync: AsyncData<Match?>(match),
        messagesAsync: AsyncError<List<ChatMessage>>(
          messageError,
          StackTrace.empty,
        ),
        suvbotActionsAsync: _emptySuvbotActionsAsync,
        profile: null,
        hostProfile: null,
      );
      expect(
        failedMessages.messagesRetryIntent,
        HostChatRetryIntent.reloadMessages,
      );

      final suvbotMatch = buildMatch(
        id: 'suvbot_runner-1',
        user1Id: suvbotUid,
        user2Id: 'runner-1',
      );
      final failedSuvbotActions = HostChatScreenState.resolve(
        matchId: suvbotMatch.id,
        uid: 'runner-1',
        matchAsync: AsyncData<Match?>(suvbotMatch),
        messagesAsync: _emptyMessagesAsync,
        suvbotActionsAsync: AsyncError<List<SuvbotActionItem>>(
          suvbotError,
          StackTrace.empty,
        ),
        profile: null,
        hostProfile: null,
      );
      expect(
        failedSuvbotActions.suvbotActionsRetryIntent,
        HostChatRetryIntent.reloadSuvbotActions,
      );
    });
  });

  group('ChatRouteState', () {
    testWidgets('centralizes host inquiry provider lookups for the route', (
      tester,
    ) async {
      final match = buildMatch(
        id: 'host-inquiry-1',
        user1Id: 'guest-1',
        user2Id: 'host-1',
        conversationType: MatchConversationType.clubHostInquiry,
        clubId: 'club-1',
      );
      final club = Club(
        id: 'club-1',
        name: 'Sea Face Social',
        description: 'Small social runs and conversation-led evenings.',
        location: 'Mumbai',
        area: 'Bandra',
        hostUserId: 'host-1',
        ownerUserId: 'host-1',
        hostUserIds: const ['host-1'],
        createdAt: DateTime(2026),
      );
      final profile = buildPublicProfile(uid: 'guest-1', name: 'Aarav');
      ChatRouteState? state;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('host-1')),
            matchRepositoryProvider.overrideWithValue(
              FakeMatchRepository(match: match),
            ),
            conversationRepositoryProvider.overrideWithValue(
              FakeConversationRepository(),
            ),
            watchClubProvider(
              'club-1',
            ).overrideWith((ref) => Stream.value(club)),
            watchPublicProfileProvider(
              'guest-1',
            ).overrideWith((ref) => Stream.value(profile)),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                state = ref.watch(
                  chatRouteStateProvider(
                    const ChatRouteStateArgs(
                      matchId: 'host-inquiry-1',
                      initialProfile: null,
                    ),
                  ),
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await pumpFeatureUi(tester);

      expect(state?.uid, 'host-1');
      expect(state?.lookupState.publicProfileUid, 'guest-1');
      expect(state?.chatState.name, 'Aarav');
      expect(state?.chatState.shareCardEnabled, isFalse);
      expect(state?.showEventContextHeader, isTrue);
      expect(state?.showComposer, isTrue);
    });
  });

  group('ChatScreen', () {
    testWidgets('hydrates the other profile without route extra', (
      tester,
    ) async {
      final matchRepository = FakeMatchRepository(match: buildMatch());
      final conversationRepository = FakeConversationRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            watchEventProvider(
              'event-1',
            ).overrideWith((ref) => Stream.value(null)),
            watchPublicProfileProvider('runner-2').overrideWith(
              (ref) => Stream.value(
                buildPublicProfile(uid: 'runner-2', name: 'Taylor'),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ChatScreen(matchId: 'match-1'),
          ),
        ),
      );

      await pumpFeatureUi(tester);

      expect(find.text('Taylor'), findsOneWidget);
      expect(find.text('Say hi to Taylor!'), findsOneWidget);
    });

    testWidgets('empty match thread grounds the prompt in the shared event', (
      tester,
    ) async {
      final event = buildEvent(startTime: DateTime(2026, 5, 29, 19));
      final matchRepository = FakeMatchRepository(match: buildMatch());
      final conversationRepository = FakeConversationRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            watchEventProvider(
              'event-1',
            ).overrideWith((ref) => Stream.value(event)),
            watchPublicProfileProvider('runner-2').overrideWith(
              (ref) => Stream.value(
                buildPublicProfile(uid: 'runner-2', name: 'Taylor'),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ChatScreen(matchId: 'match-1'),
          ),
        ),
      );

      await pumpFeatureUi(tester);

      expect(
        find.text('You both ran ${event.title}. Say hi to Taylor!'),
        findsOneWidget,
      );
    });

    testWidgets('resets unread once the uid becomes available after mount', (
      tester,
    ) async {
      final uidController = StreamController<String?>.broadcast();
      addTearDown(uidController.close);

      final matchRepository = FakeMatchRepository(match: buildMatch());
      final conversationRepository = FakeConversationRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => uidController.stream),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            watchEventProvider(
              'event-1',
            ).overrideWith((ref) => Stream.value(null)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ChatScreen(matchId: 'match-1'),
          ),
        ),
      );

      await tester.pump();
      expect(conversationRepository.markReadCalls, isEmpty);

      uidController.add('runner-1');
      await tester.pump();
      await tester.pump();

      expect(conversationRepository.markReadCalls, [('match-1', 'runner-1')]);
    });

    testWidgets('sends trimmed messages and clears the input', (tester) async {
      final matchRepository = FakeMatchRepository(match: buildMatch());
      final conversationRepository = FakeConversationRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            watchEventProvider(
              'event-1',
            ).overrideWith((ref) => Stream.value(null)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: ChatScreen(
              matchId: 'match-1',
              otherProfile: buildPublicProfile(uid: 'runner-2', name: 'Taylor'),
            ),
          ),
        ),
      );

      await pumpFeatureUi(tester);

      await tester.enterText(find.byType(TextField), '  Hello Taylor  ');
      await tester.tap(find.byIcon(CatchIcons.sendRounded));
      await pumpFeatureUi(tester);

      expect(conversationRepository.sendCalls, hasLength(1));
      expect(conversationRepository.sendCalls.single.$1, 'match-1');
      expect(conversationRepository.sendCalls.single.$2, 'runner-1');
      expect(conversationRepository.sendCalls.single.$3, 'Hello Taylor');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        isEmpty,
      );
    });

    testWidgets('keeps composed text when send fails', (tester) async {
      final matchRepository = FakeMatchRepository(match: buildMatch());
      final conversationRepository = FakeConversationRepository(
        failSends: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            watchEventProvider(
              'event-1',
            ).overrideWith((ref) => Stream.value(null)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: ChatScreen(
              matchId: 'match-1',
              otherProfile: buildPublicProfile(uid: 'runner-2', name: 'Taylor'),
            ),
          ),
        ),
      );

      await pumpFeatureUi(tester);

      await tester.enterText(find.byType(TextField), '  Still here  ');
      await tester.tap(find.byIcon(CatchIcons.sendRounded));
      await pumpFeatureUi(tester);

      expect(conversationRepository.sendCalls, hasLength(1));
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        '  Still here  ',
      );
    });

    testWidgets('resets unread again for incoming messages while open', (
      tester,
    ) async {
      final messageController = StreamController<List<ChatMessage>>.broadcast();
      addTearDown(messageController.close);
      final matchRepository = FakeMatchRepository(match: buildMatch());
      final conversationRepository = FakeConversationRepository(
        messageStream: messageController.stream,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            watchEventProvider(
              'event-1',
            ).overrideWith((ref) => Stream.value(null)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: ChatScreen(
              matchId: 'match-1',
              otherProfile: buildPublicProfile(uid: 'runner-2', name: 'Taylor'),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(conversationRepository.markReadCalls, [('match-1', 'runner-1')]);

      messageController.add([
        buildMessage(senderId: 'runner-2', text: 'Incoming'),
      ]);
      await tester.pump();
      await tester.pump();

      expect(conversationRepository.markReadCalls, [
        ('match-1', 'runner-1'),
        ('match-1', 'runner-1'),
      ]);
    });

    testWidgets('shows a friendly error and retry when messages fail to load', (
      tester,
    ) async {
      final matchRepository = FakeMatchRepository(match: buildMatch());
      final conversationRepository = FakeConversationRepository();
      var messageProviderBuilds = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            watchEventProvider(
              'event-1',
            ).overrideWith((ref) => Stream.value(null)),
            watchConversationMessagesProvider('match-1').overrideWith((ref) {
              messageProviderBuilds += 1;
              return Stream<List<ChatMessage>>.error(
                Exception('messages failed'),
                StackTrace.empty,
              );
            }),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: ChatScreen(
              matchId: 'match-1',
              otherProfile: buildPublicProfile(uid: 'runner-2', name: 'Taylor'),
            ),
          ),
        ),
      );

      await pumpFeatureUi(tester);

      expect(find.text('Unable to load messages.'), findsOneWidget);
      final buildsBeforeRetry = messageProviderBuilds;

      await tester.tap(find.widgetWithText(CatchButton, 'Try again'));
      await pumpFeatureUi(tester);

      expect(messageProviderBuilds, greaterThan(buildsBeforeRetry));
    });

    testWidgets('routes match load errors through a retryable chat state', (
      tester,
    ) async {
      final matchRepository = FakeMatchRepository(
        matchStream: () =>
            Stream<Match?>.error(Exception('match failed'), StackTrace.empty),
      );
      final conversationRepository = FakeConversationRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: ChatScreen(
              matchId: 'match-1',
              otherProfile: buildPublicProfile(uid: 'runner-2', name: 'Taylor'),
            ),
          ),
        ),
      );

      await pumpFeatureUi(tester);

      expect(find.text('Messages unavailable'), findsOneWidget);
      final callsBeforeRetry = matchRepository.watchMatchCalls;

      await tester.tap(find.widgetWithText(CatchButton, 'Reload messages'));
      await pumpFeatureUi(tester);

      expect(matchRepository.watchMatchCalls, greaterThan(callsBeforeRetry));
    });

    testWidgets(
      'host inquiry disables profile navigation and share card actions',
      (tester) async {
        final match = buildMatch(
          id: 'host-inquiry-1',
          user1Id: 'guest-1',
          user2Id: 'host-1',
          conversationType: MatchConversationType.clubHostInquiry,
          clubId: 'club-1',
        );
        final matchRepository = FakeMatchRepository(match: match);
        final conversationRepository = FakeConversationRepository();
        final safetyRepository = FakeSafetyRepository();
        final club = Club(
          id: 'club-1',
          name: 'Sea Face Social',
          description: 'Small social runs and conversation-led evenings.',
          location: 'Mumbai',
          area: 'Bandra',
          hostUserId: 'host-1',
          hostName: 'Mira Shah',
          ownerUserId: 'host-1',
          hostUserIds: const ['host-1'],
          hostProfiles: const [
            ClubHostProfile(
              uid: 'host-1',
              displayName: 'Mira from Sea Face',
              role: ClubHostRole.owner,
            ),
          ],
          createdAt: DateTime(2026),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              uidProvider.overrideWith((ref) => Stream.value('host-1')),
              matchRepositoryProvider.overrideWithValue(matchRepository),
              conversationRepositoryProvider.overrideWithValue(
                conversationRepository,
              ),
              safetyRepositoryProvider.overrideWith((ref) => safetyRepository),
              watchClubProvider(
                'club-1',
              ).overrideWith((ref) => Stream.value(club)),
              watchEventProvider(
                'event-1',
              ).overrideWith((ref) => Stream.value(null)),
              watchPublicProfileProvider('guest-1').overrideWith(
                (ref) => Stream.value(
                  buildPublicProfile(uid: 'guest-1', name: 'Aarav'),
                ),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: const ChatScreen(matchId: 'host-inquiry-1'),
            ),
          ),
        );

        await pumpFeatureUi(tester);

        await tester.tap(find.text('Aarav'));
        await pumpFeatureUi(tester);
        expect(tester.takeException(), isNull);

        await tester.tap(find.byTooltip('Chat actions'));
        await pumpFeatureUi(tester);

        expect(find.text('Share card'), findsNothing);
        expect(find.text('Report'), findsOneWidget);
        expect(find.text('Block'), findsOneWidget);

        await tester.tap(find.text('Report'));
        await pumpFeatureUi(tester);

        expect(safetyRepository.reportCalls, [
          (targetUserId: 'guest-1', contextId: 'host-inquiry-1'),
        ]);
        expect(find.text('Report submitted for Aarav.'), findsOneWidget);

        await tester.tap(find.byTooltip('Chat actions'));
        await pumpFeatureUi(tester);
        await tester.tap(
          find.ancestor(of: find.text('Block'), matching: find.byType(InkWell)),
        );
        await pumpFeatureUi(tester);

        expect(find.text('Block Aarav?'), findsOneWidget);

        await tester.tap(find.widgetWithText(CatchButton, 'Block'));
        await pumpFeatureUi(tester);

        expect(safetyRepository.blockCalls, ['guest-1']);
      },
    );

    testWidgets('prompts before sharing an empty consumer thread', (
      tester,
    ) async {
      final matchRepository = FakeMatchRepository(match: buildMatch());
      final conversationRepository = FakeConversationRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            watchEventProvider(
              'event-1',
            ).overrideWith((ref) => Stream.value(null)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: ChatScreen(
              matchId: 'match-1',
              otherProfile: buildPublicProfile(uid: 'runner-2', name: 'Taylor'),
            ),
          ),
        ),
      );

      await pumpFeatureUi(tester);
      await tester.tap(find.byTooltip('Chat actions'));
      await pumpFeatureUi(tester);
      await tester.tap(find.text('Share card'));
      await pumpFeatureUi(tester);

      expect(
        find.text('Send a message before sharing a card.'),
        findsOneWidget,
      );
    });

    testWidgets('disables the composer for blocked host inquiry chats', (
      tester,
    ) async {
      final matchRepository = FakeMatchRepository(
        match: buildMatch(
          id: 'host-inquiry-1',
          user1Id: 'guest-1',
          user2Id: 'host-1',
          conversationType: MatchConversationType.clubHostInquiry,
          status: MatchStatus.blocked,
          clubId: 'club-1',
        ),
      );
      final conversationRepository = FakeConversationRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('host-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            watchClubProvider('club-1').overrideWith(
              (ref) => Stream.value(
                Club(
                  id: 'club-1',
                  name: 'Sea Face Social',
                  description:
                      'Small social runs and conversation-led evenings.',
                  location: 'Mumbai',
                  area: 'Bandra',
                  hostUserId: 'host-1',
                  ownerUserId: 'host-1',
                  hostUserIds: const ['host-1'],
                  createdAt: DateTime(2026),
                ),
              ),
            ),
            watchPublicProfileProvider('guest-1').overrideWith(
              (ref) => Stream.value(
                buildPublicProfile(uid: 'guest-1', name: 'Aarav'),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ChatScreen(matchId: 'host-inquiry-1'),
          ),
        ),
      );

      await pumpFeatureUi(tester);

      expect(find.text('This chat is closed.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Should not send');
      await tester.tap(find.byIcon(CatchIcons.sendRounded));
      await pumpFeatureUi(tester);

      expect(conversationRepository.sendCalls, isEmpty);
    });

    testWidgets('surfaces failed report mutations through chat feedback', (
      tester,
    ) async {
      final match = buildMatch(
        id: 'host-inquiry-1',
        user1Id: 'guest-1',
        user2Id: 'host-1',
        conversationType: MatchConversationType.clubHostInquiry,
        clubId: 'club-1',
      );
      final matchRepository = FakeMatchRepository(match: match);
      final conversationRepository = FakeConversationRepository();
      final safetyRepository = FakeSafetyRepository(failReports: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('host-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            safetyRepositoryProvider.overrideWith((ref) => safetyRepository),
            watchClubProvider('club-1').overrideWith(
              (ref) => Stream.value(
                Club(
                  id: 'club-1',
                  name: 'Sea Face Social',
                  description:
                      'Small social runs and conversation-led evenings.',
                  location: 'Mumbai',
                  area: 'Bandra',
                  hostUserId: 'host-1',
                  ownerUserId: 'host-1',
                  hostUserIds: const ['host-1'],
                  createdAt: DateTime(2026),
                ),
              ),
            ),
            watchPublicProfileProvider('guest-1').overrideWith(
              (ref) => Stream.value(
                buildPublicProfile(uid: 'guest-1', name: 'Aarav'),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ChatScreen(matchId: 'host-inquiry-1'),
          ),
        ),
      );

      await pumpFeatureUi(tester);
      await tester.tap(find.byTooltip('Chat actions'));
      await pumpFeatureUi(tester);
      await tester.tap(find.text('Report'));
      await pumpFeatureUi(tester);

      expect(safetyRepository.reportCalls, [
        (targetUserId: 'guest-1', contextId: 'host-inquiry-1'),
      ]);
      expect(find.text('report failed'), findsOneWidget);
    });

    testWidgets('surfaces failed block mutations through chat feedback', (
      tester,
    ) async {
      final match = buildMatch(
        id: 'host-inquiry-1',
        user1Id: 'guest-1',
        user2Id: 'host-1',
        conversationType: MatchConversationType.clubHostInquiry,
        clubId: 'club-1',
      );
      final matchRepository = FakeMatchRepository(match: match);
      final conversationRepository = FakeConversationRepository();
      final safetyRepository = FakeSafetyRepository(failBlocks: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('host-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            safetyRepositoryProvider.overrideWith((ref) => safetyRepository),
            watchClubProvider('club-1').overrideWith(
              (ref) => Stream.value(
                Club(
                  id: 'club-1',
                  name: 'Sea Face Social',
                  description:
                      'Small social runs and conversation-led evenings.',
                  location: 'Mumbai',
                  area: 'Bandra',
                  hostUserId: 'host-1',
                  ownerUserId: 'host-1',
                  hostUserIds: const ['host-1'],
                  createdAt: DateTime(2026),
                ),
              ),
            ),
            watchPublicProfileProvider('guest-1').overrideWith(
              (ref) => Stream.value(
                buildPublicProfile(uid: 'guest-1', name: 'Aarav'),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ChatScreen(matchId: 'host-inquiry-1'),
          ),
        ),
      );

      await pumpFeatureUi(tester);
      await tester.tap(find.byTooltip('Chat actions'));
      await pumpFeatureUi(tester);
      await tester.tap(
        find.ancestor(of: find.text('Block'), matching: find.byType(InkWell)),
      );
      await pumpFeatureUi(tester);
      await tester.tap(find.widgetWithText(CatchButton, 'Block'));
      await pumpFeatureUi(tester);

      expect(safetyRepository.blockCalls, ['guest-1']);
      expect(find.text('block failed'), findsOneWidget);
    });

    testWidgets('retries failed Suvbot controls through the typed target', (
      tester,
    ) async {
      final matchRepository = FakeMatchRepository(
        match: buildMatch(
          id: 'suvbot_runner-1',
          user1Id: suvbotUid,
          user2Id: 'runner-1',
          eventIds: const ['suvbot'],
        ),
      );
      final conversationRepository = FakeConversationRepository();
      var actionsProviderBuilds = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            suvbotActionsProvider.overrideWith((ref) async {
              actionsProviderBuilds += 1;
              throw Exception('controls failed');
            }),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ChatScreen(matchId: 'suvbot_runner-1'),
          ),
        ),
      );

      await pumpFeatureUi(tester);

      expect(find.text('Reload controls'), findsOneWidget);
      final buildsBeforeRetry = actionsProviderBuilds;

      await tester.tap(find.text('Reload controls'));
      await pumpFeatureUi(tester);

      expect(actionsProviderBuilds, greaterThan(buildsBeforeRetry));
    });

    testWidgets('shows Suvbot controls without chat composer', (tester) async {
      final matchRepository = FakeMatchRepository(
        match: buildMatch(
          id: 'suvbot_runner-1',
          user1Id: suvbotUid,
          user2Id: 'runner-1',
          eventIds: const ['suvbot'],
          lastMessagePreview: 'I can refresh your seeded demo state.',
          lastMessageSenderId: suvbotUid,
        ),
      );
      final conversationRepository = FakeConversationRepository();
      final suvbotRepository = FakeSuvbotRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            suvbotRepositoryProvider.overrideWithValue(suvbotRepository),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ChatScreen(matchId: 'suvbot_runner-1'),
          ),
        ),
      );

      await pumpFeatureUi(tester);

      expect(find.text('Suvbot'), findsOneWidget);
      expect(find.text('Suvbot controls'), findsOneWidget);
      expect(find.text('No typing needed'), findsOneWidget);
      expect(find.text('Refresh all'), findsOneWidget);
      expect(find.text('Check setup'), findsOneWidget);
      expect(find.text('Create a test state'), findsOneWidget);
      expect(find.text('Signups'), findsOneWidget);
      expect(find.text('Post-event'), findsOneWidget);
      expect(find.text('Chats'), findsOneWidget);
      expect(find.text('Payments'), findsOneWidget);
      expect(find.text('Reset...'), findsOneWidget);
      expect(find.text('YOU BOTH RAN'), findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(find.byIcon(CatchIcons.imageOutlined), findsNothing);
      expect(find.byIcon(CatchIcons.sendRounded), findsNothing);

      await tester.tap(find.text('Check setup'));
      await pumpFeatureUi(tester);

      expect(suvbotRepository.calls.single.actionId, 'checkDemoState');

      await tester.tap(find.text('Reset...'));
      await pumpFeatureUi(tester);
      expect(find.text('Reset demo state'), findsOneWidget);
      expect(find.text('Delete demo chat state.'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
      await tester.tap(find.text('Reset chats'));
      await pumpFeatureUi(tester);

      expect(suvbotRepository.calls.last.actionId, 'resetChats');

      await tester.tap(find.text('Match tester'));
      await pumpFeatureUi(tester);
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), '+919999999999');
      await tester.tap(find.text('Create match'));
      await pumpFeatureUi(tester);

      expect(suvbotRepository.calls.last.actionId, 'matchTesterByPhone');
      expect(suvbotRepository.calls.last.text, '+919999999999');
    });
  });
}
