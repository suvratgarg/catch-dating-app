import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_detail_display_state.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_loading_skeleton.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_surface_style.dart';
import 'package:catch_dating_app/events/presentation/widgets/who_is_going.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/shared/reviews_section.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

class EventDetailSocialSection extends StatelessWidget {
  const EventDetailSocialSection({
    super.key,
    required this.event,
    required this.clubId,
    required this.reviews,
    required this.userProfile,
    required this.state,
    required this.now,
    this.surfaceStyle,
  });

  final Event event;
  final String clubId;
  final List<Review> reviews;
  final UserProfile? userProfile;
  final EventDetailSocialState state;
  final DateTime now;
  final EventDetailSurfaceStyle? surfaceStyle;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return EventDetailSocialSkeleton(surfaceStyle: surfaceStyle);
    }

    final profile = userProfile;
    final canShowMemberContext = state.showMemberContext && profile != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchSection.divided(
          title: context.l10n.eventsEventDetailSocialSectionTitleWhoSGoing,
          count: event.signedUpCount,
          dividerColor: surfaceStyle?.dividerColor,
          titleColor: surfaceStyle?.headingColor,
          child: canShowMemberContext
              ? WhoIsGoing(
                  event: event,
                  userProfile: profile,
                  surfaceStyle: surfaceStyle,
                  showHeader: false,
                  showCatchWindowStatus: false,
                  now: now,
                )
              : GuestWhoIsGoing(surfaceStyle: surfaceStyle, showHeader: false),
        ),
        if (canShowMemberContext && state.reviews.visible) ...[
          CatchSection.divided(
            title: context.l10n.eventsEventDetailSocialSectionTitleReviews,
            dividerColor: surfaceStyle?.dividerColor,
            titleColor: surfaceStyle?.headingColor,
            child: EventReviewsSection(
              clubId: clubId,
              eventId: event.id,
              reviews: reviews,
              currentUid: profile.uid,
              userProfile: profile,
              canWrite: state.reviews.canWrite,
              canRespond: state.reviews.canRespond,
            ),
          ),
        ],
      ],
    );
  }
}

class GuestWhoIsGoing extends StatelessWidget {
  const GuestWhoIsGoing({super.key, this.surfaceStyle, this.showHeader = true});

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
                  context.l10n.eventsEventDetailSocialSectionTextWhoSGoing,
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
            context.l10n.eventsEventDetailSocialSectionTextSignInToSee,
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
