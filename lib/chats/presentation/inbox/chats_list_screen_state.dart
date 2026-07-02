import 'package:catch_dating_app/chats/presentation/inbox/chats_list_view_model.dart';
import 'package:catch_dating_app/chats/presentation/inbox/host_inbox_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostInboxScreenState {
  const HostInboxScreenState({
    required this.hostFilter,
    required this.unreadThreadCount,
    required this.showSearchAction,
    required this.displayState,
  });

  factory HostInboxScreenState.fromAsync({
    required AsyncValue<ChatsListViewModel> viewModel,
    required AsyncValue<String?> uid,
    required String query,
    required HostInboxFilter selectedFilter,
    required bool isHostApp,
  }) {
    final String? uidValue;
    final AsyncValue<ChatsListViewModel> effectiveViewModel;
    switch (uid) {
      case AsyncData(:final value):
        uidValue = value;
        effectiveViewModel = viewModel;
      case AsyncError(:final error, :final stackTrace):
        uidValue = null;
        effectiveViewModel = AsyncError<ChatsListViewModel>(error, stackTrace);
      default:
        uidValue = null;
        effectiveViewModel = const AsyncLoading<ChatsListViewModel>();
    }
    final source = effectiveViewModel.asData?.value;
    final normalizedQuery = query.trim();
    final hostFilter = isHostApp ? selectedFilter : null;

    return HostInboxScreenState(
      hostFilter: hostFilter,
      unreadThreadCount: _unreadThreadCount(source),
      showSearchAction:
          (source?.totalThreadCount ?? 0) > 0 || normalizedQuery.isNotEmpty,
      displayState: ChatsListDisplayState.fromAsync(
        viewModel: effectiveViewModel,
        uid: uidValue,
        query: normalizedQuery,
        hostFilter: hostFilter,
      ),
    );
  }

  final HostInboxFilter? hostFilter;
  final int unreadThreadCount;
  final bool showSearchAction;
  final ChatsListDisplayState displayState;

  static int _unreadThreadCount(ChatsListViewModel? vm) {
    if (vm == null) return 0;
    return [
      ...vm.newMatches,
      ...vm.conversations,
    ].where((preview) => preview.unreadCount > 0).length;
  }
}

enum ChatsListEmptyKind {
  noThreads,
  noSearchResults,
  noHostSearchResults,
  noUnreadQueries,
}

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
      return hostFilter == null
          ? ChatsListEmptyKind.noSearchResults
          : ChatsListEmptyKind.noHostSearchResults;
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
