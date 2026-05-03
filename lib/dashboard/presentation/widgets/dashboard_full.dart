import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_recommendations_provider.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/activity_section.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/catches_callout.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/next_run_hero.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/quick_actions.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/recommendations.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/stride_card.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
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
    final viewModel = buildDashboardFullViewModel(
      signedUpRuns: signedUpRuns,
      attendedRunsAsync: ref.watch(attendedRunsProvider(user.uid)),
      recommendedRunsAsync: ref.watch(
        dashboardRecommendedRunsProvider(
          DashboardRecommendationsQuery(
            userId: user.uid,
            followedClubIds: user.joinedRunClubIds,
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.s5,
                Sizes.p8,
                CatchSpacing.s5,
                Sizes.p10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayCity(user.city?.label).toUpperCase(),
                          style: CatchTextStyles.labelM(context, color: t.ink3)
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                        ),
                        gapH2,
                        Text(
                          '${greeting()}, $firstName',
                          style: CatchTextStyles.displayL(context),
                        ),
                      ],
                    ),
                  ),
                  PersonAvatar(
                    size: 42,
                    name: user.name,
                    imageUrl: user.photoUrls.firstOrNull,
                    borderWidth: 2,
                    borderColor: t.primary,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  CatchSpacing.s5,
                  Sizes.p4,
                  CatchSpacing.s5,
                  Sizes.p24,
                ),
                children: [
                  if (viewModel.nextRun != null) ...[
                    NextRunHero(tokens: t, nextRun: viewModel.nextRun!),
                    gapH18,
                  ],
                  ..._buildAttendedRunSection(
                    attendedRunsSection: viewModel.attendedRunsSection,
                    activeSwipeRun: viewModel.activeSwipeRun,
                    tokens: t,
                  ),
                  gapH18,
                  QuickActions(tokens: t),
                  ..._buildRecommendedRunsSection(
                    recommendationsSection: viewModel.recommendationsSection,
                    tokens: t,
                  ),
                  gapH18,
                  ActivitySection(uid: user.uid),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAttendedRunSection({
    required DashboardSectionModel<List<Run>> attendedRunsSection,
    required Run? activeSwipeRun,
    required CatchTokens tokens,
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
        CatchesCallout(tokens: tokens, activeRun: activeSwipeRun),
        gapH14,
      ],
      StrideCard(tokens: tokens, attendedRuns: attendedRuns),
    ];
  }

  List<Widget> _buildRecommendedRunsSection({
    required DashboardSectionModel<List<Run>> recommendationsSection,
    required CatchTokens tokens,
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
    return runs.isEmpty
        ? const []
        : [gapH18, Recommendations(tokens: tokens, runs: runs)];
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
      padding: const EdgeInsets.all(Sizes.p16),
      borderColor: t.line,
      child: Row(
        children: [
          if (isLoading) ...[
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
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
