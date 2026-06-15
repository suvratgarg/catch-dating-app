import 'dart:async';

import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Booking confirmed!')));
        }
      });
      ref.listen(EventBookingController.cancelMutation, (prev, next) {
        if (prev?.isPending == true && next.isSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Booking cancelled.')));
        }
      });
    }

    if (isHostApp) {
      bottomNavigationBar = null;
    } else if (!isAuthenticated) {
      bottomNavigationBar = _GuestBookCta(
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
                _EventCompanionEntry(
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
                _EventInviteLoopCard(
                  event: event,
                  onShare: shareEvent,
                  surfaceStyle: style,
                ),
              Divider(color: style.dividerColor, height: 1),
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

class _EventInviteLoopCard extends StatelessWidget {
  const _EventInviteLoopCard({
    required this.event,
    required this.onShare,
    required this.surfaceStyle,
  });

  final Event event;
  final ValueChanged<BuildContext> onShare;
  final EventDetailSurfaceStyle surfaceStyle;

  @override
  Widget build(BuildContext context) {
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

class _EventCompanionEntry extends ConsumerWidget {
  const _EventCompanionEntry({
    required this.event,
    required this.clubId,
    required this.surfaceStyle,
  });

  final Event event;
  final String clubId;
  final EventDetailSurfaceStyle surfaceStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(watchEventSuccessPlanProvider(event.id));
    return planAsync.maybeWhen(
      data: (plan) => plan == null
          ? const SizedBox.shrink()
          : _EventCompanionCard(
              event: event,
              clubId: clubId,
              surfaceStyle: surfaceStyle,
            ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _EventCompanionCard extends StatelessWidget {
  const _EventCompanionCard({
    required this.event,
    required this.clubId,
    required this.surfaceStyle,
  });

  final Event event;
  final String clubId;
  final EventDetailSurfaceStyle surfaceStyle;

  @override
  Widget build(BuildContext context) {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(nowSaved ? 'Event saved.' : 'Event removed.')),
    );
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Could not open calendar.')));
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open calendar.')));
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

class _GuestBookCta extends StatelessWidget {
  const _GuestBookCta({
    required this.clubId,
    required this.eventId,
    this.inviteCode,
    this.inviteLinkId,
    this.darkSurface = false,
  });

  final String clubId;
  final String eventId;
  final String? inviteCode;
  final String? inviteLinkId;
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
}
