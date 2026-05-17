import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
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
        Positioned(
          top: 52,
          right: 16,
          child: CatchBadge(
            label: '${event.signedUpCount}/${event.capacityLimit} spots',
            tone: CatchBadgeTone.live,
            size: CatchBadgeSize.md,
          ),
        ),
        Positioned(
          left: CatchSpacing.s5,
          right: CatchSpacing.s5,
          bottom: 16,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.meetingPoint,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(CatchRadius.pill),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  event.distanceKm == event.distanceKm.roundToDouble()
                      ? '${event.distanceKm.round()}km'
                      : '${event.distanceKm.toStringAsFixed(1)}km',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
              ),
            ],
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
        errorBuilder: (_, _, _) => const _EventPhotoFallback(),
      );
    }
    return const _EventPhotoFallback();
  }
}

class _EventPhotoFallback extends StatelessWidget {
  const _EventPhotoFallback();

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
          Icons.directions_run,
          color: t.primary.withValues(alpha: 0.42),
          size: 72,
        ),
      ),
    );
  }
}
