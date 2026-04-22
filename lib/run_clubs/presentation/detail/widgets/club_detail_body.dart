import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
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
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClubDetailBody extends StatelessWidget {
  const ClubDetailBody({
    super.key,
    required this.runClub,
    required this.runs,
    required this.upcoming,
    required this.reviews,
    required this.appUser,
    required this.uid,
    required this.isHost,
    required this.isMember,
    required this.isMutating,
  });

  final RunClub runClub;
  final List<Run> runs;
  final List<Run> upcoming;
  final List<Review> reviews;
  final AppUser? appUser;
  final String? uid;
  final bool isHost;
  final bool isMember;
  final bool isMutating;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final showMembershipControls = !isHost && uid != null;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            ClubHeroAppBar(club: runClub, isHost: isHost),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.screenH,
                20,
                CatchSpacing.screenH,
                0,
              ),
              sliver: SliverList.list(
                children: [
                  StatsStrip(club: runClub, upcomingCount: upcoming.length),
                  const SizedBox(height: 16),
                  Text(
                    runClub.description,
                    style: CatchTextStyles.bodyMd(context, color: t.ink2),
                  ),
                  const SizedBox(height: 20),
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
                    appUser: appUser,
                    isHost: isHost,
                    isMember: isMember,
                  ),
                  const SizedBox(height: 24),
                  Text('Schedule', style: CatchTextStyles.displaySm(context)),
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
        ),
        if (isHost)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            right: 8,
            child: Builder(
              builder: (ctx) => Padding(
                padding: const EdgeInsets.all(8),
                child: IconBtn(
                  background: t.primary,
                  onTap: () => ctx.pushNamed(
                    Routes.createRunScreen.name,
                    pathParameters: {'runClubId': runClub.id},
                    extra: runClub,
                  ),
                  child: Icon(Icons.add_rounded, size: 20, color: t.primaryInk),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
