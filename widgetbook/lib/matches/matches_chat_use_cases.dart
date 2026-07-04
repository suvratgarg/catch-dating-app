import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/data/conversation_repository.dart';
import 'package:catch_dating_app/chats/data/suvbot_repository.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/domain/suvbot_action_item.dart';
import 'package:catch_dating_app/chats/presentation/chat_screen.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chat_inbox_screen.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chats_list_screen_state.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chats_list_view_model.dart';
import 'package:catch_dating_app/chats/presentation/inbox/host_inbox_filter.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chat_conversations_list.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_empty_state.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_list.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_list_body.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_sliver_header.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_event_context_header.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_input_bar.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_message_list.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_share_card.dart';
import 'package:catch_dating_app/chats/presentation/widgets/message_bubble.dart';
import 'package:catch_dating_app/chats/presentation/widgets/suvbot_action_bar.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_divider.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:catch_dating_app/core/widgets/catch_share_card_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/labs/design_fixtures/matches_chat_surface_fixtures.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/matches/shared/match_celebration_dialog.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:go_router/go_router.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

final _consumerMatches = MatchesChatSurfaceFixtures.populatedMatches;
final _hostMatches = MatchesChatSurfaceFixtures.hostInquiryMatches;
final _hostNewInquiryMatches = [
  MatchesChatSurfaceFixtures.hostInquiryMatches.first.copyWith(
    id: 'design-host-inquiry-new',
    lastMessageAt: null,
    lastMessagePreview: null,
    lastMessageSenderId: null,
  ),
];
final _taylorMatch = MatchesChatSurfaceFixtures.activeConversationMatch();
final _blockedMatch = MatchesChatSurfaceFixtures.blockedMatch();
final _suvbotMatch = MatchesChatSurfaceFixtures.suvbotMatch();
final _event = MatchesChatSurfaceFixtures.event;
final _club = MatchesChatSurfaceFixtures.club;
const _chatsListSkeletonPreviewHeight = 360.0;

