import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/health_activity/data/health_activity_repository.dart';
import 'package:catch_dating_app/health_activity/domain/weekly_activity_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardStrideSection extends ConsumerStatefulWidget {
  const DashboardStrideSection({super.key, required this.section});

  final DashboardSectionModel<WeeklyRunningActivitySnapshot> section;

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
    final granted = await ref
        .read(healthActivityRepositoryProvider)
        .requestRunningReadPermission();
    ref.invalidate(weeklyRunningActivityProvider);
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
    await ref.read(healthActivityRepositoryProvider).installHealthConnect();
    ref.invalidate(weeklyRunningActivityProvider);
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

  final WeeklyRunningActivitySnapshot snapshot;
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
    final maxMeters = summary.maxDailyDistanceMeters;

    return CatchSurface(
      padding: const EdgeInsets.all(Sizes.p18),
      borderColor: t.line,
      backgroundColor: t.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your stride · this week',
            style: CatchTextStyles.titleL(context),
          ),
          gapH8,
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                totalKm.toStringAsFixed(1),
                style: CatchTextStyles.displayXL(
                  context,
                ).copyWith(fontSize: 36, letterSpacing: -1),
              ),
              gapW6,
              Text(
                'km · ${summary.runCount} run${summary.runCount == 1 ? '' : 's'}',
                style: CatchTextStyles.bodyS(context),
              ),
            ],
          ),
          gapH4,
          Text(
            _sourceText(snapshot),
            style: CatchTextStyles.bodyS(context).copyWith(color: t.ink3),
          ),
          gapH10,
          SizedBox(
            height: 58,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 7; i++) ...[
                  if (i > 0) gapW6,
                  Expanded(
                    child: StrideBarColumn(
                      fraction: maxMeters > 0
                          ? summary.distanceMetersByWeekday[i] / maxMeters
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
              spacing: Sizes.p8,
              runSpacing: Sizes.p8,
              children: [
                if (onConnect != null)
                  _StrideActionButton(
                    icon: Icons.favorite_outline_rounded,
                    label: isConnecting
                        ? 'Connecting...'
                        : 'Connect ${snapshot.platformLabel}',
                    onPressed: isConnecting ? null : onConnect,
                    isBusy: isConnecting,
                  ),
                if (onInstallHealthConnect != null)
                  _StrideActionButton(
                    icon: Icons.download_rounded,
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

  String _sourceText(WeeklyRunningActivitySnapshot snapshot) {
    return switch (snapshot.source) {
      WeeklyRunningActivitySource.healthPlatform =>
        'From ${snapshot.platformLabel}',
      WeeklyRunningActivitySource.mixed =>
        '${snapshot.platformLabel} + Catch check-ins',
      WeeklyRunningActivitySource.catchFallback => 'Catch check-ins only',
      WeeklyRunningActivitySource.none =>
        snapshot.message ?? 'No running activity this week yet.',
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
                      ? t.primary.withValues(alpha: isToday ? 0.5 : 1)
                      : t.line2,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        gapH4,
        Text(
          dayLabel,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: t.ink3,
          ),
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
    return TextButton.icon(
      onPressed: onPressed,
      icon: isBusy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CatchLoadingIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: 16),
      label: Text(label),
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
      padding: const EdgeInsets.all(CatchSpacing.s4),
      borderColor: t.line,
      child: Row(
        children: [
          if (isLoading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CatchLoadingIndicator(strokeWidth: 2),
            )
          else
            Icon(Icons.error_outline_rounded, color: t.primary, size: 18),
          gapW10,
          Expanded(
            child: Text(
              message,
              style: CatchTextStyles.bodyS(context).copyWith(color: t.ink2),
            ),
          ),
        ],
      ),
    );
  }
}
