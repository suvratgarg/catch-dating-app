import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chat_blast_composer_sheet.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chats_list_screen_state.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chats_list_view_model.dart';
import 'package:catch_dating_app/chats/presentation/inbox/host_inbox_filter.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_list.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_sliver_header.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatsListScreen extends ConsumerStatefulWidget {
  const ChatsListScreen({super.key});

  @override
  ConsumerState<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends ConsumerState<ChatsListScreen> {
  HostInboxFilter _hostInboxFilter = HostInboxFilter.all;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final isHostApp = AppConfig.appRole.isHost;

    final uidAsync = ref.watch(uidProvider);
    final viewModelAsync = ref.watch(chatsListViewModelProvider);
    final searchValue = ref.watch(chatSearchQueryProvider);
    final query = searchValue.trim();
    final screenState = HostInboxScreenState.fromAsync(
      viewModel: _catchAsyncState(viewModelAsync),
      uid: _catchAsyncState(uidAsync),
      query: query,
      selectedFilter: _hostInboxFilter,
      isHostApp: isHostApp,
    );

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            ...CatchSliverHeader(
              title: ChatsBrowseHeader(
                showSearchAction: screenState.showSearchAction,
                searchValue: searchValue,
                onSearchChanged: ref
                    .read(chatSearchQueryProvider.notifier)
                    .setQuery,
                hostFilter: screenState.hostFilter,
                hostUnreadCount: screenState.unreadThreadCount,
                onHostFilterChanged: _handleHostFilterChanged,
              ),
            ).buildSlivers(context),
            ChatsList(
              hostFilter: screenState.hostFilter,
              displayState: screenState.displayState,
              onThreadSelected: _openChatThread,
              onHostBroadcastSelected: isHostApp
                  ? _showHostBroadcastComposer
                  : null,
            ),
            const CatchSliverTerminalPadding(),
          ],
        ),
      ),
    );
  }

  void _handleHostFilterChanged(HostInboxFilter filter) {
    if (filter == _hostInboxFilter) return;
    setState(() => _hostInboxFilter = filter);
  }

  void _openChatThread(ChatThreadPreview preview) {
    final routeName = AppConfig.appRole.isHost
        ? Routes.hostChatScreen.name
        : Routes.chatScreen.name;
    context.goNamed(routeName, pathParameters: {'matchId': preview.matchId});
  }

  void _showHostBroadcastComposer() {
    showCatchBottomSheet<void>(
      context: context,
      builder: (context) => const ChatBlastComposerSheet(),
    );
  }
}

CatchAsyncState<T> _catchAsyncState<T>(AsyncValue<T> value) {
  return catchAsyncStateFromAsyncValue(value);
}
