import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_hype_avatar_stack.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'who_is_going.g.dart';

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
  const WhoIsGoing({super.key, required this.event, required this.userProfile});

  final Event event;
  final UserProfile userProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rosterAsync = ref.watch(
      watchEventParticipationRosterProvider(event.id),
    );

    return rosterAsync.when(
      loading: () => _WhoIsGoingContent(
        event: event,
        roster: EventParticipationRoster.empty(),
        userProfile: userProfile,
        fallbackTotal: event.signedUpCount,
      ),
      error: (e, _) => CatchInlineErrorState.fromError(
        e,
        context: AppErrorContext.event,
        compact: true,
        onRetry: () =>
            ref.invalidate(watchEventParticipationRosterProvider(event.id)),
      ),
      data: (roster) => _WhoIsGoingContent(
        event: event,
        roster: roster,
        userProfile: userProfile,
      ),
    );
  }
}

class _WhoIsGoingContent extends ConsumerWidget {
  const _WhoIsGoingContent({
    required this.event,
    required this.roster,
    required this.userProfile,
    this.fallbackTotal,
  });

  final Event event;
  final EventParticipationRoster roster;
  final UserProfile userProfile;
  final int? fallbackTotal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final total = fallbackTotal ?? roster.bookedCount;
    final hasActiveSwipeWindow = hasOpenSwipeWindow(event);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Who's going",
                style: CatchTextStyles.titleL(context),
              ),
            ),
            Text(
              '$total/${event.capacityLimit}',
              style: CatchTextStyles.labelL(context, color: t.ink2),
            ),
          ],
        ),
        gapH12,
        if (total == 0)
          _EmptyRosterMessage(
            title: event.isUpcoming
                ? 'No attendees yet'
                : 'No attendees booked',
            message: event.isUpcoming
                ? 'Be the first to book this event.'
                : 'This event did not have any booked attendees.',
          )
        else ...[
          EventHypeAvatarStack(
            eventId: event.id,
            totalCount: total,
            viewerInterestedInGenders: userProfile.interestedInGenders,
            size: 44,
            limit: 7,
            obscured: true,
            showOverflowCount: true,
          ),
          gapH12,
          if (event.isUpcoming)
            _SwipeWindowBanner(
              icon: Icons.lock_outline_rounded,
              message: 'Swiping unlocks for 24 hours after the event finishes.',
            )
          else if (hasActiveSwipeWindow)
            _SwipeWindowBanner(
              icon: Icons.favorite_rounded,
              message:
                  'The swipe window is open for 24 hours after the event finishes.',
            )
          else
            _SwipeWindowBanner(
              icon: Icons.schedule_rounded,
              message: 'The swipe window for this event has closed.',
            ),
        ],
      ],
    );
  }
}

class _EmptyRosterMessage extends StatelessWidget {
  const _EmptyRosterMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: const EdgeInsets.all(CatchSpacing.s4),
      radius: CatchRadius.md,
      borderColor: t.line,
      child: Row(
        children: [
          Icon(Icons.groups_2_outlined, size: 20, color: t.ink3),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: CatchTextStyles.titleS(context)),
                gapH4,
                Text(
                  message,
                  style: CatchTextStyles.bodyS(context, color: t.ink2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeWindowBanner extends StatelessWidget {
  const _SwipeWindowBanner({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: const EdgeInsets.all(12),
      tone: CatchSurfaceTone.primarySoft,
      radius: CatchRadius.md,
      borderWidth: 0,
      child: Row(
        children: [
          Icon(icon, size: 16, color: t.primary),
          gapW8,
          Expanded(
            child: Text(
              message,
              style: CatchTextStyles.bodyS(context, color: t.primary),
            ),
          ),
        ],
      ),
    );
  }
}
