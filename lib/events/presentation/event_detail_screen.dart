import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_host_contact_controller.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/app_error_context.dart' as app_ops;
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/events/data/event_calendar_links.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/presentation/event_detail_controller.dart';
import 'package:catch_dating_app/events/presentation/event_detail_display_state.dart';
import 'package:catch_dating_app/events/presentation/event_detail_information_state.dart';
import 'package:catch_dating_app/events/presentation/event_detail_screen_state.dart';
import 'package:catch_dating_app/events/presentation/event_detail_view_model.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_body.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_cta.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_loading_skeleton.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_surface_style.dart';
import 'package:catch_dating_app/events/shared/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/shared/event_share_card.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/app_deep_links.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/domain/profile_readiness.dart';
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
    this.enableMapNetworkTiles = true,
  });

  final String clubId;
  final String eventId;
  final Event? initialEvent;
  final String? inviteCode;
  final String? inviteLinkId;
  final EventDetailPresentationMode presentationMode;
  final Object? heroTag;
  final bool enableMapNetworkTiles;

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
    if (_recordedInviteLinkId ==
        context.l10n.eventsEventDetailScreenVisiblecopyEventidInvitelinkid(
          eventId: widget.eventId,
          inviteLinkId: inviteLinkId,
        )) {
      return;
    }
    _recordedInviteLinkId = context.l10n
        .eventsEventDetailScreenVisiblecopyEventidInvitelinkid(
          eventId: widget.eventId,
          inviteLinkId: inviteLinkId,
        );
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
    final uidAsync = ref.watch(uidProvider);
    final vm = vmAsync.asData?.value;
    final resolvedClubId = vm?.event.clubId ?? widget.clubId;
    final clubAsync = ref.watch(fetchClubProvider(resolvedClubId));
    final isHostApp = AppConfig.appRole.isHost;

    if (vm != null) {
      if (vm.event.clubId != widget.clubId) {
        return CatchErrorScaffold(
          title: context.l10n.eventsEventDetailScreenTitleEventNotFound,
          message: context.l10n.eventsEventDetailScreenMessageThisEventIsNo,
        );
      }
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
        l10n: context.l10n,
        clubState: _catchAsyncState(clubAsync),
        currentUid: vm.userProfile?.uid,
        canMessageHost:
            sectionVisibility.showConsumerActions &&
            vm.userProfile?.hasSocialReadyProfileOn(now) == true,
      );
      final socialState = eventDetailSocialStateFrom(
        event: vm.event,
        hasReviews: vm.reviews.isNotEmpty,
        userProfile: vm.userProfile,
        isAuthenticated: vm.isAuthenticated,
        renderAsHost: sectionVisibility.renderSocialAsHost,
        participation: vm.participation,
        now: now,
      );
      final informationState = eventDetailInformationStateFrom(
        event: vm.event,
        l10n: context.l10n,
      );

      if (vm.isAuthenticated) {
        ref.listen(EventBookingController.bookMutation, (prev, next) {
          if (prev?.isPending == true && next.isSuccess) {
            showCatchSnackBar(
              context,
              context.l10n.eventsEventDetailScreenVisiblecopyBookingConfirmed,
            );
          }
        });
        ref.listen(EventBookingController.cancelMutation, (prev, next) {
          if (prev?.isPending == true && next.isSuccess) {
            showCatchSnackBar(
              context,
              context.l10n.eventsEventDetailScreenVisiblecopyBookingCancelled,
            );
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
              event: vm.event,
              clubId: widget.clubId,
              userProfile: vm.userProfile,
              isAuthenticated: vm.isAuthenticated,
              isSaved: vm.isSaved,
              now: now,
            ),
            companionState: companionState,
            hostState: hostState,
            socialState: socialState,
            informationState: informationState,
            onLocationTap: () => context.pushNamed(
              Routes.eventLocationMapScreen.name,
              pathParameters: {
                context.l10n.eventsEventDetailScreenBodyEventid: vm.event.id,
              },
            ),
            onOpenCompanion: () => context.pushNamed(
              Routes.eventSuccessCompanionScreen.name,
              pathParameters: {
                context.l10n.eventsEventDetailScreenBodyClubid: widget.clubId,
                context.l10n.eventsEventDetailScreenBodyEventid: vm.event.id,
              },
              extra: vm.event,
            ),
            onRetryCompanion: () =>
                ref.invalidate(watchEventSuccessPlanProvider(vm.event.id)),
            onViewClub: (clubId) => context.pushNamed(
              eventDetailOrganizerRouteFor(isHostApp: isHostApp).name,
              pathParameters: {
                context.l10n.eventsEventDetailScreenBodyClubid: clubId,
              },
            ),
            onMessageHost: (clubId, hostUid) => unawaited(
              _messageHost(
                context,
                clubId: clubId,
                hostUid: hostUid,
                eventId: widget.eventId,
              ),
            ),
            onRetryHosts: () =>
                ref.invalidate(fetchClubProvider(vm.event.clubId)),
            inviteCode: widget.inviteCode,
            inviteLinkId: widget.inviteLinkId,
            now: now,
            presentationMode: widget.presentationMode,
            heroTag: widget.heroTag,
            enableMapNetworkTiles: widget.enableMapNetworkTiles,
          ),
          bottomNavigationBar: _eventDetailBottomNavigationBar(
            event: vm.event,
            userProfile: vm.userProfile,
            clubId: widget.clubId,
            isAuthenticated: vm.isAuthenticated,
            isSaved: vm.isSaved,
            isHosted: vm.isHost,
            isClubMember: vm.isClubMember,
            participation: vm.participation,
            inviteCode: widget.inviteCode,
            inviteLinkId: widget.inviteLinkId,
            now: now,
            darkSurface: isSpotlightDark,
            sectionVisibility: sectionVisibility,
            completeProfileLabel:
                context.l10n.eventsEventDetailScreenLabelCompleteBookingProfile,
            onGuestBook: () => _openEventSignIn(
              context,
              clubId: widget.clubId,
              eventId: vm.event.id,
              inviteCode: widget.inviteCode,
              inviteLinkId: widget.inviteLinkId,
            ),
            onCompleteProfile: () => _openEventProfileCompletion(
              context,
              clubId: widget.clubId,
              eventId: vm.event.id,
            ),
          ),
        ),
      );
    }

    final canRenderGuestInitialEvent =
        !isHostApp &&
        uidAsync.hasValue &&
        uidAsync.value == null &&
        clubAsync.asData?.value?.isPubliclyBrowseable == true;
    if (vmAsync.isLoading &&
        _initialEventMatchesRoute &&
        canRenderGuestInitialEvent) {
      final event = widget.initialEvent!;
      final now = DateTime.now();
      final sectionVisibility = eventDetailSectionVisibilityStateFrom(
        event: event,
        participation: null,
        isHostApp: isHostApp,
        isHost: false,
        now: now,
      );
      final isSpotlightDark =
          widget.presentationMode == EventDetailPresentationMode.spotlightDark;
      final style = _eventDetailSurfaceStyle(
        context,
        presentationMode: widget.presentationMode,
      );
      final informationState = eventDetailInformationStateFrom(
        event: event,
        l10n: context.l10n,
      );

      return Scaffold(
        backgroundColor: style.pageBackground,
        body: EventDetailBody(
          event: event,
          userProfile: null,
          clubId: widget.clubId,
          reviews: const [],
          isAuthenticated: false,
          sectionVisibility: sectionVisibility,
          isSaved: false,
          participation: null,
          savePending: false,
          surfaceStyle: style,
          onBack: () => Navigator.of(context).pop(),
          onShare: (_) {},
          showShareAction: false,
          showAddToCalendar: false,
          onAddToCalendar: (_) {},
          onToggleSaved: () => _openEventSignIn(
            context,
            clubId: widget.clubId,
            eventId: event.id,
            inviteCode: widget.inviteCode,
            inviteLinkId: widget.inviteLinkId,
          ),
          companionState: const EventDetailCompanionState.hidden(),
          hostState: const EventDetailHostState.loading(),
          socialState: const EventDetailSocialState.loading(),
          informationState: informationState,
          onLocationTap: () => context.pushNamed(
            Routes.eventLocationMapScreen.name,
            pathParameters: {
              context.l10n.eventsEventDetailScreenBodyEventid: event.id,
            },
          ),
          onOpenCompanion: () {},
          onRetryCompanion: () =>
              ref.invalidate(watchEventSuccessPlanProvider(event.id)),
          onViewClub: (clubId) => context.pushNamed(
            Routes.clubDetailScreen.name,
            pathParameters: {
              context.l10n.eventsEventDetailScreenBodyClubid: clubId,
            },
          ),
          onMessageHost: (clubId, hostUid) => unawaited(
            _messageHost(
              context,
              clubId: clubId,
              hostUid: hostUid,
              eventId: widget.eventId,
            ),
          ),
          onRetryHosts: () => ref.invalidate(fetchClubProvider(widget.clubId)),
          inviteCode: widget.inviteCode,
          inviteLinkId: widget.inviteLinkId,
          now: now,
          presentationMode: widget.presentationMode,
          heroTag: widget.heroTag,
          enableMapNetworkTiles: widget.enableMapNetworkTiles,
        ),
        bottomNavigationBar: _eventDetailBottomNavigationBar(
          event: event,
          userProfile: null,
          clubId: widget.clubId,
          isAuthenticated: false,
          participation: null,
          inviteCode: widget.inviteCode,
          inviteLinkId: widget.inviteLinkId,
          now: now,
          darkSurface: isSpotlightDark,
          sectionVisibility: sectionVisibility,
          completeProfileLabel:
              context.l10n.eventsEventDetailScreenLabelCompleteBookingProfile,
          onGuestBook: () => _openEventSignIn(
            context,
            clubId: widget.clubId,
            eventId: event.id,
            inviteCode: widget.inviteCode,
            inviteLinkId: widget.inviteLinkId,
          ),
          onCompleteProfile: () {},
        ),
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

    return CatchErrorScaffold(
      title: context.l10n.eventsEventDetailScreenTitleEventNotFound,
      message: context.l10n.eventsEventDetailScreenMessageThisEventIsNo,
    );
  }

  bool get _initialEventMatchesRoute =>
      widget.initialEvent != null &&
      widget.initialEvent!.id == widget.eventId &&
      widget.initialEvent!.clubId == widget.clubId;

  void _toggleSavedEvent(
    BuildContext context, {
    required Event event,
    required String clubId,
    required UserProfile? userProfile,
    required bool isAuthenticated,
    required bool isSaved,
    required DateTime now,
  }) {
    if (!isAuthenticated ||
        !eventDetailHasBookingReadyProfile(userProfile, now: now)) {
      if (!isAuthenticated) {
        _openEventSignIn(context, clubId: clubId, eventId: event.id);
      } else {
        _openEventProfileCompletion(context, clubId: clubId, eventId: event.id);
      }
      return;
    }
    final readyProfile = userProfile!;

    unawaited(
      EventDetailController.toggleSavedEventMutation
          .run(ref, (tx) async {
            final nowSaved = await tx
                .get(eventDetailControllerProvider.notifier)
                .toggleSavedEvent(
                  event: event,
                  userProfile: readyProfile,
                  isSaved: isSaved,
                );
            if (!context.mounted) return nowSaved;
            showCatchSnackBar(
              context,
              nowSaved
                  ? context.l10n.eventsEventDetailScreenVisiblecopyEventSaved
                  : context.l10n.eventsEventDetailScreenVisiblecopyEventRemoved,
            );
            return nowSaved;
          })
          .catchError((Object error, StackTrace stackTrace) {
            ref
                .read(errorLoggerProvider)
                .logError(
                  error,
                  stackTrace,
                  reason: context
                      .l10n
                      .eventsEventDetailScreenVisiblecopyEventdetailscreenTogglesavedeventFailed,
                );
            return isSaved;
          }),
    );
  }

  Future<void> _messageHost(
    BuildContext context, {
    required String clubId,
    required String hostUid,
    required String eventId,
  }) async {
    final matchId = await ClubHostContactController.startConversationMutation
        .run(
          ref,
          (tx) => tx
              .get(clubHostContactControllerProvider.notifier)
              .startConversation(
                clubId: clubId,
                hostUid: hostUid,
                eventId: eventId,
              ),
        );
    if (!context.mounted) return;
    unawaited(
      context.pushNamed(
        Routes.chatScreen.name,
        pathParameters: {'matchId': matchId},
      ),
    );
  }
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
  bool isSaved = false,
  bool isHosted = false,
  bool isClubMember = false,
  required EventParticipation? participation,
  required String? inviteCode,
  required String? inviteLinkId,
  required DateTime now,
  required bool darkSurface,
  required EventDetailSectionVisibilityState sectionVisibility,
  required String completeProfileLabel,
  required VoidCallback onGuestBook,
  required VoidCallback onCompleteProfile,
}) {
  if (!sectionVisibility.showBottomNavigation) return null;

  if (!isAuthenticated) {
    if (event.isCancelled || !event.startTime.isAfter(now)) return null;
    return GuestBookCta(onPressed: onGuestBook, darkSurface: darkSurface);
  }

  if (!sectionVisibility.showConsumerActions) {
    return null;
  }

  if (!eventDetailHasBookingReadyProfile(userProfile, now: now)) {
    if (event.isCancelled || !event.startTime.isAfter(now)) return null;
    return EventBookingDock(
      label: completeProfileLabel,
      onPressed: onCompleteProfile,
    );
  }

  return EventDetailCta(
    event: event,
    userProfile: userProfile!,
    clubId: clubId,
    participation: participation,
    isSaved: isSaved,
    isHosted: isHosted,
    isClubMember: isClubMember,
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

void _openEventProfileCompletion(
  BuildContext context, {
  required String clubId,
  required String eventId,
}) {
  unawaited(
    context.push(
      profileCompletionLocation(
        from: AppDeepLinks.inAppEventPath(clubId: clubId, eventId: eventId),
      ),
    ),
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
    showCatchSnackBar(
      context,
      context.l10n.eventsEventDetailScreenVisiblecopyCouldNotOpenCalendar,
    );
  } on Object catch (error, stackTrace) {
    final actionError = ExternalActionException(
      context.l10n.eventsEventDetailScreenVisiblecopyFailedToAddEvent,
      cause: error,
      stackTrace: stackTrace,
    );

    if (context.mounted) {
      app_ops.logAppError(
        actionError,
        stackTrace: stackTrace,
        context: app_ops.AppErrorContext(
          operation: app_ops.AppOperation.plugin,
          action:
              context.l10n.eventsEventDetailScreenVisiblecopyAddEventToCalendar,
          resource: context.l10n.eventsEventDetailScreenVisiblecopyCalendarLink,
        ),
        logError: ProviderScope.containerOf(
          context,
          listen: false,
        ).read(errorLoggerProvider),
      );

      showCatchSnackBar(
        context,
        context.l10n.eventsEventDetailScreenVisiblecopyCouldNotOpenCalendar,
      );
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

/// Keeps Event Detail inside the runtime's route family. In particular, a
/// host preview must never navigate to the consumer-only organizer route.
Routes eventDetailOrganizerRouteFor({required bool isHostApp}) =>
    isHostApp ? Routes.hostClubDetailScreen : Routes.clubDetailScreen;

CatchAsyncState<T> _catchAsyncState<T>(AsyncValue<T> value) {
  return value.when(
    data: CatchAsyncState<T>.data,
    loading: () => const CatchAsyncState.loading(),
    error: (error, stackTrace) => CatchAsyncState<T>.error(error),
  );
}
