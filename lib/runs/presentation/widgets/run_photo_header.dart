import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';

class RunPhotoHeader extends StatelessWidget {
  const RunPhotoHeader({super.key, required this.run});

  final Run run;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _RunPhotoBackground(run: run),
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
            label: '${run.signedUpCount}/${run.capacityLimit} spots',
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
                      run.meetingPoint,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      run.title,
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
                  run.distanceKm == run.distanceKm.roundToDouble()
                      ? '${run.distanceKm.round()}km'
                      : '${run.distanceKm.toStringAsFixed(1)}km',
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

class _RunPhotoBackground extends StatelessWidget {
  const _RunPhotoBackground({required this.run});

  final Run run;

  @override
  Widget build(BuildContext context) {
    final photoUrl = run.photoUrl?.trim();
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
        semanticLabel: '${run.title} photo',
        errorBuilder: (_, _, _) => const _RunPhotoFallback(),
      );
    }
    return const _RunPhotoFallback();
  }
}

class _RunPhotoFallback extends StatelessWidget {
  const _RunPhotoFallback();

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
