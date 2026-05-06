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
  });

  final Run run;
  final String runClubId;
  final List<Review> reviews;
  final UserProfile? userProfile;
  final bool isAuthenticated;
  final RunParticipation? participation;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final profile = userProfile;
    final canShowMemberContext = isAuthenticated && profile != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canShowMemberContext)
          WhoIsRunning(run: run, userProfile: profile)
        else
          const _GuestWhoIsRunning(),
        const SizedBox(height: 24),
        Divider(color: t.line, height: 1),
        const SizedBox(height: 24),
        if (canShowMemberContext)
          ReviewsSection(
            runClubId: runClubId,
            runId: run.id,
            reviews: reviews,
            currentUid: profile.uid,
            userProfile: profile,
            hasAttended:
                participation?.status == RunParticipationStatus.attended,
          ),
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
              const SizedBox(width: 8),
              Text("Who's running", style: CatchTextStyles.titleL(context)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to see who has booked this run.',
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
        ],
      ),
    );
  }
}
