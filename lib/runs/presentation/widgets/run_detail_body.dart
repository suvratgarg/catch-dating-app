import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/vibe_tag.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_section.dart';
import 'package:catch_dating_app/routing/app_deep_links.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_booking_controller.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:catch_dating_app/runs/presentation/widgets/requirements_row.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_detail_cta.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_photo_header.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_stats_grid.dart';
import 'package:catch_dating_app/runs/presentation/widgets/when_where_card.dart';
import 'package:catch_dating_app/runs/presentation/widgets/who_is_running.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

typedef RunShareHandler = Future<void> Function(BuildContext context, Run run);

class RunDetailBody extends ConsumerWidget {
  const RunDetailBody({
    super.key,
    required this.run,
    required this.userProfile,
    required this.runClubId,
    required this.reviews,
    this.onShareRun,
  });

  final Run run;
  final UserProfile userProfile;
  final String runClubId;
  final List<Review> reviews;
  final RunShareHandler? onShareRun;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final run = this.run;
    final userProfile = this.userProfile;
    final isSaved = userProfile.savedRunIds.contains(run.id);

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
              child: CatchTopBarIconAction(
                icon: Icons.arrow_back_ios_new_rounded,
                tooltip: 'Back',
                background: t.surface,
                onPressed: () => Navigator.of(context).pop(),
                foregroundColor: t.ink,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Builder(
                  builder: (buttonContext) => CatchTopBarIconAction(
                    icon: Icons.ios_share_rounded,
                    tooltip: 'Share run',
                    background: t.surface,
                    onPressed: () => unawaited(
                      (onShareRun ?? _shareRun)(buttonContext, run),
                    ),
                    foregroundColor: t.ink,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                child: CatchTopBarIconAction(
                  icon: isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  tooltip: isSaved ? 'Unsave run' : 'Save run',
                  background: t.surface,
                  onPressed: () => unawaited(
                    _toggleSavedRun(context, ref, run, userProfile, isSaved),
                  ),
                  foregroundColor: t.ink,
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
              CatchSpacing.s5,
              20,
              CatchSpacing.s5,
              32,
            ),
            sliver: SliverList.list(
              children: [
                Text(run.title, style: CatchTextStyles.displayL(context)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    VibeTag(label: run.pace.label, active: true),
                    const SizedBox(width: 6),
                    Text(
                      run.shortDateLabel,
                      style: CatchTextStyles.bodyS(context, color: t.ink2),
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
                    style: CatchTextStyles.bodyM(context, color: t.ink2),
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

Future<void> _shareRun(BuildContext context, Run run) async {
  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  final uri = AppDeepLinks.run(runClubId: run.runClubId, runId: run.id);

  try {
    await SharePlus.instance.share(
      ShareParams(
        text:
            'Join me for ${run.title} at ${run.meetingPoint}: ${uri.toString()}',
        subject: run.title,
        sharePositionOrigin: origin,
      ),
    );
  } on Object {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open share sheet.')),
    );
  }
}

Future<void> _toggleSavedRun(
  BuildContext context,
  WidgetRef ref,
  Run run,
  UserProfile userProfile,
  bool isSaved,
) async {
  try {
    final repository = ref.read(userProfileRepositoryProvider);
    if (isSaved) {
      await repository.unsaveRun(uid: userProfile.uid, runId: run.id);
    } else {
      await repository.saveRun(uid: userProfile.uid, runId: run.id);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isSaved ? 'Run removed.' : 'Run saved.')),
    );
  } on Object {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not update saved runs.')),
    );
  }
}
