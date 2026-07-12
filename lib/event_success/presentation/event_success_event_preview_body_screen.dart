import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/event_success/domain/event_success_event_preview.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_feature_blocks.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_hero_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

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
    final referenceNow = now ?? DateTime.now();
    final preview = EventSuccessEventPreview.fromEvent(
      event: event,
      club: club,
      roster: roster,
      viewer: userProfile,
      now: referenceNow,
    );
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: CatchTopBar(
        title: context
            .l10n
            .eventSuccessEventSuccessEventPreviewBodyScreenTitleEventSuccessPreview,
        border: true,
      ),
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
                        EventPreviewHero(preview: preview),
                        gapH16,
                        IntegrationNotesCard(notes: preview.integrationNotes),
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

class EventPreviewHero extends StatelessWidget {
  const EventPreviewHero({super.key, required this.preview});

  final EventSuccessEventPreview preview;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final event = preview.event;
    final clubName =
        preview.club?.name ??
        context
            .l10n
            .eventSuccessEventSuccessEventPreviewBodyScreenVisiblecopyThisClub;

    return EventSuccessHeroSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchBadge(
                label: context
                    .l10n
                    .eventSuccessEventSuccessEventPreviewBodyScreenLabelPreviewOnly,
                tone: CatchBadgeTone.solid,
                icon: CatchIcons.visibilityOutlined,
              ),
              CatchBadge(
                label: context
                    .l10n
                    .eventSuccessEventSuccessEventPreviewBodyScreenLabelDevStaging,
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
            context.l10n
                .eventSuccessEventSuccessEventPreviewBodyScreenTextClubnameTitle(
                  clubName: clubName,
                  title: preview.playbook.title,
                ),
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
                label: context.l10n
                    .eventSuccessEventSuccessEventPreviewBodyScreenLabelCapacitylimitTarget(
                      capacityLimit: event.capacityLimit,
                    ),
                foregroundColor: t.accentInk,
              ),
              EventSuccessDarkPill(
                label: context.l10n
                    .eventSuccessEventSuccessEventPreviewBodyScreenLabelBookedcountBooked(
                      bookedCount: preview.livePlan.bookedCount,
                    ),
                foregroundColor: t.accentInk,
              ),
              EventSuccessDarkPill(
                label: context.l10n
                    .eventSuccessEventSuccessEventPreviewBodyScreenLabelCheckedincountCheckedIn(
                      checkedInCount: preview.livePlan.checkedInCount,
                    ),
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

class IntegrationNotesCard extends StatelessWidget {
  const IntegrationNotesCard({super.key, required this.notes});

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
                  context
                      .l10n
                      .eventSuccessEventSuccessEventPreviewBodyScreenTextHowThisMapsTo,
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
