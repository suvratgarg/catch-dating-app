import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chats_list_celebration_controller.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chats_list_screen_state.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chats_list_view_model.dart';
import 'package:catch_dating_app/chats/presentation/inbox/host_inbox_filter.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chat_conversations_list.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_empty_state.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_list_body.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_divider.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatsList extends ConsumerWidget {
  const ChatsList({
    super.key,
    this.hostFilter,
    this.displayState,
    this.onThreadSelected,
    this.onHostBroadcastSelected,
  });

  final HostInboxFilter? hostFilter;
  final ChatsListDisplayState? displayState;
  final ChatThreadSelectedCallback? onThreadSelected;
  final VoidCallback? onHostBroadcastSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    final uid = uidAsync.asData?.value;
    final query = ref.watch(chatSearchQueryProvider).trim();

    if (uid != null) {
      ref.listen(watchMatchesForUserProvider(uid), (previous, next) {
        const ChatsListCelebrationController().showNewMatchCelebrations(
          context: context,
          uid: uid,
          previous: previous,
          next: next,
          isHostApp: AppConfig.appRole.isHost,
        );
      });
    }

    final effectiveState =
        displayState ??
        ChatsListDisplayState.fromAsync(
          viewModel: _catchAsyncState(ref.watch(chatsListViewModelProvider)),
          uid: uid,
          query: query,
          hostFilter: hostFilter,
        );

    return switch (effectiveState) {
      ChatsListLoading() => const ChatsListSkeleton(),
      ChatsListError(:final error, :final retryIntent) =>
        CatchSliverErrorState.fromError(
          error,
          context: AppErrorContext.chat,
          onRetry: () {
            switch (retryIntent) {
              case ChatsListRetryIntent.reloadViewModel:
                ref.invalidate(chatsListViewModelProvider);
            }
          },
        ),
      ChatsListContent(:final viewModel) => ChatsListBody(
        viewModel: viewModel,
        onThreadSelected: onThreadSelected ?? (_) {},
        onHostBroadcastSelected: onHostBroadcastSelected,
      ),
      ChatsListEmpty(:final kind) => SliverFillRemaining(
        child: switch (kind) {
          ChatsListEmptyKind.noSearchResults =>
            const ChatsEmptyState.noSearchResults(),
          ChatsListEmptyKind.noHostSearchResults =>
            const ChatsEmptyState.noHostSearchResults(),
          ChatsListEmptyKind.noUnreadQueries =>
            const ChatsEmptyState.noUnreadQueries(),
          ChatsListEmptyKind.noThreads =>
            AppConfig.appRole.isHost
                ? const ChatsEmptyState.hostInbox()
                : const ChatsEmptyState(),
        },
      ),
    };
  }
}

CatchAsyncState<T> _catchAsyncState<T>(AsyncValue<T> value) {
  return value.when(
    data: CatchAsyncState<T>.data,
    loading: () => const CatchAsyncState.loading(),
    error: (error, stackTrace) => CatchAsyncState<T>.error(error),
  );
}

class ChatsListSkeleton extends StatelessWidget {
  const ChatsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: CatchInsets.chatListGutter,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ChatPersonRowSkeleton(
                divider: index > 0,
                squareAvatar: AppConfig.appRole.isHost,
              ),
              childCount: 5,
            ),
          ),
        ),
      ],
    );
  }
}

class ChatPersonRowSkeleton extends StatelessWidget {
  const ChatPersonRowSkeleton({
    super.key,
    required this.divider,
    required this.squareAvatar,
  });

  final bool divider;
  final bool squareAvatar;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (divider)
          const Positioned(
            top: 0,
            left: CatchLayout.chatListDividerInset,
            right: 0,
            child: CatchDivider(),
          ),
        Padding(
          padding: CatchInsets.chatListTileVertical,
          child: Row(
            children: [
              squareAvatar
                  ? CatchSkeleton.box(
                      width: CatchLayout.chatListAvatarExtent,
                      height: CatchLayout.chatListAvatarExtent,
                      radius: CatchRadius.md,
                    )
                  : CatchSkeleton.circle(
                      size: CatchLayout.chatListAvatarExtent,
                    ),
              const SizedBox(width: CatchLayout.chatListTextGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CatchSkeleton.text(
                      width: CatchLayout.skeletonTextTitleWidth,
                    ),
                    const SizedBox(height: CatchSpacing.micro6),
                    CatchSkeleton.text(),
                  ],
                ),
              ),
              const SizedBox(width: CatchLayout.chatListTextGap),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CatchSkeleton.text(width: CatchLayout.skeletonTextTimeWidth),
                  const SizedBox(height: CatchSpacing.micro6),
                  CatchSkeleton.box(
                    width: CatchLayout.chatUnreadPillWidth,
                    height: CatchSpacing.s4,
                    radius: CatchRadius.pill,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
