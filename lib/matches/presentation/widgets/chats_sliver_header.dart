import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
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
         bottom: ChatsBrowseHeader(
           showSearchAction: showSearchAction,
           hostFilter: hostFilter,
           hostUnreadCount: hostUnreadCount,
           onHostFilterChanged: onHostFilterChanged,
         ),
       );
}

class ChatsBrowseHeader extends ConsumerStatefulWidget {
  const ChatsBrowseHeader({
    super.key,
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
  ConsumerState<ChatsBrowseHeader> createState() => _ChatsBrowseHeaderState();
}

class _ChatsBrowseHeaderState extends ConsumerState<ChatsBrowseHeader> {
  bool _searchOpen = false;

  @override
  Widget build(BuildContext context) {
    final isHostApp = AppConfig.appRole.isHost;
    final query = ref.watch(chatSearchQueryProvider);
    final searchActive = _searchOpen || query.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildChatsTopBar(
          context,
          title: isHostApp ? 'Inbox' : 'Chats',
          subtitle: isHostApp
              ? 'Attendee queries'
              : 'Messages from your matches',
          searchEnabled: widget.showSearchAction || searchActive,
          searchActive: searchActive,
          searchValue: query,
          onSearchChanged: (value) =>
              ref.read(chatSearchQueryProvider.notifier).setQuery(value),
          searchPlaceholder: 'Search by name',
          searchAutofocus: true,
          onSearchSubmitted: _closeEmptySearch,
          onSearchFocusChanged: _handleSearchFocusChanged,
          onSearchExpandedChanged: (expanded) =>
              setState(() => _searchOpen = expanded),
          searchTooltip: isHostApp ? 'Search attendees' : 'Search chats',
          searchSemanticLabel: isHostApp ? 'Search attendees' : 'Search chats',
        ),
        if (widget.hostFilter != null)
          SizedBox(
            height: _hostInboxFilterHeight,
            child: Padding(
              padding: CatchInsets.screenControlRow,
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

  Widget _buildChatsTopBar(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool searchEnabled,
    required bool searchActive,
    required String searchValue,
    required ValueChanged<String> onSearchChanged,
    required String searchPlaceholder,
    required bool searchAutofocus,
    required ValueChanged<String> onSearchSubmitted,
    required ValueChanged<bool> onSearchFocusChanged,
    required ValueChanged<bool> onSearchExpandedChanged,
    required String searchTooltip,
    required String searchSemanticLabel,
  }) {
    final ambientScaler = MediaQuery.textScalerOf(context);
    final clampedFactor = ambientScaler.scale(1.0).clamp(0.85, 1.0);
    final clampedScaler = TextScaler.linear(clampedFactor);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: clampedScaler),
      child: CatchTopBar(
        titleWidget: _buildChatsTopBarTitle(
          context,
          title: title,
          subtitle: subtitle,
        ),
        leadingType: CatchTopBarLeading.none,
        applySafeArea: false,
        gutter: false,
        height: _chatsBrowseHeaderHeight,
        contentPadding: CatchInsets.screenTitleBlock,
        searchEnabled: searchEnabled,
        searchExpanded: searchActive,
        onSearchExpandedChanged: onSearchExpandedChanged,
        searchValue: searchValue,
        onSearch: onSearchChanged,
        searchPlaceholder: searchPlaceholder,
        searchAutofocus: searchAutofocus,
        onSearchSubmitted: onSearchSubmitted,
        onSearchFocusChanged: onSearchFocusChanged,
        searchTooltip: searchTooltip,
        searchSemanticLabel: searchSemanticLabel,
        searchCollapsedExtent: CatchLayout.browseHeaderSearchExtent,
      ),
    );
  }

  Widget _buildChatsTopBarTitle(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.headline(context),
        ),
        const SizedBox(height: CatchGaps.headerTitleToSubtitle),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.supporting(context),
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
