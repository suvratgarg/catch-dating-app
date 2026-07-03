import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_analytics_bar.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_stat_column.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/user_analytics/data/user_analytics_repository.dart';
import 'package:catch_dating_app/user_analytics/shared/user_analytics_copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserAnalyticsPanel extends ConsumerStatefulWidget {
  const UserAnalyticsPanel({super.key});

  @override
  ConsumerState<UserAnalyticsPanel> createState() => _UserAnalyticsPanelState();
}

class _UserAnalyticsPanelState extends ConsumerState<UserAnalyticsPanel> {
  var _rangePreset = UserAnalyticsRangePreset.thirtyDays;

  @override
  Widget build(BuildContext context) {
    final query = UserAnalyticsQuery(rangePreset: _rangePreset);
    final reportAsync = ref.watch(userAnalyticsProvider(query));

    return CatchSection.divided(
      title: UserAnalyticsCopy.sectionTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchOptionGroup<UserAnalyticsRangePreset>(
            selected: _rangePreset,
            onChanged: (preset) => setState(() => _rangePreset = preset),
            variant: CatchOptionGroupVariant.mono,
            options: [
              CatchOption(
                value: UserAnalyticsRangePreset.sevenDays,
                label: UserAnalyticsCopy
                    .rangeLabels[UserAnalyticsRangePreset.sevenDays]!,
              ),
              CatchOption(
                value: UserAnalyticsRangePreset.thirtyDays,
                label: UserAnalyticsCopy
                    .rangeLabels[UserAnalyticsRangePreset.thirtyDays]!,
              ),
              CatchOption(
                value: UserAnalyticsRangePreset.ninetyDays,
                label: UserAnalyticsCopy
                    .rangeLabels[UserAnalyticsRangePreset.ninetyDays]!,
              ),
              CatchOption(
                value: UserAnalyticsRangePreset.month,
                label: UserAnalyticsCopy
                    .rangeLabels[UserAnalyticsRangePreset.month]!,
              ),
            ],
          ),
          gapH16,
          reportAsync.when(
            loading: () => Semantics(
              label: UserAnalyticsCopy.loadingLabel,
              child: const UserAnalyticsReportSkeleton(),
            ),
            error: (error, _) => CatchErrorState.fromError(
              error,
              context: AppErrorContext.profile,
              onRetry: () => ref.invalidate(userAnalyticsProvider(query)),
            ),
            data: (report) => UserAnalyticsReportView(report: report),
          ),
        ],
      ),
    );
  }
}

class UserAnalyticsReportView extends StatelessWidget {
  const UserAnalyticsReportView({super.key, required this.report});

  final UserAnalyticsReport report;

  @override
  Widget build(BuildContext context) {
    if (report.summaryCards.every(
      (metric) => metric.status == UserAnalyticsMetricStatus.missing,
    )) {
      return const UserAnalyticsEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAnalyticsMetricGrid(metrics: report.summaryCards),
        gapH20,
        UserAnalyticsTrendPanel(points: report.trend),
        if (report.coachingTipRefs.isNotEmpty) ...[
          gapH20,
          UserAnalyticsTipsPanel(tips: report.coachingTipRefs),
        ],
        gapH20,
        UserAnalyticsDataQualityPanel(rows: report.dataQuality),
      ],
    );
  }
}

