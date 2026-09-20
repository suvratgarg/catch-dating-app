part of 'event_detail_screen.dart';

mixin _EventDetailScreenActions on ConsumerState<EventDetailScreen> {
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
    final failureReason = context
        .l10n
        .eventsEventDetailScreenVisiblecopyEventdetailscreenTogglesavedeventFailed;

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
                .logError(error, stackTrace, reason: failureReason);
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

bool _showsEventDetailBottomNavigation({
  required Event event,
  required UserProfile? userProfile,
  required bool isAuthenticated,
  required OrganizerSupplyCapabilities organizerCapabilities,
  required DateTime now,
  required EventDetailSectionVisibilityState sectionVisibility,
}) {
  if (!organizerCapabilities.bookable) return false;
  if (!sectionVisibility.showBottomNavigation) return false;

  if (!isAuthenticated) {
    return !event.isCancelled && event.startTime.isAfter(now);
  }

  if (!sectionVisibility.showConsumerActions) {
    return false;
  }

  if (!eventDetailHasBookingReadyProfile(userProfile, now: now)) {
    return !event.isCancelled && event.startTime.isAfter(now);
  }

  return true;
}
