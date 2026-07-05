import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/event_detail_display_state.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_design_primitives.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_hero_app_bar.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_loading_skeleton.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_overview_section.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_social_section.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_surface_style.dart';
import 'package:catch_dating_app/events/shared/event_detail_route_transition.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

typedef EventDetailMessageHostCallback =
    void Function(String clubId, String hostUid);

class EventDetailBody extends StatelessWidget {
  const EventDetailBody({
    super.key,
    required this.event,
    required this.userProfile,
    required this.clubId,
    required this.reviews,
    required this.isAuthenticated,
    required this.sectionVisibility,
    required this.isSaved,
    required this.participation,
    required this.savePending,
    required this.onBack,
    required this.onShare,
    this.showShareAction = true,
    required this.showAddToCalendar,
    required this.onAddToCalendar,
    required this.onToggleSaved,
    required this.companionState,
    required this.hostState,
    required this.socialState,
    required this.onLocationTap,
    required this.onOpenCompanion,
    required this.onRetryCompanion,
    required this.onViewClub,
    required this.onMessageHost,
    required this.onRetryHosts,
    this.surfaceStyle,
    this.inviteCode,
    this.inviteLinkId,
    this.now,
    this.presentationMode = EventDetailPresentationMode.standard,
    this.heroTag,
  });

  final Event event;
  final UserProfile? userProfile;
  final String clubId;
  final List<Review> reviews;
  final bool isAuthenticated;
  final EventDetailSectionVisibilityState sectionVisibility;
  final bool isSaved;
  final EventParticipation? participation;
  final EventDetailSurfaceStyle? surfaceStyle;
  final bool savePending;
  final VoidCallback onBack;
  final ValueChanged<BuildContext> onShare;
  final bool showShareAction;
  final bool showAddToCalendar;
  final ValueChanged<BuildContext> onAddToCalendar;
  final VoidCallback onToggleSaved;
  final EventDetailCompanionState companionState;
  final EventDetailHostState hostState;
  final EventDetailSocialState socialState;
  final VoidCallback? onLocationTap;
  final VoidCallback onOpenCompanion;
  final VoidCallback onRetryCompanion;
  final ValueChanged<String> onViewClub;
  final EventDetailMessageHostCallback onMessageHost;
  final VoidCallback onRetryHosts;
  final String? inviteCode;
  final String? inviteLinkId;
  final DateTime? now;
  final EventDetailPresentationMode presentationMode;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final event = this.event;
    final userProfile = this.userProfile;
    final isSpotlightDark =
        presentationMode == EventDetailPresentationMode.spotlightDark;
    final style =
        surfaceStyle ??
        (isSpotlightDark
            ? EventDetailSurfaceStyle.dark(t)
            : EventDetailSurfaceStyle.light(
                t,
                useWhite:
                    presentationMode == EventDetailPresentationMode.ticket,
              ));

    return CustomScrollView(
      slivers: [
        EventDetailHeroAppBar(
          event: event,
          isSaved: isSaved,
          savePending: savePending,
          onBack: onBack,
          onShare: onShare,
          showShareAction: showShareAction,
          showAddToCalendar: showAddToCalendar,
          onAddToCalendar: onAddToCalendar,
          presentationMode: presentationMode,
          heroTag: heroTag,
          onToggleSaved: onToggleSaved,
        ),
        SliverToBoxAdapter(
          child: EventDetailTicketStubBand(
            event: event,
            notchBackgroundColor: style.pageBackground,
          ),
        ),
        CatchDetailSliverSectionList(
          topPadding: CatchSpacing.screenPt,
          bottomPadding: CatchSpacing.screenPb,
          sections: [
            EventDetailOverviewSection(
              event: event,
              surfaceStyle: style,
              onLocationTap: onLocationTap,
            ),
            EventCompanionEntry(
              state: companionState,
              surfaceStyle: style,
              onOpen: onOpenCompanion,
              onRetry: onRetryCompanion,
            ),
            if (sectionVisibility.showInviteLoop)
              EventDetailCalloutCard(
                leadingIcon: CatchIcons.platformShare(
                  platform: Theme.of(context).platform,
                ),
                title: 'Bring someone into the room',
                body:
                    'Your spot is booked. Invite a friend who would make this event better.',
                actionLabel: 'Invite a friend',
                actionIcon: CatchIcons.sendRounded,
                onAction: onShare,
                surfaceStyle: style,
                borderColor: style.isDark
                    ? style.borderColor
                    : CatchTokens.of(context).primary.withValues(
                        alpha: CatchOpacity.eventDetailLightBorder,
                      ),
              ),
            CatchDivider.section(color: style.dividerColor),
            EventDetailHostsSection(
              event: event,
              state: hostState,
              onViewClub: onViewClub,
              onMessageHost: onMessageHost,
              onRetry: onRetryHosts,
              surfaceStyle: style,
            ),
            EventDetailSocialSection(
              event: event,
              clubId: clubId,
              reviews: reviews,
              userProfile: userProfile,
              state: socialState,
              surfaceStyle: style,
            ),
          ],
        ),
      ],
    );
  }
}