class UserAnalyticsEmptyState extends StatelessWidget {
  const UserAnalyticsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(CatchIcons.autoGraphRounded, color: t.ink2),
          const SizedBox(width: CatchSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  UserAnalyticsCopy.emptyTitle,
                  style: CatchTextStyles.labelL(context, color: t.ink),
                ),
                gapH6,
                Text(
                  UserAnalyticsCopy.emptyBody,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserAnalyticsReportSkeleton extends StatelessWidget {
  const UserAnalyticsReportSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - CatchSpacing.s3) / 2;
            return Wrap(
              spacing: CatchSpacing.s3,
              runSpacing: CatchSpacing.s3,
              children: [
                for (var index = 0; index < 4; index++)
                  SizedBox(
                    width: itemWidth,
                    child: CatchSurface(
                      padding: CatchInsets.content,
                      borderColor: CatchTokens.of(context).line,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CatchSkeleton.box(
                                width: CatchIcon.sm,
                                height: CatchIcon.sm,
                              ),
                              const Spacer(),
                              CatchSkeleton.box(
                                width: CatchSpacing.s8,
                                height: CatchIcon.sm,
                                radius: CatchRadius.pill,
                              ),
                            ],
                          ),
                          gapH12,
                          CatchSkeleton.text(
                            width: index.isEven
                                ? CatchLayout.skeletonTextShortWidth
                                : CatchLayout.skeletonTextTitleWidth,
                          ),
                          gapH8,
                          CatchSkeleton.text(
                            width: CatchLayout.skeletonTextShortWidth,
                          ),
                          gapH8,
                          CatchSkeleton.textBlock(lines: 2),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        gapH20,
        UserAnalyticsSection(
          label: UserAnalyticsCopy.trendTitle,
          child: CatchSurface(
            padding: CatchInsets.content,
            borderColor: CatchTokens.of(context).line,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: CatchSkeleton.textBlock(lines: 2)),
                    gapW16,
                    Expanded(child: CatchSkeleton.textBlock(lines: 2)),
                  ],
                ),
                gapH16,
                SizedBox(
                  height: CatchSpacing.s16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var index = 0; index < 12; index++) ...[
                        if (index > 0)
                          const SizedBox(width: CatchSpacing.micro6),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: 0.2 + ((index % 5) * 0.15),
                              child: CatchSkeleton.box(height: double.infinity),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        gapH20,
        UserAnalyticsSection(
          label: UserAnalyticsCopy.tipsTitle,
          child: CatchSurface(
            padding: CatchInsets.content,
            borderColor: CatchTokens.of(context).line,
            child: Column(
              children: [
                for (var index = 0; index < 2; index++) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CatchSkeleton.box(
                        width: CatchIcon.sm,
                        height: CatchIcon.sm,
                      ),
                      gapW12,
                      Expanded(child: CatchSkeleton.textBlock(lines: 2)),
                    ],
                  ),
                  if (index == 0) gapH16,
                ],
              ],
            ),
          ),
        ),
        gapH20,
        UserAnalyticsSection(
          label: UserAnalyticsCopy.dataQualityTitle,
          child: CatchSurface(
            padding: CatchInsets.content,
            borderColor: CatchTokens.of(context).line,
            child: Column(
              children: [
                for (var index = 0; index < 2; index++) ...[
                  Row(
                    children: [
                      CatchSkeleton.box(
                        width: CatchIcon.sm,
                        height: CatchIcon.sm,
                      ),
                      gapW12,
                      Expanded(child: CatchSkeleton.text()),
                    ],
                  ),
                  if (index == 0) ...[
                    gapH12,
                    Divider(color: CatchTokens.of(context).line),
                    gapH12,
                  ],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class UserAnalyticsMetricGrid extends StatelessWidget {
  const UserAnalyticsMetricGrid({super.key, required this.metrics});

  final List<UserAnalyticsMetricCard> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - CatchSpacing.s3) / 2;
        return Wrap(
          spacing: CatchSpacing.s3,
          runSpacing: CatchSpacing.s3,
          children: [
            for (final metric in metrics.take(6))
              SizedBox(
                width: itemWidth,
                child: UserAnalyticsMetricTile(metric: metric),
              ),
          ],
        );
      },
    );
  }
}

class UserAnalyticsMetricTile extends StatelessWidget {
  const UserAnalyticsMetricTile({super.key, required this.metric});

  final UserAnalyticsMetricCard metric;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final muted = metric.status == UserAnalyticsMetricStatus.missing;
    final badge = _statusBadge(metric.status);
    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: muted
          ? t.warning.withValues(alpha: CatchOpacity.mutedBorderUrgent)
          : t.line,
      backgroundColor: muted
          ? t.warning.withValues(alpha: CatchOpacity.warningFill)
          : t.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_metricIcon(metric.id), size: CatchIcon.sm, color: t.ink2),
              const Spacer(),
              ?badge,
            ],
          ),
          gapH12,
          Text(
            _formatMetricValue(metric),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.numericLarge(
              context,
              color: muted ? t.ink3 : t.ink,
            ),
          ),
          gapH4,
          Text(
            UserAnalyticsCopy.metricLabel(metric.id, fallback: metric.label),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.labelM(context, color: t.ink2),
          ),
          if (UserAnalyticsCopy.metricCaption(
                metric.id,
                fallback: metric.caption,
              )
              case final caption? when caption.trim().isNotEmpty) ...[
            gapH8,
            Text(
              caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.supporting(context, color: t.ink3),
            ),
          ],
        ],
      ),
    );
  }
}

class UserAnalyticsTrendPanel extends StatelessWidget {
  const UserAnalyticsTrendPanel({super.key, required this.points});

  final List<UserAnalyticsTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final maxCaughtYou = points.fold<num>(0, (max, point) {
      final value = point.metrics['caughtYou'] ?? 0;
      return value > max ? value : max;
    });
    final totalCaughtYou = points.fold<num>(
      0,
      (sum, point) => sum + (point.metrics['caughtYou'] ?? 0),
    );
    final totalMatches = points.fold<num>(
      0,
      (sum, point) => sum + (point.metrics['mutualCatches'] ?? 0),
    );

