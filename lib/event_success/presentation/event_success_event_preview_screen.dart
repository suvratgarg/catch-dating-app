import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/event_success/domain/event_success_event_preview.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_feature_blocks.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dev/staging-only route that previews the future event-success layer against
/// today's event data. This route is read-only and intentionally does not create
/// event-success documents, check-in codes, crushes, prompts, or reports.
class EventSuccessEventPreviewRouteScreen extends ConsumerWidget {
  const EventSuccessEventPreviewRouteScreen({
    super.key,
    required this.clubId,
    required this.eventId,
    this.initialEvent,
  });

  final String clubId;
  final String eventId;
  final Event? initialEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(watchEventProvider(eventId));
    final event = eventAsync.asData?.value ?? initialEvent;
    final clubAsync = ref.watch(fetchClubProvider(clubId));
    final rosterAsync = ref.watch(
      watchEventParticipationRosterProvider(eventId),
    );
    final userProfileAsync = ref.watch(watchUserProfileProvider);

    if (event == null && eventAsync.isLoading) {
      return Scaffold(
        backgroundColor: CatchTokens.of(context).bg,
        body: const SafeArea(child: Center(child: CatchLoadingIndicator())),
      );
    }

    if (event == null) {
      final error = eventAsync.error;
      if (error != null) {
        return CatchErrorScaffold.fromError(
          error,
          context: AppErrorContext.event,
          onRetry: () => ref.invalidate(watchEventProvider(eventId)),
        );
      }

      return const CatchErrorScaffold(
        title: 'Event not found',
        message: 'This event is no longer available for preview.',
      );
    }

    return EventSuccessEventPreviewScreen(
      event: event,
      club: clubAsync.asData?.value,
      roster: rosterAsync.asData?.value,
      userProfile: userProfileAsync.asData?.value,
    );
  }
}

class EventSuccessEventPreviewScreen extends StatelessWidget {
  const EventSuccessEventPreviewScreen({
    super.key,
    required this.event,
    this.club,
    this.roster,
    this.userProfile,
    this.now,
  });

  final Event event;
  final Club? club;
  final EventParticipationRoster? roster;
  final UserProfile? userProfile;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final preview = EventSuccessEventPreview.fromEvent(
      event: event,
      club: club,
      roster: roster,
      viewer: userProfile,
      now: now,
    );
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(title: const Text('Event success preview')),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.s5,
                CatchSpacing.s4,
                CatchSpacing.s5,
                CatchSpacing.s8,
              ),
              sliver: SliverList.list(
                children: [
                  _EventPreviewHero(preview: preview),
                  gapH16,
                  _IntegrationNotesCard(notes: preview.integrationNotes),
                  gapH16,
                  EventSuccessHostSetupFlow(initialDraft: preview.hostDraft),
                  gapH16,
                  EventSuccessLiveHostMode(plan: preview.livePlan),
                  gapH16,
                  EventSuccessAttendeeCompanionPreview(
                    state: preview.attendeeState,
                  ),
                  gapH16,
                  EventSuccessPostEventReport(brief: preview.brief),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventPreviewHero extends StatelessWidget {
  const _EventPreviewHero({required this.preview});

  final EventSuccessEventPreview preview;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final event = preview.event;
    final clubName = preview.club?.name ?? 'This club';

    return CatchSurface(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [t.accent, t.ink],
      ),
      borderColor: Colors.transparent,
      padding: const EdgeInsets.all(CatchSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: const [
              CatchBadge(
                label: 'Preview only',
                tone: CatchBadgeTone.solid,
                icon: Icons.visibility_outlined,
              ),
              CatchBadge(
                label: 'Dev/staging',
                tone: CatchBadgeTone.live,
                icon: Icons.science_outlined,
              ),
            ],
          ),
          gapH20,
          Text(
            event.title,
            style: CatchTextStyles.displayL(context, color: t.accentInk),
          ),
          gapH8,
          Text(
            '$clubName · ${preview.playbook.title}',
            style: CatchTextStyles.bodyL(
              context,
              color: t.accentInk.withValues(alpha: 0.86),
            ),
          ),
          gapH20,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              EventSuccessDarkPill(
                label: '${event.capacityLimit} target',
                foregroundColor: t.accentInk,
              ),
              EventSuccessDarkPill(
                label: '${preview.livePlan.bookedCount} booked',
                foregroundColor: t.accentInk,
              ),
              EventSuccessDarkPill(
                label: '${preview.livePlan.checkedInCount} checked in',
                foregroundColor: t.accentInk,
              ),
              EventSuccessDarkPill(
                label: event.pace.label,
                foregroundColor: t.accentInk,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IntegrationNotesCard extends StatelessWidget {
  const _IntegrationNotesCard({required this.notes});

  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_tree_outlined, color: t.primary),
              gapW10,
              Expanded(
                child: Text(
                  'How this maps to the live app',
                  style: CatchTextStyles.titleM(context),
                ),
              ),
            ],
          ),
          gapH10,
          for (final note in notes) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_rounded, size: 18, color: t.success),
                gapW8,
                Expanded(
                  child: Text(
                    note,
                    style: CatchTextStyles.bodyS(context, color: t.ink2),
                  ),
                ),
              ],
            ),
            if (note != notes.last) gapH8,
          ],
        ],
      ),
    );
  }
}
