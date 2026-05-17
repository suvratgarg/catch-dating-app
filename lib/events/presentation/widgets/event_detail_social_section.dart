import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/widgets/who_is_going.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_section.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

class EventDetailSocialSection extends StatelessWidget {
  const EventDetailSocialSection({
    super.key,
    required this.event,
    required this.clubId,
    required this.reviews,
    required this.userProfile,
    required this.isAuthenticated,
    required this.participation,
    this.now,
  });

  final Event event;
  final String clubId;
  final List<Review> reviews;
  final UserProfile? userProfile;
  final bool isAuthenticated;
  final EventParticipation? participation;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final profile = userProfile;
    final canShowMemberContext = isAuthenticated && profile != null;
    final reviewAccessStarted = !event.endTime.isAfter(now ?? DateTime.now());
    final hasReviewAccess =
        participation?.status == EventParticipationStatus.attended &&
        reviewAccessStarted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canShowMemberContext)
          WhoIsGoing(event: event, userProfile: profile)
        else
          const _GuestWhoIsGoing(),
        if (canShowMemberContext) ...[
          gapH24,
          Divider(color: t.line, height: 1),
          gapH24,
          EventReviewsSection(
            clubId: clubId,
            eventId: event.id,
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

class _GuestWhoIsGoing extends StatelessWidget {
  const _GuestWhoIsGoing();

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
              Text("Who's going", style: CatchTextStyles.titleL(context)),
            ],
          ),
          gapH8,
          Text(
            'Sign in to see who has booked this event.',
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
        ],
      ),
    );
  }
}
