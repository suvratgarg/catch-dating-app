import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_browse_header.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:catch_dating_app/matches/presentation/host_inbox_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _chatsBrowseHeaderHeight = CatchLayout.browseHeaderHeight;
const double _hostInboxFilterHeight = CatchSpacing.s11;

class ChatsSliverHeader extends CatchSliverHeader {
  ChatsSliverHeader({
    bool showSearchAction = true,
    HostInboxFilter? hostFilter,
    int hostUnreadCount = 0,
    ValueChanged<HostInboxFilter>? onHostFilterChanged,
  }) : super(
         title: const SizedBox.shrink(),
         bottomHeight:
             _chatsBrowseHeaderHeight +
             (hostFilter == null ? 0 : _hostInboxFilterHeight),
         bottom: _ChatsBrowseHeader(
           showSearchAction: showSearchAction,
           hostFilter: hostFilter,
           hostUnreadCount: hostUnreadCount,
           onHostFilterChanged: onHostFilterChanged,
         ),
       );
}

class _ChatsBrowseHeader extends ConsumerStatefulWidget {
  const _ChatsBrowseHeader({
    required this.showSearchAction,
    required this.hostFilter,
    required this.hostUnreadCount,
    required this.onHostFilterChanged,
  });

  final bool showSearchAction;
  final HostInboxFilter? hostFilter;
  final int hostUnreadCount;
  final ValueChanged<HostInboxFilter>? onHostFilterChanged;

  @override
  ConsumerState<_ChatsBrowseHeader> createState() => _ChatsBrowseHeaderState();
}

class _ChatsBrowseHeaderState extends ConsumerState<_ChatsBrowseHeader> {
  bool _searchOpen = false;

  @override
  Widget build(BuildContext context) {
    final isHostApp = AppConfig.appRole.isHost;
    final query = ref.watch(chatSearchQueryProvider);
    final searchActive = _searchOpen || query.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CatchBrowseHeader(
          title: isHostApp ? 'Inbox' : 'Chats',
          subtitle: isHostApp
              ? 'Attendee queries'
              : 'Messages from your matches',
          searchActive: searchActive,
          searchValue: query,
          onSearchChanged: (value) =>
              ref.read(chatSearchQueryProvider.notifier).setQuery(value),
          searchPlaceholder: 'Search by name',
          searchAutofocus: true,
          onSearchSubmitted: _closeEmptySearch,
          onSearchFocusChanged: _handleSearchFocusChanged,
          onOpenSearch: () => setState(() => _searchOpen = true),
          onCloseSearch: () => setState(() => _searchOpen = false),
          searchActionVisible: widget.showSearchAction,
          searchTooltip: isHostApp ? 'Search attendees' : 'Search chats',
          searchSemanticLabel: isHostApp ? 'Search attendees' : 'Search chats',
        ),
        if (widget.hostFilter != null)
          SizedBox(
            height: _hostInboxFilterHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s5),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CatchOptionGroup<HostInboxFilter>(
                  options: [
                    const CatchOption(value: HostInboxFilter.all, label: 'All'),
                    CatchOption(
                      value: HostInboxFilter.unread,
                      label: 'Unread · ${widget.hostUnreadCount}',
                    ),
                  ],
                  selected: widget.hostFilter!,
                  onChanged: widget.onHostFilterChanged,
                ),
              ),
            ),
          ),
      ],
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
