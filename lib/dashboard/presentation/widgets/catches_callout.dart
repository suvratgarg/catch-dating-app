import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CatchesCallout extends StatelessWidget {
  const CatchesCallout({
    super.key,
    required this.tokens,
    required this.activeRun,
  });

  final CatchTokens tokens;
  final Run activeRun;

  static String _formatCountdown(Duration remaining) {
    final h = remaining.inHours;
    final m = remaining.inMinutes.remainder(60);
    return '${h}H ${m.toString().padLeft(2, '0')}M';
  }

  @override
  Widget build(BuildContext context) {
    final t = tokens;

    final now = DateTime.now();
    final windowClose = swipeWindowClosesAt(activeRun);
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
              child: Icon(
                Icons.favorite_rounded,
                color: t.primaryInk,
                size: 22,
              ),
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
                    style: CatchTextStyles.displaySm(
                      context,
                      color: t.primaryInk,
                    ),
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
