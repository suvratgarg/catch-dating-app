import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen_state.dart';
import 'package:catch_dating_app/explore/presentation/widgets/catch_cover_story.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_city_picker.dart';
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
      return Padding(
        padding: CatchInsets.screenTitleBlock,
        child: Row(
          children: [
            cityPicker,
            gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(chrome.title, style: CatchTextStyles.headline(context)),
                  const SizedBox(height: CatchGaps.headerTitleToSubtitle),
                  Text(
                    chrome.subtitle,
                    style: CatchTextStyles.supporting(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return CatchTopBar(
      leading: cityPicker,
      title: chrome.title,
      subtitle: chrome.subtitle,
      backgroundColor: backgroundColor ?? t.bg,
      applySafeArea: false,
      searchEnabled: true,
      searchValue: chrome.searchValue,
      onSearch: onQueryChanged,
      searchPlaceholder: chrome.searchPlaceholder,
      searchTooltip: chrome.searchTooltip,
      searchSemanticLabel: chrome.searchSemanticLabel,
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
    this.onQueryChanged,
    this.onFeaturedEventSelected,
  });

  final String query;
  final ExploreEventItem? featuredItem;
  final ExploreCityPickerState cityPickerState;
  final ValueChanged<CityData>? onCitySelected;
  final List<Widget> actions;
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
    final chrome = ExploreChromeState.discovery(
      query: widget.query,
      searchRequested: _searchRequested,
      hasFeaturedItem: featuredItem != null,
    );
    final coverItem = featuredItem;

    if (!chrome.showCoverStory || coverItem == null) {
      final t = CatchTokens.of(context);
      final topInset = MediaQuery.paddingOf(context).top;
      return ColoredBox(
        color: t.bg,
        child: Padding(
          padding: CatchInsets.pageBody.copyWith(
            top: topInset + CatchSpacing.s6,
            bottom: CatchSpacing.s4,
          ),
          child: CatchTopBar(
            leading: ExploreCityPicker(
              state: widget.cityPickerState,
              onSelected: widget.onCitySelected,
            ),
            title: chrome.title,
            subtitle: chrome.subtitle,
            backgroundColor: t.bg,
            gutter: false,
            applySafeArea: false,
            searchEnabled: true,
            searchExpanded: chrome.searchExpanded,
            searchValue: chrome.searchValue,
            searchAutofocus: chrome.searchAutofocus,
            onSearchExpandedChanged: (expanded) {
              if (_searchRequested == expanded) return;
              setState(() => _searchRequested = expanded);
            },
            onSearch: widget.onQueryChanged,
            searchPlaceholder: chrome.searchPlaceholder,
            searchTooltip: chrome.searchTooltip,
            searchSemanticLabel: chrome.searchSemanticLabel,
            actions: widget.actions,
          ),
        ),
      );
    }

    final coverState = ExploreCoverStoryState.from(coverItem);
    return CatchCoverStory(
      activityKind: coverItem.event.activityKind,
      kicker: coverState.kicker,
      title: coverState.title,
      cta: coverState.ctaLabel,
      onCta: () => widget.onFeaturedEventSelected?.call(coverItem),
      data: coverState.timePriceLabel,
      data2: coverState.attendanceLabel,
      showSearch: true,
      onSearch: () => setState(() => _searchRequested = true),
    );
  }
}