class EventDetailCalloutCard extends StatelessWidget {
  const EventDetailCalloutCard({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
    required this.surfaceStyle,
    this.borderColor,
  });

  final IconData leadingIcon;
  final String title;
  final String body;
  final String actionLabel;
  final IconData actionIcon;
  final ValueChanged<BuildContext> onAction;
  final EventDetailSurfaceStyle surfaceStyle;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      backgroundColor: surfaceStyle.surfaceBackground,
      borderColor: borderColor ?? surfaceStyle.borderColor,
      padding: CatchInsets.tileContentCompact,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(leadingIcon, color: t.primary),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CatchTextStyles.sectionTitle(
                    context,
                    color: surfaceStyle.headingColor,
                  ),
                ),
                gapH4,
                Text(
                  body,
                  style: CatchTextStyles.supporting(
                    context,
                    color: surfaceStyle.bodyColor,
                  ),
                ),
                gapH12,
                Builder(
                  builder: (buttonContext) => CatchButton(
                    label: actionLabel,
                    variant: CatchButtonVariant.secondary,
                    icon: Icon(actionIcon),
                    onPressed: () => onAction(buttonContext),
                    fullWidth: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventCompanionEntry extends StatelessWidget {
  const EventCompanionEntry({
    super.key,
    required this.state,
    required this.surfaceStyle,
    required this.onOpen,
    required this.onRetry,
  });

  final EventDetailCompanionState state;
  final EventDetailSurfaceStyle surfaceStyle;
  final VoidCallback onOpen;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      EventDetailCompanionStatus.hidden => const SizedBox.shrink(),
      EventDetailCompanionStatus.loading => EventDetailCompanionSkeleton(
        surfaceStyle: surfaceStyle,
      ),
      EventDetailCompanionStatus.error => CatchInlineErrorState.fromError(
        state.error!,
        onRetry: onRetry,
        compact: true,
      ),
      EventDetailCompanionStatus.available => EventDetailCalloutCard(
        leadingIcon: CatchIcons.autoAwesomeOutlined,
        title: 'Event companion',
        body:
            'Check in, see your social prompt, and handle private follow-up after the event.',
        actionLabel: 'Open companion',
        actionIcon: CatchIcons.phoneIphoneRounded,
        onAction: (_) => onOpen(),
        surfaceStyle: surfaceStyle,
      ),
    };
  }
}

class GuestBookCta extends StatelessWidget {
  const GuestBookCta({
    super.key,
    required this.onPressed,
    this.darkSurface = false,
  });

  final VoidCallback onPressed;
  final bool darkSurface;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SafeArea(
      child: ColoredBox(
        color: darkSurface ? t.ink : t.surface,
        child: Padding(
          padding: CatchInsets.contentBlock,
          child: CatchButton(
            label: 'Sign in to book this event',
            onPressed: onPressed,
            icon: Icon(
              CatchIcons.lockOutlineRounded,
              size: CatchIcon.md,
              color: t.primary,
            ),
            fullWidth: true,
          ),
        ),
      ),
    );
  }
}

/// "Your hosts" section renders the design-system [EventDetailHostCard] from
/// explicit route-provided host state.
class EventDetailHostsSection extends StatelessWidget {
  const EventDetailHostsSection({
    super.key,
    required this.event,
    required this.state,
    required this.onViewClub,
    required this.onMessageHost,
    required this.onRetry,
    this.surfaceStyle,
  });

  final Event event;
  final EventDetailHostState state;
  final ValueChanged<String> onViewClub;
  final EventDetailMessageHostCallback onMessageHost;
  final VoidCallback onRetry;
  final EventDetailSurfaceStyle? surfaceStyle;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case EventDetailHostStatus.hidden:
        return const SizedBox.shrink();
      case EventDetailHostStatus.loading:
        return EventDetailHostsSkeleton(surfaceStyle: surfaceStyle);
      case EventDetailHostStatus.error:
        return CatchInlineErrorState.fromError(
          state.error!,
          onRetry: onRetry,
          compact: true,
        );
      case EventDetailHostStatus.content:
        final style = surfaceStyle;
        final clubId = state.clubId!;
        final hostUid = state.hostUid;
        final canMessage = state.canMessage && hostUid != null;

        return CatchSection.divided(
          title: 'Your hosts',
          dividerColor: style?.dividerColor,
          titleColor: style?.headingColor,
          child: EventDetailHostCard(
            activityKind: event.activityKind,
            hostName: state.hostName!,
            photoUrl: state.photoUrl,
            meta: state.meta,
            verified: state.verified,
            stats: state.stats,
            surfaceColor: style?.surfaceBackground,
            borderColor: style?.borderColor,
            nameColor: style?.headingColor,
            metaColor: style?.bodyColor,
            statValueColor: style?.headingColor,
            statLabelColor: style?.mutedColor,
            dividerColor: style?.dividerColor,
            onViewClub: () => onViewClub(clubId),
            onMessage: canMessage ? () => onMessageHost(clubId, hostUid) : null,
          ),
        );
    }
  }
}
