import 'package:catch_dating_app/chats/presentation/inbox/chats_search_header_controller.dart';
import 'package:catch_dating_app/chats/presentation/inbox/host_inbox_filter.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

const double _hostInboxFilterHeight = CatchLayout.tabRailHeight;

double chatsBrowseHeaderHeight({
  required BuildContext context,
  required bool hasHostFilter,
  required bool hasHeaderSubtitle,
}) =>
    CatchScreenTopBar.heightFor(
      context: context,
      hasSubtitle: hasHeaderSubtitle,
    ) +
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
  });

  final bool showSearchAction;
  final String searchValue;
  final ValueChanged<String>? onSearchChanged;
  final HostInboxFilter? hostFilter;
  final int hostUnreadCount;
  final ValueChanged<HostInboxFilter>? onHostFilterChanged;
  final bool showHostSubtitle;

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
    final l10n = context.l10n;
    final isHostApp = AppConfig.appRole.isHost;
    final hasHeaderSubtitle = isHostApp && widget.showHostSubtitle;
    final query = widget.searchValue;
    final searchActive = _searchController.isSearchActive(query);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CatchScreenTopBar(
          context: context,
          title: isHostApp ? l10n.hostInboxTitle : l10n.consumerChatsTitle,
          subtitle: hasHeaderSubtitle ? l10n.hostInboxSubtitle : null,
          leadingType: CatchTopBarLeading.none,
          applySafeArea: false,
          searchEnabled: widget.showSearchAction || searchActive,
          searchExpanded: searchActive,
          onSearchExpandedChanged: (expanded) =>
              setState(() => _searchController.setExpanded(expanded)),
          searchValue: query,
          onSearch: widget.onSearchChanged ?? (_) {},
          searchPlaceholder: l10n.sharedSearchByNameHint,
          searchAutofocus: true,
          onSearchSubmitted: _closeEmptySearch,
          onSearchFocusChanged: _handleSearchFocusChanged,
          searchTooltip: isHostApp
              ? l10n.hostSearchAttendeesAction
              : l10n.consumerSearchChatsAction,
          searchSemanticLabel: isHostApp
              ? l10n.hostSearchAttendeesAction
              : l10n.consumerSearchChatsAction,
        ),
        if (widget.hostFilter != null)
          CatchTabRail<HostInboxFilter>(
            options: [
              CatchOption(
                value: HostInboxFilter.all,
                label: l10n.hostInboxAllFilter,
              ),
              CatchOption(
                value: HostInboxFilter.unread,
                label: l10n.hostInboxUnreadCount(count: widget.hostUnreadCount),
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
