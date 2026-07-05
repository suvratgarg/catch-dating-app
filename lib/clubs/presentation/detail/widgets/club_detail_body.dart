import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_screen_state.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_contact_section.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_hero_app_bar.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_host_section.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_photo_strip.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_schedule_section.dart';
import 'package:catch_dating_app/clubs/shared/club_identity_atoms.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_metric_strip.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/reviews/shared/reviews_section.dart';
import 'package:flutter/material.dart';

typedef ClubEventSelectionHandler = void Function(Event event);

const EdgeInsets _clubActivityTilePadding = EdgeInsets.symmetric(
  horizontal: CatchSpacing.s4,
  vertical: CatchSpacing.s3,
);

class ClubDetailBody extends StatelessWidget {
  const ClubDetailBody({
    super.key,
    required this.state,
    this.onShareClub,
    this.onEventSelected,
    this.onViewHostProfile,
    this.onMessageHost,
    this.onContactSelected,
  });

  final ClubDetailBodyState state;
  final ClubShareHandler? onShareClub;
  final ClubEventSelectionHandler? onEventSelected;
  final ClubHostProfileHandler? onViewHostProfile;
  final ClubHostMessageHandler? onMessageHost;
  final ClubContactActionHandler? onContactSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final club = state.club;
    final tags = visibleClubTags(club, limit: 6);
    final nextEvent = state.nextEvent;
    final showTrailingSections =
        state.showReviews || state.contactActions.isNotEmpty;

