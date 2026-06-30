import 'dart:math' as math;

import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/presentation/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/explore/presentation/widgets/catch_cover_story.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_city_picker.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const double _clubsBrowseHeaderHeight = CatchLayout.browseHeaderHeight;

class ExploreSliverHeader extends CatchSliverHeader {
  ExploreSliverHeader({bool showSearchField = true})
    : super(
        title: const SizedBox.shrink(),
        bottomHeight: _clubsBrowseHeaderHeight,
        bottom: ExploreBrowseHeaderContent(showSearchAction: showSearchField),
      );
}

/// Non-sliver browse header — same content as [ExploreSliverHeader] but
/// embeddable inside a regular Column. Uses [CatchTopBar] with built-in
/// search support instead of a custom animated search morph.
class ExploreBrowseHeaderContent extends ConsumerWidget {
  const ExploreBrowseHeaderContent({
    super.key,
    this.showSearchAction = true,
    this.backgroundColor,
  });

  final bool showSearchAction;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(exploreSearchQueryProvider);
    final t = CatchTokens.of(context);

    if (!showSearchAction) {
      return Padding(
        padding: CatchInsets.screenTitleBlock,
        child: Row(
          children: [
            const ExploreCityPicker(),
            gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Explore', style: CatchTextStyles.headline(context)),
                  const SizedBox(height: CatchGaps.headerTitleToSubtitle),
                  Text(
                    'Find an event worth showing up for.',
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
      leading: const ExploreCityPicker(),
      title: 'Explore',
      subtitle: 'Find an event worth showing up for.',
      backgroundColor: backgroundColor ?? t.bg,
      applySafeArea: false,
      searchEnabled: true,
      searchValue: query,
      onSearch: (value) =>
          ref.read(exploreSearchQueryProvider.notifier).setQuery(value),
      searchPlaceholder: 'Search events or clubs',
      searchTooltip: 'Search events or clubs',
      searchSemanticLabel: 'Search events or clubs',
    );
  }
}

class ExploreDiscoveryCoverHeader extends ConsumerStatefulWidget {
  const ExploreDiscoveryCoverHeader({super.key});

  @override
  ConsumerState<ExploreDiscoveryCoverHeader> createState() =>
      _ExploreDiscoveryCoverHeaderState();
}

class _ExploreDiscoveryCoverHeaderState
    extends ConsumerState<ExploreDiscoveryCoverHeader> {
  bool _searchRequested = false;

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(exploreSearchQueryProvider);
    final searchActive = query.trim().isNotEmpty;
    final featuredItem = ref
        .watch(exploreFeedViewModelProvider)
        .asData
        ?.value
        .featuredItem;

    if (_searchRequested || searchActive || featuredItem == null) {
      final t = CatchTokens.of(context);
      final topInset = MediaQuery.paddingOf(context).top;
      return ColoredBox(
        color: t.bg,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            topInset + CatchSpacing.s6,
            CatchSpacing.s5,
            CatchSpacing.s4,
          ),
          child: CatchTopBar(
            leading: const ExploreCityPicker(),
            title: 'Explore',
            subtitle: 'Find an event worth showing up for.',
            backgroundColor: t.bg,
            gutter: false,
            applySafeArea: false,
            searchEnabled: true,
            searchExpanded: _searchRequested || searchActive,
            searchValue: query,
            searchAutofocus: _searchRequested,
            onSearchExpandedChanged: (expanded) {
              if (_searchRequested == expanded) return;
              setState(() => _searchRequested = expanded);
            },
            onSearch: (value) =>
                ref.read(exploreSearchQueryProvider.notifier).setQuery(value),
            searchPlaceholder: 'Search events or clubs',
            searchTooltip: 'Search events or clubs',
            searchSemanticLabel: 'Search events or clubs',
          ),
        ),
      );
    }

    return CatchCoverStory(
      activityKind: featuredItem.event.activityKind,
      kicker: _coverKicker(featuredItem),
      title: featuredItem.event.title,
      cta: 'Claim a seat',
      onCta: () => _openFeaturedEvent(context, ref, featuredItem),
      data:
          '${EventFormatters.time(featuredItem.event.startTime)} - ${featuredItem.priceLabel}',
      data2:
          '${featuredItem.event.signedUpCount} going - ${_coverSpotsLabel(featuredItem)}',
      showSearch: true,
      onSearch: () => setState(() => _searchRequested = true),
    );
  }
}

void _openFeaturedEvent(
  BuildContext context,
  WidgetRef ref,
  ExploreEventItem item,
) {
  ref
      .read(appAnalyticsProvider)
      .logEvent(
        AnalyticsEvents.exploreEventOpened,
        parameters: {
          'event_id': item.event.id,
          'club_id': item.event.clubId,
          'source': 'cover_header',
        },
      );
  context.pushNamed(
    Routes.eventDetailScreen.name,
    pathParameters: {'clubId': item.event.clubId, 'eventId': item.event.id},
    extra: EventDetailRouteExtra(
      initialEvent: item.event,
      presentationMode: EventDetailPresentationMode.spotlightDark,
    ),
  );
}

String _coverKicker(ExploreEventItem item) {
  return '${_coverTimeScope(item.event.startTime)} - '
      '${item.club.name} - ${item.event.locationName}';
}

String _coverTimeScope(DateTime start) {
  final now = DateTime.now();
  final today = DateUtils.dateOnly(now);
  final eventDay = DateUtils.dateOnly(start);
  final dayOffset = eventDay.difference(today).inDays;
  return switch (dayOffset) {
    0 => 'Tonight',
    1 => 'Tomorrow',
    _ when dayOffset >= 0 && dayOffset < DateTime.daysPerWeek => 'This week',
    _ => EventFormatters.shortWeekday(start),
  };
}

String _coverSpotsLabel(ExploreEventItem item) {
  final spots = math.max(0, item.event.spotsRemaining);
  return spots == 1 ? '1 left' : '$spots left';
}
