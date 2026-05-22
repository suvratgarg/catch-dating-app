import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/city_picker.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_search_field.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_browse_header.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const double _clubsBrowseHeaderHeight = 88;

class ClubsSliverHeader extends CatchSliverHeader {
  ClubsSliverHeader({bool showSearchField = true})
    : super(
        title: const SizedBox.shrink(),
        bottomHeight: _clubsBrowseHeaderHeight,
        bottom: _ClubsBrowseHeader(showSearchAction: showSearchField),
      );
}

class _ClubsBrowseHeader extends ConsumerStatefulWidget {
  const _ClubsBrowseHeader({required this.showSearchAction});

  final bool showSearchAction;

  @override
  ConsumerState<_ClubsBrowseHeader> createState() => _ClubsBrowseHeaderState();
}

class _ClubsBrowseHeaderState extends ConsumerState<_ClubsBrowseHeader> {
  bool _searchOpen = false;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final canCreate = ref.watch(canCreateClubProvider).asData?.value ?? false;
    final query = ref.watch(clubSearchQueryProvider);
    final searchActive = _searchOpen || query.isNotEmpty;

    return CatchBrowseHeader(
      title: 'Clubs',
      subtitle: 'Find your people.',
      leading: const CityPicker(),
      searchActive: searchActive,
      searchField: ClubsSearchField(
        autofocus: true,
        onSubmitted: _closeEmptySearch,
        onFocusChanged: _handleSearchFocusChanged,
      ),
      onOpenSearch: () => setState(() => _searchOpen = true),
      searchActionVisible: widget.showSearchAction,
      searchTooltip: 'Search clubs',
      searchSemanticLabel: 'Search clubs',
      actions: [
        if (canCreate)
          Tooltip(
            message: 'Create club',
            child: Semantics(
              button: true,
              label: 'Create club',
              child: IconBtn(
                size: 44,
                onTap: () => context.pushNamed(Routes.createClubScreen.name),
                child: Icon(Icons.add_rounded, size: 20, color: t.ink),
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
    if (ref.read(clubSearchQueryProvider).trim().isEmpty) {
      setState(() => _searchOpen = false);
    }
  }
}
