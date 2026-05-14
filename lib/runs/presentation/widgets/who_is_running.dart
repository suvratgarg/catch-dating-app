import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/runs/data/run_participation_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_participation_roster.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_hype_avatar_stack.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'who_is_running.g.dart';

@riverpod
Future<Map<String, (String name, String? photoUrl)>> runnerProfiles(
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

class WhoIsRunning extends ConsumerWidget {
  const WhoIsRunning({super.key, required this.run, required this.userProfile});

  final Run run;
  final UserProfile userProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rosterAsync = ref.watch(watchRunParticipationRosterProvider(run.id));

    return rosterAsync.when(
      loading: () => _WhoIsRunningContent(
        run: run,
        roster: RunParticipationRoster.empty(),
        userProfile: userProfile,
        fallbackTotal: run.signedUpCount,
      ),
      error: (e, _) => CatchInlineErrorState.fromError(
        e,
        context: AppErrorContext.run,
        compact: true,
        onRetry: () =>
            ref.invalidate(watchRunParticipationRosterProvider(run.id)),
      ),
      data: (roster) => _WhoIsRunningContent(
        run: run,
        roster: roster,
        userProfile: userProfile,
      ),
    );
  }
}

class _WhoIsRunningContent extends ConsumerWidget {
  const _WhoIsRunningContent({
    required this.run,
    required this.roster,
    required this.userProfile,
    this.fallbackTotal,
  });

  final Run run;
  final RunParticipationRoster roster;
  final UserProfile userProfile;
  final int? fallbackTotal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final total = fallbackTotal ?? roster.bookedCount;
    final hasActiveSwipeWindow = hasOpenSwipeWindow(run);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Who's running",
                style: CatchTextStyles.titleL(context),
              ),
            ),
            Text(
              '$total/${run.capacityLimit}',
              style: CatchTextStyles.labelL(context, color: t.ink2),
            ),
          ],
        ),
        gapH12,
        if (total == 0)
          _EmptyRosterMessage(
            title: run.isUpcoming ? 'No runners yet' : 'No runners booked',
            message: run.isUpcoming
                ? 'Be the first to book this run.'
                : 'This run did not have any booked runners.',
          )
        else ...[
          RunHypeAvatarStack(
            runId: run.id,
            totalCount: total,
            viewerInterestedInGenders: userProfile.interestedInGenders,
            size: 44,
            limit: 7,
            obscured: true,
            showOverflowCount: true,
          ),
          gapH12,
          if (run.isUpcoming)
            _SwipeWindowBanner(
              icon: Icons.lock_outline_rounded,
              message: 'Swiping unlocks for 24 hours after the run finishes.',
            )
          else if (hasActiveSwipeWindow)
            _SwipeWindowBanner(
              icon: Icons.favorite_rounded,
              message:
                  'The swipe window is open for 24 hours after the run finishes.',
            )
          else
            _SwipeWindowBanner(
              icon: Icons.schedule_rounded,
              message: 'The swipe window for this run has closed.',
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
      tone: CatchSurfaceTone.raised,
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
