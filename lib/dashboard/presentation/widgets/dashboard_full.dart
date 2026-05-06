import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/catches_callout.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_sliver_header.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/next_run_hero.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/quick_actions.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/recommendations.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/run_arrival_action_card.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/stride_card.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DashboardFull extends ConsumerWidget {
  const DashboardFull({
    super.key,
    required this.user,
    required this.signedUpRuns,
  });

  static const scrollViewKey = ValueKey('dashboard-full-scroll-view');

  final UserProfile user;
  final List<Run> signedUpRuns;

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
    final firstName = user.name.split(' ').first;
    final viewModel = ref.watch(
      dashboardFullViewModelProvider(
        signedUpRuns: signedUpRuns,
        uid: user.uid,
        followedClubIds: user.joinedRunClubIds,
      ),
    );

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: CustomScrollView(
          key: scrollViewKey,
          slivers: [
            ...DashboardSliverHeader(
              eyebrow: dayCity(user.city?.label).toUpperCase(),
              title: '${greeting()}, $firstName',
              avatar: PersonAvatar(
                size: 42,
                name: user.name,
                imageUrl: user.photoUrls.firstOrNull,
                borderWidth: 2,
                borderColor: t.primary,
              ),
            ).buildSlivers(context),
            DashboardFullSliverBody(viewModel: viewModel),
          ],
        ),
      ),
    );
  }
}

class DashboardFullSliverBody extends StatelessWidget {
  const DashboardFullSliverBody({super.key, required this.viewModel});

  final DashboardFullViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.s1,
        CatchSpacing.s5,
        CatchSpacing.s6,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          if (viewModel.arrivalAction != null) ...[
            RunArrivalActionCard(action: viewModel.arrivalAction!),
            gapH18,
          ],
          if (viewModel.nextRun != null) ...[
            NextRunHero(nextRun: viewModel.nextRun!),
            gapH18,
          ],
          ..._buildAttendedRunSection(
            attendedRunsSection: viewModel.attendedRunsSection,
            activeSwipeRun: viewModel.activeSwipeRun,
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
    required Run? activeSwipeRun,
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
    return [
      if (activeSwipeRun != null) ...[
        CatchesCallout(activeRun: activeSwipeRun),
        gapH14,
      ],
      StrideCard(attendedRuns: attendedRuns),
    ];
  }

  List<Widget> _buildRecommendedRunsSection({
    required DashboardSectionModel<List<Run>> recommendationsSection,
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

    final runs = recommendationsSection.data ?? const <Run>[];
    return runs.isEmpty ? const [] : [gapH18, Recommendations(runs: runs)];
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
