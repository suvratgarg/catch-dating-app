import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:flutter/material.dart';

class EventPhotoHeader extends StatelessWidget {
  const EventPhotoHeader({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _EventPhotoBackground(event: event),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.4, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EventPhotoBackground extends StatelessWidget {
  const _EventPhotoBackground({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final photoUrl = event.photoUrl?.trim();
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
        semanticLabel: '${event.title} photo',
        errorBuilder: (_, _, _) => _EventPhotoFallback(event: event),
      );
    }
    return _EventPhotoFallback(event: event);
  }
}

class _EventPhotoFallback extends StatelessWidget {
  const _EventPhotoFallback({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [t.raised, t.surface, t.primary.withValues(alpha: 0.18)],
        ),
      ),
      child: Center(
        child: Icon(
          _fallbackIconFor(event.activityKind),
          color: t.primary.withValues(alpha: 0.42),
          size: 72,
        ),
      ),
    );
  }
}

IconData _fallbackIconFor(ActivityKind activityKind) {
  return switch (activityKind) {
    ActivityKind.socialRun || ActivityKind.running => Icons.directions_run,
    ActivityKind.walking => Icons.directions_walk,
    ActivityKind.pickleball ||
    ActivityKind.padel ||
    ActivityKind.tennis ||
    ActivityKind.badminton => Icons.sports_tennis,
    ActivityKind.cycling || ActivityKind.spinClass => Icons.directions_bike,
    ActivityKind.yoga => Icons.self_improvement,
    ActivityKind.strengthTraining => Icons.fitness_center,
    ActivityKind.pubQuiz => Icons.quiz_outlined,
    ActivityKind.barCrawl => Icons.local_bar_outlined,
    ActivityKind.dinner => Icons.restaurant_outlined,
    ActivityKind.singlesMixer => Icons.groups_outlined,
    ActivityKind.openActivity => Icons.event_available_outlined,
  };
}
