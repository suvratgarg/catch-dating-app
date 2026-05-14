import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_section.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/runs/presentation/widgets/who_is_running.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

class RunDetailSocialSection extends StatelessWidget {
  const RunDetailSocialSection({
    super.key,
    required this.run,
    required this.runClubId,
    required this.reviews,
    required this.userProfile,
    required this.isAuthenticated,
    required this.participation,
    this.now,
  });

  final Run run;
  final String runClubId;
  final List<Review> reviews;
  final UserProfile? userProfile;
  final bool isAuthenticated;
  final RunParticipation? participation;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final profile = userProfile;
    final canShowMemberContext = isAuthenticated && profile != null;
    final reviewAccessStarted = !run.endTime.isAfter(now ?? DateTime.now());
    final hasReviewAccess =
        participation?.status == RunParticipationStatus.attended &&
        reviewAccessStarted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canShowMemberContext)
          WhoIsRunning(run: run, userProfile: profile)
        else
          const _GuestWhoIsRunning(),
        if (canShowMemberContext) ...[
          gapH24,
          Divider(color: t.line, height: 1),
          gapH24,
          RunReviewsSection(
            runClubId: runClubId,
            runId: run.id,
            reviews: reviews,
            currentUid: profile.uid,
            userProfile: profile,
            hasAttended: hasReviewAccess,
          ),
        ],
      ],
    );
  }
}

class _GuestWhoIsRunning extends StatelessWidget {
  const _GuestWhoIsRunning();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline_rounded, size: 16, color: t.ink3),
              gapW8,
              Text("Who's running", style: CatchTextStyles.titleL(context)),
            ],
          ),
          gapH8,
          Text(
            'Sign in to see who has booked this run.',
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
        ],
      ),
    );
  }
}
