import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/static_map_dark.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class NextRunHero extends ConsumerWidget {
  const NextRunHero({super.key, required this.tokens, required this.uid});

  final CatchTokens tokens;
  final String uid;

  static String _countdown(DateTime startTime) {
    final diff = startTime.difference(DateTime.now());
    if (diff.inDays >= 1) return 'IN ${diff.inDays}D';
    if (diff.inHours >= 1) return 'IN ${diff.inHours}H';
    return 'STARTING SOON';
  }

  static String _formatTime(DateTime dt) =>
      DateFormat('EEE d MMM · h:mm a').format(dt);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = tokens;
    final runsAsync = ref.watch(signedUpRunsProvider(uid));

    final Run? nextRun = runsAsync.asData?.value
        .where((r) => r.isUpcoming)
        .fold<Run?>(null, (best, r) =>
            best == null || r.startTime.isBefore(best.startTime) ? r : best);

    if (nextRun == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(Sizes.p18),
      decoration: BoxDecoration(
        color: t.ink,
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: StaticMapDark(),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '● NEXT RUN · ${_countdown(nextRun.startTime)}',
                style: CatchTextStyles.labelSm(
                  context,
                  color: t.surface.withValues(alpha: 0.75),
                ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.4),
              ),
              gapH8,
              Text(
                nextRun.title,
                style: CatchTextStyles.displayLg(context, color: t.surface),
              ),
              gapH10,
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 13, color: t.surface),
                  gapW4,
                  Text(
                    _formatTime(nextRun.startTime),
                    style: CatchTextStyles.caption(
                      context,
                      color: t.surface.withValues(alpha: 0.85),
                    ),
                  ),
                  gapW14,
                  Icon(Icons.location_on_outlined, size: 13, color: t.surface),
                  gapW4,
                  Flexible(
                    child: Text(
                      nextRun.meetingPoint,
                      style: CatchTextStyles.caption(
                        context,
                        color: t.surface.withValues(alpha: 0.85),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              gapH14,
              Row(
                children: [
                  if (nextRun.signedUpCount > 0) ...[
                    SizedBox(
                      height: 28,
                      width: 28 + (nextRun.signedUpCount.clamp(1, 4) - 1) * (28 - 8.0),
                      child: Stack(
                        children: [
                          for (var i = 0;
                              i < nextRun.signedUpCount && i < 4;
                              i++)
                            Positioned(
                              left: i * (28 - 8.0),
                              child: PersonAvatar(
                                size: 28,
                                name: nextRun.signedUpUserIds[i],
                                borderWidth: 2,
                                borderColor: t.ink,
                              ),
                            ),
                        ],
                      ),
                    ),
                    gapW10,
                  ],
                  Flexible(
                    child: Text(
                      '${nextRun.signedUpCount} runner${nextRun.signedUpCount == 1 ? '' : 's'} confirmed',
                      style: CatchTextStyles.caption(
                        context,
                        color: t.surface.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
