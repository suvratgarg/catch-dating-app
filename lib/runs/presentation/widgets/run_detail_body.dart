import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:catch_dating_app/core/widgets/vibe_tag.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_section.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_booking_controller.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:catch_dating_app/runs/presentation/widgets/requirements_row.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_detail_cta.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_photo_header.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_stats_grid.dart';
import 'package:catch_dating_app/runs/presentation/widgets/when_where_card.dart';
import 'package:catch_dating_app/runs/presentation/widgets/who_is_running.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunDetailBody extends ConsumerWidget {
  const RunDetailBody({
    super.key,
    required this.run,
    required this.userProfile,
    required this.runClubId,
    required this.reviews,
  });

  final Run run;
  final UserProfile userProfile;
  final String runClubId;
  final List<Review> reviews;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final run = this.run;
    final userProfile = this.userProfile;

    ref.listen(RunBookingController.bookMutation, (prev, next) {
      if (prev?.isPending == true && next.isSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booking confirmed!')));
      }
    });
    ref.listen(RunBookingController.cancelMutation, (prev, next) {
      if (prev?.isPending == true && next.isSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booking cancelled.')));
      }
    });

    return Scaffold(
      backgroundColor: t.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: t.surface,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: IconBtn(
                background: t.surface,
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: t.ink,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: IconBtn(
                  background: t.surface,
                  // TODO: implement share. Use share_plus to share a deep-link
                  // like https://catch.app/runs/${run.id}
                  onTap: () {},
                  child: Icon(Icons.ios_share_rounded, size: 18, color: t.ink),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                child: IconBtn(
                  background: t.surface,
                  // TODO: implement bookmark/save. Decide whether this persists
                  // to Firestore (savedRunIds on UserProfile) or local prefs, then
                  // wire a toggle mutation and swap the icon to filled when saved.
                  onTap: () {},
                  child: Icon(
                    Icons.bookmark_border_rounded,
                    size: 18,
                    color: t.ink,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: RunPhotoHeader(run: run),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.screenH,
              20,
              CatchSpacing.screenH,
              32,
            ),
            sliver: SliverList.list(
              children: [
                Text(run.title, style: CatchTextStyles.displayLg(context)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    VibeTag(label: run.pace.label, active: true),
                    const SizedBox(width: 6),
                    Text(
                      run.shortDateLabel,
                      style: CatchTextStyles.bodySm(context, color: t.ink2),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                RunStatsGrid(run: run),
                const SizedBox(height: 20),
                WhenWhereCard(run: run),
                if (run.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    run.description,
                    style: CatchTextStyles.bodyMd(context, color: t.ink2),
                  ),
                ],
                if (run.hasRequirements) ...[
                  const SizedBox(height: 20),
                  RequirementsRow(run: run),
                ],
                const SizedBox(height: 24),
                Divider(color: t.line, height: 1),
                const SizedBox(height: 24),
                WhoIsRunning(run: run, userProfile: userProfile),
                const SizedBox(height: 24),
                Divider(color: t.line, height: 1),
                const SizedBox(height: 24),
                ReviewsSection(
                  runClubId: runClubId,
                  runId: run.id,
                  reviews: reviews,
                  currentUid: userProfile.uid,
                  userProfile: userProfile,
                  hasAttended: run.hasAttended(userProfile.uid),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: RunDetailCta(run: run, userProfile: userProfile),
    );
  }
}
