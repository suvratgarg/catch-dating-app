import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Shows a swipe-window callout for the most recent attended run that still
/// has an open swipe window (run.endTime + 24 h > now).
/// Returns [SizedBox.shrink] when no active window exists.
class CatchesCallout extends ConsumerWidget {
  const CatchesCallout({super.key, required this.tokens, required this.uid});

  final CatchTokens tokens;
  final String uid;

  static const _swipeWindowDuration = Duration(hours: 24);

  static String _formatCountdown(Duration remaining) {
    final h = remaining.inHours;
    final m = remaining.inMinutes.remainder(60);
    return '${h}H ${m.toString().padLeft(2, '0')}M';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = tokens;
    final attendedAsync = ref.watch(attendedRunsProvider(uid));
    final attended = attendedAsync.asData?.value ?? [];

    final now = DateTime.now();

    final Run? activeRun = attended.fold<Run?>(null, (best, run) {
      final windowClose = run.endTime.add(_swipeWindowDuration);
      if (windowClose.isBefore(now)) return best;
      if (best == null) return run;
      return run.endTime.isAfter(best.endTime) ? run : best;
    });

    if (activeRun == null) return const SizedBox.shrink();

    final windowClose = activeRun.endTime.add(_swipeWindowDuration);
    final remaining = windowClose.difference(now);

    return GestureDetector(
      onTap: () => context.go('/catches/${activeRun.id}'),
      child: Container(
        padding: const EdgeInsets.all(Sizes.p16),
        decoration: BoxDecoration(
          color: t.primary,
          borderRadius: BorderRadius.circular(CatchRadius.cardLg),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite_rounded, color: t.primaryInk, size: 22),
            ),
            gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SWIPE WINDOW CLOSING · ${_formatCountdown(remaining)}',
                    style: CatchTextStyles.labelSm(
                      context,
                      color: t.primaryInk.withValues(alpha: 0.85),
                    ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.0),
                  ),
                  gapH2,
                  Text(
                    'Swipe on runners from ${activeRun.title}',
                    style: CatchTextStyles.displaySm(context, color: t.primaryInk),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: t.primaryInk, size: 22),
          ],
        ),
      ),
    );
  }
}
