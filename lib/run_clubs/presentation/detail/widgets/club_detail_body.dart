import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_section.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/detail/widgets/club_hero_app_bar.dart';
import 'package:catch_dating_app/run_clubs/presentation/detail/widgets/host_stats_bar.dart';
import 'package:catch_dating_app/run_clubs/presentation/detail/widgets/membership_button.dart';
import 'package:catch_dating_app/run_clubs/presentation/detail/widgets/stats_strip.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_schedule_grid.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ClubDetailBody extends StatelessWidget {
  const ClubDetailBody({
    super.key,
    required this.runClub,
    required this.runs,
    required this.upcoming,
    required this.reviews,
    required this.userProfile,
    required this.uid,
    required this.isHost,
    required this.isMember,
    required this.isMutating,
  });

  final RunClub runClub;
  final List<Run> runs;
  final List<Run> upcoming;
  final List<Review> reviews;
  final UserProfile? userProfile;
  final String? uid;
  final bool isHost;
  final bool isMember;
  final bool isMutating;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final showMembershipControls = !isHost && uid != null;

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
                _HostActionPanel(runClub: runClub, tokens: t),
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
                _ClubContactSection(runClub: runClub, tokens: t),
                const SizedBox(height: 20),
              ],
              if (isHost) ...[
                HostStatsBar(runs: upcoming),
                const SizedBox(height: 20),
              ],
              if (showMembershipControls)
                MembershipButton(
                  clubId: runClub.id,
                  isMember: isMember,
                  isMutating: isMutating,
                ),
              if (showMembershipControls) const SizedBox(height: 24),
              ReviewsSection(
                runClubId: runClub.id,
                reviews: reviews,
                currentUid: uid,
                userProfile: userProfile,
                isHost: isHost,
                isMember: isMember,
              ),
              const SizedBox(height: 24),
              Text('Schedule', style: CatchTextStyles.titleL(context)),
              const SizedBox(height: 12),
            ],
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: true,
          child: RunScheduleGrid(
            runs: runs,
            onRunSelected: (run) => context.pushNamed(
              Routes.runDetailScreen.name,
              pathParameters: {'runClubId': runClub.id, 'runId': run.id},
            ),
          ),
        ),
      ],
    );
  }
}

class _HostActionPanel extends StatelessWidget {
  const _HostActionPanel({required this.runClub, required this.tokens});

  final RunClub runClub;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOST TOOLS',
            style: CatchTextStyles.labelM(
              context,
              color: t.ink3,
            ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage this club and publish upcoming runs.',
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CatchButton(
                label: 'Edit club',
                onPressed: () => context.pushNamed(
                  Routes.editRunClubScreen.name,
                  pathParameters: {'runClubId': runClub.id},
                  extra: runClub,
                ),
                icon: const Icon(Icons.edit_outlined, size: 14),
                size: CatchButtonSize.sm,
                variant: CatchButtonVariant.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CatchButton(
                  label: 'Add run',
                  onPressed: () => context.pushNamed(
                    Routes.createRunScreen.name,
                    pathParameters: {'runClubId': runClub.id},
                    extra: runClub,
                  ),
                  icon: const Icon(Icons.add_rounded, size: 14),
                  size: CatchButtonSize.sm,
                  fullWidth: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClubContactSection extends StatelessWidget {
  const _ClubContactSection({required this.runClub, required this.tokens});

  final RunClub runClub;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONTACT',
            style: CatchTextStyles.labelM(
              context,
              color: t.ink3,
            ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          if (runClub.instagramHandle != null)
            _ContactRow(
              icon: Icons.alternate_email_rounded,
              label: runClub.instagramHandle!,
              onTap: () => _launchUrl(
                'https://instagram.com/${runClub.instagramHandle!.replaceFirst('@', '')}',
              ),
            ),
          if (runClub.phoneNumber != null)
            _ContactRow(
              icon: Icons.call_outlined,
              label: runClub.phoneNumber!,
              onTap: () => _launchUrl('tel:${runClub.phoneNumber}'),
            ),
          if (runClub.email != null)
            _ContactRow(
              icon: Icons.email_outlined,
              label: runClub.email!,
              onTap: () => _launchUrl('mailto:${runClub.email}'),
            ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
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

    return Padding(
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
    );
  }
}
