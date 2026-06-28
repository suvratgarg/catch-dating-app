import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
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

    return _buildExploreBrowseHeader(
      context,
      searchActive: searchActive,
      searchValue: query,
      onSearchChanged: (value) =>
          ref.read(exploreSearchQueryProvider.notifier).setQuery(value),
      onSearchSubmitted: _closeEmptySearch,
      onSearchFocusChanged: _handleSearchFocusChanged,
      onSearchTap: () => setState(() => _searchOpen = true),
      onCloseSearch: () => setState(() => _searchOpen = false),
      searchActionVisible: widget.showSearchAction,
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

Widget _buildExploreBrowseHeader(
  BuildContext context, {
  required bool searchActive,
  required String searchValue,
  required ValueChanged<String> onSearchChanged,
  required ValueChanged<String> onSearchSubmitted,
  required ValueChanged<bool> onSearchFocusChanged,
  required VoidCallback onSearchTap,
  required VoidCallback onCloseSearch,
  required bool searchActionVisible,
  Color? backgroundColor,
}) {
  final t = CatchTokens.of(context);
  final ambientScaler = MediaQuery.textScalerOf(context);
  final clampedFactor = ambientScaler.scale(1.0).clamp(0.85, 1.0);
  final clampedScaler = TextScaler.linear(clampedFactor);

  return ColoredBox(
    color: backgroundColor ?? t.bg,
    child: Padding(
      padding: CatchInsets.screenTitleBlock,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: clampedScaler),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: CatchLayout.browseHeaderContentHeight,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: searchActive ? 1 : 0),
                duration: CatchMotion.base,
                curve: CatchMotion.standardCurve,
                builder: (context, progress, _) {
                  final showSearchControl =
                      searchActionVisible || searchActive || progress > 0.001;
                  return Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      ExcludeSemantics(
                        excluding: progress > 0.5,
                        child: IgnorePointer(
                          ignoring: progress > 0.02,
                          child: Opacity(
                            opacity: (1 - (progress * 1.5)).clamp(0.0, 1.0),
                            child: _buildExploreBrowseTitleLayout(
                              context,
                              reserveSearchAction: searchActionVisible,
                            ),
                          ),
                        ),
                      ),
                      if (showSearchControl)
                        _buildExploreBrowseSearchControl(
                          context,
                          progress: progress,
                          maxWidth: constraints.maxWidth,
                          value: searchValue,
                          autofocus: searchActive,
                          onSearchTap: onSearchTap,
                          onCloseSearch: onCloseSearch,
                          onChanged: onSearchChanged,
                          onSubmitted: onSearchSubmitted,
                          onFocusChanged: onSearchFocusChanged,
                        ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    ),
  );
}

Widget _buildExploreBrowseSearchControl(
  BuildContext context, {
  required double progress,
  required double maxWidth,
  required String value,
  required bool autofocus,
  required VoidCallback onSearchTap,
  required VoidCallback onCloseSearch,
  required ValueChanged<String> onChanged,
  required ValueChanged<String> onSubmitted,
  required ValueChanged<bool> onFocusChanged,
}) {
  final t = CatchTokens.of(context);
  final clampedProgress = progress.clamp(0.0, 1.0);
  final width =
      CatchLayout.browseHeaderSearchExtent +
      ((maxWidth - CatchLayout.browseHeaderSearchExtent) * clampedProgress);
  final fieldOpacity = ((clampedProgress - 0.12) / 0.88).clamp(0.0, 1.0);
  final showField = clampedProgress > 0.06;

  return Align(
    alignment: Alignment.centerRight,
    child: SizedBox(
      width: width,
      height: CatchLayout.browseHeaderSearchExtent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CatchRadius.pill),
        child: showField
            ? Opacity(
                opacity: fieldOpacity,
                child: CatchSearchField(
                  value: value,
                  onChanged: onChanged,
                  placeholder: 'Search events or clubs',
                  autofocus: autofocus,
                  onSubmitted: onSubmitted,
                  onFocusChanged: onFocusChanged,
                  semanticLabel: 'Search events or clubs',
                  emptyTrailingIcon: CatchIcons.close,
                  emptyTrailingTooltip: 'Close search',
                  onEmptyTrailingPressed: onCloseSearch,
                ),
              )
            : Tooltip(
                message: 'Search events or clubs',
                child: Semantics(
                  button: true,
                  label: 'Search events or clubs',
                  child: CatchIconButton(
                    size: CatchLayout.browseHeaderSearchExtent,
                    onTap: onSearchTap,
                    background: t.raised,
                    child: Icon(
                      CatchIcons.search,
                      size: CatchIcon.control,
                      color: t.ink,
                    ),
                  ),
                ),
              ),
      ),
    ),
  );
}

