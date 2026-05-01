import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AttendedRunTile extends StatelessWidget {
  const AttendedRunTile({super.key, required this.run});

  final Run run;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final dateStr = DateFormat('EEE d MMM').format(run.startTime);
    final remaining = swipeWindowClosesAt(run).difference(DateTime.now());
    final countdown = _formatCountdown(remaining);

    return CatchSurface(
      padding: const EdgeInsets.all(Sizes.p16),
      borderColor: t.line,
      onTap: () => context.pushNamed(
        Routes.swipeRunScreen.name,
        pathParameters: {'runId': run.id},
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: t.heroGrad,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.favorite_rounded, color: t.primaryInk),
          ),
          gapW14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OPEN CATCH WINDOW',
                  style: CatchTextStyles.labelM(
                    context,
                    color: t.primary,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                gapH4,
                Text(
                  run.title,
                  style: CatchTextStyles.titleL(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                gapH4,
                Text(
                  '$dateStr · ${run.attendedUserIds.length} runners checked in',
                  style: CatchTextStyles.bodyS(context, color: t.ink2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          gapW10,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                countdown,
                style: CatchTextStyles.mono(context, color: t.ink),
              ),
              gapH4,
              CatchButton(
                label: 'Recap',
                onPressed: () => context.pushNamed(
                  Routes.runRecapScreen.name,
                  pathParameters: {'runId': run.id},
                ),
                variant: CatchButtonVariant.ghost,
                size: CatchButtonSize.sm,
                foregroundColor: t.primary,
              ),
              gapH4,
              CatchBadge(
                label: 'Swipe',
                tone: CatchBadgeTone.solid,
                size: CatchBadgeSize.md,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatCountdown(Duration remaining) {
    if (remaining.isNegative) return 'CLOSED';
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    if (hours > 0) return '${hours}H ${minutes.toString().padLeft(2, '0')}M';
    return '${minutes.clamp(0, 59)}M';
  }
}
