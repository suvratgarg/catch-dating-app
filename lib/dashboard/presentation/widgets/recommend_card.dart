import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_corner_sash.dart';
import 'package:catch_dating_app/core/widgets/catch_event_card_compact.dart';
import 'package:catch_dating_app/core/widgets/catch_event_card_hero.dart';
import 'package:catch_dating_app/core/widgets/catch_event_thumbnail.dart';
import 'package:catch_dating_app/core/widgets/catch_meta_row.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Dashboard recommendation card.
///
/// Wraps [CatchEventCardCompact] so the dashboard rail visually matches the
/// Explore feed — same caps-time kicker, photo + scrim, dot-separated
/// meta. The recommender's "reason" (e.g. *From your clubs*, *Top rated*)
/// becomes the corner sash so each rail card has a single curatorial mark
/// instead of competing chips.
class RecommendCard extends StatelessWidget {
  const RecommendCard({super.key, required this.event, this.clubName, this.reasonLabel, this.width});

  factory RecommendCard.fromRecommendation({
    Key? key,
    required DashboardEventRecommendation recommendation,
    double? width,
  }) {
    return RecommendCard(
      key: key,
      event: recommendation.event,
      clubName: recommendation.clubName,
      reasonLabel: recommendation.reasonLabel,
      width: width,
    );
  }

  factory RecommendCard.fromEvent({
    Key? key,
    required Event event,
    double? width,
  }) {
    return RecommendCard(
      key: key,
      event: event,
      clubName: 'Your club',
      reasonLabel: 'From your clubs',
      width: width,
    );
  }

  final Event event;
  final String? clubName;
  final String? reasonLabel;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final cardWidth = width;
    final card = CatchEventCardCompact(
      title: event.title,
      subtitle: _buildSubtitle(),
      kickerLabel: _kickerLabel(),
      kickerTrailing: _kickerTrailing(),
      meta: [
        CatchMetaEntry(
          icon: activityKindGlyph(event.activityKind),
          label: event.activitySummaryLabel,
        ),
        CatchMetaEntry(
          icon: CatchIcons.group,
          label: '${event.signedUpCount}/${event.capacityLimit}',
        ),
      ],
      distanceTrailing: null,
      photoUrl: event.photoUrl,
      pace: event.pace,
      activityKind: event.activityKind,
      sash: reasonLabel == null
          ? null
          : CatchEventSashSpec(
              label: reasonLabel!,
              tone: CatchSashTone.brand,
            ),
      priceLabel: event.isFree
          ? 'Free'
          : EventFormatters.priceInPaise(
              event.priceInPaise,
              currencyCode: event.currency,
            ),
      onTap: () => context.pushNamed(
        Routes.dashboardEventDetailScreen.name,
        pathParameters: {'clubId': event.clubId, 'eventId': event.id},
        extra: event,
      ),
    );

    if (cardWidth == null) return card;
    return SizedBox(width: cardWidth, child: card);
  }

  String _buildSubtitle() {
    final club = clubName;
    if (club == null || club.isEmpty) return event.locationName;
    return '$club · ${event.locationName}';
  }

  String _kickerLabel() {
    final start = event.startTime;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(start.year, start.month, start.day);
    final time = EventFormatters.time(start);
    final diffDays = eventDay.difference(today).inDays;
    return switch (diffDays) {
      0 => 'Today · $time',
      1 => 'Tomorrow · $time',
      _ => '${EventFormatters.shortWeekday(start)} · $time',
    };
  }

  String? _kickerTrailing() {
    final delta = event.startTime.difference(DateTime.now());
    if (delta.inMinutes <= 0 || delta.inHours >= 24) return null;
    if (delta.inHours < 1) return 'in ${delta.inMinutes}m';
    final minutes = delta.inMinutes.remainder(60);
    if (minutes == 0) return 'in ${delta.inHours}h';
    return 'in ${delta.inHours}h ${minutes}m';
  }
}
