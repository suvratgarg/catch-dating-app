import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/static_map_dark.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NextRunHero extends StatelessWidget {
  const NextRunHero({super.key, required this.nextRun});

  static const cardKey = Key('next-run-hero-card');

  final Run nextRun;

  static String _countdown(DateTime startTime) {
    final diff = startTime.difference(DateTime.now());
    if (diff.inDays >= 1) return 'IN ${diff.inDays}D';
    if (diff.inHours >= 1) return 'IN ${diff.inHours}H';
    return 'STARTING SOON';
  }

  static String _formatTime(DateTime dt) =>
      DateFormat('EEE d MMM · h:mm a').format(dt);

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textureOpacity = isDark ? 0.16 : 0.08;

    return CatchSurface(
      key: cardKey,
      padding: EdgeInsets.zero,
      backgroundColor: t.surface,
      borderColor: t.line2,
      radius: 22,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(opacity: textureOpacity, child: StaticMapDark()),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    t.surface.withValues(alpha: isDark ? 0.96 : 0.94),
                    t.surface.withValues(alpha: isDark ? 0.82 : 0.88),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Sizes.p18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NextRunStatusPill(label: _countdown(nextRun.startTime)),
                gapH14,
                Text(
                  nextRun.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.displayM(context, color: t.ink),
                ),
                gapH12,
                Wrap(
                  spacing: CatchSpacing.s3,
                  runSpacing: CatchSpacing.s1,
                  children: [
                    _RunMetaChip(
                      icon: Icons.access_time_rounded,
                      label: _formatTime(nextRun.startTime),
                    ),
                    _RunMetaChip(
                      icon: Icons.location_on_outlined,
                      label: nextRun.meetingPoint,
                    ),
                  ],
                ),
                gapH16,
                _ConfirmedRow(nextRun: nextRun),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextRunStatusPill extends StatelessWidget {
  const _NextRunStatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.primarySoft.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(CatchRadius.pill),
        border: Border.all(color: t.primary.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s3,
          vertical: CatchSpacing.s1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: t.primary,
                shape: BoxShape.circle,
              ),
              child: const SizedBox.square(dimension: 7),
            ),
            gapW8,
            Flexible(
              child: Text(
                'NEXT RUN · $label',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.labelS(
                  context,
                  color: t.primary,
                ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RunMetaChip extends StatelessWidget {
  const _RunMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: t.ink3),
          gapW4,
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.bodyS(context, color: t.ink2),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmedRow extends StatelessWidget {
  const _ConfirmedRow({required this.nextRun});

  final Run nextRun;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
      children: [
        if (nextRun.signedUpCount > 0) ...[
          SizedBox(
            height: 32,
            width: 32 + (nextRun.signedUpCount.clamp(1, 4) - 1) * (32 - 9.0),
            child: Stack(
              children: [
                for (var i = 0; i < nextRun.signedUpCount && i < 4; i++)
                  Positioned(
                    left: i * (32 - 9.0),
                    child: PersonAvatar(
                      size: 32,
                      name: '${nextRun.id}-$i',
                      borderWidth: 2,
                      borderColor: t.surface,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.bodyM(context, color: t.ink2),
          ),
        ),
      ],
    );
  }
}
