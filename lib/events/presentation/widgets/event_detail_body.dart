import 'dart:async';

import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_host_contact_controller.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/presentation/event_calendar_links.dart';
import 'package:catch_dating_app/events/presentation/event_detail_controller.dart';
import 'package:catch_dating_app/events/presentation/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_cta.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_design_primitives.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_hero_app_bar.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_overview_section.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_social_section.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_surface_style.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_share_card.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/routing/app_deep_links.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

typedef EventShareHandler =
    Future<void> Function(BuildContext context, Event event);

class EventDetailBody extends ConsumerWidget {
  const EventDetailBody({
    super.key,
    required this.event,
    required this.userProfile,
    required this.clubId,
    required this.reviews,
    required this.isAuthenticated,
    required this.isHost,
    required this.isSaved,
    required this.participation,
    this.inviteCode,
    this.inviteLinkId,
    this.onShareEvent,
    this.now,
    this.presentationMode = EventDetailPresentationMode.standard,
    this.heroTag,
  });

  final Event event;
  final UserProfile? userProfile;
  final String clubId;
  final List<Review> reviews;
  final bool isAuthenticated;
  final bool isHost;
  final bool isSaved;
  final EventParticipation? participation;
  final String? inviteCode;
  final String? inviteLinkId;
  final EventShareHandler? onShareEvent;
  final DateTime? now;
  final EventDetailPresentationMode presentationMode;
  final Object? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final event = this.event;
    final userProfile = this.userProfile;
    final saveMutation = ref.watch(
      EventDetailController.toggleSavedEventMutation,
    );
    final share = ref.watch(externalShareControllerProvider);
    final calendar = ref.watch(eventCalendarControllerProvider);
    final now = this.now ?? DateTime.now();
    final isHostApp = AppConfig.appRole.isHost;
    final showConsumerActions = !isHostApp && !isHost;
    final isSpotlightDark =
        presentationMode == EventDetailPresentationMode.spotlightDark;
    final style = isSpotlightDark
        ? EventDetailSurfaceStyle.dark(t)
        : EventDetailSurfaceStyle.light(
            t,
            useWhite: presentationMode == EventDetailPresentationMode.ticket,
          );
    final Widget? bottomNavigationBar;
    void shareEvent(BuildContext buttonContext) => unawaited(
      onShareEvent != null
          ? onShareEvent!(buttonContext, event)
          : _shareEvent(buttonContext, event, share, inviteCode, inviteLinkId),
    );

    if (isAuthenticated) {
      ref.listen(EventBookingController.bookMutation, (prev, next) {
        if (prev?.isPending == true && next.isSuccess) {
          showCatchSnackBar(context, 'Booking confirmed!');
        }
      });
      ref.listen(EventBookingController.cancelMutation, (prev, next) {
        if (prev?.isPending == true && next.isSuccess) {
          showCatchSnackBar(context, 'Booking cancelled.');
        }
      });
    }

    if (isHostApp) {
      bottomNavigationBar = null;
    } else if (!isAuthenticated) {
      bottomNavigationBar = _guestBookCta(
        context,
        clubId: clubId,
        eventId: event.id,
        inviteCode: inviteCode,
        inviteLinkId: inviteLinkId,
        darkSurface: isSpotlightDark,
      );
    } else if (userProfile != null && showConsumerActions) {
      bottomNavigationBar = EventDetailCta(
        event: event,
        userProfile: userProfile,
        clubId: clubId,
        participation: participation,
        inviteCode: inviteCode,
        inviteLinkId: inviteLinkId,
        now: now,
        darkSurface: isSpotlightDark,
      );
    } else {
      bottomNavigationBar = null;
    }

