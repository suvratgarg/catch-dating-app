import 'dart:async';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_hero_app_bar.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_schedule_section.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/stats_strip.dart';
import 'package:catch_dating_app/clubs/presentation/shared/club_identity_atoms.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:catch_dating_app/core/widgets/catch_section_header.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_section.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

typedef ClubEventSelectionHandler = void Function(Event event);
typedef ClubHostProfileHandler = void Function(String hostUid);
typedef ClubHostMessageHandler =
    Future<void> Function(BuildContext context, ClubHostProfile host);
typedef ClubContactActionHandler =
    Future<void> Function(ClubContactAction action);

enum ClubContactActionKind { instagram, phone, email }

class ClubContactAction {
  const ClubContactAction._({
    required this.kind,
    required this.label,
    required this.uri,
    required this.openExternally,
  });

  factory ClubContactAction.instagram(String handle) {
    final normalized = handle.replaceFirst('@', '');
    return ClubContactAction._(
      kind: ClubContactActionKind.instagram,
      label: handle,
      uri: Uri.parse('https://instagram.com/$normalized'),
      openExternally: true,
    );
  }

  factory ClubContactAction.phone(String phoneNumber) {
    return ClubContactAction._(
      kind: ClubContactActionKind.phone,
      label: phoneNumber,
      uri: Uri(scheme: 'tel', path: phoneNumber),
      openExternally: false,
    );
  }

  factory ClubContactAction.email(String email) {
    return ClubContactAction._(
      kind: ClubContactActionKind.email,
      label: email,
      uri: Uri(scheme: 'mailto', path: email),
      openExternally: false,
    );
  }

  final ClubContactActionKind kind;
  final String label;
  final Uri uri;
  final bool openExternally;
}

class ClubDetailBody extends StatelessWidget {
  const ClubDetailBody({
    super.key,
    required this.club,
    required this.upcoming,
    required this.reviews,
    required this.userProfile,
    required this.uid,
    required this.isHost,
    required this.isMember,
    required this.isMutating,
    required this.clubPushNotificationsEnabled,
    required this.isClubPushMutating,
    required this.isAuthenticated,
    this.canMessageHosts = false,
    this.isMessageHostPending = false,
    this.onShareClub,
    this.onEventSelected,
    this.onViewHostProfile,
    this.onMessageHost,
    this.onContactSelected,
  });

  final Club club;
  final List<Event> upcoming;
  final List<Review> reviews;
  final UserProfile? userProfile;
  final String? uid;
  final bool isHost;
  final bool isMember;
  final bool isMutating;
  final bool clubPushNotificationsEnabled;
  final bool isClubPushMutating;
  final bool isAuthenticated;
  final bool canMessageHosts;
  final bool isMessageHostPending;
  final ClubShareHandler? onShareClub;
  final ClubEventSelectionHandler? onEventSelected;
  final ClubHostProfileHandler? onViewHostProfile;
  final ClubHostMessageHandler? onMessageHost;
  final ClubContactActionHandler? onContactSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    const sectionGap = SizedBox(height: CatchLayout.detailScreenSectionGap);
    final tags = visibleClubTags(club, limit: 6);
    final hasContact =
        club.instagramHandle != null ||
        club.phoneNumber != null ||
        club.email != null;
    final nextEvent = _nextPublishedEvent(upcoming);

    return ColoredBox(
      color: t.surface,
      child: CustomScrollView(
        slivers: [
          ClubHeroAppBar(
            club: club,
            isHost: isHost,
            locationLabel: _clubHeroLocationLabel(club, nextEvent),
            onShareClub: onShareClub,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              CatchLayout.detailScreenHorizontalPadding,
              CatchLayout.detailScreenTopPadding,
              CatchLayout.detailScreenHorizontalPadding,
              0,
            ),
            sliver: SliverList.list(
              children: [
                if (nextEvent != null) ...[
                  _ClubNextRunBanner(
                    event: nextEvent,
                    onTap: onEventSelected == null
                        ? null
                        : () => onEventSelected!(nextEvent),
                  ),
                  gapH16,
                ],
                StatsStrip(club: club, upcomingCount: upcoming.length),
                CatchSectionStack(
                  padding: const EdgeInsets.only(top: CatchSpacing.screenPt),
                  children: [
                    CatchDesignSection(
                      kicker: 'About',
                      first: true,
                      child: Text(
                        club.description,
                        style: CatchTextStyles.bodyLead(
                          context,
                          color: t.ink,
                        ).copyWith(fontWeight: FontWeight.w400),
                      ),
                    ),
                    if (tags.isNotEmpty)
                      CatchDesignSection(
                        kicker: 'What we do',
                        child: _ClubActivitySection(club: club, tags: tags),
                      ),
                    if (club.clubPhotos.isNotEmpty)
                      CatchDesignSection(
                        kicker: 'From the club',
                        child: _ClubPhotoStrip(club: club),
                      ),
                    CatchDesignSection(
                      kicker: 'Your hosts',
                      count: club.displayHostProfiles.length,
                      child: _ClubHostSection(
                        club: club,
                        canViewProfile: onViewHostProfile != null,
                        canMessageHost: canMessageHosts,
                        isMessageHostPending: isMessageHostPending,
                        currentUid: uid,
                        onViewProfile: onViewHostProfile,
                        onMessageHost: onMessageHost,
                      ),
                    ),
                    if (hasContact)
                      CatchDesignSection(
                        kicker: 'Get in touch',
                        child: _ClubContactSection(
                          club: club,
                          showTitle: false,
                          onContactSelected: onContactSelected,
                        ),
                      ),
                  ],
                ),
                sectionGap,
              ],
            ),
          ),
          ClubScheduleSection(
            events: upcoming,
            isHost: isHost,
            onEventSelected: onEventSelected,
          ),
          if (isAuthenticated)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                CatchLayout.detailScreenHorizontalPadding,
                0,
                CatchLayout.detailScreenHorizontalPadding,
                CatchLayout.detailScreenBottomPadding,
              ),
              sliver: SliverToBoxAdapter(
                child: ClubReviewsSection(reviews: reviews, currentUid: uid),
              ),
            ),
        ],
      ),
    );
  }
}

