import 'package:catch_dating_app/chats/presentation/inbox/chats_search_header_controller.dart';
import 'package:catch_dating_app/chats/presentation/inbox/host_inbox_filter.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:flutter/material.dart';

const double _chatsBrowseHeaderHeight = CatchLayout.browseHeaderHeight;
const double _hostInboxFilterHeight = CatchLayout.tabRailHeight;

double chatsBrowseHeaderHeight({
  required bool hasHostFilter,
  required bool hasHeaderSubtitle,
}) =>
    (hasHeaderSubtitle ? _chatsBrowseHeaderHeight : CatchLayout.topBarHeight) +
    (hasHostFilter ? _hostInboxFilterHeight : 0);

class ChatsBrowseHeader extends StatefulWidget {
  const ChatsBrowseHeader({
    super.key,
    required this.showSearchAction,
    required this.searchValue,
    required this.onSearchChanged,
    required this.hostFilter,
    required this.hostUnreadCount,
    required this.onHostFilterChanged,
    this.showHostSubtitle = true,
    this.height,
    this.contentPadding,
  });

  final bool showSearchAction;
  final String searchValue;
  final ValueChanged<String>? onSearchChanged;
  final HostInboxFilter? hostFilter;
  final int hostUnreadCount;
  final ValueChanged<HostInboxFilter>? onHostFilterChanged;
  final bool showHostSubtitle;
  final double? height;
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<ChatsBrowseHeader> createState() => _ChatsBrowseHeaderState();
}

class _ChatsBrowseHeaderState extends State<ChatsBrowseHeader> {
  late final ChatsSearchHeaderController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = ChatsSearchHeaderController();
  }

  @override
  Widget build(BuildContext context) {
    final isHostApp = AppConfig.appRole.isHost;
    final hasHeaderSubtitle = isHostApp && widget.showHostSubtitle;
    final query = widget.searchValue;
    final searchActive = _searchController.isSearchActive(query);
    final headerHeight =
        widget.height ??
        (hasHeaderSubtitle
            ? CatchLayout.browseHeaderHeight
            : CatchLayout.topBarHeight);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.textScalerOf(context).scale(1.0).clamp(0.85, 1.0),
            ),
          ),
          child: CatchScreenTopBar(
            title: isHostApp ? 'Inbox' : 'Chats',
            subtitle: hasHeaderSubtitle ? 'Attendee queries' : null,
            leadingType: CatchTopBarLeading.none,
            applySafeArea: false,
            height: headerHeight,
            contentPadding:
                widget.contentPadding ??
                (hasHeaderSubtitle
                    ? CatchInsets.screenTitleBlock
                    : CatchInsets.screenTitleBlockCompact),
            searchEnabled: widget.showSearchAction || searchActive,
            searchExpanded: searchActive,
            onSearchExpandedChanged: (expanded) =>
                setState(() => _searchController.setExpanded(expanded)),
            searchValue: query,
            onSearch: widget.onSearchChanged ?? (_) {},
            searchPlaceholder: 'Search by name',
            searchAutofocus: true,
            onSearchSubmitted: _closeEmptySearch,
            onSearchFocusChanged: _handleSearchFocusChanged,
            searchTooltip: isHostApp ? 'Search attendees' : 'Search chats',
            searchSemanticLabel: isHostApp
                ? 'Search attendees'
                : 'Search chats',
          ),
        ),
        if (widget.hostFilter != null)
          CatchTabRail<HostInboxFilter>(
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
      ],
    );
  }

  void _closeEmptySearch(String value) {
    if (_searchController.closeAfterSubmitted(value)) {
      setState(() {});
    }
  }

  void _handleSearchFocusChanged(bool focused) {
    if (_searchController.closeAfterFocusChanged(
      focused: focused,
      query: widget.searchValue,
    )) {
      setState(() {});
    }
  }
}
