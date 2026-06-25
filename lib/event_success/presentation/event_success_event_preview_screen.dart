import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
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
      return const EventSuccessEventPreviewLoadingScreen();
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

class EventSuccessEventPreviewLoadingScreen extends StatelessWidget {
  const EventSuccessEventPreviewLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: const CatchTopBar(title: 'Event success preview', border: true),
      body: const SafeArea(child: EventSuccessEventPreviewLoadingBody()),
    );
  }
}

class EventSuccessEventPreviewLoadingBody extends StatelessWidget {
  const EventSuccessEventPreviewLoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: CatchLayout.maxContentWidth,
              ),
              child: const Padding(
                padding: CatchInsets.pageBodyRelaxed,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _EventPreviewHeroSkeleton(),
                    gapH16,
                    _EventPreviewNotesSkeleton(),
                    gapH16,
                    _EventPreviewSetupSkeleton(),
                    gapH16,
                    _EventPreviewLiveSkeleton(),
                    gapH16,
                    _EventPreviewCompanionSkeleton(),
                    gapH16,
                    _EventPreviewReportSkeleton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EventPreviewHeroSkeleton extends StatelessWidget {
  const _EventPreviewHeroSkeleton();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [t.accent, t.ink],
      ),
      borderColor: t.surface.withValues(alpha: CatchOpacity.none),
      padding: CatchInsets.contentRelaxed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchSkeleton.box(
                width: 104,
                height: CatchLayout.badgeActionHeight,
                radius: CatchRadius.pill,
              ),
              CatchSkeleton.box(
                width: 92,
                height: CatchLayout.badgeActionHeight,
                radius: CatchRadius.pill,
              ),
            ],
          ),
          gapH20,
          CatchSkeleton.text(width: 230),
          gapH10,
          CatchSkeleton.text(width: 190),
          gapH20,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (var i = 0; i < 4; i++)
                CatchSkeleton.box(
                  width: i == 0 ? 92 : 78,
                  height: CatchLayout.badgeActionHeight,
                  radius: CatchRadius.pill,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventPreviewNotesSkeleton extends StatelessWidget {
  const _EventPreviewNotesSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _EventPreviewSectionSkeleton(
      titleWidth: 210,
      textLines: 3,
      actionCount: 0,
    );
  }
}

class _EventPreviewSetupSkeleton extends StatelessWidget {
  const _EventPreviewSetupSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _EventPreviewSectionSkeleton(
      titleWidth: 150,
      textLines: 3,
      actionCount: 3,
    );
  }
}

class _EventPreviewLiveSkeleton extends StatelessWidget {
  const _EventPreviewLiveSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _EventPreviewSectionSkeleton(
      titleWidth: 132,
      textLines: 2,
      actionCount: 2,
    );
  }
}

class _EventPreviewCompanionSkeleton extends StatelessWidget {
  const _EventPreviewCompanionSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _EventPreviewSectionSkeleton(
      titleWidth: 170,
      textLines: 3,
      actionCount: 1,
    );
  }
}

class _EventPreviewReportSkeleton extends StatelessWidget {
  const _EventPreviewReportSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _EventPreviewSectionSkeleton(
      titleWidth: 188,
      textLines: 2,
      actionCount: 3,
    );
  }
}

class _EventPreviewSectionSkeleton extends StatelessWidget {
  const _EventPreviewSectionSkeleton({
    required this.titleWidth,
    required this.textLines,
    required this.actionCount,
  });

  final double titleWidth;
  final int textLines;
  final int actionCount;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: titleWidth),
          gapH12,
          CatchSkeleton.textBlock(lines: textLines),
          if (actionCount > 0) ...[
            gapH16,
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                for (var i = 0; i < actionCount; i++)
                  CatchSkeleton.box(
                    width: i == 0 ? 112 : 86,
                    height: CatchLayout.badgeActionHeight,
                    radius: CatchRadius.pill,
                  ),
              ],
            ),
          ],
        ],
      ),
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
      appBar: const CatchTopBar(title: 'Event success preview', border: true),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: CatchLayout.maxContentWidth,
                  ),
                  child: Padding(
                    padding: CatchInsets.pageBodyRelaxed,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _EventPreviewHero(preview: preview),
                        gapH16,
                        _IntegrationNotesCard(notes: preview.integrationNotes),
                        gapH16,
                        EventSuccessHostSetupFlow(
                          initialDraft: preview.hostDraft,
                        ),
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
                ),
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
      borderColor: t.surface.withValues(alpha: CatchOpacity.none),
      padding: CatchInsets.contentRelaxed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchBadge(
                label: 'Preview only',
                tone: CatchBadgeTone.solid,
                icon: CatchIcons.visibilityOutlined,
              ),
              CatchBadge(
                label: 'Dev/staging',
                tone: CatchBadgeTone.live,
                icon: CatchIcons.scienceOutlined,
              ),
            ],
          ),
          gapH20,
          Text(
            event.title,
            style: CatchTextStyles.headline(context, color: t.accentInk),
          ),
          gapH8,
          Text(
            '$clubName · ${preview.playbook.title}',
            style: CatchTextStyles.bodyL(
              context,
              color: t.accentInk.withValues(
                alpha: CatchOpacity.eventSuccessPreviewMeta,
              ),
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
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CatchIcons.accountTreeOutlined, color: t.primary),
              gapW10,
              Expanded(
                child: Text(
                  'How this maps to the live app',
                  style: CatchTextStyles.sectionTitle(context),
                ),
              ),
            ],
          ),
          gapH10,
          for (final note in notes) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CatchIcons.checkRounded,
                  size: CatchIcon.md,
                  color: t.success,
                ),
                gapW8,
                Expanded(
                  child: Text(
                    note,
                    style: CatchTextStyles.supporting(context, color: t.ink2),
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
