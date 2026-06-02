import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_stride_actions.dart';
import 'package:catch_dating_app/health_activity/domain/weekly_activity_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardStrideSection extends ConsumerStatefulWidget {
  const DashboardStrideSection({super.key, required this.section});

  final DashboardSectionModel<WeeklyActivitySnapshot> section;

  @override
  ConsumerState<DashboardStrideSection> createState() =>
      _DashboardStrideSectionState();
}

class _DashboardStrideSectionState
    extends ConsumerState<DashboardStrideSection> {
  bool _isConnecting = false;
  bool _isInstallingHealthConnect = false;

  @override
  Widget build(BuildContext context) {
    final section = widget.section;
    if (section.isLoading) {
      return _StrideSectionStateCard(
        message: section.message ?? 'Loading your weekly running activity...',
        isLoading: true,
      );
    }
    if (section.hasError) {
      return _StrideSectionStateCard(
        message:
            section.message ?? 'Unable to load your weekly running activity.',
      );
    }

    return StrideCard(
      snapshot: section.data!,
      isConnecting: _isConnecting,
      isInstallingHealthConnect: _isInstallingHealthConnect,
      onConnect: section.data!.canRequestPermission ? _connect : null,
      onInstallHealthConnect: section.data!.canInstallHealthConnect
          ? _installHealthConnect
          : null,
    );
  }

  Future<void> _connect() async {
    if (_isConnecting) return;
    setState(() => _isConnecting = true);
    final actions = ref.read(dashboardStrideActionsProvider);
    final granted = await actions.requestActivityReadPermission();
    actions.refreshWeeklyActivity();
    if (!mounted) return;
    setState(() => _isConnecting = false);
    if (!granted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Health access was not granted.')),
      );
    }
  }

  Future<void> _installHealthConnect() async {
    if (_isInstallingHealthConnect) return;
    setState(() => _isInstallingHealthConnect = true);
    final actions = ref.read(dashboardStrideActionsProvider);
    await actions.installHealthConnect();
    actions.refreshWeeklyActivity();
    if (!mounted) return;
    setState(() => _isInstallingHealthConnect = false);
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
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                if (onConnect != null)
                  _StrideActionButton(
                    icon: CatchIcons.favoriteOutlineRounded,
                    label: isConnecting
                        ? 'Connecting...'
                        : 'Connect ${snapshot.platformLabel}',
                    onPressed: isConnecting ? null : onConnect,
                    isBusy: isConnecting,
                  ),
                if (onInstallHealthConnect != null)
                  _StrideActionButton(
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
                          alpha: isToday
                              ? CatchOpacity.strideTodayBar
                              : CatchOpacity.visible,
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

class _StrideActionButton extends StatelessWidget {
  const _StrideActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isBusy,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return CatchButton(
      label: label,
      onPressed: onPressed,
      icon: isBusy
          ? const SizedBox.square(
              dimension: CatchIcon.xs,
              child: CatchLoadingIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: CatchIcon.xs),
      variant: CatchButtonVariant.ghost,
      size: CatchButtonSize.sm,
    );
  }
}

class _StrideSectionStateCard extends StatelessWidget {
  const _StrideSectionStateCard({
    required this.message,
    this.isLoading = false,
  });

  final String message;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Row(
        children: [
          if (isLoading)
            const SizedBox.square(
              dimension: CatchIcon.md,
              child: CatchLoadingIndicator(strokeWidth: 2),
            )
          else
            Icon(
              CatchIcons.errorOutlineRounded,
              color: t.primary,
              size: CatchIcon.md,
            ),
          gapW10,
          Expanded(
            child: Text(
              message,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ),
        ],
      ),
    );
  }
}
