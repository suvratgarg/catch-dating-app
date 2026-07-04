import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_loading_widgets.dart';
import 'package:catch_dating_app/health_activity/domain/weekly_activity_summary.dart';
import 'package:flutter/material.dart';

class DashboardStrideSectionActions {
  const DashboardStrideSectionActions({
    required this.onRetry,
    required this.onConnect,
    required this.onInstallHealthConnect,
  });

  final VoidCallback onRetry;
  final VoidCallback onConnect;
  final VoidCallback onInstallHealthConnect;
}

class DashboardStrideActionState {
  const DashboardStrideActionState({
    this.isConnecting = false,
    this.isInstallingHealthConnect = false,
  });

  static const idle = DashboardStrideActionState();

  final bool isConnecting;
  final bool isInstallingHealthConnect;
}

class DashboardStrideSection extends StatelessWidget {
  const DashboardStrideSection({
    super.key,
    required this.section,
    required this.actions,
    this.actionState = DashboardStrideActionState.idle,
  });

  final DashboardSectionModel<WeeklyActivitySnapshot> section;
  final DashboardStrideSectionActions actions;
  final DashboardStrideActionState actionState;

  @override
  Widget build(BuildContext context) {
    if (section.isLoading) {
      return const DashboardStrideLoadingCard();
    }
    final error = section.error;
    if (error != null) {
      return CatchInlineErrorState.fromError(
        error,
        context: AppErrorContext.dashboard,
        compact: true,
        onRetry: actions.onRetry,
      );
    }

    final snapshot = section.data!;
    return StrideCard(
      snapshot: snapshot,
      isConnecting: actionState.isConnecting,
      isInstallingHealthConnect: actionState.isInstallingHealthConnect,
      onConnect: snapshot.canRequestPermission ? actions.onConnect : null,
      onInstallHealthConnect: snapshot.canInstallHealthConnect
          ? actions.onInstallHealthConnect
          : null,
    );
  }
}

class StrideCard extends StatelessWidget {
  const StrideCard({
    super.key,
    required this.snapshot,
    this.onConnect,
    this.onInstallHealthConnect,
    this.isConnecting = false,
    this.isInstallingHealthConnect = false,
  });

  final WeeklyActivitySnapshot snapshot;
  final VoidCallback? onConnect;
  final VoidCallback? onInstallHealthConnect;
  final bool isConnecting;
  final bool isInstallingHealthConnect;

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    final now = DateTime.now();
    final isToday = now.weekday - 1; // 0 = Mon
    final summary = snapshot.summary;
    final totalKm = summary.totalDistanceKm;
    final maxMinutes = summary.maxDailyActiveMinutes;

    return CatchSurface(
      padding: CatchInsets.tileContent,
      borderColor: t.line,
      backgroundColor: t.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your activity · this week',
            style: CatchTextStyles.sectionTitle(context),
          ),
          gapH8,
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                totalKm.toStringAsFixed(1),
                style: CatchTextStyles.statDisplay(context),
              ),
              gapW6,
              Flexible(
                child: Text(
                  _metricLabel(summary),
                  style: CatchTextStyles.supporting(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          gapH4,
          Text(
            _sourceText(snapshot),
            style: CatchTextStyles.supporting(context, color: t.ink3),
          ),
          gapH10,
          SizedBox(
            height: CatchLayout.strideChartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 7; i++) ...[
                  if (i > 0) gapW6,
                  Expanded(
                    child: StrideBarColumn(
                      fraction: maxMinutes > 0
                          ? summary.activeMinutesByWeekday[i] / maxMinutes
                          : 0,
                      dayLabel: _days[i],
                      isToday: i == isToday,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onConnect != null || onInstallHealthConnect != null) ...[
            gapH12,
            Semantics(
              label: 'Activity tracking actions',
              child: Wrap(
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                children: [
                  if (onConnect != null)
                    _buildStrideActionButton(
                      icon: CatchIcons.favoriteOutlineRounded,
                      label: isConnecting
                          ? 'Connecting...'
                          : 'Connect ${snapshot.platformLabel}',
                      onPressed: isConnecting ? null : onConnect,
                      isBusy: isConnecting,
                    ),
                  if (onInstallHealthConnect != null)
                    _buildStrideActionButton(
                      icon: CatchIcons.downloadRounded,
                      label: isInstallingHealthConnect
                          ? 'Opening...'
                          : 'Install Health Connect',
                      onPressed: isInstallingHealthConnect
                          ? null
                          : onInstallHealthConnect,
                      isBusy: isInstallingHealthConnect,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _metricLabel(WeeklyActivitySummary summary) {
    final activityNoun = summary.activityCount == 1 ? 'activity' : 'activities';
    final minutes = summary.totalActiveMinutes;
    if (summary.totalDistanceMeters <= 0) {
      return '$minutes min · ${summary.activityCount} $activityNoun';
    }
    return 'km · $minutes min · ${summary.activityCount} $activityNoun';
  }

  String _sourceText(WeeklyActivitySnapshot snapshot) {
    return switch (snapshot.source) {
      WeeklyActivitySource.healthPlatform => 'From ${snapshot.platformLabel}',
      WeeklyActivitySource.mixed =>
        '${snapshot.platformLabel} + Catch check-ins',
      WeeklyActivitySource.catchFallback => 'Catch check-ins only',
      WeeklyActivitySource.none =>
        snapshot.message ?? 'No activity this week yet.',
    };
  }

  Widget _buildStrideActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isBusy,
  }) {
    return CatchButton(
      label: label,
      onPressed: onPressed,
      icon: isBusy
          ? CatchSkeleton.box(width: CatchIcon.xs, height: CatchIcon.xs)
          : Icon(icon, size: CatchIcon.xs),
      variant: CatchButtonVariant.ghost,
      size: CatchButtonSize.sm,
    );
  }
}

class StrideBarColumn extends StatelessWidget {
  const StrideBarColumn({
    super.key,
    required this.fraction,
    required this.dayLabel,
    required this.isToday,
  });

  final double fraction;
  final String dayLabel;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: fraction > 0 ? fraction : 0.04,
              child: Container(
                decoration: BoxDecoration(
                  color: fraction > 0
                      ? t.primary.withValues(
                          // Today reads fullest; other days sit back at ~55%.
                          alpha: isToday
                              ? CatchOpacity.visible
                              : CatchOpacity.strideInactiveBar,
                        )
                      : t.line2,
                  borderRadius: BorderRadius.circular(CatchRadius.xs),
                ),
              ),
            ),
          ),
        ),
        gapH4,
        Text(
          dayLabel,
          style: CatchTextStyles.statusLabel(context, color: t.ink3),
        ),
      ],
    );
  }
}