Event? _nextPublishedEvent(List<Event> events) {
  final upcoming = [
    for (final event in events)
      if (!event.isCancelled) event,
  ]..sort((a, b) => a.startTime.compareTo(b.startTime));
  return upcoming.isEmpty ? null : upcoming.first;
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

class _ClubNextRunBanner extends StatelessWidget {
  const _ClubNextRunBanner({required this.event, this.onTap});

  final Event event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final activity = ActivityPalette.resolve(context, event.activityKind);

    return Semantics(
      button: onTap != null,
      label: _nextRunLabel(event),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CatchRadius.md),
          child: Ink(
            decoration: BoxDecoration(
              color: activity.soft,
              borderRadius: BorderRadius.circular(CatchRadius.md),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CatchSpacing.s4,
                vertical: CatchSpacing.s3,
              ),
              child: Row(
                children: [
                  Icon(
                    activity.glyph,
                    size: CatchIcon.sm,
                    color: activity.deep,
                  ),
                  gapW10,
                  Expanded(
                    child: Text(
                      _nextRunLabel(event),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.monoLabelS(
                        context,
                        color: activity.deep,
                      ).copyWith(fontWeight: FontWeight.w700),
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
          ),
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

class _ClubActivitySection extends StatelessWidget {
  const _ClubActivitySection({required this.club, required this.tags});

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
        ..._activityChips(activities),
        if (activities.isEmpty)
          CatchActivityChip(
            activityKind: ActivityKind.openActivity,
            label: tags.first,
            primary: true,
          ),
        if (firstGenericTag != null) _genericTagChip(firstGenericTag),
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
            for (final tag in remainingGenericTags) _genericTagChip(tag),
          ],
        ),
      ],
    );
  }

  List<Widget> _activityChips(List<ActivityKind> kinds) {
    return [
      for (final activity in kinds)
        CatchActivityChip(
          activityKind: activity,
          primary: activity == club.hostDefaults.primaryActivityKind,
        ),
    ];
  }

  Widget _genericTagChip(String tag) {
    return ClubTagWrap(
      tags: [tag],
      tone: CatchBadgeTone.neutral,
      size: CatchBadgeSize.md,
      uppercase: false,
    );
  }
}

class _ClubHostSection extends StatelessWidget {
  const _ClubHostSection({
    required this.club,
    required this.canViewProfile,
    required this.canMessageHost,
    required this.isMessageHostPending,
    required this.currentUid,
    required this.onViewProfile,
    required this.onMessageHost,
  });

  final Club club;
  final bool canViewProfile;
  final bool canMessageHost;
  final bool isMessageHostPending;
  final String? currentUid;
  final ClubHostProfileHandler? onViewProfile;
  final ClubHostMessageHandler? onMessageHost;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hosts = club.displayHostProfiles;

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.tileContentCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final host in hosts) ...[
            Semantics(
              button: canViewProfile,
              label: canViewProfile ? 'View ${host.displayName} profile' : null,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: canViewProfile
                    ? () => onViewProfile?.call(host.uid)
                    : null,
                child: _ClubHostRow(
                  host: host,
                  borderColor: t.primarySoft,
                  showChevron: canViewProfile,
                  onMessage:
                      canMessageHost &&
                          currentUid != null &&
                          currentUid != host.uid &&
                          !isMessageHostPending &&
                          onMessageHost != null
                      ? () => unawaited(onMessageHost!(context, host))
                      : null,
                ),
              ),
            ),
            if (host != hosts.last) gapH12,
          ],
        ],
      ),
    );
  }
}

