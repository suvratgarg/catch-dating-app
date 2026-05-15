import 'dart:async';

import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
import 'package:catch_dating_app/host_tools/presentation/host_club_tools.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_section.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/detail/widgets/club_hero_app_bar.dart';
import 'package:catch_dating_app/run_clubs/presentation/detail/widgets/club_schedule_section.dart';
import 'package:catch_dating_app/run_clubs/presentation/detail/widgets/membership_button.dart';
import 'package:catch_dating_app/run_clubs/presentation/detail/widgets/stats_strip.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ClubDetailBody extends StatelessWidget {
  const ClubDetailBody({
    super.key,
    required this.runClub,
    required this.upcoming,
    required this.reviews,
    required this.userProfile,
    required this.uid,
    required this.isHost,
    required this.isMember,
    required this.isMutating,
    required this.clubPushNotificationsEnabled,
    required this.isClubPushMutating,
    required this.isAuthenticated,
  });

  final RunClub runClub;
  final List<Run> upcoming;
  final List<Review> reviews;
  final UserProfile? userProfile;
  final String? uid;
  final bool isHost;
  final bool isMember;
  final bool isMutating;
  final bool clubPushNotificationsEnabled;
  final bool isClubPushMutating;
  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final showMembershipControls = isAuthenticated && !isHost;

    return CustomScrollView(
      slivers: [
        ClubHeroAppBar(club: runClub, isHost: isHost),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            20,
            CatchSpacing.s5,
            0,
          ),
          sliver: SliverList.list(
            children: [
              if (isHost) ...[
                HostClubToolsPanel(
                  runClub: runClub,
                  onEditClub: () => context.pushNamed(
                    Routes.editRunClubScreen.name,
                    pathParameters: {'runClubId': runClub.id},
                    extra: runClub,
                  ),
                  onCreateRun: () => context.pushNamed(
                    Routes.createRunScreen.name,
                    pathParameters: {'runClubId': runClub.id},
                    extra: runClub,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              StatsStrip(club: runClub, upcomingCount: upcoming.length),
              const SizedBox(height: 16),
              Text(
                runClub.description,
                style: CatchTextStyles.bodyM(context, color: t.ink2),
              ),
              const SizedBox(height: 20),
              if (runClub.instagramHandle != null ||
                  runClub.phoneNumber != null ||
                  runClub.email != null) ...[
                _ClubContactSection(runClub: runClub),
                const SizedBox(height: 20),
              ],
              if (isHost) ...[
                HostStatsStrip(runs: upcoming),
                const SizedBox(height: 20),
              ],
              if (showMembershipControls)
                MembershipButton(
                  clubId: runClub.id,
                  isMember: isMember,
                  isMutating: isMutating,
                  pushNotificationsEnabled: clubPushNotificationsEnabled,
                  isPushMutating: isClubPushMutating,
                ),
              if (showMembershipControls) const SizedBox(height: 24),
              if (!isAuthenticated) ...[
                _GuestPrompt(runClub: runClub),
                const SizedBox(height: 24),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
        ClubScheduleSection(
          runs: upcoming,
          isHost: isHost,
          onRunSelected: (run) => context.pushNamed(
            Routes.runDetailScreen.name,
            pathParameters: {'runClubId': runClub.id, 'runId': run.id},
          ),
        ),
        if (isAuthenticated)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s5,
              0,
              CatchSpacing.s5,
              CatchSpacing.s6,
            ),
            sliver: SliverToBoxAdapter(
              child: RunClubReviewsSection(
                reviews: reviews,
                currentUid: uid,
                maxVisibleReviews: 3,
              ),
            ),
          ),
      ],
    );
  }
}

class _ClubContactSection extends ConsumerWidget {
  const _ClubContactSection({required this.runClub});

  final RunClub runClub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final links = ref.watch(externalLinkControllerProvider);

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'CONTACT', heavy: true),
          const SizedBox(height: 12),
          if (runClub.instagramHandle != null)
            _ContactRow(
              icon: Icons.alternate_email_rounded,
              label: runClub.instagramHandle!,
              onTap: () => unawaited(
                links.openExternal(_instagramUri(runClub.instagramHandle!)),
              ),
            ),
          if (runClub.phoneNumber != null)
            _ContactRow(
              icon: Icons.call_outlined,
              label: runClub.phoneNumber!,
              onTap: () =>
                  unawaited(links.open(_phoneUri(runClub.phoneNumber!))),
            ),
          if (runClub.email != null)
            _ContactRow(
              icon: Icons.email_outlined,
              label: runClub.email!,
              onTap: () => unawaited(links.open(_emailUri(runClub.email!))),
            ),
        ],
      ),
    );
  }

  static Uri _instagramUri(String handle) =>
      Uri.parse('https://instagram.com/${handle.replaceFirst('@', '')}');

  static Uri _phoneUri(String phoneNumber) =>
      Uri(scheme: 'tel', path: phoneNumber);

  static Uri _emailUri(String email) => Uri(scheme: 'mailto', path: email);
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Semantics(
      button: true,
      label: label,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(icon, size: 18, color: t.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: CatchTextStyles.bodyM(context, color: t.ink),
                  ),
                ),
                Icon(Icons.open_in_new_rounded, size: 14, color: t.ink3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuestPrompt extends StatelessWidget {
  const _GuestPrompt({required this.runClub});

  final RunClub runClub;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(
            'Sign in to join this club, see member reviews, and connect with the community.',
            style: CatchTextStyles.bodyM(context, color: t.ink2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          CatchButton(
            label: 'Sign in to join',
            onPressed: () => context.pushNamed(
              Routes.onboardingScreen.name,
              queryParameters: {'from': '/clubs/run-clubs/${runClub.id}'},
            ),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
