import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_analytics_bar.dart';
import 'package:catch_dating_app/core/widgets/catch_analytics_kit.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_stat_column.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/user_analytics/data/user_analytics_repository.dart';
import 'package:catch_dating_app/user_analytics/shared/user_analytics_copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserAnalyticsPanel extends ConsumerStatefulWidget {
  const UserAnalyticsPanel({super.key, this.showSectionTitle = true});

  final bool showSectionTitle;

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
      title: widget.showSectionTitle
          ? UserAnalyticsCopy.sectionTitle(context.l10n)
          : null,
      first: !widget.showSectionTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchField.select<UserAnalyticsRangePreset>(
            title: UserAnalyticsCopy.rangeTitle(context.l10n),
            values: UserAnalyticsRangePreset.values
                .where((preset) => preset != UserAnalyticsRangePreset.custom)
                .toList(growable: false),
            value: _rangePreset,
            itemLabel: (preset) =>
                UserAnalyticsCopy.rangeLabel(context.l10n, preset),
            prefixIcon: Icon(CatchIcons.calendarMonthOutlined),
            onChanged: (preset) {
              if (preset == null) return;
              setState(() => _rangePreset = preset);
            },
          ),
          gapH16,
          reportAsync.when(
            loading: () => Semantics(
              label: UserAnalyticsCopy.loadingLabel(context.l10n),
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

    return CatchSectionStack(
      padding: EdgeInsets.zero,
      children: [
        CatchSection.divided(
          first: true,
          child: CatchAnalyticsMetricGrid(
            metrics: [
              for (final metric in report.summaryCards)
                _userMetricCardData(metric, context.l10n),
            ],
            maxItems: 6,
          ),
        ),
        UserAnalyticsTrendPanel(points: report.trend),
        if (report.coachingTipRefs.isNotEmpty)
          UserAnalyticsTipsPanel(tips: report.coachingTipRefs),
        UserAnalyticsDataCoveragePanel(rows: report.dataQuality),
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
                  UserAnalyticsCopy.emptyTitle(context.l10n),
                  style: CatchTextStyles.labelL(context, color: t.ink),
                ),
                gapH6,
                Text(
                  UserAnalyticsCopy.emptyBody(context.l10n),
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
    return CatchSectionStack(
      padding: EdgeInsets.zero,
      children: [
        CatchSection.divided(
          first: true,
          child: LayoutBuilder(
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
        ),
        CatchSection.divided(
          title: UserAnalyticsCopy.trendTitle(context.l10n),
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
        CatchSection.fieldRows(
          title: UserAnalyticsCopy.tipsTitle(context.l10n),
          children: [
            for (var index = 0; index < 2; index++)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CatchFieldTokens.rowHorizontalPadding,
                  vertical: CatchFieldTokens.rowVerticalPadding,
                ),
                child: Row(
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
              ),
          ],
        ),
        CatchSection.fieldRows(
          title: UserAnalyticsCopy.dataQualityTitle(context.l10n),
          children: [
            for (var index = 0; index < 2; index++)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CatchFieldTokens.rowHorizontalPadding,
                  vertical: CatchFieldTokens.rowVerticalPadding,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CatchSkeleton.box(
                      width: CatchIcon.md,
                      height: CatchIcon.md,
                    ),
                    gapW12,
                    Expanded(child: CatchSkeleton.textBlock(lines: 2)),
                  ],
                ),
              ),
          ],
        ),
      ],
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

    return CatchSection.divided(
      title: UserAnalyticsCopy.trendTitle(context.l10n),
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
                    label: UserAnalyticsCopy.trendMetricLabel(
                      context.l10n,
                      'caughtYou',
                    ),
                    value: _formatCount(totalCaughtYou),
                  ),
                ),
                Expanded(
                  child: CatchStatColumn(
                    label: UserAnalyticsCopy.trendMetricLabel(
                      context.l10n,
                      'mutualCatches',
                    ),
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
    return CatchSection.fieldRows(
      title: UserAnalyticsCopy.tipsTitle(context.l10n),
      children: [for (final tip in tips) UserAnalyticsTipRow(tip: tip)],
    );
  }
}

class UserAnalyticsTipRow extends StatelessWidget {
  const UserAnalyticsTipRow({super.key, required this.tip});

  final UserAnalyticsCoachingTipRef tip;

  @override
  Widget build(BuildContext context) {
    final copy = UserAnalyticsCopy.tip(context.l10n, tip.copyKey);
    return CatchField.content(
      icon: CatchIcons.sparkle,
      iconColor: CatchTokens.of(context).ink2,
      title: copy.title,
      body: copy.body,
    );
  }
}

class UserAnalyticsDataCoveragePanel extends StatelessWidget {
  const UserAnalyticsDataCoveragePanel({super.key, required this.rows});

  final List<UserAnalyticsDataQuality> rows;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSection.fieldRows(
      title: UserAnalyticsCopy.dataQualityTitle(context.l10n),
      children: [
        for (final row in rows)
          CatchField.content(
            icon: switch (row.state) {
              UserAnalyticsDataQualityState.ok =>
                CatchIcons.checkCircleOutlineRounded,
              UserAnalyticsDataQualityState.partial =>
                CatchIcons.warningAmberRounded,
              UserAnalyticsDataQualityState.missing =>
                CatchIcons.errorOutlineRounded,
            },
            iconColor: switch (row.state) {
              UserAnalyticsDataQualityState.ok => t.success,
              UserAnalyticsDataQualityState.partial => t.warning,
              UserAnalyticsDataQualityState.missing => t.danger,
            },
            title: UserAnalyticsCopy.dataQualityLabel(
              context.l10n,
              row.id,
              state: row.state,
            ),
            body: row.detail,
          ),
      ],
    );
  }
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

CatchMetricCardData _userMetricCardData(
  UserAnalyticsMetricCard metric,
  AppLocalizations l10n,
) {
  return CatchMetricCardData(
    icon: _metricIcon(metric.id),
    value: _formatMetricValue(metric),
    label: UserAnalyticsCopy.metricLabel(
      l10n,
      metric.id,
      fallback: metric.label,
    ),
    caption: UserAnalyticsCopy.metricCaption(
      l10n,
      metric.id,
      fallback: metric.caption,
    ),
    status: switch (metric.status) {
      UserAnalyticsMetricStatus.ready => CatchMetricStatus.ready,
      UserAnalyticsMetricStatus.partial => CatchMetricStatus.partial,
      UserAnalyticsMetricStatus.missing => CatchMetricStatus.missing,
    },
    partialBadgeLabel: _userAnalyticsPartialBadgeLabel(l10n),
    missingBadgeLabel: _userAnalyticsMissingBadgeLabel(l10n),
  );
}

String _userAnalyticsPartialBadgeLabel(AppLocalizations l10n) =>
    UserAnalyticsCopy.partialBadge(l10n);

String _userAnalyticsMissingBadgeLabel(AppLocalizations l10n) =>
    UserAnalyticsCopy.missingBadge(l10n);

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