    return ColoredBox(
      color: t.surface,
      child: CustomScrollView(
        slivers: [
          ClubHeroAppBar(
            club: club,
            isHost: state.isHost,
            locationLabel: _clubHeroLocationLabel(club, nextEvent),
            onShareClub: onShareClub,
          ),
          CatchDetailSliverSectionList(
            gap: CatchSpacing.screenPt,
            bottomPadding: 0,
            sections: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (nextEvent != null) ...[
                    ClubNextRunBanner(
                      event: nextEvent,
                      onTap: onEventSelected == null
                          ? null
                          : () => onEventSelected!(nextEvent),
                    ),
                    gapH16,
                  ],
                  CatchMetricStrip(items: _clubMetricItems(club)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CatchSection.divided(
                    title: 'About',
                    first: true,
                    child: Text(
                      club.description,
                      style: CatchTextStyles.proseL(context, color: t.ink),
                    ),
                  ),
                  if (tags.isNotEmpty)
                    CatchSection.divided(
                      title: 'What we do',
                      child: ClubActivitySection(club: club, tags: tags),
                    ),
                  if (club.clubPhotos.isNotEmpty)
                    CatchSection.divided(
                      title: 'From the club',
                      child: ClubPhotoStrip(club: club),
                    ),
                  CatchSection.divided(
                    title: 'Your hosts',
                    count: club.displayHostProfiles.length,
                    child: ClubHostSection(
                      club: club,
                      canViewProfile: onViewHostProfile != null,
                      isMessageHostPending: state.isMessageHostPending,
                      messageableHostUids: state.messageableHostUids,
                      onViewProfile: onViewHostProfile,
                      onMessageHost: onMessageHost,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ClubScheduleSection(
            events: state.upcomingEvents,
            isHost: state.isHost,
            onEventSelected: onEventSelected,
            bottomPadding: showTrailingSections
                ? 0
                : CatchLayout.detailScreenBottomPadding,
          ),
          if (showTrailingSections)
            CatchDetailSliverSectionList(
              topPadding: 0,
              sections: [
                if (state.showReviews)
                  CatchSection.divided(
                    title: 'Reviews',
                    child: ClubReviewsSection(
                      reviews: state.reviews,
                      currentUid: state.uid,
                    ),
                  ),
                if (state.contactActions.isNotEmpty)
                  CatchSection.divided(
                    title: 'Get in touch',
                    child: ClubContactSection(
                      actions: state.contactActions,
                      showTitle: false,
                      onContactSelected: onContactSelected,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

List<CatchMetricStripItem> _clubMetricItems(Club club) {
  return [
    CatchMetricStripItem(value: '${club.memberCount}', label: 'members'),
    CatchMetricStripItem(
      value: club.rating > 0 ? club.rating.toStringAsFixed(1) : '—',
      label: 'rating',
    ),
    CatchMetricStripItem(value: '${club.reviewCount}', label: 'reviews'),
    CatchMetricStripItem(value: _clubEstablishedLabel(club), label: 'est.'),
  ];
}

String _clubEstablishedLabel(Club club) {
  const months = <String>[
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  final month = months[(club.createdAt.month - 1).clamp(0, 11)];
  final year = (club.createdAt.year % 100).toString().padLeft(2, '0');
  return '$month \'$year';
}

String _clubHeroLocationLabel(Club club, Event? nextEvent) {
  final meetingLocation = nextEvent?.effectiveMeetingLocation;
  final candidates = [
    meetingLocation?.address,
    meetingLocation?.name,
    '${club.area}, ${cityLabel(club.location)}',
  ];
  for (final candidate in candidates) {
    final normalized = candidate?.trim();
    if (normalized != null && normalized.isNotEmpty) return normalized;
  }
  return cityLabel(club.location);
}

class ClubNextRunBanner extends StatelessWidget {
  const ClubNextRunBanner({super.key, required this.event, this.onTap});

  final Event event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final activity = ActivityPalette.resolve(context, event.activityKind);

    return Semantics(
      button: onTap != null,
      label: _nextRunLabel(event),
      child: CatchSurface(
        onTap: onTap,
        radius: CatchRadius.md,
        padding: _clubActivityTilePadding,
        backgroundColor: activity.soft,
        child: Row(
          children: [
            Icon(activity.glyph, size: CatchIcon.sm, color: activity.deep),
            gapW10,
            Expanded(
              child: Text(
                _nextRunLabel(event),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.monoLabelS(
                  context,
                  color: activity.deep,
                ),
              ),
            ),
            gapW10,
            Icon(
              CatchIcons.arrowForwardRounded,
              size: CatchIcon.sm,
              color: activity.deep,
            ),
          ],
        ),
      ),
    );
  }
}

String _nextRunLabel(Event event) {
  final day = EventFormatters.shortWeekday(event.startTime).toUpperCase();
  final month = EventFormatters.shortMonth(event.startTime).toUpperCase();
  final time = EventFormatters.time(event.startTime).toUpperCase();
  return 'NEXT RUN · $day ${event.startTime.day} $month · $time';
}

class ClubActivitySection extends StatelessWidget {
  const ClubActivitySection({
    super.key,
    required this.club,
    required this.tags,
  });

  final Club club;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final activities = club.hostDefaults.effectiveSupportedActivityKinds;
    final activityLabels = {
      for (final activity in activities) activity.label.toLowerCase(),
    };
    final genericTags = [
      for (final tag in tags)
        if (!activityLabels.contains(tag.toLowerCase())) tag,
    ];
    final firstGenericTag = genericTags.isEmpty ? null : genericTags.first;
    final remainingGenericTags = genericTags.skip(1).toList(growable: false);

    final primaryWrap = Wrap(
      spacing: CatchSpacing.micro6,
      runSpacing: CatchSpacing.micro6,
      children: [
        for (final activity in activities)
          CatchActivityChip(
            activityKind: activity,
            primary: activity == club.hostDefaults.primaryActivityKind,
          ),
        if (activities.isEmpty)
          CatchActivityChip(
            activityKind: ActivityKind.openActivity,
            label: tags.first,
            primary: true,
          ),
        if (firstGenericTag != null)
          ClubTagWrap(
            tags: [firstGenericTag],
            tone: CatchBadgeTone.neutral,
            size: CatchBadgeSize.md,
            uppercase: false,
          ),
      ],
    );

    if (remainingGenericTags.isEmpty) return primaryWrap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        primaryWrap,
        gapH6,
        Wrap(
          spacing: CatchSpacing.micro6,
          runSpacing: CatchSpacing.micro6,
          children: [
            for (final tag in remainingGenericTags)
              ClubTagWrap(
                tags: [tag],
                tone: CatchBadgeTone.neutral,
                size: CatchBadgeSize.md,
                uppercase: false,
              ),
          ],
        ),
      ],
    );
  }
}