@widgetbook.UseCase(
  name: 'Consumer route states',
  type: ChatsListScreen,
  path: '[P1 product surfaces]/Matches and chat',
)
Widget matchesListConsumerRouteStates(BuildContext context) {
  return _AppRoleBoundary(
    role: AppRole.consumer,
    child: _MatchesCatalog(
      title: 'ChatsListScreen',
      contractId: 'screen.matches.list',
      children: [
        _StateCard(
          label: 'matches loading',
          child: _DeviceFrame(
            child: _MatchesListRouteScope(
              viewModel: const AsyncLoading<ChatsListViewModel>(),
              matches: _consumerMatches,
            ),
          ),
        ),
        _StateCard(
          label: 'matches error',
          child: _DeviceFrame(
            child: _MatchesListRouteScope(
              viewModel: AsyncError<ChatsListViewModel>(
                StateError('Matches failed'),
                StackTrace.empty,
              ),
              matches: _consumerMatches,
            ),
          ),
        ),
        _StateCard(
          label: 'offline load error',
          child: _DeviceFrame(
            child: _MatchesListRouteScope(
              viewModel: AsyncError<ChatsListViewModel>(
                MatchesChatSurfaceFixtures.offlineException(
                  action: 'load matches',
                ),
                StackTrace.empty,
              ),
              matches: _consumerMatches,
            ),
          ),
        ),
        _StateCard(
          label: 'populated with unread and new match rows',
          child: _DeviceFrame(
            child: _MatchesListRouteScope(
              viewModel: AsyncData<ChatsListViewModel>(_consumerViewModel()),
              matches: _consumerMatches,
            ),
          ),
        ),
        _StateCard(
          label: 'search empty',
          child: _DeviceFrame(
            child: _MatchesListRouteScope(
              query: 'no dinner runners nearby',
              viewModel: AsyncData<ChatsListViewModel>(
                _emptySearchViewModel(totalThreadCount: 3),
              ),
              matches: _consumerMatches,
            ),
          ),
        ),
        _StateCard(
          label: 'no catches empty',
          child: _DeviceFrame(
            child: _MatchesListRouteScope(
              viewModel: AsyncData<ChatsListViewModel>(
                _emptySearchViewModel(totalThreadCount: 0),
              ),
              matches: const [],
            ),
          ),
        ),
        _StateCard(
          label: 'match celebration',
          child: _DeviceFrame(
            child: _MatchesListRouteScope(
              viewModel: AsyncData<ChatsListViewModel>(_consumerViewModel()),
              matches: _consumerMatches,
              child: _CelebrationPreview(match: _taylorMatch),
            ),
          ),
        ),
        _StateCard(
          label: 'thread tile variants',
          child: _DeviceFrame(
            height: 420,
            child: _MatchesListRouteScope(
              viewModel: AsyncData<ChatsListViewModel>(_consumerViewModel()),
              matches: _consumerMatches,
              child: _ThreadTileVariants(viewModel: _consumerViewModel()),
            ),
          ),
        ),
        _StateCard(
          label: 'text scale 2.0',
          child: _DeviceFrame(
            child: _MediaOverride(
              textScaler: const TextScaler.linear(2),
              child: _MatchesListRouteScope(
                viewModel: AsyncData<ChatsListViewModel>(_consumerViewModel()),
                matches: _consumerMatches,
              ),
            ),
          ),
        ),
        _StateCard(
          label: 'reduced motion',
          child: _DeviceFrame(
            child: _MediaOverride(
              disableAnimations: true,
              child: _MatchesListRouteScope(
                viewModel: AsyncData<ChatsListViewModel>(_consumerViewModel()),
                matches: _consumerMatches,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Host inbox states',
  type: ChatsListScreen,
  path: '[P1 product surfaces]/Matches and chat',
)
Widget matchesListHostInboxStates(BuildContext context) {
  return _AppRoleBoundary(
    role: AppRole.host,
    child: _MatchesCatalog(
      title: 'ChatsListScreen host inbox',
      contractId: 'screen.host.inbox + screen.matches.list',
      children: [
        _StateCard(
          label: 'uid loading',
          child: _DeviceFrame(
            child: _MatchesListRouteScope(
              uid: null,
              initialLocation: Routes.hostInboxScreen.path,
              viewModel: const AsyncLoading<ChatsListViewModel>(),
              matches: _hostMatches,
            ),
          ),
        ),
        _StateCard(
          label: 'matches loading',
          child: _DeviceFrame(
            child: _MatchesListRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              initialLocation: Routes.hostInboxScreen.path,
              viewModel: const AsyncLoading<ChatsListViewModel>(),
              matches: _hostMatches,
            ),
          ),
        ),
        _StateCard(
          label: 'matches error',
          child: _DeviceFrame(
            child: _MatchesListRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              initialLocation: Routes.hostInboxScreen.path,
              viewModel: AsyncError<ChatsListViewModel>(
                StateError('Host inbox unavailable'),
                StackTrace.empty,
              ),
              matches: _hostMatches,
            ),
          ),
        ),
        _StateCard(
          label: 'offline',
          child: _DeviceFrame(
            child: _MatchesListRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              initialLocation: Routes.hostInboxScreen.path,
              viewModel: AsyncError<ChatsListViewModel>(
                MatchesChatSurfaceFixtures.offlineException(
                  action: 'load host inbox',
                ),
                StackTrace.empty,
              ),
              matches: _hostMatches,
            ),
          ),
        ),
        _StateCard(
          label: 'empty attendee queries',
          child: _DeviceFrame(
            child: _MatchesListRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              initialLocation: Routes.hostInboxScreen.path,
              viewModel: const AsyncData<ChatsListViewModel>(
                ChatsListViewModel(
                  newMatches: <ChatThreadPreview>[],
                  conversations: <ChatThreadPreview>[],
                  totalThreadCount: 0,
                ),
              ),
              matches: const <Match>[],
            ),
          ),
        ),
        _StateCard(
          label: 'attendee queries',
          child: _DeviceFrame(
            child: _MatchesListRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              initialLocation: Routes.hostInboxScreen.path,
              viewModel: AsyncData<ChatsListViewModel>(_hostInboxViewModel()),
              matches: _hostMatches,
            ),
          ),
        ),
        _StateCard(
          label: 'unread filter with rows',
          child: _DeviceFrame(
            child: _MatchesListRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              initialLocation: Routes.hostInboxScreen.path,
              viewModel: AsyncData<ChatsListViewModel>(_hostInboxViewModel()),
              matches: _hostMatches,
              child: const _HostUnreadOnlyInbox(),
            ),
          ),
        ),
        _StateCard(
          label: 'host unread filter empty',
          child: _DeviceFrame(
            child: _MatchesListRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              initialLocation: Routes.hostInboxScreen.path,
              viewModel: AsyncData<ChatsListViewModel>(
                _hostInboxReadOnlyViewModel(),
              ),
              matches: _hostMatches
                  .map((match) => match.copyWith(unreadCounts: const {}))
                  .toList(),
              child: const _HostUnreadOnlyInbox(),
            ),
          ),
        ),
        _StateCard(
          label: 'search active',
          child: _DeviceFrame(
            child: _MatchesListRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              initialLocation: Routes.hostInboxScreen.path,
              query: 'Aarav',
              viewModel: AsyncData<ChatsListViewModel>(_hostInboxViewModel()),
              matches: _hostMatches,
            ),
          ),
        ),
        _StateCard(
          label: 'search empty',
          child: _DeviceFrame(
            child: _MatchesListRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              initialLocation: Routes.hostInboxScreen.path,
              query: 'No attendee by this name',
              viewModel: AsyncData<ChatsListViewModel>(
                _emptySearchViewModel(totalThreadCount: _hostMatches.length),
              ),
              matches: _hostMatches,
            ),
          ),
        ),
        _StateCard(
          label: 'new inquiry row',
          child: _DeviceFrame(
            child: _MatchesListRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              initialLocation: Routes.hostInboxScreen.path,
              viewModel: AsyncData<ChatsListViewModel>(
                _viewModelFor(
                  uid: MatchesChatSurfaceFixtures.hostUid,
                  matches: _hostNewInquiryMatches,
                ),
              ),
              matches: _hostNewInquiryMatches,
            ),
          ),
        ),
        _StateCard(
          label: 'text scale 2.0',
          child: _DeviceFrame(
            child: _MediaOverride(
              textScaler: const TextScaler.linear(2),
              child: _MatchesListRouteScope(
                uid: MatchesChatSurfaceFixtures.hostUid,
                initialLocation: Routes.hostInboxScreen.path,
                viewModel: AsyncData<ChatsListViewModel>(_hostInboxViewModel()),
                matches: _hostMatches,
              ),
            ),
          ),
        ),
        _StateCard(
          label: 'reduced motion',
          child: _DeviceFrame(
            child: _MediaOverride(
              disableAnimations: true,
              child: _MatchesListRouteScope(
                uid: MatchesChatSurfaceFixtures.hostUid,
                initialLocation: Routes.hostInboxScreen.path,
                viewModel: AsyncData<ChatsListViewModel>(_hostInboxViewModel()),
                matches: _hostMatches,
              ),
            ),
          ),
        ),
        _StateCard(
          label: 'dark theme',
          child: _DeviceFrame(
            child: _MatchesListRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              initialLocation: Routes.hostInboxScreen.path,
              themeMode: ThemeMode.dark,
              viewModel: AsyncData<ChatsListViewModel>(_hostInboxViewModel()),
              matches: _hostMatches,
            ),
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Sheet states',
  type: HostBroadcastComposerSheet,
  path: '[P1 product surfaces]/Matches and chat/Host inbox',
)
Widget hostBroadcastComposerSheetStates(BuildContext context) {
  return _AppRoleBoundary(
    role: AppRole.host,
    child: _MatchesCatalog(
      title: 'HostBroadcastComposerSheet',
      contractId: 'sheet.host.broadcast_composer',
      children: const [
        _StateCard(
          label: 'template review surface',
          child: _HostBroadcastComposerFrame(),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Sliver states',
  type: ChatsList,
  path: '[P1 product surfaces]/Matches and chat/Components',
)
Widget chatsListSliverStates(BuildContext context) {
  return _AppRoleBoundary(
    role: AppRole.consumer,
    child: _MatchesCatalog(
      title: 'ChatsList',
      contractId: 'component.messaging.chats_list',
      children: [
        _StateCard(
          label: 'loaded sliver',
          child: _DeviceFrame(
            height: 420,
            child: _MatchesListRouteScope(
              viewModel: AsyncData<ChatsListViewModel>(_consumerViewModel()),
              matches: _consumerMatches,
              child: Scaffold(
                body: SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      ChatsList(
                        displayState: ChatsListContent(
                          viewModel: _consumerViewModel(),
                        ),
                        onThreadSelected: (_) {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _StateCard(
          label: 'loading skeleton',
          child: _DeviceFrame(
            height: 360,
            child: _MatchesListRouteScope(
              viewModel: const AsyncLoading<ChatsListViewModel>(),
              matches: _consumerMatches,
              child: const Scaffold(
                body: SafeArea(
                  child: CustomScrollView(
                    slivers: [ChatsList(displayState: ChatsListLoading())],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Skeleton states',
  type: ChatsListSkeleton,
  path: '[P1 product surfaces]/Matches and chat/Components',
)
Widget chatsListSkeletonStates(BuildContext context) {
  return _AppRoleBoundary(
    role: AppRole.consumer,
    child: _MatchesCatalog(
      title: 'ChatsListSkeleton',
      contractId: 'component.messaging.chats_list_skeleton',
      children: const [
        _StateCard(
          label: 'consumer loading',
          child: _DeviceFrame(
            height: _chatsListSkeletonPreviewHeight,
            child: Scaffold(
              body: SafeArea(
                child: CustomScrollView(slivers: [ChatsListSkeleton()]),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Skeleton states',
  type: ChatPersonRowSkeleton,
  path: '[P1 product surfaces]/Matches and chat/Components',
)
Widget chatPersonRowSkeletonStates(BuildContext context) {
  return _MatchesCatalog(
    title: 'ChatPersonRowSkeleton',
    contractId: 'component.messaging.chat_person_row_skeleton',
    children: const [
      _StateCard(
        label: 'match row',
        child: ChatPersonRowSkeleton(divider: false, squareAvatar: false),
      ),
      _StateCard(
        label: 'host inquiry row',
        child: ChatPersonRowSkeleton(divider: true, squareAvatar: true),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Header states',
  type: ChatsBrowseHeader,
  path: '[P1 product surfaces]/Matches and chat/Components',
)
Widget chatsBrowseHeaderStates(BuildContext context) {
  return _AppRoleBoundary(
    role: AppRole.host,
    child: _MatchesCatalog(
      title: 'ChatsBrowseHeader',
      contractId: 'component.messaging.chats_browse_header',
      children: [
        _StateCard(
          label: 'host inbox filters',
          child: _DeviceFrame(
            height: 180,
            child: _MatchesListRouteScope(
              viewModel: AsyncData<ChatsListViewModel>(_hostInboxViewModel()),
              matches: _hostMatches,
              child: Scaffold(
                body: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ChatsBrowseHeader(
                        showSearchAction: true,
                        searchValue: '',
                        onSearchChanged: (_) {},
                        hostFilter: HostInboxFilter.all,
                        hostUnreadCount: 2,
                        onHostFilterChanged: (_) {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Body states',
  type: ChatsListBody,
  path: '[P1 product surfaces]/Matches and chat/Components',
)
Widget chatsListBodyStates(BuildContext context) {
  return _AppRoleBoundary(
    role: AppRole.consumer,
    child: _MatchesCatalog(
      title: 'ChatsListBody',
      contractId: 'component.messaging.chats_list_body',
      children: [
        _StateCard(
          label: 'consumer conversations',
          child: _ChatSliverFrame(
            slivers: [
              ChatsListBody(
                viewModel: _consumerViewModel(),
                onThreadSelected: (_) {},
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Sliver states',
  type: ChatConversationsList,
  path: '[P1 product surfaces]/Matches and chat/Components',
)
Widget chatConversationsListStates(BuildContext context) {
  final viewModel = _consumerViewModel();
  return _AppRoleBoundary(
    role: AppRole.consumer,
    child: _MatchesCatalog(
      title: 'ChatConversationsList',
      contractId: 'component.messaging.chat_conversations_list',
      children: [
        _StateCard(
          label: 'contiguous rows',
          child: _ChatSliverFrame(
            height: 360,
            slivers: [
              ChatConversationsList(
                matches: [...viewModel.newMatches, ...viewModel.conversations],
                onThreadSelected: (_) {},
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Empty states',
  type: ChatsEmptyState,
  path: '[P1 product surfaces]/Matches and chat/Components',
)
Widget chatsEmptyStateVariants(BuildContext context) {
  return _AppRoleBoundary(
    role: AppRole.consumer,
    child: _MatchesCatalog(
      title: 'ChatsEmptyState',
      contractId: 'component.messaging.chats_empty_state',
      children: const [
        _StateCard(
          label: 'no catches',
          child: _PrimitiveReviewFrame(height: 360, child: ChatsEmptyState()),
        ),
        _StateCard(
          label: 'search empty',
          child: _PrimitiveReviewFrame(
            height: 360,
            child: ChatsEmptyState.noSearchResults(),
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Card states',
  type: HostInboxBroadcastCard,
  path: '[P1 product surfaces]/Matches and chat/Components',
)
Widget hostInboxBroadcastCardStates(BuildContext context) {
  return _AppRoleBoundary(
    role: AppRole.host,
    child: _MatchesCatalog(
      title: 'HostInboxBroadcastCard',
      contractId: 'component.messaging.host_inbox_broadcast_card',
      children: const [
        _StateCard(
          label: 'attendee blast affordance',
          child: _PrimitiveReviewFrame(
            height: 132,
            child: Padding(
              padding: CatchInsets.content,
              child: HostInboxBroadcastCard(threadCount: 8),
            ),
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Renderer states',
  type: ChatMessageList,
  path: '[P1 product surfaces]/Matches and chat/Components',
)
Widget chatMessageListRendererStates(BuildContext context) {
  return _AppRoleBoundary(
    role: AppRole.consumer,
    child: _MatchesCatalog(
      title: 'ChatMessageList',
      contractId: 'component.messaging.chat_message_list',
      children: [
        const _StateCard(
          label: 'loading skeleton',
          child: _ChatMessageListFrame(
            messages: AsyncLoading<List<ChatMessage>>(),
          ),
        ),
        _StateCard(
          label: 'populated messages',
          child: _ChatMessageListFrame(
            messages: AsyncData<List<ChatMessage>>(
              MatchesChatSurfaceFixtures.conversationMessages,
            ),
            event: _event,
          ),
        ),
        _StateCard(
          label: 'empty event-grounded prompt',
          child: _ChatMessageListFrame(
            messages: const AsyncData<List<ChatMessage>>([]),
            event: _event,
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Sheet states',
  type: CatchShareCardSheet,
  path: '[P1 product surfaces]/Matches and chat/Components',
)
Widget chatShareCardSheetStates(BuildContext context) {
  return _AppRoleBoundary(
    role: AppRole.consumer,
    child: _MatchesCatalog(
      title: 'CatchShareCardSheet',
      contractId: 'sheet.messaging.chat_share_card',
      children: [
        _StateCard(
          label: 'export preview',
          child: _DeviceFrame(
            height: 640,
            child: _ShareCardPreview(
              messages: MatchesChatSurfaceFixtures.conversationMessages,
              event: _event,
            ),
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Card states',
  type: ChatShareCard,
  path: '[P1 product surfaces]/Matches and chat/Components',
)
Widget chatShareCardStates(BuildContext context) {
  return _AppRoleBoundary(
    role: AppRole.consumer,
    child: _MatchesCatalog(
      title: 'ChatShareCard',
      contractId: 'component.messaging.chat_share_card',
      children: [
        _StateCard(
          label: 'event conversation card',
          child: _PrimitiveReviewFrame(
            height: 440,
            child: Padding(
              padding: CatchInsets.content,
              child: ChatShareCard(
                messages: MatchesChatSurfaceFixtures.conversationMessages,
                currentUid: MatchesChatSurfaceFixtures.viewerUid,
                event: _event,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Share card header',
  type: ShareCardHeader,
  path: '[P1 product surfaces]/Matches and chat/Components',
)
Widget chatShareCardHeaderState(BuildContext context) {
  final t = CatchTokens.of(context);

  return Padding(
    padding: CatchInsets.content,
    child: ShareCardHeader(event: _event, accent: t.primary, visual: null),
  );
}

@widgetbook.UseCase(
  name: 'Share card bubbles',
  type: ShareCardBubble,
  path: '[P1 product surfaces]/Matches and chat/Components',
)
Widget chatShareCardBubbleStates(BuildContext context) {
  return const Padding(
    padding: CatchInsets.content,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ShareCardBubble(
          text: 'That was weirdly easy to say yes to.',
          isMe: false,
          isFirstInGroup: true,
          isLastInGroup: false,
        ),
        ShareCardBubble(
          text: 'Same. Coffee after?',
          isMe: true,
          isFirstInGroup: true,
          isLastInGroup: true,
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Dialog states',
  type: MatchCelebrationDialog,
  path: '[P1 product surfaces]/Matches and chat/Components',
)
Widget matchCelebrationDialogStates(BuildContext context) {
  return _AppRoleBoundary(
    role: AppRole.consumer,
    child: _MatchesCatalog(
      title: 'MatchCelebrationDialog',
      contractId: 'dialog.matches.celebration',
      children: [
        _StateCard(
          label: 'new catch',
          child: _DeviceFrame(
            child: _MatchesListRouteScope(
              viewModel: AsyncData<ChatsListViewModel>(_consumerViewModel()),
              matches: _consumerMatches,
              child: _CelebrationPreview(match: _taylorMatch),
            ),
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Route states',
  type: ChatScreen,
  path: '[P1 product surfaces]/Matches and chat',
)
Widget matchChatRouteStates(BuildContext context) {
  return _AppRoleBoundary(
    role: AppRole.consumer,
    child: _MatchesCatalog(
      title: 'ChatScreen',
      contractId: 'screen.matches.chat',
      children: [
        _StateCard(
          label: 'messages loading',
          child: _DeviceFrame(
            child: _ChatRouteScope(match: _taylorMatch, messagesLoading: true),
          ),
        ),
        _StateCard(
          label: 'messages error',
          child: _DeviceFrame(
            child: _ChatRouteScope(
              match: _taylorMatch,
              messagesError: StateError('Messages failed'),
            ),
          ),
        ),
        _StateCard(
          label: 'offline message error',
          child: _DeviceFrame(
            child: _ChatRouteScope(
              match: _taylorMatch,
              messagesError: MatchesChatSurfaceFixtures.offlineException(
                action: 'load conversation messages',
              ),
            ),
          ),
        ),
        _StateCard(
          label: 'empty thread',
          child: _DeviceFrame(
            child: _ChatRouteScope(
              match: MatchesChatSurfaceFixtures.newMatch(),
              messages: const [],
            ),
          ),
        ),
        _StateCard(
          label: 'populated thread',
          child: _DeviceFrame(
            child: _ChatRouteScope(
              match: _taylorMatch,
              messages: MatchesChatSurfaceFixtures.conversationMessages,
            ),
          ),
        ),
        _StateCard(
          label: 'image attachment thread',
          child: _DeviceFrame(
            child: _ChatRouteScope(
              match: _taylorMatch,
              messages: MatchesChatSurfaceFixtures.imageMessages,
            ),
          ),
        ),
        _StateCard(
          label: 'chat unavailable',
          child: _DeviceFrame(
            child: _ChatRouteScope(match: null, matchId: 'missing-match'),
          ),
        ),
        _StateCard(
          label: 'blocked chat',
          child: _DeviceFrame(
            child: _ChatRouteScope(
              match: _blockedMatch,
              messages: MatchesChatSurfaceFixtures.conversationMessages,
            ),
          ),
        ),
        _StateCard(
          label: 'host inquiry identity',
          child: _DeviceFrame(
            child: _ChatRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              match: _hostMatches.first,
              messages: [
                MatchesChatSurfaceFixtures.message(
                  id: 'host-msg-1',
                  senderId: MatchesChatSurfaceFixtures.guestUid,
                  text: 'Is there parking near the start?',
                  sentAt: MatchesChatSurfaceFixtures.now.subtract(
                    const Duration(minutes: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
        _StateCard(
          label: 'Suvbot controls',
          child: _DeviceFrame(
            child: _ChatRouteScope(
              match: _suvbotMatch,
              messages: [
                MatchesChatSurfaceFixtures.message(
                  id: 'suvbot-msg-1',
                  senderId: suvbotUid,
                  text: 'I can refresh your seeded demo state.',
                  sentAt: MatchesChatSurfaceFixtures.now.subtract(
                    const Duration(minutes: 3),
                  ),
                ),
              ],
            ),
          ),
        ),
        _StateCard(
          label: 'Suvbot action error',
          child: _DeviceFrame(
            child: _ChatRouteScope(
              match: _suvbotMatch,
              messages: const [],
              suvbotRepository: MatchesChatFixtureSuvbotRepository(
                error: StateError('Suvbot failed'),
              ),
            ),
          ),
        ),
        _StateCard(
          label: 'share card sheet',
          child: _DeviceFrame(
            height: 640,
            child: _ShareCardPreview(
              messages: MatchesChatSurfaceFixtures.conversationMessages,
              event: _event,
            ),
          ),
        ),
        _StateCard(
          label: 'composer states',
          child: _DeviceFrame(
            height: 420,
            child: const _ComposerStatesPreview(),
          ),
        ),
        _StateCard(
          label: 'text scale 2.0',
          child: _DeviceFrame(
            child: _MediaOverride(
              textScaler: const TextScaler.linear(2),
              child: _ChatRouteScope(
                match: _taylorMatch,
                messages: MatchesChatSurfaceFixtures.conversationMessages,
              ),
            ),
          ),
        ),
        _StateCard(
          label: 'reduced motion',
          child: _DeviceFrame(
            child: _MediaOverride(
              disableAnimations: true,
              child: _ChatRouteScope(
                match: _taylorMatch,
                messages: MatchesChatSurfaceFixtures.conversationMessages,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Host chat states',
  type: ChatScreen,
  path: '[P1 product surfaces]/Matches and chat',
)
Widget hostChatRouteStates(BuildContext context) {
  return _AppRoleBoundary(
    role: AppRole.host,
    child: _MatchesCatalog(
      title: 'ChatScreen host inquiry',
      contractId: 'screen.host.chat',
      children: [
        _StateCard(
          label: 'match loading',
          child: _DeviceFrame(
            child: _ChatRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              match: _hostMatches.first,
              matchLoading: true,
              hostRoute: true,
            ),
          ),
        ),
        _StateCard(
          label: 'match error',
          child: _DeviceFrame(
            child: _ChatRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              match: _hostMatches.first,
              matchError: StateError('Host chat failed'),
              hostRoute: true,
            ),
          ),
        ),
        _StateCard(
          label: 'chat unavailable',
          child: _DeviceFrame(
            child: const _ChatRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              match: null,
              matchId: 'design-host-chat-missing',
              hostRoute: true,
            ),
          ),
        ),
        _StateCard(
          label: 'host inquiry identity',
          child: _DeviceFrame(
            child: _ChatRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              match: _hostMatches.first,
              hostRoute: true,
              messages: [
                MatchesChatSurfaceFixtures.message(
                  id: 'host-msg-1',
                  senderId: MatchesChatSurfaceFixtures.guestUid,
                  text: 'Is there parking near the start?',
                  sentAt: MatchesChatSurfaceFixtures.now.subtract(
                    const Duration(minutes: 18),
                  ),
                ),
                MatchesChatSurfaceFixtures.message(
                  id: 'host-msg-2',
                  senderId: MatchesChatSurfaceFixtures.hostUid,
                  text: 'Yes. Park by the promenade and meet at the jetty.',
                  sentAt: MatchesChatSurfaceFixtures.now.subtract(
                    const Duration(minutes: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        _StateCard(
          label: 'messages loading',
          child: _DeviceFrame(
            child: _ChatRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              match: _hostMatches.first,
              hostRoute: true,
              messagesLoading: true,
            ),
          ),
        ),
        _StateCard(
          label: 'messages error',
          child: _DeviceFrame(
            child: _ChatRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              match: _hostMatches.first,
              hostRoute: true,
              messagesError: StateError('Host messages failed'),
            ),
          ),
        ),
        _StateCard(
          label: 'offline message error',
          child: _DeviceFrame(
            child: _ChatRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              match: _hostMatches.first,
              hostRoute: true,
              messagesError: MatchesChatSurfaceFixtures.offlineException(
                action: 'load host inquiry messages',
              ),
            ),
          ),
        ),
        _StateCard(
          label: 'empty inquiry thread',
          child: _DeviceFrame(
            child: _ChatRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              match: _hostMatches.first,
              hostRoute: true,
              messages: const [],
            ),
          ),
        ),
        _StateCard(
          label: 'event context fallback',
          child: _DeviceFrame(
            child: _ChatRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              match: _hostMatches.first,
              hostRoute: true,
              includeEvent: false,
              messages: MatchesChatSurfaceFixtures.conversationMessages,
            ),
          ),
        ),
        _StateCard(
          label: 'blocked host chat',
          child: _DeviceFrame(
            child: _ChatRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              match: _hostMatches.first.copyWith(
                status: MatchStatus.blocked,
                blockedBy: MatchesChatSurfaceFixtures.guestUid,
                blockedAt: MatchesChatSurfaceFixtures.now.subtract(
                  const Duration(hours: 2),
                ),
              ),
              hostRoute: true,
              messages: MatchesChatSurfaceFixtures.conversationMessages,
            ),
          ),
        ),
        _StateCard(
          label: 'composer states',
          child: _DeviceFrame(
            height: 420,
            child: const _ComposerStatesPreview(),
          ),
        ),
        _StateCard(
          label: 'text scale 2.0',
          child: _DeviceFrame(
            child: _MediaOverride(
              textScaler: const TextScaler.linear(2),
              child: _ChatRouteScope(
                uid: MatchesChatSurfaceFixtures.hostUid,
                match: _hostMatches.first,
                hostRoute: true,
                messages: MatchesChatSurfaceFixtures.conversationMessages,
              ),
            ),
          ),
        ),
        _StateCard(
          label: 'reduced motion',
          child: _DeviceFrame(
            child: _MediaOverride(
              disableAnimations: true,
              child: _ChatRouteScope(
                uid: MatchesChatSurfaceFixtures.hostUid,
                match: _hostMatches.first,
                hostRoute: true,
                messages: MatchesChatSurfaceFixtures.conversationMessages,
              ),
            ),
          ),
        ),
        _StateCard(
          label: 'dark theme',
          child: _DeviceFrame(
            child: _ChatRouteScope(
              uid: MatchesChatSurfaceFixtures.hostUid,
              match: _hostMatches.first,
              hostRoute: true,
              themeMode: ThemeMode.dark,
              messages: MatchesChatSurfaceFixtures.conversationMessages,
            ),
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Primitive states',
  type: ChatEventContextHeader,
  path: '[P1 product surfaces]/Matches and chat/Primitives',
)
Widget chatEventContextHeaderPrimitiveStates(BuildContext context) {
  return _AppRoleBoundary(
    role: AppRole.consumer,
    child: _MatchesCatalog(
      title: 'ChatEventContextHeader',
      contractId: 'primitive.messaging.chat_event_context_header',
      children: [
        _StateCard(
          label: 'social run context',
          child: _PrimitiveReviewFrame(
            height: 132,
            child: ChatEventContextHeader(event: _event),
          ),
        ),
        _StateCard(
          label: 'fallback without event',
          child: const _PrimitiveReviewFrame(
            height: 132,
            child: ChatEventContextHeader(event: null),
          ),
        ),
        _StateCard(
          label: 'dinner context',
          child: _PrimitiveReviewFrame(
            height: 132,
            child: ChatEventContextHeader(
              event: _event.copyWith(
                eventFormat: EventFormatSnapshot.fromActivityKind(
                  ActivityKind.dinner,
                ),
                startTime: DateTime(2026, 6, 25, 20),
                endTime: DateTime(2026, 6, 25, 22),
                meetingPoint: 'Long Table, Colaba',
                distanceKm: 0,
                pace: PaceLevel.easy,
              ),
            ),
          ),
        ),
        _StateCard(
          label: 'long custom event title',
          child: _PrimitiveReviewFrame(
            height: 132,
            child: ChatEventContextHeader(
              event: _event.copyWith(
                eventFormat: EventFormatSnapshot.custom(
                  label: 'Community art walk and tasting',
                  interactionModel: EventInteractionModel.freeFormMixer,
                ),
                startTime: DateTime(2026, 6, 27, 18),
                endTime: DateTime(2026, 6, 27, 20),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Primitive states',
  type: MessageBubble,
  path: '[P1 product surfaces]/Matches and chat/Primitives',
)
Widget messageBubblePrimitiveStates(BuildContext context) {
  final now = MatchesChatSurfaceFixtures.now;

  return _AppRoleBoundary(
    role: AppRole.consumer,
    child: _MatchesCatalog(
      title: 'MessageBubble',
      contractId: 'primitive.messaging.message_bubble',
      children: [
        _StateCard(
          label: 'self and other messages',
          child: _MessageBubblePrimitiveFrame(
            children: [
              MessageBubble(
                text: 'That final kilometer was harder than advertised.',
                isMe: false,
                sentAt: now.subtract(const Duration(minutes: 42)),
              ),
              MessageBubble(
                text: 'Worth it for the sea-facing coffee plan.',
                isMe: true,
                sentAt: now.subtract(const Duration(minutes: 40)),
              ),
            ],
          ),
        ),
        _StateCard(
          label: 'long copy wraps with timestamp',
          child: _MessageBubblePrimitiveFrame(
            height: 280,
            children: [
              MessageBubble(
                text: _longIncomingMessageCopy,
                isMe: false,
                sentAt: now.subtract(const Duration(minutes: 28)),
              ),
              MessageBubble(
                text: _longOutgoingMessageCopy,
                isMe: true,
                sentAt: now.subtract(const Duration(minutes: 24)),
              ),
            ],
          ),
        ),
        _StateCard(
          label: 'grouped and sending',
          child: _MessageBubblePrimitiveFrame(
            children: [
              MessageBubble(
                text: 'Same route next week?',
                isMe: false,
                sentAt: now.subtract(const Duration(minutes: 12)),
                isFirstInGroup: true,
                isLastInGroup: false,
              ),
              MessageBubble(
                text: 'I can do Thursday.',
                isMe: false,
                sentAt: now.subtract(const Duration(minutes: 11)),
                isFirstInGroup: false,
              ),
              const MessageBubble(
                text: 'Checking the club calendar now.',
                isMe: true,
                sentAt: null,
              ),
            ],
          ),
        ),
        _StateCard(
          label: 'image attachment',
          child: _MessageBubblePrimitiveFrame(
            height: 320,
            children: [
              MessageBubble(
                text: 'Route card from tonight.',
                imageUrl:
                    MatchesChatSurfaceFixtures.imageMessages.first.imageUrl,
                isMe: true,
                sentAt: now.subtract(const Duration(minutes: 12)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Primitive states',
  type: ChatInputBar,
  path: '[P1 product surfaces]/Matches and chat/Primitives',
)
Widget chatInputBarPrimitiveStates(BuildContext context) {
  return _AppRoleBoundary(
    role: AppRole.consumer,
    child: _MatchesCatalog(
      title: 'ChatInputBar',
      contractId: 'primitive.messaging.chat_input_bar',
      children: const [
        _StateCard(
          label: 'default ready',
          child: _ChatInputBarPrimitiveFrame(
            state: _ComposerPrimitiveState.ready,
          ),
        ),
        _StateCard(
          label: 'sending text',
          child: _ChatInputBarPrimitiveFrame(
            state: _ComposerPrimitiveState.sendingText,
          ),
        ),
        _StateCard(
          label: 'sending image',
          child: _ChatInputBarPrimitiveFrame(
            state: _ComposerPrimitiveState.sendingImage,
          ),
        ),
        _StateCard(
          label: 'disabled closed chat',
          child: _ChatInputBarPrimitiveFrame(
            state: _ComposerPrimitiveState.disabled,
          ),
        ),
        _StateCard(
          label: 'text only no image action',
          child: _ChatInputBarPrimitiveFrame(
            state: _ComposerPrimitiveState.textOnly,
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Timestamped message text',
  type: TimestampedMessageText,
  path: '[P1 product surfaces]/Matches and chat/Primitives',
)
Widget timestampedMessageTextState(BuildContext context) {
  final t = CatchTokens.of(context);

  return Padding(
    padding: CatchInsets.content,
    child: TimestampedMessageText(
      text: 'That final kilometer was harder than advertised.',
      timestamp: '7:42 PM',
      textStyle: CatchTextStyles.chatMessage(context, color: t.ink),
      timestampStyle: CatchTextStyles.meta(context, color: t.ink3),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Media message body',
  type: MediaMessageBody,
  path: '[P1 product surfaces]/Matches and chat/Primitives',
)
Widget mediaMessageBodyState(BuildContext context) {
  final t = CatchTokens.of(context);

  return Padding(
    padding: CatchInsets.content,
    child: MediaMessageBody(
      text: 'Route card from tonight.',
      timestamp: '8:04 PM',
      imageUrl: MatchesChatSurfaceFixtures.imageMessages.first.imageUrl,
      textStyle: CatchTextStyles.chatMessage(context, color: t.ink),
      timestampStyle: CatchTextStyles.meta(context, color: t.ink3),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Primitive states',
  type: SuvbotActionBar,
  path: '[P1 product surfaces]/Matches and chat/Primitives',
)
Widget suvbotActionBarPrimitiveStates(BuildContext context) {
  return _AppRoleBoundary(
    role: AppRole.consumer,
    child: _MatchesCatalog(
      title: 'SuvbotActionBar',
      contractId: 'primitive.messaging.suvbot_action_bar',
      children: [
        _StateCard(
          label: 'loaded actions',
          child: _SuvbotActionBarPrimitiveFrame(
            actions: AsyncData<List<SuvbotActionItem>>(
              MatchesChatSurfaceFixtures.suvbotActions,
            ),
          ),
        ),
        _StateCard(
          label: 'pending action',
          child: _SuvbotActionBarPrimitiveFrame(
            actions: AsyncData<List<SuvbotActionItem>>(
              MatchesChatSurfaceFixtures.suvbotActions,
            ),
            pending: true,
          ),
        ),
        const _StateCard(
          label: 'loading',
          child: _SuvbotActionBarPrimitiveFrame(
            actions: AsyncLoading<List<SuvbotActionItem>>(),
          ),
        ),
        _StateCard(
          label: 'load error',
          child: _SuvbotActionBarPrimitiveFrame(
            actions: AsyncError<List<SuvbotActionItem>>(
              StateError('Suvbot controls unavailable'),
              StackTrace.empty,
            ),
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Primitive states',
  type: SuvbotResetActionRow,
  path: '[P1 product surfaces]/Matches and chat/Primitives',
)
Widget suvbotResetActionRowPrimitiveStates(BuildContext context) {
  const resetActionIds = {
    'resetChats',
    'resetBookings',
    'resetNotifications',
    'clearDemoState',
  };
  final resetActions = MatchesChatSurfaceFixtures.suvbotActions
      .where((action) => resetActionIds.contains(action.id))
      .toList(growable: false);

  return _AppRoleBoundary(
    role: AppRole.consumer,
    child: _MatchesCatalog(
      title: 'SuvbotResetActionRow',
      contractId: 'primitive.messaging.suvbot_reset_action_row',
      children: [
        _StateCard(
          label: 'destructive reset actions',
          child: _SuvbotResetActionRowsFrame(actions: resetActions),
        ),
        _StateCard(
          label: 'pending disabled',
          child: _SuvbotResetActionRowsFrame(
            actions: resetActions,
            pending: true,
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Sheet states',
  type: MatchTesterSheet,
  path: '[P1 product surfaces]/Matches and chat/Primitives',
)
Widget matchTesterSheetStates(BuildContext context) {
  final action = MatchesChatSurfaceFixtures.suvbotActions.firstWhere(
    (action) => action.id == 'matchTesterByPhone',
  );

  return _AppRoleBoundary(
    role: AppRole.consumer,
    child: _MatchesCatalog(
      title: 'MatchTesterSheet',
      contractId: 'sheet.messaging.match_tester',
      children: [
        _StateCard(
          label: 'ready for phone input',
          child: _MatchTesterSheetFrame(action: action),
        ),
        _StateCard(
          label: 'pending submit',
          child: _MatchTesterSheetFrame(action: action, pending: true),
        ),
      ],
    ),
  );
}

Widget catchPersonRowChatPreviewPrimitiveStates(BuildContext context) {
  final readMatch = _taylorMatch.copyWith(unreadCounts: const {});
  final longCopyMatch = MatchesChatSurfaceFixtures.activeConversationMatch(
    id: 'design-match-long-copy',
    preview:
        'I checked with the host and the post-run coffee table can fit everyone if we arrive together.',
    lastMessageAt: MatchesChatSurfaceFixtures.now.subtract(
      const Duration(minutes: 9),
    ),
  );

  return _AppRoleBoundary(
    role: AppRole.consumer,
    child: _MatchesCatalog(
      title: 'CatchPersonRow chat previews',
      contractId: 'primitive.messaging.person_row_chat_preview',
      children: [
        _StateCard(
          label: 'default read conversation',
          child: _CatchPersonRowChatPreviewFrame(
            preview: _threadPreviewFor(
              match: readMatch,
              uid: MatchesChatSurfaceFixtures.viewerUid,
            ),
          ),
        ),
        _StateCard(
          label: 'unread active conversation',
          child: _CatchPersonRowChatPreviewFrame(
            preview: _threadPreviewFor(
              match: _taylorMatch,
              uid: MatchesChatSurfaceFixtures.viewerUid,
            ),
          ),
        ),
        _StateCard(
          label: 'new match indicator',
          child: _CatchPersonRowChatPreviewFrame(
            preview: _threadPreviewFor(
              match: MatchesChatSurfaceFixtures.newMatch(),
              uid: MatchesChatSurfaceFixtures.viewerUid,
            ),
          ),
        ),
        _StateCard(
          label: 'own latest message',
          child: _CatchPersonRowChatPreviewFrame(
            preview: _threadPreviewFor(
              match: MatchesChatSurfaceFixtures.ownLatestMessageMatch(),
              uid: MatchesChatSurfaceFixtures.viewerUid,
            ),
          ),
        ),
        _StateCard(
          label: 'host inquiry unread',
          child: _CatchPersonRowChatPreviewFrame(
            preview: _threadPreviewFor(
              match: _hostMatches.first,
              uid: MatchesChatSurfaceFixtures.hostUid,
            ),
          ),
        ),
        _StateCard(
          label: 'long preview truncation',
          child: _CatchPersonRowChatPreviewFrame(
            preview: _threadPreviewFor(
              match: longCopyMatch,
              uid: MatchesChatSurfaceFixtures.viewerUid,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ChatSliverFrame extends StatelessWidget {
  const _ChatSliverFrame({required this.slivers, this.height = 420});

  final List<Widget> slivers;
  final double height;

  @override
  Widget build(BuildContext context) {
    return _DeviceFrame(
      height: height,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          return Scaffold(
            backgroundColor: t.bg,
            body: SafeArea(child: CustomScrollView(slivers: slivers)),
          );
        },
      ),
    );
  }
}

class _ChatMessageListFrame extends StatefulWidget {
  const _ChatMessageListFrame({required this.messages, this.event});

  final AsyncValue<List<ChatMessage>> messages;
  final Event? event;

  @override
  State<_ChatMessageListFrame> createState() => _ChatMessageListFrameState();
}

class _ChatMessageListFrameState extends State<_ChatMessageListFrame> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DeviceFrame(
      height: 420,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          return Scaffold(
            backgroundColor: t.bg,
            body: SafeArea(
              child: ChatMessageList(
                messagesAsync: widget.messages,
                currentUid: MatchesChatSurfaceFixtures.viewerUid,
                otherName: 'Taylor',
                event: widget.event,
                scrollController: _scrollController,
                onRetry: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MatchesListRouteScope extends StatelessWidget {
  const _MatchesListRouteScope({
    required this.viewModel,
    required this.matches,
    this.uid = MatchesChatSurfaceFixtures.viewerUid,
    this.query = '',
    this.initialLocation = '/chats',
    this.themeMode = ThemeMode.light,
    this.child,
  });

  final AsyncValue<ChatsListViewModel> viewModel;
  final List<Match> matches;
  final String? uid;
  final String query;
  final String initialLocation;
  final ThemeMode themeMode;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final effectiveUid = uid;
    final matchRepository = MatchesChatFixtureMatchRepository(matches: matches);

    return ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(AsyncData<String?>(effectiveUid)),
        chatsListViewModelProvider.overrideWithValue(viewModel),
        matchRepositoryProvider.overrideWithValue(matchRepository),
        conversationRepositoryProvider.overrideWithValue(
          MatchesChatFixtureConversationRepository(
            messagesByConversationId: {
              _taylorMatch.id: MatchesChatSurfaceFixtures.conversationMessages,
              for (final match in matches) match.id: const <ChatMessage>[],
            },
          ),
        ),
        if (effectiveUid != null)
          watchMatchesForUserProvider(
            effectiveUid,
          ).overrideWith((ref) => Stream<List<Match>>.value(matches)),
        watchEventProvider(
          MatchesChatSurfaceFixtures.eventId,
        ).overrideWith((ref) => Stream<Event?>.value(_event)),
        watchClubProvider(
          MatchesChatSurfaceFixtures.clubId,
        ).overrideWith((ref) => Stream.value(_club)),
        ..._publicProfileOverrides,
      ],
      child: _SeedChatSearchQuery(
        query: query,
        child:
            child ??
            _MatchesListRouter(
              initialLocation: initialLocation,
              themeMode: themeMode,
            ),
      ),
    );
  }
}

class _ChatRouteScope extends StatelessWidget {
  const _ChatRouteScope({
    this.uid = MatchesChatSurfaceFixtures.viewerUid,
    this.match,
    this.matchId,
    this.messages,
    this.matchLoading = false,
    this.matchError,
    this.messagesLoading = false,
    this.messagesError,
    this.includeEvent = true,
    this.hostRoute = false,
    this.themeMode = ThemeMode.light,
    this.suvbotRepository = const MatchesChatFixtureSuvbotRepository(),
  });

  final String? uid;
  final Match? match;
  final String? matchId;
  final List<ChatMessage>? messages;
  final bool matchLoading;
  final Object? matchError;
  final bool messagesLoading;
  final Object? messagesError;
  final bool includeEvent;
  final bool hostRoute;
  final ThemeMode themeMode;
  final SuvbotRepository suvbotRepository;

  @override
  Widget build(BuildContext context) {
    final id = matchId ?? match?.id ?? 'design-chat-missing';
    final effectiveMessages =
        messages ?? MatchesChatSurfaceFixtures.conversationMessages;
    final matches = match == null ? <Match>[] : <Match>[match!];
    final matchRepository = MatchesChatFixtureMatchRepository(
      matches: matches,
      matchById: {id: match},
      matchError: matchError,
    );
    final conversationRepository = MatchesChatFixtureConversationRepository(
      messagesByConversationId: {id: effectiveMessages},
      loading: messagesLoading,
      messagesError: messagesError,
      failSends: true,
    );

    return ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(AsyncData<String?>(uid)),
        matchRepositoryProvider.overrideWithValue(matchRepository),
        conversationRepositoryProvider.overrideWithValue(
          conversationRepository,
        ),
        suvbotRepositoryProvider.overrideWithValue(suvbotRepository),
        safetyRepositoryProvider.overrideWithValue(
          const MatchesChatFixtureSafetyRepository(),
        ),
        externalShareControllerProvider.overrideWithValue(
          ExternalShareController((_) async {}),
        ),
        matchStreamProvider(id).overrideWith((ref) {
          if (matchLoading) return MatchesChatSurfaceFixtures.loadingStream();
          if (matchError != null) {
            return Stream<Match?>.error(matchError!, StackTrace.empty);
          }
          return Stream<Match?>.value(match);
        }),
        watchConversationMessagesProvider(id).overrideWith(
          (ref) => conversationRepository.watchMessages(conversationId: id),
        ),
        watchEventProvider(MatchesChatSurfaceFixtures.eventId).overrideWith(
          (ref) => Stream<Event?>.value(includeEvent ? _event : null),
        ),
        watchClubProvider(
          MatchesChatSurfaceFixtures.clubId,
        ).overrideWith((ref) => Stream.value(_club)),
        ..._publicProfileOverrides,
      ],
      child: _ChatRouter(
        initialLocation: hostRoute
            ? '${Routes.hostInboxScreen.path}/$id'
            : '${Routes.matchesListScreen.path}/$id',
        themeMode: themeMode,
      ),
    );
  }
}

class _MatchesListRouter extends StatelessWidget {
  const _MatchesListRouter({
    required this.initialLocation,
    required this.themeMode,
  });

  final String initialLocation;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: Routes.matchesListScreen.path,
          name: Routes.matchesListScreen.name,
          builder: (_, _) => const ChatsListScreen(),
          routes: [
            GoRoute(
              path: ':matchId',
              name: Routes.chatScreen.name,
              builder: (_, state) => ChatScreen(
                matchId: state.pathParameters['matchId']!,
                otherProfile: _profileForRouteExtra(state.extra),
              ),
            ),
          ],
        ),
        GoRoute(
          path: Routes.hostInboxScreen.path,
          name: Routes.hostInboxScreen.name,
          builder: (_, _) => const ChatsListScreen(),
          routes: [
            GoRoute(
              path: ':matchId',
              name: Routes.hostChatScreen.name,
              builder: (_, state) => ChatScreen(
                matchId: state.pathParameters['matchId']!,
                otherProfile: _profileForRouteExtra(state.extra),
              ),
            ),
          ],
        ),
        _publicProfileRoute,
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

class _ChatRouter extends StatelessWidget {
  const _ChatRouter({
    required this.initialLocation,
    this.themeMode = ThemeMode.light,
  });

  final String initialLocation;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: Routes.chatScreen.path,
          name: Routes.chatScreen.name,
          builder: (_, state) => ChatScreen(
            matchId: state.pathParameters['matchId']!,
            otherProfile: _profileForRouteExtra(state.extra),
          ),
        ),
        GoRoute(
          path: Routes.hostChatScreen.path,
          name: Routes.hostChatScreen.name,
          builder: (_, state) => ChatScreen(
            matchId: state.pathParameters['matchId']!,
            otherProfile: _profileForRouteExtra(state.extra),
          ),
        ),
        _publicProfileRoute,
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

final _publicProfileRoute = GoRoute(
  path: Routes.publicProfileScreen.path,
  name: Routes.publicProfileScreen.name,
  builder: (_, state) {
    final uid = state.pathParameters['uid']!;
    final profile = MatchesChatSurfaceFixtures.profileFor(uid);
    return Scaffold(
      body: Center(
        child: Text(
          profile.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
    );
  },
);

PublicProfile? _profileForRouteExtra(Object? extra) {
  return extra is PublicProfile ? extra : null;
}

class _HostUnreadOnlyInbox extends StatelessWidget {
  const _HostUnreadOnlyInbox();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            ...CatchSliverHeader(
              title: const SizedBox.shrink(),
              bottomHeight: chatsBrowseHeaderHeight(hasHostFilter: true),
              bottom: ChatsBrowseHeader(
                showSearchAction: true,
                searchValue: '',
                onSearchChanged: null,
                hostFilter: HostInboxFilter.unread,
                hostUnreadCount: 0,
                onHostFilterChanged: (_) {},
              ),
            ).buildSlivers(context),
            const ChatsList(hostFilter: HostInboxFilter.unread),
          ],
        ),
      ),
    );
  }
}

class _CelebrationPreview extends StatelessWidget {
  const _CelebrationPreview({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    return MatchCelebrationDialog(
      match: match,
      otherUid: match.otherId(MatchesChatSurfaceFixtures.viewerUid),
      onSendMessage: () {},
      onKeepSwiping: () {},
    );
  }
}

class _ThreadTileVariants extends StatelessWidget {
  const _ThreadTileVariants({required this.viewModel});

  final ChatsListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final previews = [...viewModel.newMatches, ...viewModel.conversations];
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: CatchInsets.chatListGutter,
          children: [
            for (final (index, preview) in previews.indexed)
              _chatPersonRowForPreview(
                preview,
                divider: index > 0,
                onTap: () {},
              ),
          ],
        ),
      ),
    );
  }
}

CatchPersonRow _chatPersonRowForPreview(
  ChatThreadPreview preview, {
  bool divider = false,
  VoidCallback? onTap,
}) {
  final unreadCount = preview.unreadCount;
  final isNew = !preview.hasConversation;
  return CatchPersonRow(
    data: CatchPersonRowData(
      name: preview.displayName,
      imageUrl: preview.photoUrl,
      lastMessage: preview.previewText,
      timestamp: AppTimeFormatters.chatTimestamp(preview.timestamp),
      unreadCount: unreadCount,
      isFresh: unreadCount > 0 || isNew,
      showFreshDot: unreadCount == 0 && isNew,
      avatarShape: preview.match.isClubHostInquiry
          ? CatchPersonAvatarShape.square
          : CatchPersonAvatarShape.circle,
    ),
    avatarSize: CatchLayout.chatListAvatarExtent,
    padding: CatchInsets.chatListTileVertical,
    divider: divider,
    showFreshBackground: false,
    onTap: onTap,
  );
}

class _HostBroadcastComposerFrame extends StatelessWidget {
  const _HostBroadcastComposerFrame();

  @override
  Widget build(BuildContext context) {
    return _DeviceFrame(
      height: 420,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          return Scaffold(
            backgroundColor: t.bg,
            body: const Align(
              alignment: Alignment.bottomCenter,
              child: HostBroadcastComposerSheet(),
            ),
          );
        },
      ),
    );
  }
}

class _ShareCardPreview extends StatelessWidget {
  const _ShareCardPreview({required this.messages, required this.event});

  final List<ChatMessage> messages;
  final Event event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: CatchShareCardSheet(
            card: ChatShareCard(
              messages: messages,
              currentUid: MatchesChatSurfaceFixtures.viewerUid,
              event: event,
            ),
            share: ExternalShareController((_) async {}),
            fileName: 'catch-chat-card.png',
            buttonLabel: 'Share card',
            footnote: 'Names, photos, and timestamps are hidden.',
            subject: 'Catch chat card',
            text: 'Shared from Catch.',
            maxWidth: CatchLayout.chatShareCardWidth,
            pixelRatio: CatchLayout.chatShareCardPixelRatio,
          ),
        ),
      ),
    );
  }
}

class _ComposerStatesPreview extends StatefulWidget {
  const _ComposerStatesPreview();

  @override
  State<_ComposerStatesPreview> createState() => _ComposerStatesPreviewState();
}

class _ComposerStatesPreviewState extends State<_ComposerStatesPreview> {
  late final TextEditingController _readyController;
  late final TextEditingController _sendingController;
  late final TextEditingController _imagePendingController;
  late final TextEditingController _disabledController;

  @override
  void initState() {
    super.initState();
    _readyController = TextEditingController(text: 'That last loop was fun.');
    _sendingController = TextEditingController(text: 'Sending this now...');
    _imagePendingController = TextEditingController(
      text: 'Uploading a photo...',
    );
    _disabledController = TextEditingController();
  }

  @override
  void dispose() {
    _readyController.dispose();
    _sendingController.dispose();
    _imagePendingController.dispose();
    _disabledController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            ChatInputBar(
              controller: _readyController,
              sending: false,
              onSend: () {},
              onSendImage: () {},
            ),
            gapH12,
            ChatInputBar(
              controller: _sendingController,
              sending: true,
              onSend: () {},
              onSendImage: () {},
            ),
            gapH12,
            ChatInputBar(
              controller: _imagePendingController,
              sending: false,
              sendingImage: true,
              onSend: () {},
              onSendImage: () {},
            ),
            gapH12,
            ChatInputBar(
              controller: _disabledController,
              sending: false,
              disabledReason: 'This chat is closed.',
              onSend: null,
              onSendImage: null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimitiveReviewFrame extends StatelessWidget {
  const _PrimitiveReviewFrame({required this.child, this.height = 180});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return _DeviceFrame(
      height: height,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          return Scaffold(
            backgroundColor: t.bg,
            body: SafeArea(
              child: Align(alignment: Alignment.topCenter, child: child),
            ),
          );
        },
      ),
    );
  }
}

class _MessageBubblePrimitiveFrame extends StatelessWidget {
  const _MessageBubblePrimitiveFrame({
    required this.children,
    this.height = 240,
  });

  final List<Widget> children;
  final double height;

  @override
  Widget build(BuildContext context) {
    return _DeviceFrame(
      height: height,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          return Scaffold(
            backgroundColor: t.bg,
            body: SafeArea(
              child: ListView(
                padding: CatchInsets.chatListGutter,
                children: children,
              ),
            ),
          );
        },
      ),
    );
  }
}

enum _ComposerPrimitiveState {
  ready,
  sendingText,
  sendingImage,
  disabled,
  textOnly,
}

class _ChatInputBarPrimitiveFrame extends StatefulWidget {
  const _ChatInputBarPrimitiveFrame({required this.state});

  final _ComposerPrimitiveState state;

  @override
  State<_ChatInputBarPrimitiveFrame> createState() =>
      _ChatInputBarPrimitiveFrameState();
}

class _ChatInputBarPrimitiveFrameState
    extends State<_ChatInputBarPrimitiveFrame> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _initialText);
  }

  @override
  void didUpdateWidget(covariant _ChatInputBarPrimitiveFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _controller.text = _initialText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _initialText {
    return switch (widget.state) {
      _ComposerPrimitiveState.ready => 'That last loop was fun.',
      _ComposerPrimitiveState.sendingText => 'Sending this now...',
      _ComposerPrimitiveState.sendingImage => 'Uploading a photo...',
      _ComposerPrimitiveState.disabled => '',
      _ComposerPrimitiveState.textOnly => 'No image for this reply.',
    };
  }

  @override
  Widget build(BuildContext context) {
    return _DeviceFrame(
      height: 132,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          final disabled = widget.state == _ComposerPrimitiveState.disabled;
          return Scaffold(
            backgroundColor: t.bg,
            body: SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  ChatInputBar(
                    controller: _controller,
                    sending:
                        widget.state == _ComposerPrimitiveState.sendingText,
                    sendingImage:
                        widget.state == _ComposerPrimitiveState.sendingImage,
                    disabledReason: disabled ? 'This chat is closed.' : null,
                    showImageButton:
                        widget.state != _ComposerPrimitiveState.textOnly,
                    onSend: disabled ? null : () {},
                    onSendImage: disabled ? null : () {},
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SuvbotActionBarPrimitiveFrame extends StatelessWidget {
  const _SuvbotActionBarPrimitiveFrame({
    required this.actions,
    this.pending = false,
  });

  final AsyncValue<List<SuvbotActionItem>> actions;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    return _DeviceFrame(
      height: 340,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          return Scaffold(
            backgroundColor: t.bg,
            body: SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  SuvbotActionBar(
                    actions: actions,
                    pending: pending,
                    onAction: (_) async {},
                    onTextAction: (_, _) async {},
                    onRetry: () {},
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SuvbotResetActionRowsFrame extends StatelessWidget {
  const _SuvbotResetActionRowsFrame({
    required this.actions,
    this.pending = false,
  });

  final List<SuvbotActionItem> actions;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    return _DeviceFrame(
      height: 280,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          return Scaffold(
            backgroundColor: t.bg,
            body: SafeArea(
              child: Padding(
                padding: CatchInsets.content,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: t.surface,
                    border: Border.all(color: t.line),
                    borderRadius: BorderRadius.circular(CatchRadius.md),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final (index, action) in actions.indexed) ...[
                        SuvbotResetActionRow(
                          action: action,
                          pending: pending,
                          onTap: () {},
                        ),
                        if (index != actions.length - 1)
                          const CatchDivider.fieldRow(indent: 0),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MatchTesterSheetFrame extends StatelessWidget {
  const _MatchTesterSheetFrame({required this.action, this.pending = false});

  final SuvbotActionItem action;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    return _DeviceFrame(
      height: 340,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          return Scaffold(
            backgroundColor: t.bg,
            body: SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: MatchTesterSheet(
                  action: action,
                  pending: pending,
                  onTextAction: (_, _) async {},
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CatchPersonRowChatPreviewFrame extends StatelessWidget {
  const _CatchPersonRowChatPreviewFrame({required this.preview});

  final ChatThreadPreview preview;

  @override
  Widget build(BuildContext context) {
    return _DeviceFrame(
      height: 132,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          return Scaffold(
            backgroundColor: t.bg,
            body: SafeArea(
              child: ListView(
                padding: CatchInsets.chatListGutter,
                children: [_chatPersonRowForPreview(preview, onTap: () {})],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SeedChatSearchQuery extends ConsumerStatefulWidget {
  const _SeedChatSearchQuery({required this.query, required this.child});

  final String query;
  final Widget child;

  @override
  ConsumerState<_SeedChatSearchQuery> createState() =>
      _SeedChatSearchQueryState();
}

class _SeedChatSearchQueryState extends ConsumerState<_SeedChatSearchQuery> {
  @override
  void initState() {
    super.initState();
    _seed();
  }

  @override
  void didUpdateWidget(covariant _SeedChatSearchQuery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) _seed();
  }

  void _seed() {
    final notifier = ref.read(chatSearchQueryProvider.notifier);
    if (widget.query.isEmpty) {
      notifier.clear();
    } else {
      notifier.setQuery(widget.query);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _AppRoleBoundary extends StatefulWidget {
  const _AppRoleBoundary({required this.role, required this.child});

  final AppRole role;
  final Widget child;

  @override
  State<_AppRoleBoundary> createState() => _AppRoleBoundaryState();
}

class _AppRoleBoundaryState extends State<_AppRoleBoundary> {
  @override
  void initState() {
    super.initState();
    AppConfig.configureEntrypointRole(widget.role);
  }

  @override
  void didUpdateWidget(covariant _AppRoleBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role != widget.role) {
      AppConfig.configureEntrypointRole(widget.role);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppConfig.configureEntrypointRole(widget.role);
    return widget.child;
  }
}

const _longIncomingMessageCopy =
    'I checked the event notes and the host moved the meetup point closer to the '
    'jetty, so we should still have enough time for coffee after.';

const _longOutgoingMessageCopy =
    'Perfect. I will book the next one once it goes live and send you the route '
    'card so we can compare the pace groups.';

class _MatchesCatalog extends StatelessWidget {
  const _MatchesCatalog({
    required this.title,
    required this.contractId,
    required this.children,
  });

  final String title;
  final String contractId;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: CatchInsets.content,
          children: [
            Text(title, style: CatchTextStyles.titleL(context)),
            gapH4,
            Text(
              contractId,
              style: CatchTextStyles.monoLabel(context, color: t.ink2),
            ),
            gapH24,
            for (final child in children) ...[child, gapH20],
          ],
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(CatchRadius.lg),
      ),
      child: Padding(
        padding: CatchInsets.content,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: CatchTextStyles.sectionTitle(context)),
            gapH12,
            child,
          ],
        ),
      ),
    );
  }
}

class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({required this.child, this.height = 720});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(CatchRadius.lg),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.lg),
            child: SizedBox(height: height, child: child),
          ),
        ),
      ),
    );
  }
}

class _MediaOverride extends StatelessWidget {
  const _MediaOverride({
    required this.child,
    this.textScaler,
    this.disableAnimations = false,
  });

  final Widget child;
  final TextScaler? textScaler;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    final base = MediaQuery.of(context);
    return MediaQuery(
      data: base.copyWith(
        textScaler: textScaler ?? base.textScaler,
        disableAnimations: disableAnimations || base.disableAnimations,
      ),
      child: child,
    );
  }
}

ChatsListViewModel _consumerViewModel() {
  return _viewModelFor(
    uid: MatchesChatSurfaceFixtures.viewerUid,
    matches: _consumerMatches,
  );
}

ChatsListViewModel _hostInboxViewModel() {
  return _viewModelFor(
    uid: MatchesChatSurfaceFixtures.hostUid,
    matches: _hostMatches,
  );
}

ChatsListViewModel _hostInboxReadOnlyViewModel() {
  return _viewModelFor(
    uid: MatchesChatSurfaceFixtures.hostUid,
    matches: _hostMatches
        .map((match) => match.copyWith(unreadCounts: const {}))
        .toList(),
  );
}

ChatsListViewModel _emptySearchViewModel({required int totalThreadCount}) {
  return ChatsListViewModel(
    newMatches: const [],
    conversations: const [],
    totalThreadCount: totalThreadCount,
  );
}

ChatsListViewModel _viewModelFor({
  required String uid,
  required List<Match> matches,
}) {
  final newMatches = <ChatThreadPreview>[];
  final conversations = <ChatThreadPreview>[];
  for (final match in matches) {
    final preview = _threadPreviewFor(match: match, uid: uid);
    if (preview.hasConversation) {
      conversations.add(preview);
    } else {
      newMatches.add(preview);
    }
  }
  newMatches.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return ChatsListViewModel(
    newMatches: List.unmodifiable(newMatches),
    conversations: List.unmodifiable(conversations),
    totalThreadCount: matches.length,
  );
}

ChatThreadPreview _threadPreviewFor({
  required Match match,
  required String uid,
}) {
  final otherUid = match.otherId(uid);
  final profile = MatchesChatSurfaceFixtures.profileFor(otherUid);
  final hostProfile = match.isClubHostInquiry
      ? _club.displayHostProfiles
            .where((host) => host.uid == otherUid)
            .firstOrNull
      : null;
  final displayName = hostProfile?.displayName ?? profile.name;
  final hasConversation = match.lastMessagePreview != null;
  final previewText = !hasConversation
      ? match.isClubHostInquiry
            ? 'Ask the host'
            : 'You matched!'
      : match.lastMessageSenderId == uid
      ? 'You: ${match.lastMessagePreview}'
      : match.lastMessagePreview!;

  return ChatThreadPreview(
    match: match,
    matchId: match.id,
    otherUid: otherUid,
    displayName: displayName,
    photoUrl: hostProfile?.avatarUrl ?? profile.primaryPhotoThumbnailUrl,
    previewText: previewText,
    timestamp: match.lastMessageAt ?? match.createdAt,
    unreadCount: match.unreadConversationCountFor(uid),
    hasConversation: hasConversation,
    eventIds: match.eventIds,
  );
}

List<Override> get _publicProfileOverrides {
  const uids = [
    MatchesChatSurfaceFixtures.taylorUid,
    MatchesChatSurfaceFixtures.morganUid,
    MatchesChatSurfaceFixtures.guestUid,
    'design-chat-guest-2',
    'design-chat-isha',
  ];
  return [
    for (final uid in uids)
      watchPublicProfileProvider(uid).overrideWith(
        (ref) => Stream<PublicProfile?>.value(
          MatchesChatSurfaceFixtures.profileFor(uid),
        ),
      ),
  ];
}
