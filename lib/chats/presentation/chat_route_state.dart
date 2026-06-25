import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/data/conversation_repository.dart';
import 'package:catch_dating_app/chats/data/suvbot_repository.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/presentation/chat_controller.dart';
import 'package:catch_dating_app/chats/presentation/chat_thread_lookup_state.dart';
import 'package:catch_dating_app/chats/presentation/host_chat_screen_state.dart';
import 'package:catch_dating_app/chats/presentation/suvbot_controller.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRouteStateProvider =
    Provider.family<ChatRouteState, ChatRouteStateArgs>((ref, args) {
      final uid = ref.watch(uidProvider.select((value) => value.value));
      final messagesAsync = ref.watch(
        watchConversationMessagesProvider(args.matchId),
      );
      final matchAsync = ref.watch(matchStreamProvider(args.matchId));
      final match = matchAsync.asData?.value;

      final initialLookupState = ChatThreadLookupState.resolve(
        matchId: args.matchId,
        uid: uid,
        match: match,
        routeProfile: args.initialProfile,
      );
      final hostInquiryClub = initialLookupState.hostInquiryClubId == null
          ? null
          : ref
                .watch(watchClubProvider(initialLookupState.hostInquiryClubId!))
                .asData
                ?.value;
      final lookupState = ChatThreadLookupState.resolve(
        matchId: args.matchId,
        uid: uid,
        match: match,
        routeProfile: args.initialProfile,
        hostInquiryClub: hostInquiryClub,
      );

      final eventAsync = lookupState.latestEventId == null
          ? const AsyncData<Event?>(null)
          : ref.watch(watchEventProvider(lookupState.latestEventId!));
      final otherProfileAsync = lookupState.publicProfileUid == null
          ? const AsyncData<PublicProfile?>(null)
          : ref.watch(
              watchPublicProfileProvider(lookupState.publicProfileUid!),
            );
      final suvbotActionsAsync = lookupState.isSuvbot
          ? ref.watch(suvbotActionsProvider)
          : const AsyncData(<SuvbotActionItem>[]);

      final profile =
          otherProfileAsync.asData?.value ?? lookupState.initialProfile;
      final chatState = HostChatScreenState.resolve(
        matchId: args.matchId,
        uid: uid,
        matchAsync: matchAsync,
        messagesAsync: messagesAsync,
        suvbotActionsAsync: suvbotActionsAsync,
        profile: profile,
        hostProfile: lookupState.hostProfile,
        reportUserPending: ref
            .watch(ChatController.reportUserMutation)
            .isPending,
        blockUserPending: ref.watch(ChatController.blockUserMutation).isPending,
      );

      return ChatRouteState(
        uid: uid,
        matchAsync: matchAsync,
        messagesAsync: messagesAsync,
        lookupState: lookupState,
        chatState: chatState,
        eventAsync: eventAsync,
        suvbotActionsAsync: suvbotActionsAsync,
        share: ref.watch(externalShareControllerProvider),
        suvbotPending: ref.watch(SuvbotController.requestMutation).isPending,
        sendMessagePending: ref
            .watch(ChatController.sendMessageMutation)
            .isPending,
        sendImagePending: ref.watch(ChatController.sendImageMutation).isPending,
      );
    });

class ChatRouteStateArgs {
  const ChatRouteStateArgs({
    required this.matchId,
    required this.initialProfile,
  });

  final String matchId;
  final PublicProfile? initialProfile;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatRouteStateArgs &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId &&
          initialProfile == other.initialProfile;

  @override
  int get hashCode => Object.hash(matchId, initialProfile);
}

class ChatRouteState {
  const ChatRouteState({
    required this.uid,
    required this.matchAsync,
    required this.messagesAsync,
    required this.lookupState,
    required this.chatState,
    required this.eventAsync,
    required this.suvbotActionsAsync,
    required this.share,
    required this.suvbotPending,
    required this.sendMessagePending,
    required this.sendImagePending,
  });

  final String? uid;
  final AsyncValue<Match?> matchAsync;
  final AsyncValue<List<ChatMessage>> messagesAsync;
  final ChatThreadLookupState lookupState;
  final HostChatScreenState chatState;
  final AsyncValue<Event?> eventAsync;
  final AsyncValue<List<SuvbotActionItem>> suvbotActionsAsync;
  final ExternalShareController share;
  final bool suvbotPending;
  final bool sendMessagePending;
  final bool sendImagePending;

  List<ChatMessage>? get initialMessages => messagesAsync.asData?.value;
  List<ChatMessage> get messages => initialMessages ?? const [];
  Event? get event => eventAsync.asData?.value;
  bool get isSuvbot => lookupState.isSuvbot;
  HostChatRouteError? get routeError => chatState.routeError;
  bool get showEventContextHeader => !isSuvbot && routeError == null;
  bool get showSuvbotActionBar => isSuvbot && routeError == null;
  bool get showComposer => !isSuvbot && routeError == null;
}
