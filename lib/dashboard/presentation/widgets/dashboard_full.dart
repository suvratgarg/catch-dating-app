import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_sliver_header.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/quick_actions.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/recommendations.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/run_focus_rail.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/stride_card.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/presentation/run_club_name_lookup.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DashboardFull extends ConsumerWidget {
  const DashboardFull({
    super.key,
    required this.user,
    required this.signedUpRuns,
    required this.followedClubIds,
  });

  static const scrollViewKey = ValueKey('dashboard-full-scroll-view');

  final UserProfile user;
  final List<Run> signedUpRuns;
  final List<String> followedClubIds;

  static String greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }

  static String dayCity(String? cityLabel) {
    final day = DateFormat('EEEE').format(DateTime.now());
    return '$day · ${cityLabel ?? 'Mumbai'}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final firstName = user.greetingDisplayName;
    final viewModel = ref.watch(
      dashboardFullViewModelProvider(
        signedUpRuns: signedUpRuns,
        user: user,
        uid: user.uid,
        followedClubIds: followedClubIds,
      ),
    );

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: CustomScrollView(
          key: scrollViewKey,
          slivers: [
            ...DashboardSliverHeader(
              eyebrow: dayCity(cityLabel(user.city)).toUpperCase(),
              title: '${greeting()}, $firstName',
            ).buildSlivers(context),
            DashboardFullSliverBody(viewModel: viewModel, user: user),
          ],
        ),
      ),
    );
  }
}

class DashboardFullSliverBody extends ConsumerWidget {
  const DashboardFullSliverBody({
    super.key,
    required this.viewModel,
    required this.user,
  });

  final DashboardFullViewModel viewModel;
  final UserProfile user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusRuns = [
      ...viewModel.upcomingRuns,
      if (viewModel.activeSwipeRun != null) viewModel.activeSwipeRun!,
      if (viewModel.pendingReviewRun != null) viewModel.pendingReviewRun!,
    ];
    final clubNamesAsync = ref.watch(
      runClubNameLookupProvider(
        RunClubNameLookupQuery(focusRuns.map((run) => run.runClubId)),
      ),
    );
    final clubNames = clubNamesAsync.asData?.value;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.s1,
        CatchSpacing.s5,
        CatchSpacing.s6,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          if (focusRuns.isNotEmpty) ...[
            RunFocusRail(
              upcomingRuns: viewModel.upcomingRuns,
              arrivalAction: viewModel.arrivalAction,
              activeSwipeRun: viewModel.activeSwipeRun,
              pendingReviewRun: viewModel.pendingReviewRun,
              reviewer: user,
              clubNameBuilder: (run) => clubNames?[run.runClubId],
            ),
            gapH18,
          ],
          if (viewModel.hostRunTools.isNotEmpty) ...[
            HostToolsRail(tools: viewModel.hostRunTools),
            gapH18,
          ],
          ..._buildAttendedRunSection(
            attendedRunsSection: viewModel.attendedRunsSection,
          ),
          gapH18,
          const QuickActions(),
          ..._buildRecommendedRunsSection(
            recommendationsSection: viewModel.recommendationsSection,
          ),
        ]),
      ),
    );
  }

  List<Widget> _buildAttendedRunSection({
    required DashboardSectionModel<List<Run>> attendedRunsSection,
  }) {
    if (attendedRunsSection.isLoading) {
      return const [
        _DashboardSectionStateCard(
          message: 'Loading your recent runs...',
          isLoading: true,
        ),
      ];
    }

    if (attendedRunsSection.hasError) {
      return const [
        _DashboardSectionStateCard(message: 'Unable to load your recent runs.'),
      ];
    }

    final attendedRuns = attendedRunsSection.data ?? const <Run>[];
    return [StrideCard(attendedRuns: attendedRuns)];
  }

  List<Widget> _buildRecommendedRunsSection({
    required DashboardSectionModel<List<DashboardRunRecommendation>>
    recommendationsSection,
  }) {
    if (recommendationsSection.isLoading) {
      return const [
        gapH18,
        _DashboardSectionStateCard(
          message: 'Loading recommended runs...',
          isLoading: true,
        ),
      ];
    }

    if (recommendationsSection.hasError) {
      return const [
        gapH18,
        _DashboardSectionStateCard(message: 'Unable to load recommended runs.'),
      ];
    }

    final recommendations =
        recommendationsSection.data ?? const <DashboardRunRecommendation>[];
    return recommendations.isEmpty
        ? const []
        : [gapH18, Recommendations(recommendations: recommendations)];
  }
}

class HostToolsRail extends StatelessWidget {
  const HostToolsRail({super.key, required this.tools});