    return UserAnalyticsSection(
      label: UserAnalyticsCopy.trendTitle,
      child: CatchSurface(
        padding: CatchInsets.content,
        borderColor: CatchTokens.of(context).line,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CatchStatColumn(
                    label: UserAnalyticsCopy.trendMetricLabel('caughtYou'),
                    value: _formatCount(totalCaughtYou),
                  ),
                ),
                Expanded(
                  child: CatchStatColumn(
                    label: UserAnalyticsCopy.trendMetricLabel('mutualCatches'),
                    value: _formatCount(totalMatches),
                  ),
                ),
              ],
            ),
            gapH16,
            SizedBox(
              height: CatchSpacing.s16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final point in points.take(18)) ...[
                    if (point != points.first)
                      const SizedBox(width: CatchSpacing.micro6),
                    Expanded(
                      child: CatchAnalyticsBar(
                        value: point.metrics['caughtYou'] ?? 0,
                        maxValue: maxCaughtYou,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserAnalyticsTipsPanel extends StatelessWidget {
  const UserAnalyticsTipsPanel({super.key, required this.tips});

  final List<UserAnalyticsCoachingTipRef> tips;

  @override
  Widget build(BuildContext context) {
    return UserAnalyticsSection(
      label: UserAnalyticsCopy.tipsTitle,
      child: CatchSurface(
        padding: CatchInsets.content,
        borderColor: CatchTokens.of(context).line,
        child: Column(
          children: [
            for (final tip in tips) ...[
              if (tip != tips.first) gapH16,
              UserAnalyticsTipRow(tip: tip),
            ],
          ],
        ),
      ),
    );
  }
}

class UserAnalyticsTipRow extends StatelessWidget {
  const UserAnalyticsTipRow({super.key, required this.tip});

  final UserAnalyticsCoachingTipRef tip;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final copy = UserAnalyticsCopy.tip(tip.copyKey);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(CatchIcons.sparkle, size: CatchIcon.sm, color: t.ink2),
        const SizedBox(width: CatchSpacing.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                copy.title,
                style: CatchTextStyles.labelM(context, color: t.ink),
              ),
              gapH4,
              Text(
                copy.body,
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class UserAnalyticsDataQualityPanel extends StatelessWidget {
  const UserAnalyticsDataQualityPanel({super.key, required this.rows});

  final List<UserAnalyticsDataQuality> rows;

  @override
  Widget build(BuildContext context) {
    return UserAnalyticsSection(
      label: UserAnalyticsCopy.dataQualityTitle,
      child: CatchSurface(
        padding: CatchInsets.content,
        borderColor: CatchTokens.of(context).line,
        child: Column(
          children: [
            for (final row in rows) ...[
              if (row != rows.first)
                Divider(color: CatchTokens.of(context).line),
              UserAnalyticsDataQualityRow(row: row),
            ],
          ],
        ),
      ),
    );
  }
}

class UserAnalyticsDataQualityRow extends StatelessWidget {
  const UserAnalyticsDataQualityRow({super.key, required this.row});

  final UserAnalyticsDataQuality row;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(_qualityIcon(row.state), size: CatchIcon.sm, color: t.ink2),
        const SizedBox(width: CatchSpacing.s3),
        Expanded(
          child: Text(
            row.detail,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ),
      ],
    );
  }
}

class UserAnalyticsSection extends StatelessWidget {
  const UserAnalyticsSection({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: CatchTextStyles.labelL(context)),
        gapH8,
        child,
      ],
    );
  }
}

CatchBadge? _statusBadge(UserAnalyticsMetricStatus status) {
  return switch (status) {
    UserAnalyticsMetricStatus.partial => const CatchBadge(
      label: UserAnalyticsCopy.partialBadge,
      tone: CatchBadgeTone.warning,
    ),
    UserAnalyticsMetricStatus.missing => const CatchBadge(
      label: UserAnalyticsCopy.missingBadge,
    ),
    UserAnalyticsMetricStatus.ready => null,
  };
}

IconData _metricIcon(String id) => switch (id) {
  'profileViews' => CatchIcons.eye,
  'caughtYou' => CatchIcons.favoriteOutline,
  'mutualCatches' => CatchIcons.sparkle,
  'chatsStarted' => CatchIcons.chatCircle,
  'eventsAttended' => CatchIcons.eventAvailableOutlined,
  'followThroughRate' => CatchIcons.autoGraphRounded,
  _ => CatchIcons.autoGraphRounded,
};

IconData _qualityIcon(UserAnalyticsDataQualityState state) => switch (state) {
  UserAnalyticsDataQualityState.ok => CatchIcons.checkCircleOutlineRounded,
  UserAnalyticsDataQualityState.partial => CatchIcons.info,
  UserAnalyticsDataQualityState.missing => CatchIcons.errorOutlineRounded,
};

String _formatMetricValue(UserAnalyticsMetricCard metric) {
  return switch (metric.unit) {
    UserAnalyticsMetricUnit.percent => '${_formatCount(metric.value)}%',
    UserAnalyticsMetricUnit.durationSeconds => _formatDuration(metric.value),
    UserAnalyticsMetricUnit.count => _formatCount(metric.value),
  };
}

String _formatCount(num value) {
  final rounded = value.round();
  if (rounded >= 1000000) {
    return '${(rounded / 1000000).toStringAsFixed(1)}M';
  }
  if (rounded >= 10000) {
    return '${(rounded / 1000).toStringAsFixed(1)}K';
  }
  return rounded.toString();
}

String _formatDuration(num seconds) {
  final rounded = seconds.round();
  if (rounded < 60) return '${rounded}s';
  return '${(rounded / 60).round()}m';
}
