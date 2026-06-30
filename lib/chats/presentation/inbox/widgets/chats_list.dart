import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chats_list_view_model.dart';
import 'package:catch_dating_app/chats/presentation/inbox/host_inbox_filter.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chat_conversations_list.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_empty_state.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_list_body.dart';
import 'package:catch_dating_app/matches/presentation/widgets/match_celebration_dialog.dart';
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
        if (!context.mounted) return;
        if (AppConfig.appRole.isHost) return;
        if (previous == null || !previous.hasValue || !next.hasValue) return;
        final prevIds = previous.value!.map((m) => m.id).toSet();
        final newMatches = next.value!
            .where((m) => !prevIds.contains(m.id))
            .toList();
        for (final match in newMatches) {
          showMatchCelebration(context, ref, match, uid);
        }
      });
    }

    final effectiveState =
        displayState ??
        ChatsListDisplayState.fromAsync(
          viewModel: ref.watch(chatsListViewModelProvider),
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
          onRetry: () => _retryChatsList(ref, retryIntent),
        ),
      ChatsListContent(:final viewModel) => ChatsListBody(
        viewModel: viewModel,
        onThreadSelected: onThreadSelected ?? (_) {},
        onHostBroadcastSelected: onHostBroadcastSelected,
      ),
      ChatsListEmpty(:final kind) => SliverFillRemaining(
        child: _emptyStateFor(kind),
      ),
    };
  }

  Widget _emptyStateFor(ChatsListEmptyKind kind) {
    return switch (kind) {
      ChatsListEmptyKind.noSearchResults =>
        const ChatsEmptyState.noSearchResults(),
      ChatsListEmptyKind.noUnreadQueries =>
        const ChatsEmptyState.noUnreadQueries(),
      ChatsListEmptyKind.noThreads => const ChatsEmptyState(),
    };
  }
}

void _retryChatsList(WidgetRef ref, ChatsListRetryIntent intent) {
  switch (intent) {
    case ChatsListRetryIntent.reloadViewModel:
      ref.invalidate(chatsListViewModelProvider);
  }
}

enum ChatsListEmptyKind { noThreads, noSearchResults, noUnreadQueries }

enum ChatsListRetryIntent { reloadViewModel }

sealed class ChatsListDisplayState {
  const ChatsListDisplayState();

  factory ChatsListDisplayState.fromAsync({
    required AsyncValue<ChatsListViewModel> viewModel,
    required String? uid,
    required String query,
    required HostInboxFilter? hostFilter,
  }) {
    return switch (viewModel) {
      AsyncLoading() => const ChatsListLoading(),
      AsyncError(:final error) => ChatsListError(error: error),
      AsyncData(:final value) => ChatsListDisplayState.fromValue(
        source: value,
        uid: uid,
        query: query,
        hostFilter: hostFilter,
      ),
    };
  }

  factory ChatsListDisplayState.fromValue({
    required ChatsListViewModel source,
    required String? uid,
    required String query,
    required HostInboxFilter? hostFilter,
  }) {
    final visibleValue = _visibleViewModelFor(
      source: source,
      hostFilter: hostFilter,
    );
    if (visibleValue.isEmpty || uid == null) {
      return ChatsListEmpty(
        kind: _emptyKindFor(
          query: query,
          source: source,
          visible: visibleValue,
          hostFilter: hostFilter,
        ),
      );
    }
    return ChatsListContent(viewModel: visibleValue);
  }

  static ChatsListViewModel _visibleViewModelFor({
    required ChatsListViewModel source,
    required HostInboxFilter? hostFilter,
  }) {
    if (hostFilter != HostInboxFilter.unread) return source;

    return source.copyWith(
      newMatches: List.unmodifiable(
        source.newMatches.where((preview) => preview.unreadCount > 0),
      ),
      conversations: List.unmodifiable(
        source.conversations.where((preview) => preview.unreadCount > 0),
      ),
    );
  }

  static ChatsListEmptyKind _emptyKindFor({
    required String query,
    required ChatsListViewModel source,
    required ChatsListViewModel visible,
    required HostInboxFilter? hostFilter,
  }) {
    if (query.isNotEmpty &&
        source.visibleThreadCount == 0 &&
        source.totalThreadCount > 0) {
      return ChatsListEmptyKind.noSearchResults;
    }
    if (hostFilter == HostInboxFilter.unread &&
        source.visibleThreadCount > 0 &&
        visible.isEmpty) {
      return ChatsListEmptyKind.noUnreadQueries;
    }
    return ChatsListEmptyKind.noThreads;
  }
}

final class ChatsListLoading extends ChatsListDisplayState {
  const ChatsListLoading();
}

final class ChatsListError extends ChatsListDisplayState {
  const ChatsListError({
    required this.error,
    this.retryIntent = ChatsListRetryIntent.reloadViewModel,
  });

  final Object error;
  final ChatsListRetryIntent retryIntent;
}

final class ChatsListEmpty extends ChatsListDisplayState {
  const ChatsListEmpty({required this.kind});

  final ChatsListEmptyKind kind;
}

final class ChatsListContent extends ChatsListDisplayState {
  const ChatsListContent({required this.viewModel});

  final ChatsListViewModel viewModel;
}

class ChatsListSkeleton extends StatelessWidget {
  const ChatsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final sectionLabel = AppConfig.appRole.isHost
        ? 'ATTENDEE QUERIES'
        : 'CONVERSATIONS';

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s4,
              CatchSpacing.micro14,
              CatchSpacing.s4,
              CatchSpacing.s2,
            ),
            child: Text(
              sectionLabel,
              style: CatchTextStyles.kicker(context, color: t.ink2),
            ),
          ),
        ),
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
        const SliverToBoxAdapter(child: SizedBox(height: CatchSpacing.s6)),
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
    final t = CatchTokens.of(context);
    return Stack(
      children: [
        if (divider)
          Positioned(
            top: 0,
            left: CatchLayout.chatListDividerInset,
            right: 0,
            child: ColoredBox(
              color: t.line.withValues(alpha: CatchOpacity.fieldRowDivider),
              child: const SizedBox(height: CatchStroke.hairline),
            ),
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