Widget _buildExploreBrowseTitleLayout(
  BuildContext context, {
  required bool reserveSearchAction,
}) {
  return Row(
    children: [
      const ExploreCityPicker(),
      gapW12,
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Explore',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.headline(context),
            ),
            const SizedBox(height: CatchGaps.headerTitleToSubtitle),
            Text(
              'Find an event worth showing up for.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.supporting(context),
            ),
          ],
        ),
      ),
      if (reserveSearchAction) ...[
        gapW8,
        const SizedBox.square(dimension: CatchLayout.browseHeaderSearchExtent),
      ],
    ],
  );
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
      return _buildExploreTopBand(
        context,
        searchActive: searchActive,
        searchValue: query,
        onSearchTap: () => setState(() => _searchOpen = true),
        onSearchChanged: (value) =>
            ref.read(exploreSearchQueryProvider.notifier).setQuery(value),
        onSearchSubmitted: _closeEmptySearch,
        onSearchFocusChanged: _handleSearchFocusChanged,
        onCloseSearch: () => setState(() => _searchOpen = false),
      );
    }

    return _buildExploreCoverHeaderContent(
      context,
      item: featuredItem,
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

Widget _buildExploreTopBand(
  BuildContext context, {
  required bool searchActive,
  required String searchValue,
  required VoidCallback onSearchTap,
  required ValueChanged<String> onSearchChanged,
  required ValueChanged<String> onSearchSubmitted,
  required ValueChanged<bool> onSearchFocusChanged,
  required VoidCallback onCloseSearch,
}) {
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
      child: _buildExploreTopRow(
        context,
        cityPresentation: ExploreCityPickerPresentation.scopeLabel,
        foreground: t.ink2,
        searchActive: searchActive,
        searchValue: searchValue,
        searchButtonBackground: t.raised,
        searchButtonForeground: t.ink,
        onSearchTap: onSearchTap,
        onSearchChanged: onSearchChanged,
        onSearchSubmitted: onSearchSubmitted,
        onSearchFocusChanged: onSearchFocusChanged,
        onCloseSearch: onCloseSearch,
      ),
    ),
  );
}

Widget _buildExploreCoverHeaderContent(
  BuildContext context, {
  required ExploreEventItem item,
  required VoidCallback onSearchTap,
  required VoidCallback onClaimSeat,
}) {
  final t = CatchTokens.of(context);
  final swatch = ActivityPalette.of(context).forKind(item.event.activityKind);
  final foreground = CatchTokens.editorialLight;
  final topInset = MediaQuery.paddingOf(context).top;
  return SizedBox(
    height: topInset + CatchLayout.exploreDiscoveryCoverHeight,
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
            padding: EdgeInsets.fromLTRB(
              CatchSpacing.s5,
              topInset + CatchSpacing.s6,
              CatchSpacing.s5,
              CatchSpacing.s5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExploreTopRow(
                  context,
                  cityPresentation: ExploreCityPickerPresentation.scopeLabel,
                  foreground: foreground,
                  searchActive: false,
                  searchValue: '',
                  searchButtonBackground: foreground.withValues(
                    alpha: CatchOpacity.controlOverlayHover,
                  ),
                  searchButtonForeground: foreground,
                  onSearchTap: onSearchTap,
                ),
                const Spacer(),
                Text(
                  _coverKicker(item).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.kicker(context, color: swatch.accent),
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
                    Expanded(
                      child: _buildExploreCoverMeta(context, item: item),
                    ),
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

Widget _buildExploreTopRow(
  BuildContext context, {
  required ExploreCityPickerPresentation cityPresentation,
  required Color foreground,
  required bool searchActive,
  required String searchValue,
  required Color searchButtonBackground,
  required Color searchButtonForeground,
  required VoidCallback onSearchTap,
  ValueChanged<String>? onSearchChanged,
  ValueChanged<String>? onSearchSubmitted,
  ValueChanged<bool>? onSearchFocusChanged,
  VoidCallback? onCloseSearch,
}) {
  if (searchActive) {
    return SizedBox(
      height: CatchLayout.browseHeaderSearchExtent,
      child: CatchSearchField(
        value: searchValue,
        onChanged: onSearchChanged,
        placeholder: 'Search events or clubs',
        autofocus: true,
        onSubmitted: onSearchSubmitted,
        onFocusChanged: onSearchFocusChanged,
        semanticLabel: 'Search events or clubs',
        emptyTrailingIcon: CatchIcons.close,
        emptyTrailingTooltip: 'Close search',
        onEmptyTrailingPressed: onCloseSearch,
      ),
    );
  }

  return SizedBox(
    height: CatchLayout.browseHeaderSearchExtent,
    child: Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: ExploreCityPicker(
              presentation: cityPresentation,
              foregroundColor:
                  cityPresentation == ExploreCityPickerPresentation.scopeLabel
                  ? foreground.withValues(
                      alpha: CatchOpacity.coverStoryLocation,
                    )
                  : null,
            ),
          ),
        ),
        gapW12,
        Tooltip(
          message: 'Search events or clubs',
          child: Semantics(
            button: true,
            label: 'Search events or clubs',
            child: CatchIconButton(
              background: searchButtonBackground,
              onTap: onSearchTap,
              child: Icon(
                CatchIcons.search,
                size: CatchIcon.md,
                color: searchButtonForeground,
              ),
            ),
          ),
        ),
      ],
    ),
  );
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

Widget _buildExploreCoverMeta(
  BuildContext context, {
  required ExploreEventItem item,
}) {
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
