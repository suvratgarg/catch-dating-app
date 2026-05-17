import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecommendCard extends StatelessWidget {
  const RecommendCard({super.key, required this.data, this.width});

  factory RecommendCard.fromRecommendation({
    Key? key,
    required DashboardEventRecommendation recommendation,
    double? width,
  }) {
    return RecommendCard(
      key: key,
      data: EventTileData.fromEvent(
        event: recommendation.event,
        status: EventTileStatus.recommended,
        clubName: recommendation.clubName,
        reasonLabel: recommendation.reasonLabel,
      ),
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
      data: EventTileData.fromEvent(
        event: event,
        status: EventTileStatus.recommended,
        clubName: 'Your club',
        reasonLabel: 'From your clubs',
      ),
      width: width,
    );
  }

  final EventTileData data;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return EventRailTile(
      data: data,
      width: width,
      onTap: () => context.pushNamed(
        Routes.dashboardEventDetailScreen.name,
        pathParameters: {'clubId': data.clubId, 'eventId': data.eventId},
        extra: data.event,
      ),
    );
  }
}