  final List<DashboardHostRunTool> tools;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Host tools', style: CatchTextStyles.titleL(context)),
            gapW8,
            CatchBadge(
              label: tools.length == 1 ? '1 run' : '${tools.length} runs',
              tone: CatchBadgeTone.brand,
            ),
          ],
        ),
        gapH10,
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth * 0.86)
                .clamp(280.0, 360.0)
                .toDouble();

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < tools.length; index += 1) ...[
                    if (index > 0) gapW12,
                    _HostToolCard(tool: tools[index], width: cardWidth),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _HostToolCard extends StatelessWidget {
  const _HostToolCard({required this.tool, required this.width});

  final DashboardHostRunTool tool;
  final double width;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final run = tool.run;
    final attendanceOpen = tool.canTakeAttendance;

    return SizedBox(
      width: width,
      child: CatchSurface(
        padding: const EdgeInsets.all(CatchSpacing.s4),
        backgroundColor: attendanceOpen ? t.primarySoft : t.surface,
        borderColor: attendanceOpen
            ? t.primary.withValues(alpha: 0.28)
            : t.line,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'HOST TOOLS',
                  style: CatchTextStyles.labelS(
                    context,
                    color: t.primary,
                  ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.0),
                ),
                const Spacer(),
                CatchBadge(
                  label: _attendanceBadgeLabel(tool.attendanceState),
                  tone: attendanceOpen
                      ? CatchBadgeTone.live
                      : CatchBadgeTone.neutral,
                  uppercase: true,
                ),
              ],
            ),
            gapH6,
            Text(
              run.title,
              style: CatchTextStyles.titleM(context),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            gapH10,
            Text(
              '${run.shortDateLabel} · ${run.timeRangeLabel}',
              style: CatchTextStyles.bodyS(context, color: t.ink2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            gapH8,
            Row(
              children: [
                Icon(Icons.group_outlined, size: 16, color: t.ink3),
                gapW6,
                Text(
                  '${run.signedUpCount}/${run.capacityLimit}',
                  style: CatchTextStyles.labelM(context, color: t.ink2),
                ),
                gapW12,
                Icon(Icons.schedule_rounded, size: 16, color: t.ink3),
                gapW6,
                Text(
                  '${run.waitlistCount}',
                  style: CatchTextStyles.labelM(context, color: t.ink2),
                ),
              ],
            ),
            gapH12,
            Row(
              children: [
                Expanded(
                  child: CatchButton(
                    label: 'Manage',
                    icon: const Icon(Icons.tune_rounded, size: 16),
                    variant: CatchButtonVariant.secondary,
                    size: CatchButtonSize.sm,
                    fullWidth: true,
                    onPressed: () => context.pushNamed(
                      Routes.hostRunManageScreen.name,
                      pathParameters: {
                        'runClubId': run.runClubId,
                        'runId': run.id,
                      },
                    ),
                  ),
                ),
                gapW8,
                Expanded(
                  child: CatchButton(
                    label: _attendanceButtonLabel(tool.attendanceState),
                    icon: const Icon(Icons.checklist_rounded, size: 16),
                    variant: attendanceOpen
                        ? CatchButtonVariant.primary
                        : CatchButtonVariant.secondary,
                    size: CatchButtonSize.sm,
                    fullWidth: true,
                    onPressed: attendanceOpen
                        ? () => context.pushNamed(
                            Routes.attendanceSheet.name,
                            pathParameters: {
                              'runClubId': run.runClubId,
                              'runId': run.id,
                            },
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _attendanceBadgeLabel(DashboardHostAttendanceState state) {
    return switch (state) {
      DashboardHostAttendanceState.open => 'Attendance open',
      DashboardHostAttendanceState.opensLater => 'Upcoming',
      DashboardHostAttendanceState.closed => 'Closed',
    };
  }

  String _attendanceButtonLabel(DashboardHostAttendanceState state) {
    return switch (state) {
      DashboardHostAttendanceState.open => 'Attendance',
      DashboardHostAttendanceState.opensLater => 'Opens later',
      DashboardHostAttendanceState.closed => 'Closed',
    };
  }
}

class _DashboardSectionStateCard extends StatelessWidget {
  const _DashboardSectionStateCard({
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
          if (isLoading) ...[
            const SizedBox(
              width: 18,
              height: 18,
              child: CatchLoadingIndicator(strokeWidth: 2),
            ),
          ] else ...[
            Icon(Icons.error_outline_rounded, color: t.primary, size: 18),
          ],
          gapW10,
          Expanded(
            child: Text(
              message,
              style: CatchTextStyles.bodyS(context, color: t.ink2),
            ),
          ),
        ],
      ),
    );
  }
}
