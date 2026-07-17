import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen_state.dart';
import 'package:catch_dating_app/explore/presentation/widgets/catch_cover_story.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_city_picker.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Non-sliver browse header embeddable in [CatchSliverHeader.bottom] or a
/// regular column. Uses [CatchTopBar] with built-in search support instead of
/// a custom animated search morph.
class ExploreBrowseHeaderContent extends StatelessWidget {
  const ExploreBrowseHeaderContent({
    super.key,
    this.query = '',
    this.onQueryChanged,
    this.showSearchAction = true,
    this.backgroundColor,
    this.cityPickerState,
    this.onCitySelected,
    this.actions = const <Widget>[],
  });

  final String query;
  final ValueChanged<String>? onQueryChanged;
  final bool showSearchAction;
  final Color? backgroundColor;
  final ExploreCityPickerState? cityPickerState;
  final ValueChanged<CityData>? onCitySelected;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final chrome = ExploreChromeState.browse(
      query: query,
      showSearchAction: showSearchAction,
      l10n: context.l10n,
    );
    final t = CatchTokens.of(context);
    final cityPicker = ExploreCityPicker(
      state:
          cityPickerState ??
          ExploreCityPickerState.disabled(
            selectedCity: defaultCityDataForMarket(),
          ),
      onSelected: onCitySelected,
    );

    if (!chrome.showSearchAction) {
      return CatchScreenHeaderTitle.block(
        leading: cityPicker,
        title: chrome.title,
      );
    }

    return CatchScreenTopBar(
      context: context,
      leading: cityPicker,
      title: chrome.title,
      backgroundColor: backgroundColor ?? t.bg,
      applySafeArea: false,
      search: CatchTopBarSearch(
        value: chrome.searchValue,
        onChanged: onQueryChanged,
        placeholder: chrome.searchPlaceholder,
        tooltip: chrome.searchTooltip,
        semanticLabel: chrome.searchSemanticLabel,
      ),
      actions: actions,
    );
  }
}

class ExploreDiscoveryCoverHeader extends StatefulWidget {
  const ExploreDiscoveryCoverHeader({
    super.key,
    this.query = '',
    this.featuredItem,
    required this.cityPickerState,
    required this.onCitySelected,
    this.actions = const <Widget>[],
    this.heroActions,
    this.searchRequested,
    this.onSearchRequestedChanged,
    this.onQueryChanged,
    this.onFeaturedEventSelected,
  });

  final String query;
  final ExploreEventItem? featuredItem;
  final ExploreCityPickerState cityPickerState;
  final ValueChanged<CityData>? onCitySelected;
  final List<Widget> actions;
  final List<Widget>? heroActions;
  final bool? searchRequested;
  final ValueChanged<bool>? onSearchRequestedChanged;
  final ValueChanged<String>? onQueryChanged;
  final ValueChanged<ExploreEventItem>? onFeaturedEventSelected;

  @override
  State<ExploreDiscoveryCoverHeader> createState() =>
      _ExploreDiscoveryCoverHeaderState();
}

class _ExploreDiscoveryCoverHeaderState
    extends State<ExploreDiscoveryCoverHeader> {
  bool _searchRequested = false;

  @override
  Widget build(BuildContext context) {
    final featuredItem = widget.featuredItem;
    final searchRequested = widget.searchRequested ?? _searchRequested;
    final chrome = ExploreChromeState.discovery(
      query: widget.query,
      searchRequested: searchRequested,
      hasFeaturedItem: featuredItem != null,
      l10n: context.l10n,
    );
    final coverItem = featuredItem;

    if (!chrome.showCoverStory || coverItem == null) {
      return ColoredBox(
        color: CatchTokens.of(context).bg,
        child: _ExploreDiscoveryTopBar(
          chrome: chrome,
          cityPickerState: widget.cityPickerState,
          onCitySelected: widget.onCitySelected,
          onQueryChanged: widget.onQueryChanged,
          onSearchExpandedChanged: _setSearchRequested,
          actions: widget.actions,
        ),
      );
    }

    final coverState = ExploreCoverStoryState.from(
      coverItem,
      l10n: context.l10n,
    );
    return CatchCoverStory(
      activityKind: coverItem.event.activityKind,
      kicker: coverState.kicker,
      title: coverState.title,
      cta: coverState.ctaLabel,
      onCta: () => widget.onFeaturedEventSelected?.call(coverItem),
      data: coverState.timePriceLabel,
      data2: coverState.attendanceLabel,
      chrome: _ExploreDiscoveryTopBar(
        chrome: chrome,
        cityPickerState: widget.cityPickerState,
        onCitySelected: widget.onCitySelected,
        onQueryChanged: widget.onQueryChanged,
        onSearchExpandedChanged: _setSearchRequested,
        actions: widget.heroActions ?? widget.actions,
        backgroundColor: Colors.transparent,
        onDarkBackdrop: true,
      ),
    );
  }

  void _setSearchRequested(bool expanded) {
    widget.onSearchRequestedChanged?.call(expanded);
    if (widget.searchRequested != null) return;
    if (_searchRequested == expanded) return;
    setState(() => _searchRequested = expanded);
  }
}

class _ExploreDiscoveryTopBar extends StatelessWidget {
  const _ExploreDiscoveryTopBar({
    required this.chrome,
    required this.cityPickerState,
    required this.onCitySelected,
    required this.onQueryChanged,
    required this.onSearchExpandedChanged,
    required this.actions,
    this.backgroundColor,
    this.onDarkBackdrop = false,
  });

  final ExploreChromeState chrome;
  final ExploreCityPickerState cityPickerState;
  final ValueChanged<CityData>? onCitySelected;
  final ValueChanged<String>? onQueryChanged;
  final ValueChanged<bool> onSearchExpandedChanged;
  final List<Widget> actions;
  final Color? backgroundColor;
  final bool onDarkBackdrop;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final darkTokens = CatchTokens.dark;
    final foreground = onDarkBackdrop ? darkTokens.ink : null;
    final mutedForeground = onDarkBackdrop ? darkTokens.darkMutedInk : null;
    final transparentControlFill = onDarkBackdrop ? Colors.transparent : null;
    final transparentControlRule = onDarkBackdrop ? Colors.transparent : null;
    final topBar = CatchScreenTopBar(
      context: context,
      leading: ExploreCityPicker(
        state: cityPickerState,
        onSelected: onCitySelected,
        foregroundColor: foreground,
        backgroundColor: transparentControlFill,
        borderColor: transparentControlRule,
      ),
      title: chrome.title,
      backgroundColor: backgroundColor ?? t.bg,
      search: CatchTopBarSearch(
        expanded: chrome.searchExpanded,
        value: chrome.searchValue,
        autofocus: chrome.searchAutofocus,
        onExpandedChanged: onSearchExpandedChanged,
        onChanged: onQueryChanged,
        placeholder: chrome.searchPlaceholder,
        tooltip: chrome.searchTooltip,
        semanticLabel: chrome.searchSemanticLabel,
        backgroundColor: transparentControlFill,
        borderColor: transparentControlRule,
        foregroundColor: foreground,
        mutedForegroundColor: mutedForeground,
      ),
      actions: actions,
    );
    if (!onDarkBackdrop) return topBar;
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(extensions: const <ThemeExtension<dynamic>>[CatchTokens.dark]),
      child: topBar,
    );
  }
}
