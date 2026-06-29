import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_surface_style.dart';
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
    required this.isHost,
    required this.participation,
    this.now,
    this.surfaceStyle,
  });

  final Event event;
  final String clubId;
  final List<Review> reviews;
  final UserProfile? userProfile;
  final bool isAuthenticated;
  final bool isHost;
  final EventParticipation? participation;
  final DateTime? now;
  final EventDetailSurfaceStyle? surfaceStyle;

  @override
  Widget build(BuildContext context) {
    final profile = userProfile;
    final canShowMemberContext = isAuthenticated && profile != null;
    final reviewAccessStarted = !event.endTime.isAfter(now ?? DateTime.now());
    final hasReviewAccess =
        participation?.status == EventParticipationStatus.attended &&
        reviewAccessStarted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchSection.divided(
          title: "Who's going",
          count: event.signedUpCount,
          dividerColor: surfaceStyle?.dividerColor,
          titleColor: surfaceStyle?.headingColor,
          child: canShowMemberContext
              ? WhoIsGoing(
                  event: event,
                  userProfile: profile,
                  surfaceStyle: surfaceStyle,
                  showHeader: false,
                )
              : _GuestWhoIsGoing(
                  surfaceStyle: surfaceStyle,
                  showHeader: false,
                ),
        ),
        if (canShowMemberContext) ...[
          CatchSection.divided(
            title: 'Reviews',
            dividerColor: surfaceStyle?.dividerColor,
            titleColor: surfaceStyle?.headingColor,
            child: EventReviewsSection(
              clubId: clubId,
              eventId: event.id,
              reviews: reviews,
              currentUid: profile.uid,
              userProfile: profile,
              isHost: isHost,
              hasAttended: hasReviewAccess,
            ),
          ),
        ],
      ],
    );
  }
}

class _GuestWhoIsGoing extends StatelessWidget {
  const _GuestWhoIsGoing({
    this.surfaceStyle,
    this.showHeader = true,
  });

  final EventDetailSurfaceStyle? surfaceStyle;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      backgroundColor: surfaceStyle?.surfaceBackground,
      borderColor: surfaceStyle?.borderColor ?? t.line,
      padding: CatchInsets.tileContentCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            Row(
              children: [
                Icon(
                  CatchIcons.lockOutlineRounded,
                  size: CatchIcon.xs,
                  color: surfaceStyle?.mutedColor ?? t.ink3,
                ),
                const SizedBox(width: CatchSpacing.s2),
                Text(
                  "Who's going",
                  style: CatchTextStyles.titleL(
                    context,
                    color: surfaceStyle?.headingColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: CatchLayout.detailScreenSupportingGap),
          ],
          Text(
            'Sign in to see who has booked this event.',
            style: CatchTextStyles.supporting(
              context,
              color: surfaceStyle?.bodyColor ?? t.ink2,
            ),
          ),
        ],
      ),
    );
  }
}
