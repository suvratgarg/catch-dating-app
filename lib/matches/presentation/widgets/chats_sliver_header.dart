import 'package:catch_dating_app/core/widgets/catch_browse_header.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:catch_dating_app/matches/presentation/widgets/chat_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _chatsBrowseHeaderHeight = 88;

class ChatsSliverHeader extends CatchSliverHeader {
  ChatsSliverHeader({bool showSearchAction = true})
    : super(
        title: const SizedBox.shrink(),
        bottomHeight: _chatsBrowseHeaderHeight,
        bottom: _ChatsBrowseHeader(showSearchAction: showSearchAction),
      );
}

class _ChatsBrowseHeader extends ConsumerStatefulWidget {
  const _ChatsBrowseHeader({required this.showSearchAction});

  final bool showSearchAction;

  @override
  ConsumerState<_ChatsBrowseHeader> createState() => _ChatsBrowseHeaderState();
}

class _ChatsBrowseHeaderState extends ConsumerState<_ChatsBrowseHeader> {
  bool _searchOpen = false;

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(chatSearchQueryProvider);
    final searchActive = _searchOpen || query.isNotEmpty;

    return CatchBrowseHeader(
      title: 'Chats',
      subtitle: 'Messages from your matches',
      searchActive: searchActive,
      searchField: ChatSearchField(
        autofocus: true,
        onSubmitted: _closeEmptySearch,
        onFocusChanged: _handleSearchFocusChanged,
      ),
      onOpenSearch: () => setState(() => _searchOpen = true),
      searchActionVisible: widget.showSearchAction,
      searchTooltip: 'Search chats',
      searchSemanticLabel: 'Search chats',
    );
  }

  void _closeEmptySearch(String value) {
    if (value.trim().isNotEmpty || !_searchOpen) return;
    setState(() => _searchOpen = false);
  }

  void _handleSearchFocusChanged(bool focused) {
    if (focused || !_searchOpen) return;
    if (ref.read(chatSearchQueryProvider).trim().isEmpty) {
      setState(() => _searchOpen = false);
    }
  }
}
