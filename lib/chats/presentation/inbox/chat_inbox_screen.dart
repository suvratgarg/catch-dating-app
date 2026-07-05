import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chats_list_screen_state.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chats_list_view_model.dart';
import 'package:catch_dating_app/chats/presentation/inbox/host_inbox_filter.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_list.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_sliver_header.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
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
        child: CustomScrollView(
          slivers: [
            ...CatchSliverHeader(
              title: const SizedBox.shrink(),
              bottomHeight: chatsBrowseHeaderHeight(
                hasHostFilter: screenState.hostFilter != null,
              ),
              bottom: ChatsBrowseHeader(
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const HostBroadcastComposerSheet(),
    );
  }
}

CatchAsyncState<T> _catchAsyncState<T>(AsyncValue<T> value) {
  return value.when(
    data: CatchAsyncState<T>.data,
    loading: () => const CatchAsyncState.loading(),
    error: (error, stackTrace) => CatchAsyncState<T>.error(error),
  );
}

class HostBroadcastComposerSheet extends StatelessWidget {
  const HostBroadcastComposerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(CatchSpacing.s3),
        child: CatchSurface(
          backgroundColor: t.surface,
          borderColor: t.line,
          padding: CatchInsets.pageBody.copyWith(
            top: CatchSpacing.s4,
            bottom: CatchSpacing.s5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CatchSurface(
                  width: CatchSpacing.s10,
                  height: CatchStroke.hairline * 3,
                  radius: CatchRadius.pill,
                  backgroundColor: t.line,
                  borderWidth: 0,
                  child: const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: CatchSpacing.s4),
              Text('New blast', style: CatchTextStyles.titleL(context)),
              const SizedBox(height: CatchSpacing.s1),
              Text(
                'Broadcast sending is not connected yet. Use this as the review surface for audience and template states.',
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
              const SizedBox(height: CatchSpacing.s4),
              CatchSurface(
                tone: CatchSurfaceTone.raised,
                borderColor: t.line,
                radius: CatchRadius.md,
                padding: const EdgeInsets.all(CatchSpacing.s3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminder',
                      style: CatchTextStyles.fieldRowTitle(context),
                    ),
                    const SizedBox(height: CatchSpacing.micro2),
                    Text(
                      'See you tonight at 8. Doors open at 7:45.',
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: CatchSpacing.s2),
              CatchSurface(
                tone: CatchSurfaceTone.raised,
                borderColor: t.line,
                radius: CatchRadius.md,
                padding: const EdgeInsets.all(CatchSpacing.s3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meeting point',
                      style: CatchTextStyles.fieldRowTitle(context),
                    ),
                    const SizedBox(height: CatchSpacing.micro2),
                    Text(
                      'Share arrival notes, parking, or table details.',
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: CatchSpacing.s4),
              const CatchButton(
                label: 'Send broadcast',
                onPressed: null,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
