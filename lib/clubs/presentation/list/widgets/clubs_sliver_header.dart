import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/city_picker.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_browse_header.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _clubsBrowseHeaderHeight = CatchLayout.browseHeaderHeight;

class ClubsSliverHeader extends CatchSliverHeader {
  ClubsSliverHeader({bool showSearchField = true})
    : super(
        title: const SizedBox.shrink(),
        bottomHeight: _clubsBrowseHeaderHeight,
        bottom: ClubsBrowseHeaderContent(showSearchAction: showSearchField),
      );
}

/// Non-sliver browse header — same content as [ClubsSliverHeader] but
/// embeddable inside a regular Column. The Explore screen uses this directly
/// so the top chrome stays outside the draggable sheet (and isn't duplicated
/// when the sheet snaps to HALF / PEEK).
class ClubsBrowseHeaderContent extends ConsumerStatefulWidget {
  const ClubsBrowseHeaderContent({
    super.key,
    this.showSearchAction = true,
    this.backgroundColor,
  });

  final bool showSearchAction;
  final Color? backgroundColor;

  @override
  ConsumerState<ClubsBrowseHeaderContent> createState() =>
      _ClubsBrowseHeaderState();
}

class _ClubsBrowseHeaderState extends ConsumerState<ClubsBrowseHeaderContent> {
  bool _searchOpen = false;

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(clubSearchQueryProvider);
    final searchActive = _searchOpen || query.isNotEmpty;

    return CatchBrowseHeader(
      title: 'Explore',
      subtitle: 'Find an event worth showing up for.',
      leading: const CityPicker(),
      searchActive: searchActive,
      searchValue: query,
      onSearchChanged: (value) =>
          ref.read(clubSearchQueryProvider.notifier).setQuery(value),
      searchPlaceholder: 'Search events or clubs',
      searchAutofocus: true,
      onSearchSubmitted: _closeEmptySearch,
      onSearchFocusChanged: _handleSearchFocusChanged,
      onOpenSearch: () => setState(() => _searchOpen = true),
      onCloseSearch: () => setState(() => _searchOpen = false),
      searchActionVisible: widget.showSearchAction,
      searchTooltip: 'Search events or clubs',
      searchSemanticLabel: 'Search events or clubs',
      backgroundColor: widget.backgroundColor,
    );
  }

  void _closeEmptySearch(String value) {
    if (value.trim().isNotEmpty || !_searchOpen) return;
    setState(() => _searchOpen = false);
  }

  void _handleSearchFocusChanged(bool focused) {
    if (focused || !_searchOpen) return;
    if (ref.read(clubSearchQueryProvider).trim().isEmpty) {
      setState(() => _searchOpen = false);
    }
  }
}