class _ClubHostRow extends StatelessWidget {
  const _ClubHostRow({
    required this.host,
    required this.borderColor,
    required this.showChevron,
    required this.onMessage,
  });

  final ClubHostProfile host;
  final Color borderColor;
  final bool showChevron;
  final VoidCallback? onMessage;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    final isOwner = host.role == ClubHostRole.owner;
    final meta =
        '${isOwner ? 'OWNER' : 'HOST'} · '
        '${showChevron ? 'VIEW PROFILE' : 'PUBLIC PROFILE'}';

    return Row(
      children: [
        ClubHostAvatar(
          name: host.displayName,
          imageUrl: host.avatarUrl,
          size: CatchSpacing.s10,
          borderWidth: 2,
          borderColor: borderColor,
        ),
        gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      host.displayName,
                      style: CatchTextStyles.name(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isOwner) ...[
                    const SizedBox(width: CatchSpacing.micro6),
                    Icon(
                      CatchIcons.sealCheck,
                      size: CatchIcon.sm,
                      color: t.primary,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: CatchSpacing.s1),
              Text(
                meta,
                style: CatchTextStyles.monoLabel(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (onMessage != null) ...[
          gapW8,
          Tooltip(
            message: 'Message host',
            child: CatchIconButton(
              onTap: onMessage,
              child: Icon(
                CatchIcons.chatBubbleOutlineRounded,
                size: CatchIcon.control,
                color: t.primary,
              ),
            ),
          ),
        ],
        if (showChevron) ...[
          gapW8,
          Icon(
            CatchIcons.chevronRightRounded,
            size: CatchIcon.lg,
            color: t.ink3,
          ),
        ],
      ],
    );
  }
}

class _ClubContactSection extends StatelessWidget {
  const _ClubContactSection({
    required this.club,
    this.showTitle = true,
    this.onContactSelected,
  });

  final Club club;
  final bool showTitle;
  final ClubContactActionHandler? onContactSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.tileContentCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            const CatchSectionHeader(title: 'Contact', heavy: true),
            gapH12,
          ],
          if (club.instagramHandle != null)
            _ContactRow(
              icon: CatchIcons.alternateEmailRounded,
              action: ClubContactAction.instagram(club.instagramHandle!),
              onContactSelected: onContactSelected,
            ),
          if (club.phoneNumber != null)
            _ContactRow(
              icon: CatchIcons.callOutlined,
              action: ClubContactAction.phone(club.phoneNumber!),
              onContactSelected: onContactSelected,
            ),
          if (club.email != null)
            _ContactRow(
              icon: CatchIcons.emailOutlined,
              action: ClubContactAction.email(club.email!),
              onContactSelected: onContactSelected,
            ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.action,
    required this.onContactSelected,
  });

  final IconData icon;
  final ClubContactAction action;
  final ClubContactActionHandler? onContactSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final onTap = onContactSelected == null
        ? null
        : () => unawaited(onContactSelected!(action));

    return Semantics(
      button: onTap != null,
      label: action.label,
      child: Padding(
        padding: CatchInsets.detailInlineRowBottomGap,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CatchRadius.sm),
          child: Padding(
            padding: CatchInsets.controlVerticalTight,
            child: Row(
              children: [
                // Contact info stays ink — it never takes the action/activity
                // color (design-system ContactRow).
                Icon(icon, size: CatchIcon.md, color: t.ink),
                gapW10,
                Expanded(
                  child: Text(
                    action.label,
                    style: CatchTextStyles.infoRowTitle(context, color: t.ink),
                  ),
                ),
                Icon(
                  CatchIcons.arrowUpRight,
                  size: CatchIcon.sm,
                  color: t.ink3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClubPhotoStrip extends StatelessWidget {
  const _ClubPhotoStrip({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final photos = club.clubPhotos.take(3).toList();

    return Column(
      children: [
        Row(
          children: [
            for (var index = 0; index < photos.length; index++) ...[
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(CatchRadius.infoTile),
                    child: ColoredBox(
                      color: t.primarySoft,
                      child: CatchNetworkImage(
                        photos[index].thumbnailOrUrl,
                        errorBuilder: (_, _, _) => Icon(
                          CatchIcons.groupsOutlined,
                          color: t.ink2,
                          size: CatchIcon.lg,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (index != photos.length - 1) gapW8,
            ],
          ],
        ),
        gapH8,
        Row(
          children: [
            Text(
              'FROM THE CLUB',
              style: CatchTextStyles.monoLabelS(context, color: t.ink),
            ),
            const Spacer(),
            Text(
              '${club.clubPhotos.length} PHOTOS',
              style: CatchTextStyles.monoLabelS(context, color: t.ink3),
            ),
          ],
        ),
      ],
    );
  }
}
