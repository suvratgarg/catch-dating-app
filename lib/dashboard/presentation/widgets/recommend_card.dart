import 'package:catch_dating_app/core/widgets/catch_event_activity_cards.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_capacity_presenter.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Dashboard recommendation card.
///
/// Wraps [CatchEventCard.ticket] so the dashboard rail uses the same activity
/// artwork and ticket shape as the Explore event feed. Recommendation reason
/// stays visible in the media label while distance, pace, and capacity are
/// folded into the ticket's bottom mono line.
class RecommendCard extends StatelessWidget {
  const RecommendCard({
    super.key,
    required this.event,
    this.clubName,
    this.reasonLabel,
    this.width,
  });

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
    final card = CatchEventCard.ticket(
      title: event.title,
      subtitle: _buildSubtitle(),
      timeLabel: EventFormatters.time(event.startTime),
      countdownLabel: _countdownLabel(),
      priceLabel: event.isFree
          ? 'Free'
          : EventFormatters.priceInPaise(
              event.priceInPaise,
              currencyCode: event.currency,
            ),
      capacityLabel: _capacityLabel(),
      activityKind: event.activityKind,
      statusLabel: reasonLabel,
      clockTime: TimeOfDay.fromDateTime(event.startTime),
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

  String _countdownLabel() {
    final start = event.startTime;
    final relative = _relativeCountdownLabel(start);
    if (relative != null) return relative;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(start.year, start.month, start.day);
    final diffDays = eventDay.difference(today).inDays;
    return switch (diffDays) {
      0 => 'Today',
      1 => 'Tomorrow',
      _ => EventFormatters.shortWeekday(start),
    };
  }

  String? _relativeCountdownLabel(DateTime startTime) {
    final delta = startTime.difference(DateTime.now());
    if (delta.inMinutes <= 0 || delta.inHours >= 24) return null;
    if (delta.inHours < 1) return 'In ${delta.inMinutes}m';
    final minutes = delta.inMinutes.remainder(60);
    if (minutes == 0) return 'In ${delta.inHours}h';
    return 'In ${delta.inHours}h ${minutes}m';
  }

  String _capacityLabel() {
    return EventCapacityPresenter(event).activityGoingAvailabilityLabel();
  }
}
