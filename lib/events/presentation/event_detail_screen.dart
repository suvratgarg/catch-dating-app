import 'dart:async';

import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_host_contact_controller.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/app_error_context.dart' as app_ops;
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/events/data/event_calendar_links.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/presentation/event_detail_controller.dart';
import 'package:catch_dating_app/events/presentation/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/presentation/event_detail_screen_state.dart';
import 'package:catch_dating_app/events/presentation/event_detail_view_model.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_body.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_cta.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_optimistic_body.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_social_section.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_surface_style.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_share_card.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/routing/app_deep_links.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({
    super.key,
    required this.clubId,
    required this.eventId,
    this.initialEvent,
    this.inviteCode,
    this.inviteLinkId,
    this.presentationMode = EventDetailPresentationMode.standard,
    this.heroTag,
  });

  final String clubId;
  final String eventId;
  final Event? initialEvent;
  final String? inviteCode;
  final String? inviteLinkId;
  final EventDetailPresentationMode presentationMode;
  final Object? heroTag;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  String? _recordedInviteLinkId;

  @override
  void initState() {
    super.initState();
    _recordInviteLinkOpen();
  }

  @override
  void didUpdateWidget(covariant EventDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.eventId != widget.eventId ||
        oldWidget.inviteLinkId != widget.inviteLinkId) {
      _recordInviteLinkOpen();
    }
  }

  void _recordInviteLinkOpen() {
    final inviteLinkId = widget.inviteLinkId?.trim();
    if (inviteLinkId == null || inviteLinkId.isEmpty) return;
    if (_recordedInviteLinkId == '${widget.eventId}:$inviteLinkId') return;
    _recordedInviteLinkId = '${widget.eventId}:$inviteLinkId';
    unawaited(
      ref
          .read(eventDetailControllerProvider.notifier)
          .recordInviteLinkOpenBestEffort(
            eventId: widget.eventId,
            inviteLinkId: inviteLinkId,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vmAsync = ref.watch(eventDetailViewModelProvider(widget.eventId));
    final vm = vmAsync.asData?.value;
    final isHostApp = AppConfig.appRole.isHost;

    if (vm != null) {
      final now = DateTime.now();
      final sectionVisibility = eventDetailSectionVisibilityStateFrom(
        event: vm.event,
        participation: vm.participation,
        isHostApp: isHostApp,
        isHost: vm.isHost,
        now: now,
      );
      final isSpotlightDark =
          widget.presentationMode == EventDetailPresentationMode.spotlightDark;
      final style = _eventDetailSurfaceStyle(
        context,
        presentationMode: widget.presentationMode,
      );
      final saveMutation = ref.watch(
        EventDetailController.toggleSavedEventMutation,
      );
      final share = ref.watch(externalShareControllerProvider);
      final calendar = ref.watch(eventCalendarControllerProvider);
      final canOpenCompanion = eventDetailCanOpenCompanion(
        participation: vm.participation,
        showConsumerActions: sectionVisibility.showConsumerActions,
      );
      final companionState = eventDetailCompanionStateFrom(
        participation: vm.participation,
        showConsumerActions: sectionVisibility.showConsumerActions,
        planState: canOpenCompanion
            ? _catchAsyncState(
                ref.watch(watchEventSuccessPlanProvider(vm.event.id)),
              )
            : null,
      );
      final hostState = eventDetailHostStateFrom(
        clubState: _catchAsyncState(
          ref.watch(fetchClubProvider(widget.clubId)),
        ),
        currentUid: vm.userProfile?.uid,
        canMessageHost:
            sectionVisibility.showConsumerActions && vm.isAuthenticated,
      );
      final socialState = eventDetailSocialStateFrom(
        event: vm.event,
        userProfile: vm.userProfile,
        isAuthenticated: vm.isAuthenticated,
        renderAsHost: sectionVisibility.renderSocialAsHost,
        participation: vm.participation,
        now: now,
      );

      if (vm.isAuthenticated) {
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

      void shareEvent(BuildContext buttonContext) => unawaited(
        _shareEvent(
          buttonContext,
          vm.event,
          share,
          widget.inviteCode,
          widget.inviteLinkId,
        ),
      );

      return CatchMutationErrorListener(
        mutation: EventDetailController.toggleSavedEventMutation,
        errorContext: AppErrorContext.event,
        child: Scaffold(
          backgroundColor: style.pageBackground,
          body: EventDetailBody(
            event: vm.event,
            userProfile: vm.userProfile,
            clubId: widget.clubId,
            reviews: vm.reviews,
            isAuthenticated: vm.isAuthenticated,
            sectionVisibility: sectionVisibility,
            isSaved: vm.isSaved,
            participation: vm.participation,
            savePending: saveMutation.isPending,
            surfaceStyle: style,
            onBack: () => Navigator.of(context).pop(),
            onShare: shareEvent,
            showAddToCalendar: _canAddEventToCalendar(
              event: vm.event,
              participation: vm.participation,
              isHost: sectionVisibility.renderSocialAsHost,
              now: now,
            ),
            onAddToCalendar: (buttonContext) => unawaited(
              _addEventToCalendar(buttonContext, vm.event, calendar),
            ),
            onToggleSaved: () => _toggleSavedEvent(
              context,
              ref,
              event: vm.event,
              clubId: widget.clubId,
              userProfile: vm.userProfile,
              isAuthenticated: vm.isAuthenticated,
              isSaved: vm.isSaved,
            ),
            companionState: companionState,
            hostState: hostState,
            socialState: socialState,
            onLocationTap: vm.event.hasExactStartingPoint
                ? () => context.pushNamed(
                    Routes.eventLocationMapScreen.name,
                    pathParameters: {'eventId': vm.event.id},
                  )
                : null,
            onOpenCompanion: () => context.pushNamed(
              Routes.eventSuccessCompanionScreen.name,
              pathParameters: {'clubId': widget.clubId, 'eventId': vm.event.id},
              extra: vm.event,
            ),
            onRetryCompanion: () =>
                ref.invalidate(watchEventSuccessPlanProvider(vm.event.id)),
            onViewClub: (clubId) => context.pushNamed(
              Routes.clubDetailScreen.name,
              pathParameters: {'clubId': clubId},
            ),
            onMessageHost: (clubId, hostUid) => unawaited(
              _messageHost(context, ref, clubId: clubId, hostUid: hostUid),
            ),
            onRetryHosts: () =>
                ref.invalidate(fetchClubProvider(widget.clubId)),
            inviteCode: widget.inviteCode,
            inviteLinkId: widget.inviteLinkId,
            now: now,
            presentationMode: widget.presentationMode,
            heroTag: widget.heroTag,
          ),
          bottomNavigationBar: _eventDetailBottomNavigationBar(
            event: vm.event,
            userProfile: vm.userProfile,
            clubId: widget.clubId,
            isAuthenticated: vm.isAuthenticated,
            participation: vm.participation,
            inviteCode: widget.inviteCode,
            inviteLinkId: widget.inviteLinkId,
            now: now,
            darkSurface: isSpotlightDark,
            sectionVisibility: sectionVisibility,
            onGuestBook: () => _openEventSignIn(
              context,
              clubId: widget.clubId,
              eventId: vm.event.id,
              inviteCode: widget.inviteCode,
              inviteLinkId: widget.inviteLinkId,
            ),
          ),
        ),
      );
    }

    if (vmAsync.isLoading && _initialEventMatchesRoute) {
      return EventDetailOptimisticBody(
        event: widget.initialEvent!,
        clubId: widget.clubId,
        presentationMode: widget.presentationMode,
        heroTag: widget.heroTag,
        inviteCode: widget.inviteCode,
        inviteLinkId: widget.inviteLinkId,
      );
    }

    if (vmAsync.isLoading) {
      return EventDetailLoadingScreen(
        presentationMode: widget.presentationMode,
        showBottomNavigation: !isHostApp,
      );
    }

    if (vmAsync.hasError) {
      return CatchErrorScaffold.fromError(
        vmAsync.error!,
        context: AppErrorContext.event,
        onRetry: () =>
            ref.invalidate(eventDetailViewModelProvider(widget.eventId)),
      );
    }

    return const CatchErrorScaffold(
      title: 'Event not found',
      message: 'This event is no longer available.',
    );
  }

  bool get _initialEventMatchesRoute =>
      widget.initialEvent != null &&
      widget.initialEvent!.id == widget.eventId &&
      widget.initialEvent!.clubId == widget.clubId;
}

EventDetailSurfaceStyle _eventDetailSurfaceStyle(
  BuildContext context, {
  required EventDetailPresentationMode presentationMode,
}) {
  final t = CatchTokens.of(context);
  if (presentationMode == EventDetailPresentationMode.spotlightDark) {
    return EventDetailSurfaceStyle.dark(t);
  }
  return EventDetailSurfaceStyle.light(
    t,
    useWhite: presentationMode == EventDetailPresentationMode.ticket,
  );
}

Widget? _eventDetailBottomNavigationBar({
  required Event event,
  required UserProfile? userProfile,
  required String clubId,
  required bool isAuthenticated,
  required EventParticipation? participation,
  required String? inviteCode,
  required String? inviteLinkId,
  required DateTime now,
  required bool darkSurface,
  required EventDetailSectionVisibilityState sectionVisibility,
  required VoidCallback onGuestBook,
}) {
  if (!sectionVisibility.showBottomNavigation) return null;

  if (!isAuthenticated) {
    return GuestBookCta(onPressed: onGuestBook, darkSurface: darkSurface);
  }

  if (userProfile == null || !sectionVisibility.showConsumerActions) {
    return null;
  }

  return EventDetailCta(
    event: event,
    userProfile: userProfile,
    clubId: clubId,
    participation: participation,
    inviteCode: inviteCode,
    inviteLinkId: inviteLinkId,
    now: now,
    darkSurface: darkSurface,
  );
}

void _openEventSignIn(
  BuildContext context, {
  required String clubId,
  required String eventId,
  String? inviteCode,
  String? inviteLinkId,
}) {
  context.go(
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
    _openEventSignIn(context, clubId: clubId, eventId: event.id);
    return;
  }

  unawaited(
    EventDetailController.toggleSavedEventMutation
        .run(ref, (tx) async {
          final nowSaved = await tx
              .get(eventDetailControllerProvider.notifier)
              .toggleSavedEvent(
                event: event,
                userProfile: userProfile,
                isSaved: isSaved,
              );
          if (!context.mounted) return nowSaved;
          showCatchSnackBar(
            context,
            nowSaved ? 'Event saved.' : 'Event removed.',
          );
          return nowSaved;
        })
        .catchError((Object error, StackTrace stackTrace) {
          ref
              .read(errorLoggerProvider)
              .logError(
                error,
                stackTrace,
                reason: 'EventDetailScreen._toggleSavedEvent failed',
              );
          return isSaved;
        }),
  );
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
      app_ops.logAppError(
        actionError,
        stackTrace: stackTrace,
        context: const app_ops.AppErrorContext(
          operation: app_ops.AppOperation.plugin,
          action: 'add event to calendar',
          resource: 'calendar_link',
        ),
        logError: ProviderScope.containerOf(
          context,
          listen: false,
        ).read(errorLoggerProvider),
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

CatchAsyncState<T> _catchAsyncState<T>(AsyncValue<T> value) {
  return value.when(
    data: CatchAsyncState<T>.data,
    loading: () => const CatchAsyncState.loading(),
    error: (error, stackTrace) => CatchAsyncState<T>.error(error),
  );
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

class EventDetailLoadingScreen extends StatelessWidget {
  const EventDetailLoadingScreen({
    super.key,
    required this.presentationMode,
    this.showBottomNavigation = true,
  });

  final EventDetailPresentationMode presentationMode;
  final bool showBottomNavigation;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final isSpotlight =
        presentationMode == EventDetailPresentationMode.spotlightDark;

    return Scaffold(
      backgroundColor: isSpotlight ? t.ink : t.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: EventDetailHeroSkeleton(presentationMode: presentationMode),
          ),
          const SliverToBoxAdapter(child: EventDetailTicketStubSkeleton()),
          const CatchDetailSliverSectionList(
            topPadding: CatchSpacing.screenPt,
            bottomPadding: CatchSpacing.screenPb,
            sections: [
              EventDetailPlanSkeleton(),
              EventDetailHintSkeleton(),
              EventDetailItinerarySkeleton(),
              EventDetailMapSkeleton(),
              EventDetailMechanismSkeleton(),
              EventDetailSocialSkeleton(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: showBottomNavigation
          ? const EventDetailLoadingCta()
          : null,
    );
  }
}

class EventDetailHeroSkeleton extends StatelessWidget {
  const EventDetailHeroSkeleton({super.key, required this.presentationMode});

  final EventDetailPresentationMode presentationMode;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = _eventDetailLoadingHeroHeight(
      width: width,
      isTicketPresentation:
          presentationMode != EventDetailPresentationMode.standard,
    );

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: CatchSkeleton.box(
              width: double.infinity,
              height: height,
              borderRadius: BorderRadius.zero,
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + CatchSpacing.s2,
            left: CatchSpacing.s2,
            right: CatchSpacing.s2,
            child: Row(
              children: [
                CatchSkeleton.circle(size: CatchIconButton.navSize),
                const Spacer(),
                CatchSkeleton.circle(size: CatchIconButton.navSize),
                gapW8,
                CatchSkeleton.circle(size: CatchIconButton.navSize),
              ],
            ),
          ),
          Positioned(
            left: CatchSpacing.s5,
            right: CatchSpacing.s5,
            bottom: CatchLayout.eventDetailHeroTitleBottomInset,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CatchSkeleton.box(
                  width: CatchLayout.skeletonTextShortWidth,
                  height: CatchIcon.sm,
                  radius: CatchRadius.pill,
                ),
                gapH12,
                CatchSkeleton.text(),
                gapH8,
                CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

double _eventDetailLoadingHeroHeight({
  required double width,
  required bool isTicketPresentation,
}) {
  if (isTicketPresentation) {
    return width > CatchLayout.maxContentWidth
        ? CatchLayout.eventDetailHeroTicketWideHeight
        : CatchLayout.eventDetailHeroTicketPhoneHeight;
  }

  if (width > CatchLayout.maxContentWidth) {
    return CatchLayout.eventDetailHeroStandardWideHeight;
  }

  return (width * CatchLayout.eventDetailHeroStandardHeightRatio)
      .clamp(
        CatchLayout.eventDetailHeroStandardMinHeight,
        CatchLayout.eventDetailHeroStandardMaxHeight,
      )
      .toDouble();
}

class EventDetailTicketStubSkeleton extends StatelessWidget {
  const EventDetailTicketStubSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return ColoredBox(
      color: t.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: CatchLayout.eventDetailTicketStubBandHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < 3; index++) ...[
                    if (index > 0) VerticalDivider(color: t.line, width: 1),
                    const Expanded(child: TicketStubCellSkeleton()),
                  ],
                ],
              ),
            ),
            Divider(color: t.line, height: 1, thickness: 1),
          ],
        ),
      ),
    );
  }
}

