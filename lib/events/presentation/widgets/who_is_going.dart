import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_surface_style.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_hype_avatar_stack.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'who_is_going.g.dart';

const _whoIsGoingAvatarLimit = 7;

@riverpod
Future<Map<String, (String name, String? photoUrl)>> attendeeProfiles(
  Ref ref,
  List<String> uids,
) async {
  if (uids.isEmpty) return {};
  final profiles = await ref
      .watch(publicProfileRepositoryProvider)
      .fetchPublicProfiles(uids);
  return {
    for (final profile in profiles)
      profile.uid: (profile.name, profile.primaryPhotoThumbnailUrl),
  };
}

class WhoIsGoing extends ConsumerWidget {
  const WhoIsGoing({
    super.key,
    required this.event,
    required this.userProfile,
    this.surfaceStyle,
    this.showHeader = true,
  });

  final Event event;
  final UserProfile userProfile;
  final EventDetailSurfaceStyle? surfaceStyle;
  final bool showHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rosterAsync = ref.watch(
      watchEventParticipationRosterProvider(event.id),
    );

    return CatchAsyncValueView<EventParticipationRoster>(
      value: rosterAsync,
      loadingBuilder: (_) => WhoIsGoingContent(
        event: event,
        roster: EventParticipationRoster.empty(),
        userProfile: userProfile,
        fallbackTotal: event.signedUpCount,
        surfaceStyle: surfaceStyle,
        showHeader: showHeader,
      ),
      errorBuilder: (_, e, _) => CatchInlineErrorState.fromError(
        e,
        context: AppErrorContext.event,
        compact: true,
        onRetry: () =>
            ref.invalidate(watchEventParticipationRosterProvider(event.id)),
      ),
      builder: (context, roster) {
        final avatarItems =
            event.isUpcomingAt(DateTime.now()) || roster.bookedCount <= 0
            ? null
            : ref
                  .watch(
                    eventHypeAvatarsProvider(
                      EventHypeAvatarQuery(
                        eventId: event.id,
                        viewerInterestedInGenders:
                            userProfile.interestedInGenders,
                        limit: _whoIsGoingAvatarLimit,
                      ),
                    ),
                  )
                  .asData
                  ?.value;
        return WhoIsGoingContent(
          event: event,
          roster: roster,
          userProfile: userProfile,
          avatarItems: avatarItems,
          surfaceStyle: surfaceStyle,
          showHeader: showHeader,
        );
      },
    );
  }
}

class WhoIsGoingContent extends StatelessWidget {
  const WhoIsGoingContent({
    super.key,
    required this.event,
    required this.roster,
    required this.userProfile,
    this.avatarItems,
    this.fallbackTotal,
    this.surfaceStyle,
    this.showHeader = true,
  });

  final Event event;
  final EventParticipationRoster roster;
  final UserProfile userProfile;
  final List<CatchPersonAvatarItem>? avatarItems;
  final int? fallbackTotal;
  final EventDetailSurfaceStyle? surfaceStyle;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final total = fallbackTotal ?? roster.bookedCount;
    final referenceNow = DateTime.now();
    final isUpcoming = event.isUpcomingAt(referenceNow);
    final hasActiveSwipeWindow = hasOpenSwipeWindow(event, now: referenceNow);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.eventsWhoIsGoingTextWhoSGoing,
                  style: CatchTextStyles.titleL(
                    context,
                    color: surfaceStyle?.headingColor,
                  ),
                ),
              ),
              Text(
                context.l10n.eventsWhoIsGoingTextTotalCapacitylimit(
                  total: total,
                  capacityLimit: event.capacityLimit,
                ),
                style: CatchTextStyles.labelL(
                  context,
                  color: surfaceStyle?.bodyColor ?? t.ink2,
                ),
              ),
            ],
          ),
          gapH12,
        ],
        if (total == 0)
          EmptyRosterMessage(
            title: isUpcoming
                ? context.l10n.eventsWhoIsGoingTitleNoAttendeesYet
                : context.l10n.eventsWhoIsGoingTitleNoAttendeesBooked,
            message: isUpcoming
                ? context.l10n.eventsWhoIsGoingMessageBeTheFirstTo
                : context.l10n.eventsWhoIsGoingMessageThisEventDidNot,
            surfaceStyle: surfaceStyle,
          )
        else ...[
          EventHypeAvatarStack(
            eventId: event.id,
            totalCount: total,
            viewerInterestedInGenders: userProfile.interestedInGenders,
            avatarItems: avatarItems,
            activityKind: event.activityKind,
            size: 44,
            limit: _whoIsGoingAvatarLimit,
            obscured: isUpcoming,
            showOverflowCount: true,
          ),
          gapH12,
          if (isUpcoming)
            SwipeWindowBanner(
              icon: CatchIcons.lockOutlineRounded,
              message: context.l10n.eventsWhoIsGoingMessageCatchesUnlockFor24,
              surfaceStyle: surfaceStyle,
            )
          else if (hasActiveSwipeWindow)
            SwipeWindowBanner(
              icon: CatchIcons.favoriteRounded,
              message: context.l10n.eventsWhoIsGoingMessageTheCatchWindowIs,
              surfaceStyle: surfaceStyle,
            )
          else
            SwipeWindowBanner(
              icon: CatchIcons.scheduleRounded,
              message: context.l10n.eventsWhoIsGoingMessageTheCatchWindowFor,
              surfaceStyle: surfaceStyle,
            ),
        ],
      ],
    );
  }
}

class EmptyRosterMessage extends StatelessWidget {
  const EmptyRosterMessage({
    super.key,
    required this.title,
    required this.message,
    this.surfaceStyle,
  });

  final String title;
  final String message;
  final EventDetailSurfaceStyle? surfaceStyle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: CatchInsets.content,
      radius: CatchRadius.md,
      backgroundColor: surfaceStyle?.surfaceBackground,
      borderColor: surfaceStyle?.borderColor ?? t.line,
      child: Row(
        children: [
          Icon(
            CatchIcons.groups2Outlined,
            size: 20,
            color: surfaceStyle?.mutedColor ?? t.ink3,
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CatchTextStyles.sectionTitle(
                    context,
                    color: surfaceStyle?.headingColor,
                  ),
                ),
                gapH4,
                Text(
                  message,
                  style: CatchTextStyles.supporting(
                    context,
                    color: surfaceStyle?.bodyColor ?? t.ink2,
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

class SwipeWindowBanner extends StatelessWidget {
  const SwipeWindowBanner({
    super.key,
    required this.icon,
    required this.message,
    this.surfaceStyle,
  });

  final IconData icon;
  final String message;
  final EventDetailSurfaceStyle? surfaceStyle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: CatchInsets.contentDense,
      tone: surfaceStyle == null
          ? CatchSurfaceTone.primarySoft
          : CatchSurfaceTone.transparent,
      backgroundColor: surfaceStyle?.primarySoftColor,
      radius: CatchRadius.md,
      borderWidth: 0,
      child: Row(
        children: [
          Icon(
            icon,
            size: CatchIcon.xs,
            color: surfaceStyle?.primaryColor ?? t.primary,
          ),
          gapW8,
          Expanded(
            child: Text(
              message,
              style: CatchTextStyles.supporting(
                context,
                color: surfaceStyle?.primaryColor ?? t.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
