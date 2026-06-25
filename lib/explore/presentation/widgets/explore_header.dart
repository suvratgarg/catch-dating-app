import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/data/city_repository.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_browse_header.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/presentation/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
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
/// embeddable inside a regular Column. The Explore screen uses this directly
/// so the top chrome stays outside the draggable sheet (and isn't duplicated
/// when the sheet snaps to HALF / PEEK).
class ExploreBrowseHeaderContent extends ConsumerStatefulWidget {
  const ExploreBrowseHeaderContent({
    super.key,
    this.showSearchAction = true,
    this.backgroundColor,
  });

  final bool showSearchAction;
  final Color? backgroundColor;

  @override
  ConsumerState<ExploreBrowseHeaderContent> createState() =>
      _ExploreBrowseHeaderState();
}

class _ExploreBrowseHeaderState
    extends ConsumerState<ExploreBrowseHeaderContent> {
  bool _searchOpen = false;

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(exploreSearchQueryProvider);
    final searchActive = _searchOpen || query.isNotEmpty;

    return CatchBrowseHeader(
      title: 'Explore',
      subtitle: 'Find an event worth showing up for.',
      leading: const ExploreCityPicker(),
      searchActive: searchActive,
      searchValue: query,
      onSearchChanged: (value) =>
          ref.read(exploreSearchQueryProvider.notifier).setQuery(value),
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
    if (ref.read(exploreSearchQueryProvider).trim().isEmpty) {
      setState(() => _searchOpen = false);
    }
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
  bool _searchOpen = false;

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(exploreSearchQueryProvider);
    final searchActive = _searchOpen || query.isNotEmpty;
    final featuredItem = ref
        .watch(exploreFeedViewModelProvider)
        .asData
        ?.value
        .featuredItem;

    if (searchActive || featuredItem == null) {
      return CatchBrowseHeader(
        title: 'Explore',
        subtitle: 'Find an event worth showing up for.',
        leading: const ExploreCityPicker(),
        searchActive: searchActive,
        searchValue: query,
        onSearchChanged: (value) =>
            ref.read(exploreSearchQueryProvider.notifier).setQuery(value),
        searchPlaceholder: 'Search events or clubs',
        searchAutofocus: true,
        onSearchSubmitted: _closeEmptySearch,
        onSearchFocusChanged: _handleSearchFocusChanged,
        onOpenSearch: () => setState(() => _searchOpen = true),
        onCloseSearch: () => setState(() => _searchOpen = false),
        searchTooltip: 'Search events or clubs',
        searchSemanticLabel: 'Search events or clubs',
      );
    }

    final city = ref.watch(selectedExploreCityProvider);
    return _ExploreCoverHeaderContent(
      item: featuredItem,
      city: city,
      onCityTap: () => _showCitySheet(context),
      onSearchTap: () => setState(() => _searchOpen = true),
      onClaimSeat: () => _openFeaturedEvent(context, featuredItem),
    );
  }

  void _closeEmptySearch(String value) {
    if (value.trim().isNotEmpty || !_searchOpen) return;
    setState(() => _searchOpen = false);
  }

  void _handleSearchFocusChanged(bool focused) {
    if (focused || !_searchOpen) return;
    if (ref.read(exploreSearchQueryProvider).trim().isEmpty) {
      setState(() => _searchOpen = false);
    }
  }

  Future<void> _showCitySheet(BuildContext context) async {
    final cities = await ref.read(cityListProvider.future);
    if (!context.mounted || cities.isEmpty) return;
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ExploreCoverCitySheet(
        cities: cities,
        selectedCity: ref.read(selectedExploreCityProvider),
        onSelected: (city) {
          ref.read(selectedExploreCityProvider.notifier).setCity(city);
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }

  void _openFeaturedEvent(BuildContext context, ExploreEventItem item) {
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
}

class _ExploreCoverHeaderContent extends StatelessWidget {
  const _ExploreCoverHeaderContent({
    required this.item,
    required this.city,
    required this.onCityTap,
    required this.onSearchTap,
    required this.onClaimSeat,
  });

  final ExploreEventItem item;
  final CityData city;
  final VoidCallback onCityTap;
  final VoidCallback onSearchTap;
  final VoidCallback onClaimSeat;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final swatch = ActivityPalette.of(context).forKind(item.event.activityKind);
    final foreground = CatchTokens.editorialLight;
    return SizedBox(
      height: CatchLayout.exploreDiscoveryCoverHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(color: t.ink),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _ExploreCoverHeaderPainter(
                  lineColor: foreground.withValues(alpha: 0.08),
                  glowColor: swatch.accent.withValues(
                    alpha: CatchOpacity.coverStoryGlow,
                  ),
                ),
              ),
            ),
            Positioned(
              right: CatchSpacing.s5,
              bottom: CatchSpacing.s2,
              child: Icon(
                _coverActivityIcon(item.event.activityKind),
                size: CatchLayout.coverStoryGhostGlyphSize,
                color: foreground.withValues(
                  alpha: CatchOpacity.coverStoryGhostGlyph,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.s5,
                CatchSpacing.s6,
                CatchSpacing.s5,
                CatchSpacing.s5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ExploreCoverScopeButton(
                          city: city,
                          foreground: foreground,
                          onTap: onCityTap,
                        ),
                      ),
                      gapW12,
                      CatchIconButton(
                        background: foreground.withValues(
                          alpha: CatchOpacity.controlOverlayHover,
                        ),
                        onTap: onSearchTap,
                        child: Icon(
                          CatchIcons.search,
                          size: CatchIcon.md,
                          color: foreground,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    _coverKicker(item).toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.kicker(
                      context,
                      color: swatch.accent,
                    ),
                  ),
                  gapH12,
                  Text(
                    item.event.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.headline(context, color: foreground),
                  ),
                  gapH20,
                  Row(
                    children: [
                      Expanded(
                        child: CatchButton(
                          label: 'Claim a seat',
                          onPressed: onClaimSeat,
                          variant: CatchButtonVariant.light,
                          fullWidth: true,
                        ),
                      ),
                      gapW12,
                      Expanded(child: _ExploreCoverMeta(item: item)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreCoverHeaderPainter extends CustomPainter {
  const _ExploreCoverHeaderPainter({
    required this.lineColor,
    required this.glowColor,
  });

  final Color lineColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (var index = -2; index < 18; index++) {
      final start = Offset(index * 28.0, size.height);
      final end = Offset(start.dx + size.height, 0);
      canvas.drawLine(start, end, linePaint);
    }

    final glowPaint = Paint()
      ..shader = RadialGradient(colors: [glowColor, Colors.transparent])
          .createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.88, size.height * 0.88),
              radius: size.width * 0.72,
            ),
          );
    canvas.drawRect(Offset.zero & size, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _ExploreCoverHeaderPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor || oldDelegate.glowColor != glowColor;
}

class _ExploreCoverScopeButton extends StatelessWidget {
  const _ExploreCoverScopeButton({
    required this.city,
    required this.foreground,
    required this.onTap,
  });

  final CityData city;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Choose city: ${city.label}',
      child: Semantics(
        button: true,
        label: 'Choose city: ${city.label}',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CatchRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s2),
            child: Text(
              'EXPLORE - ${city.label}'.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.kicker(
                context,
                color: foreground.withValues(
                  alpha: CatchOpacity.coverStoryLocation,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExploreCoverMeta extends StatelessWidget {
  const _ExploreCoverMeta({required this.item});

  final ExploreEventItem item;

  @override
  Widget build(BuildContext context) {
    final foreground = CatchTokens.editorialLight;
    return Text(
      '${EventFormatters.time(item.event.startTime)} - ${item.priceLabel}\n'
      '${item.event.signedUpCount} going - ${_coverSpotsLabel(item)}',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: CatchTextStyles.kicker(
        context,
        color: foreground.withValues(alpha: CatchOpacity.coverStoryData),
      ),
    );
  }
}

class _ExploreCoverCitySheet extends StatelessWidget {
  const _ExploreCoverCitySheet({
    required this.cities,
    required this.selectedCity,
    required this.onSelected,
  });

  final List<CityData> cities;
  final CityData selectedCity;
  final ValueChanged<CityData> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.68;
    return Material(
      color: t.surface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(CatchRadius.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: ListView.separated(
            shrinkWrap: true,
            padding: CatchInsets.pageBodyTight,
            itemCount: cities.length,
            separatorBuilder: (_, _) => gapH4,
            itemBuilder: (context, index) {
              final city = cities[index];
              final selected = city.name == selectedCity.name;
              return CatchSurface(
                tone: selected
                    ? CatchSurfaceTone.primarySoft
                    : CatchSurfaceTone.transparent,
                radius: CatchRadius.md,
                borderColor: selected ? t.primarySoft : Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: CatchSpacing.s4,
                  vertical: CatchSpacing.s3,
                ),
                onTap: () => onSelected(city),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? CatchIcons.locationOnRounded
                          : CatchIcons.locationOnOutlined,
                      color: selected ? t.primary : t.ink3,
                      size: CatchIcon.md,
                    ),
                    gapW12,
                    Expanded(
                      child: Text(
                        city.label,
                        style: CatchTextStyles.labelL(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (selected) ...[
                      gapW12,
                      Icon(
                        CatchIcons.checkRounded,
                        color: t.primary,
                        size: CatchIcon.md,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
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

IconData _coverActivityIcon(ActivityKind type) => switch (type) {
  ActivityKind.socialRun => CatchIcons.directionsRunRounded,
  ActivityKind.running => CatchIcons.directionsRunRounded,
  ActivityKind.walking => CatchIcons.directionsWalkRounded,
  ActivityKind.pickleball => CatchIcons.sportsTennisRounded,
  ActivityKind.padel => CatchIcons.sportsTennisRounded,
  ActivityKind.tennis => CatchIcons.sportsTennisRounded,
  ActivityKind.badminton => CatchIcons.sportsTennisRounded,
  ActivityKind.cycling => CatchIcons.directionsBikeRounded,
  ActivityKind.spinClass => CatchIcons.fitnessCenterRounded,
  ActivityKind.yoga => CatchIcons.selfImprovementRounded,
  ActivityKind.strengthTraining => CatchIcons.fitnessCenterRounded,
  ActivityKind.pubQuiz => CatchIcons.quizOutlined,
  ActivityKind.barCrawl => CatchIcons.localBarOutlined,
  ActivityKind.dinner => CatchIcons.restaurantOutlined,
  ActivityKind.singlesMixer => CatchIcons.groups2Outlined,
  ActivityKind.openActivity => CatchIcons.eventAvailableOutlined,
};
