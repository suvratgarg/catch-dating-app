import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/static_map_dark.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_hype_avatar_stack.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpcomingRunsHero extends StatefulWidget {
  const UpcomingRunsHero({
    super.key,
    required this.runs,
    required this.viewerInterestedInGenders,
    required this.onRunTap,
  });

  final List<Run> runs;
  final List<Gender> viewerInterestedInGenders;
  final ValueChanged<Run> onRunTap;

  static const progressIndicatorKey = Key('upcoming-runs-progress-indicator');

  @override
  State<UpcomingRunsHero> createState() => _UpcomingRunsHeroState();
}

class _UpcomingRunsHeroState extends State<UpcomingRunsHero> {
  var _index = 0;
  var _dragDistance = 0.0;

  @override
  void didUpdateWidget(covariant UpcomingRunsHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= widget.runs.length) {
      _index = widget.runs.isEmpty ? 0 : widget.runs.length - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.runs.isEmpty) return const SizedBox.shrink();

    final hasMultipleRuns = widget.runs.length > 1;
    final run = widget.runs[_index];

    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: hasMultipleRuns
              ? (_) => _dragDistance = 0
              : null,
          onHorizontalDragUpdate: hasMultipleRuns
              ? (details) => _dragDistance += details.primaryDelta ?? 0
              : null,
          onHorizontalDragEnd: hasMultipleRuns ? _handleDragEnd : null,
          child: AnimatedSwitcher(
            duration: CatchMotion.fast,
            switchInCurve: CatchMotion.standardCurve,
            switchOutCurve: CatchMotion.standardCurve,
            child: NextRunHero(
              key: ValueKey('next-run-hero-card-${run.id}'),
              nextRun: run,
              viewerInterestedInGenders: widget.viewerInterestedInGenders,
              runIndex: _index,
              runCount: widget.runs.length,
              onTap: () => widget.onRunTap(run),
            ),
          ),
        ),
        if (hasMultipleRuns) ...[
          gapH10,
          _UpcomingRunsProgressIndicator(
            index: _index,
            count: widget.runs.length,
          ),
        ],
      ],
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final shouldMoveNext = velocity < -250 || _dragDistance < -48;
    final shouldMovePrevious = velocity > 250 || _dragDistance > 48;

    if (shouldMoveNext && _index < widget.runs.length - 1) {
      setState(() => _index += 1);
    } else if (shouldMovePrevious && _index > 0) {
      setState(() => _index -= 1);
    }
    _dragDistance = 0;
  }
}

class _UpcomingRunsProgressIndicator extends StatelessWidget {
  const _UpcomingRunsProgressIndicator({
    required this.index,
    required this.count,
  });

  static const _width = 132.0;
  static const _height = 6.0;

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final progress = count <= 0
        ? 0.0
        : ((index + 1) / count).clamp(0.0, 1.0).toDouble();

    return Semantics(
      label: 'Run ${index + 1} of $count',
      child: Center(
        child: SizedBox(
          key: UpcomingRunsHero.progressIndicatorKey,
          width: _width,
          height: _height,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: progress),
            duration: CatchMotion.fast,
            curve: CatchMotion.standardCurve,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: _height,
                borderRadius: BorderRadius.circular(CatchRadius.pill),
                backgroundColor: t.line2.withValues(alpha: 0.72),
                valueColor: AlwaysStoppedAnimation<Color>(t.primary),
              );
            },
          ),
        ),
      ),
    );
  }
}

class NextRunHero extends StatelessWidget {
  const NextRunHero({
    super.key,
    required this.nextRun,
    required this.viewerInterestedInGenders,
    this.onTap,
    this.runIndex = 0,
    this.runCount = 1,
  });

  static const cardKey = Key('next-run-hero-card');

  final Run nextRun;
  final List<Gender> viewerInterestedInGenders;
  final VoidCallback? onTap;
  final int runIndex;
  final int runCount;

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
      key: runCount > 1
          ? ValueKey('next-run-hero-card-${nextRun.id}')
          : cardKey,
      padding: EdgeInsets.zero,
      backgroundColor: t.surface,
      borderColor: t.line2,
      radius: 22,
      clipBehavior: Clip.antiAlias,
      onTap: onTap,
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
                Row(
                  children: [
                    Flexible(
                      child: _NextRunStatusPill(
                        label: _countdown(nextRun.startTime),
                      ),
                    ),
                    if (runCount > 1) ...[
                      gapW8,
                      _RunCountPill(index: runIndex, count: runCount),
                    ],
                  ],
                ),
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
                _ConfirmedRow(
                  nextRun: nextRun,
                  viewerInterestedInGenders: viewerInterestedInGenders,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RunCountPill extends StatelessWidget {
  const _RunCountPill({required this.index, required this.count});

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s2,
        vertical: CatchSpacing.s1,
      ),
      radius: CatchRadius.pill,
      backgroundColor: t.surface.withValues(alpha: 0.72),
      borderColor: t.line2,
      child: Text(
        '${index + 1}/$count',
        style: CatchTextStyles.labelS(context, color: t.ink2),
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
  const _ConfirmedRow({
    required this.nextRun,
    required this.viewerInterestedInGenders,
  });

  final Run nextRun;
  final List<Gender> viewerInterestedInGenders;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
      children: [
        if (nextRun.signedUpCount > 0) ...[
          RunHypeAvatarStack(
            runId: nextRun.id,
            totalCount: nextRun.signedUpCount,
            viewerInterestedInGenders: viewerInterestedInGenders,
            size: 32,
            limit: 4,
            obscured: true,
            showOverflowCount: false,
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