class TicketStubCellSkeleton extends StatelessWidget {
  const TicketStubCellSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: CatchInsets.tileContentCompact,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CatchSkeleton.text(width: CatchLayout.skeletonTextShortWidth),
          gapH8,
          CatchSkeleton.box(
            width: CatchLayout.skeletonTextTitleWidth,
            height: CatchIcon.sm,
            radius: CatchRadius.pill,
          ),
        ],
      ),
    );
  }
}

class EventDetailPlanSkeleton extends StatelessWidget {
  const EventDetailPlanSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchSection.divided(
      title: 'The plan',
      first: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
          gapH12,
          CatchSkeleton.textBlock(),
        ],
      ),
    );
  }
}

class EventDetailHintSkeleton extends StatelessWidget {
  const EventDetailHintSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchSection.divided(
      title: 'Why you might click',
      child: Column(
        children: [
          for (var index = 0; index < 3; index++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: CatchInsets.detailHintDotTop,
                  child: CatchSkeleton.circle(
                    size: CatchLayout.eventDetailHintDotExtent,
                  ),
                ),
                gapW12,
                Expanded(child: CatchSkeleton.text()),
              ],
            ),
            if (index < 2) gapH12,
          ],
          gapH12,
          CatchSkeleton.text(),
        ],
      ),
    );
  }
}

