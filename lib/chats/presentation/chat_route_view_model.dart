import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/data/conversation_repository.dart';
import 'package:catch_dating_app/chats/data/suvbot_repository.dart';
import 'package:catch_dating_app/chats/domain/suvbot_action_item.dart';
import 'package:catch_dating_app/chats/presentation/chat_controller.dart';
import 'package:catch_dating_app/chats/presentation/chat_route_state.dart';
import 'package:catch_dating_app/chats/presentation/chat_thread_lookup_state.dart';
import 'package:catch_dating_app/chats/presentation/host_chat_screen_state.dart';
import 'package:catch_dating_app/chats/presentation/suvbot_controller.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_route_view_model.g.dart';

@riverpod
ChatRouteState chatRouteState(Ref ref, ChatRouteStateArgs args) {
  final uidAsync = ref.watch(uidProvider);
  final uid = uidAsync.asData?.value;
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
      : ref.watch(watchPublicProfileProvider(lookupState.publicProfileUid!));
  final suvbotActionsAsync = lookupState.isSuvbot
      ? ref.watch(suvbotActionsProvider)
      : const AsyncData(<SuvbotActionItem>[]);

  final profile = otherProfileAsync.asData?.value ?? lookupState.initialProfile;
  final matchState = _catchAsyncState(matchAsync);
  final messagesState = _catchAsyncState(messagesAsync);
  final suvbotActionsState = _catchAsyncState(suvbotActionsAsync);
  final chatState = HostChatScreenState.resolve(
    matchId: args.matchId,
    uid: uid,
    matchAsync: matchState,
    messagesAsync: messagesState,
    suvbotActionsAsync: suvbotActionsState,
    profile: profile,
    hostProfile: lookupState.hostProfile,
    reportUserPending: ref.watch(ChatController.reportUserMutation).isPending,
    blockUserPending: ref.watch(ChatController.blockUserMutation).isPending,
  );

  return ChatRouteState(
    uidAsync: _catchAsyncState(uidAsync),
    uid: uid,
    matchAsync: matchState,
    messagesAsync: messagesState,
    lookupState: lookupState,
    chatState: chatState,
    eventAsync: _catchAsyncState(eventAsync),
    suvbotActionsAsync: suvbotActionsState,
    share: ref.watch(externalShareControllerProvider),
    suvbotPending: ref.watch(SuvbotController.requestMutation).isPending,
    sendMessagePending: ref.watch(ChatController.sendMessageMutation).isPending,
    sendImagePending: ref.watch(ChatController.sendImageMutation).isPending,
  );
}

CatchAsyncState<T> _catchAsyncState<T>(AsyncValue<T> value) {
  return catchAsyncStateFromAsyncValue(value);
}