    return Scaffold(
      backgroundColor: style.pageBackground,
      body: CustomScrollView(
        slivers: [
          EventDetailHeroAppBar(
            event: event,
            isSaved: isSaved,
            savePending: saveMutation.isPending,
            onBack: () => Navigator.of(context).pop(),
            onShare: shareEvent,
            showAddToCalendar: _canAddEventToCalendar(
              event: event,
              participation: participation,
              isHost: isHost || isHostApp,
              now: now,
            ),
            onAddToCalendar: (buttonContext) =>
                unawaited(_addEventToCalendar(buttonContext, event, calendar)),
            presentationMode: presentationMode,
            heroTag: heroTag,
            onToggleSaved: () => _toggleSavedEvent(
              context,
              ref,
              event: event,
              clubId: clubId,
              userProfile: userProfile,
              isAuthenticated: isAuthenticated,
              isSaved: isSaved,
            ),
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
                onLocationTap: event.hasExactStartingPoint
                    ? () => context.pushNamed(
                        Routes.eventLocationMapScreen.name,
                        pathParameters: {'eventId': event.id},
                      )
                    : null,
              ),
              if (_canOpenCompanion(
                participation: participation,
                showConsumerActions: showConsumerActions,
              ))
                _eventCompanionEntry(
                  context,
                  ref,
                  event: event,
                  clubId: clubId,
                  surfaceStyle: style,
                ),
              if (_canShowInviteLoop(
                event: event,
                participation: participation,
                showConsumerActions: showConsumerActions,
                now: now,
              ))
                _eventInviteLoopCard(
                  context,
                  event: event,
                  onShare: shareEvent,
                  surfaceStyle: style,
                ),
              Divider(color: style.dividerColor, height: 1),
              _eventDetailHostsSection(
                context,
                ref,
                event: event,
                clubId: clubId,
                currentUid: userProfile?.uid,
                canMessageHost: showConsumerActions && isAuthenticated,
                surfaceStyle: style,
              ),
              EventDetailSocialSection(
                event: event,
                clubId: clubId,
                reviews: reviews,
                userProfile: userProfile,
                isAuthenticated: isAuthenticated,
                isHost: isHost || isHostApp,
                participation: participation,
                now: now,
                surfaceStyle: style,
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

bool _canShowInviteLoop({
  required Event event,
  required EventParticipation? participation,
  required bool showConsumerActions,
  required DateTime now,
}) {
  if (!showConsumerActions ||
      event.isCancelled ||
      !event.startTime.isAfter(now)) {
    return false;
  }
  return participation?.status == EventParticipationStatus.signedUp;
}

Widget _eventInviteLoopCard(
  BuildContext context, {
  required Event event,
  required ValueChanged<BuildContext> onShare,
  required EventDetailSurfaceStyle surfaceStyle,
}) {
  final t = CatchTokens.of(context);
  return CatchSurface(
    backgroundColor: surfaceStyle.surfaceBackground,
    borderColor: surfaceStyle.isDark
        ? surfaceStyle.borderColor
        : t.primary.withValues(alpha: CatchOpacity.eventDetailLightBorder),
    padding: CatchInsets.tileContentCompact,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          CatchIcons.platformShare(platform: Theme.of(context).platform),
          color: t.primary,
        ),
        gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bring someone into the room',
                style: CatchTextStyles.sectionTitle(
                  context,
                  color: surfaceStyle.headingColor,
                ),
              ),
              gapH4,
              Text(
                'Your spot is booked. Invite a friend who would make this event better.',
                style: CatchTextStyles.supporting(
                  context,
                  color: surfaceStyle.bodyColor,
                ),
              ),
              gapH12,
              Builder(
                builder: (buttonContext) => CatchButton(
                  label: 'Invite a friend',
                  variant: CatchButtonVariant.secondary,
                  icon: Icon(CatchIcons.sendRounded),
                  onPressed: () => onShare(buttonContext),
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

bool _canOpenCompanion({
  required EventParticipation? participation,
  required bool showConsumerActions,
}) {
  if (!showConsumerActions) return false;
  return switch (participation?.status) {
    EventParticipationStatus.signedUp ||
    EventParticipationStatus.attended => true,
    EventParticipationStatus.waitlisted ||
    EventParticipationStatus.cancelled ||
    EventParticipationStatus.deleted ||
    null => false,
  };
}

Widget _eventCompanionEntry(
  BuildContext context,
  WidgetRef ref, {
  required Event event,
  required String clubId,
  required EventDetailSurfaceStyle surfaceStyle,
}) {
  final planAsync = ref.watch(watchEventSuccessPlanProvider(event.id));
  return planAsync.maybeWhen(
    data: (plan) => plan == null
        ? const SizedBox.shrink()
        : _eventCompanionCard(
            context,
            event: event,
            clubId: clubId,
            surfaceStyle: surfaceStyle,
          ),
    orElse: () => const SizedBox.shrink(),
  );
}

Widget _eventCompanionCard(
  BuildContext context, {
  required Event event,
  required String clubId,
  required EventDetailSurfaceStyle surfaceStyle,
}) {
  final t = CatchTokens.of(context);
  return CatchSurface(
    backgroundColor: surfaceStyle.surfaceBackground,
    borderColor: surfaceStyle.borderColor,
    padding: CatchInsets.tileContentCompact,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(CatchIcons.autoAwesomeOutlined, color: t.primary),
        gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event companion',
                style: CatchTextStyles.sectionTitle(
                  context,
                  color: surfaceStyle.headingColor,
                ),
              ),
              gapH4,
              Text(
                'Check in, see your social prompt, and handle private follow-up after the event.',
                style: CatchTextStyles.supporting(
                  context,
                  color: surfaceStyle.bodyColor,
                ),
              ),
              gapH12,
              CatchButton(
                label: 'Open companion',
                variant: CatchButtonVariant.secondary,
                icon: Icon(CatchIcons.phoneIphoneRounded),
                onPressed: () => context.pushNamed(
                  Routes.eventSuccessCompanionScreen.name,
                  pathParameters: {'clubId': clubId, 'eventId': event.id},
                  extra: event,
                ),
                fullWidth: true,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

void _toggleSavedEvent(
  BuildContext context,
  WidgetRef ref, {
  required Event event,
  required String clubId,
  required UserProfile? userProfile,
  required bool isAuthenticated,
  required bool isSaved,
}) {
  if (!isAuthenticated || userProfile == null) {
    context.go(
      Uri(
        path: Routes.authScreen.path,
        queryParameters: {'from': '/clubs/$clubId/events/${event.id}'},
      ).toString(),
    );
    return;
  }

  EventDetailController.toggleSavedEventMutation.run(ref, (tx) async {
    final nowSaved = await tx
        .get(eventDetailControllerProvider.notifier)
        .toggleSavedEvent(
          event: event,
          userProfile: userProfile,
          isSaved: isSaved,
        );
    if (!context.mounted) return nowSaved;
    showCatchSnackBar(context, nowSaved ? 'Event saved.' : 'Event removed.');
    return nowSaved;
  });
}

Future<void> _shareEvent(
  BuildContext context,
  Event event,
  ExternalShareController share,
  String? inviteCode,
  String? inviteLinkId,
) async {
  await showEventShareCardSheet(
    context,
    event: event,
    share: share,
    inviteCode: inviteCode,
    inviteLinkId: inviteLinkId,
  );
}

Future<void> _addEventToCalendar(
  BuildContext context,
  Event event,
  EventCalendarController calendar,
) async {
  try {
    final opened = await calendar.addToCalendar(event);
    if (!context.mounted || opened) return;
    showCatchSnackBar(context, 'Could not open calendar.');
  } on Object catch (error, stackTrace) {
    final actionError = ExternalActionException(
      'Failed to add event to calendar',
      cause: error,
      stackTrace: stackTrace,
    );

    if (context.mounted) {
      ProviderScope.containerOf(context, listen: false)
          .read(errorLoggerProvider)
          .logAppException(
            normalizeBackendError(
              actionError,
              stackTrace: stackTrace,
              context: const BackendErrorContext(
                service: BackendService.external,
                action: 'add event to calendar',
                resource: 'calendar_link',
              ),
            ),
          );

      showCatchSnackBar(context, 'Could not open calendar.');
    }
  }
}

bool _canAddEventToCalendar({
  required Event event,
  required EventParticipation? participation,
  required bool isHost,
  required DateTime now,
}) {
  if (event.isCancelled || !event.startTime.isAfter(now)) return false;
  if (isHost) return true;
  return participation?.status == EventParticipationStatus.signedUp;
}

Widget _guestBookCta(
  BuildContext context, {
  required String clubId,
  required String eventId,
  String? inviteCode,
  String? inviteLinkId,
  bool darkSurface = false,
}) {
  final t = CatchTokens.of(context);
  return SafeArea(
    child: ColoredBox(
      color: darkSurface ? t.ink : t.surface,
      child: Padding(
        padding: CatchInsets.contentBlock,
        child: CatchButton(
          label: 'Sign in to book this event',
          onPressed: () => context.go(
            Uri(
              path: Routes.authScreen.path,
              queryParameters: {
                'from': AppDeepLinks.inAppEventPath(
                  clubId: clubId,
                  eventId: eventId,
                  inviteCode: inviteCode,
                  inviteLinkId: inviteLinkId,
                ),
              },
            ).toString(),
          ),
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

/// "Your hosts" section — watches the event's club and renders the design-system
/// [EventDetailHostCard] from it, wiring View club (→ club detail) and, for
/// signed-in consumers, Message host (→ host inquiry chat).
Widget _eventDetailHostsSection(
  BuildContext context,
  WidgetRef ref, {
  required Event event,
  required String clubId,
  required String? currentUid,
  required bool canMessageHost,
  EventDetailSurfaceStyle? surfaceStyle,
}) {
  final club = ref.watch(fetchClubProvider(clubId)).asData?.value;
  if (club == null) return const SizedBox.shrink();

  final hostProfiles = club.displayHostProfiles;
  final hostProfile = hostProfiles.isEmpty ? null : hostProfiles.first;
  final hostUid = hostProfile?.uid ?? club.ownerOrPrimaryHostUserId;
  final style = surfaceStyle;
  final canMessage =
      canMessageHost &&
      hostUid != null &&
      currentUid != null &&
      currentUid != hostUid;

  return CatchSection(
    title: 'Your hosts',
    dividerColor: style?.dividerColor,
    titleColor: style?.headingColor,
    child: EventDetailHostCard(
      activityKind: event.activityKind,
      hostName: club.displayHostName,
      photoUrl: hostProfile?.avatarUrl ?? club.logoPhotoUrl,
      meta: _hostMeta(club),
      verified: club.ownerOrPrimaryHostUserId != null,
      stats: _hostStats(club),
      surfaceColor: style?.surfaceBackground,
      borderColor: style?.borderColor,
      nameColor: style?.headingColor,
      metaColor: style?.bodyColor,
      statValueColor: style?.headingColor,
      statLabelColor: style?.mutedColor,
      dividerColor: style?.dividerColor,
      onViewClub: () => context.pushNamed(
        Routes.clubDetailScreen.name,
        pathParameters: {'clubId': club.id},
      ),
      onMessage: canMessage
          ? () => unawaited(
              _messageHost(context, ref, clubId: club.id, hostUid: hostUid),
            )
          : null,
    ),
  );
}

const List<String> _monthAbbrevs = <String>[
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

String _hostMeta(Club club) {
  final month = _monthAbbrevs[(club.createdAt.month - 1).clamp(0, 11)];
  final parts = <String>['HOSTING SINCE $month ${club.createdAt.year}'];
  final area = club.area.trim();
  if (area.isNotEmpty) parts.add(area.toUpperCase());
  return parts.join(' · ');
}

List<EventDetailHostStat> _hostStats(Club club) {
  final stats = <EventDetailHostStat>[];
  if (club.memberCount > 0) {
    stats.add(
      EventDetailHostStat(value: '${club.memberCount}', label: 'Members'),
    );
  }
  if (club.reviewCount > 0) {
    stats
      ..add(
        EventDetailHostStat(
          value: club.rating.toStringAsFixed(1),
          label: 'Rating',
        ),
      )
      ..add(
        EventDetailHostStat(value: '${club.reviewCount}', label: 'Reviews'),
      );
  }
  return stats;
}

Future<void> _messageHost(
  BuildContext context,
  WidgetRef ref, {
  required String clubId,
  required String hostUid,
}) async {
  final matchId = await ClubHostContactController.startConversationMutation.run(
    ref,
    (tx) => tx
        .get(clubHostContactControllerProvider.notifier)
        .startConversation(clubId: clubId, hostUid: hostUid),
  );
  if (!context.mounted) return;
  unawaited(
    context.pushNamed(
      Routes.chatScreen.name,
      pathParameters: {'matchId': matchId},
    ),
  );
}