class EventDetailItinerarySkeleton extends StatelessWidget {
  const EventDetailItinerarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchSection.divided(
      title: 'Itinerary',
      child: Column(
        children: [
          for (var index = 0; index < 3; index++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatchSkeleton.text(
                  width: CatchLayout.eventDetailItineraryTimeColumnWidth,
                ),
                gapW12,
                CatchSkeleton.circle(
                  size: CatchLayout.eventDetailItineraryDotExtent,
                ),
                gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CatchSkeleton.text(),
                      gapH8,
                      CatchSkeleton.text(),
                    ],
                  ),
                ),
              ],
            ),
            if (index < 2) gapH16,
          ],
        ],
      ),
    );
  }
}

class EventDetailMapSkeleton extends StatelessWidget {
  const EventDetailMapSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchSection.divided(
      title: 'Where',
      child: CatchSkeleton.card(height: CatchLayout.eventDetailMapCardHeight),
    );
  }
}

class EventDetailMechanismSkeleton extends StatelessWidget {
  const EventDetailMechanismSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchSection.divided(
      title: 'How sign-ups work',
      child: Column(
        children: [
          for (var index = 0; index < 3; index++) ...[
            Row(
              children: [
                CatchSkeleton.box(
                  width: CatchIcon.control,
                  height: CatchIcon.control,
                  radius: CatchRadius.pill,
                ),
                gapW12,
                Expanded(child: CatchSkeleton.text()),
              ],
            ),
            if (index < 2) gapH16,
          ],
        ],
      ),
    );
  }
}

class EventDetailSocialSkeleton extends StatelessWidget {
  const EventDetailSocialSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchSection.divided(
      title: "Who's going",
      child: Row(
        children: [
          for (var index = 0; index < 4; index++) ...[
            CatchSkeleton.circle(size: CatchIcon.avatarLg),
            if (index < 3) gapW8,
          ],
          gapW16,
          Expanded(child: CatchSkeleton.text()),
        ],
      ),
    );
  }
}

class EventDetailLoadingCta extends StatelessWidget {
  const EventDetailLoadingCta({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return ColoredBox(
      color: t.surface,
      child: SafeArea(
        top: false,
        minimum: CatchInsets.detailLoadingCtaSafeArea,
        child: CatchSkeleton.box(
          width: double.infinity,
          height: CatchLayout.buttonLgHeight,
          radius: CatchRadius.pill,
        ),
      ),
    );
  }
}
