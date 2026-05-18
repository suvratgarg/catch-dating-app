import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/bottom_cta.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_eligibility.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/event_arrival_action.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/event_joined_celebration_screen.dart';
import 'package:catch_dating_app/host_tools/presentation/host_event_tools.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventDetailCta extends ConsumerWidget {
  const EventDetailCta({
    super.key,
    required this.event,
    required this.userProfile,
    required this.clubId,
    required this.isHost,
    required this.participation,
    this.inviteCode,
    this.now,
  });

  final Event event;
  final UserProfile userProfile;
  final String clubId;
  final bool isHost;
  final EventParticipation? participation;
  final String? inviteCode;
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referenceNow = now ?? DateTime.now();

    if (isHost) {
      return HostEventBottomActions(
        item: HostEventToolItem(
          event: event,
          attendanceState: _hostAttendanceStateForEvent(
            event: event,
            now: referenceNow,
          ),
        ),
        onManageEvent: (event) => context.pushNamed(
          Routes.hostEventManageScreen.name,
          pathParameters: {'clubId': event.clubId, 'eventId': event.id},
        ),
        onTakeAttendance: (event) => context.pushNamed(
          Routes.attendanceSheet.name,
          pathParameters: {'clubId': event.clubId, 'eventId': event.id},
        ),
      );
    }

    final eligibility = _eligibilityForParticipation(
      event: event,
      userProfile: userProfile,
      participation: participation,
      now: referenceNow,
      hasInviteCode: _hasInviteCode(inviteCode),
    );
    final status = _statusForEligibility(eligibility);
    final supportsPaid = ref
        .watch(paymentRepositoryProvider)
        .supportsPaidBookings;
    final quotedPriceInPaise = event.priceInPaiseFor(userProfile);
    final isFreeForViewer = quotedPriceInPaise == 0;

    final bookMutation = ref.watch(EventBookingController.bookMutation);
    final cancelMutation = ref.watch(EventBookingController.cancelMutation);
    final joinWMutation = ref.watch(
      EventBookingController.joinWaitlistMutation,
    );
    final leaveWMutation = ref.watch(
      EventBookingController.leaveWaitlistMutation,
    );

    final errorMutation = [
      bookMutation,
      cancelMutation,
      joinWMutation,
      leaveWMutation,
    ].firstWhere((m) => m.hasError, orElse: () => bookMutation);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (errorMutation.hasError)
          ErrorBanner(
            message: appErrorMessage(
              (errorMutation as MutationError).error,
              context: AppErrorContext.event,
            ),
          ),
        switch (status) {
          EventSignUpStatus.eligible => BottomCTA(
            label: isFreeForViewer
                ? 'Join event — ${event.spotsRemaining} spots left'
                : supportsPaid
                ? 'Book event'
                : 'Unavailable on this platform',
            onPressed:
                bookMutation.isPending || (!isFreeForViewer && !supportsPaid)
                ? null
                : () {
                    final router = GoRouter.maybeOf(context);
                    final navigator = Navigator.of(
                      context,
                      rootNavigator: true,
                    );
                    EventBookingController.bookMutation.run(ref, (tx) async {
                      final data = await tx
                          .get(eventBookingControllerProvider.notifier)
                          .book(
                            event: event,
                            user: userProfile,
                            inviteCode: inviteCode,
                          );
                      if (data != null) {
                        if (router == null) return;
                        unawaited(
                          router.pushNamed(
                            Routes.paymentConfirmationScreen.name,
                            extra: data,
                          ),
                        );
                      } else {
                        unawaited(
                          navigator.push(
                            MaterialPageRoute<void>(
                              fullscreenDialog: true,
                              builder: (routeContext) =>
                                  EventJoinedCelebrationScreen(
                                    event: event,
                                    onViewEvent: () =>
                                        Navigator.of(routeContext).pop(),
                                    onBackHome: () {
                                      Navigator.of(routeContext).pop();
                                      router?.goNamed(
                                        Routes.dashboardScreen.name,
                                      );
                                    },
                                  ),
                            ),
                          ),
                        );
                      }
                    });
                  },
            isLoading: bookMutation.isPending,
            leadingContent: isFreeForViewer
                ? null
                : PriceLeading(
                    price: EventFormatters.priceInPaise(quotedPriceInPaise),
                  ),
          ),
          EventSignUpStatus.signedUp => (() {
            if (isSelfCheckInOpenForParticipationStatus(
              event: event,
              status: participation?.status,
              now: referenceNow,
            )) {
              return const SizedBox.shrink();
            }

            return BottomCTA(
              label: 'Cancel booking',
              onPressed: cancelMutation.isPending
                  ? null
                  : () => EventBookingController.cancelMutation.run(
                      ref,
                      (tx) async => tx
                          .get(eventBookingControllerProvider.notifier)
                          .cancelBooking(event: event),
                    ),
              isLoading: cancelMutation.isPending,
              leadingContent: const BookedLeading(),
            );
          })(),
          EventSignUpStatus.full => BottomCTA(
            label: 'Join waitlist',
            onPressed: joinWMutation.isPending
                ? null
                : () => EventBookingController.joinWaitlistMutation.run(
                    ref,
                    (tx) async => tx
                        .get(eventBookingControllerProvider.notifier)
                        .joinWaitlist(event: event, inviteCode: inviteCode),
                  ),
            isLoading: joinWMutation.isPending,
          ),
          EventSignUpStatus.waitlisted => BottomCTA(
            label: 'Leave waitlist',
            onPressed: leaveWMutation.isPending
                ? null
                : () => EventBookingController.leaveWaitlistMutation.run(
                    ref,
                    (tx) async => tx
                        .get(eventBookingControllerProvider.notifier)
                        .leaveWaitlist(event: event),
                  ),
            isLoading: leaveWMutation.isPending,
          ),
          EventSignUpStatus.attended => BottomCTA(
            label: 'You attended this event',
            onPressed: null,
            leadingContent: const AttendedLeading(),
          ),
          EventSignUpStatus.past => BottomCTA(
            label: 'This event has ended',
            onPressed: null,
          ),
          EventSignUpStatus.ineligible => BottomCTA(
            label: switch (eligibility) {
              AgeTooYoung(:final minAge) => 'Must be $minAge+ to join',
              AgeTooOld(:final maxAge) => 'Must be $maxAge or younger',
              EventInviteRequired() => 'Invite required',
              GenderCapacityReached() => 'Spots for your gender are full',
              _ => 'Not eligible for this event',
            },
            onPressed: null,
          ),
        },
      ],
    );
  }
}

HostEventAttendanceState _hostAttendanceStateForEvent({
  required Event event,
  required DateTime now,
}) {
  if (isHostAttendanceOpen(event: event, now: now)) {
    return HostEventAttendanceState.open;
  }
  if (now.isBefore(hostAttendanceWindowStartsAt(event))) {
    return HostEventAttendanceState.opensLater;
  }
  return HostEventAttendanceState.closed;
}

EventEligibility _eligibilityForParticipation({
  required Event event,
  required UserProfile userProfile,
  required EventParticipation? participation,
  required DateTime now,
  required bool hasInviteCode,
}) {
  return switch (participation?.status) {
    EventParticipationStatus.attended =>
      _hasEventStarted(event, now) ? const Attended() : const AlreadySignedUp(),
    EventParticipationStatus.signedUp => const AlreadySignedUp(),
    EventParticipationStatus.waitlisted => const OnWaitlist(),
    EventParticipationStatus.cancelled ||
    EventParticipationStatus.deleted ||
    null => event.eligibilityFor(
      userProfile,
      now: now,
      hasValidInvite: hasInviteCode,
    ),
  };
}

bool _hasInviteCode(String? inviteCode) =>
    inviteCode != null && inviteCode.trim().isNotEmpty;

bool _hasEventStarted(Event event, DateTime now) =>
    !event.startTime.isAfter(now);

EventSignUpStatus _statusForEligibility(EventEligibility eligibility) {
  return switch (eligibility) {
    Attended() => EventSignUpStatus.attended,
    AlreadySignedUp() => EventSignUpStatus.signedUp,
    EventPast() => EventSignUpStatus.past,
    OnWaitlist() => EventSignUpStatus.waitlisted,
    EventFull() => EventSignUpStatus.full,
    Eligible() => EventSignUpStatus.eligible,
    _ => EventSignUpStatus.ineligible,
  };
}

class PriceLeading extends StatelessWidget {
  const PriceLeading({super.key, required this.price});

  final String price;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(price, style: CatchTextStyles.titleL(context)),
        Text(
          'per person',
          style: CatchTextStyles.bodyS(
            context,
            color: CatchTokens.of(context).ink2,
          ),
        ),
      ],
    );
  }
}

class BookedLeading extends StatelessWidget {
  const BookedLeading({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, color: t.primary, size: 18),
        const SizedBox(width: 6),
        Text("You're in!", style: CatchTextStyles.labelL(context)),
      ],
    );
  }
}

class AttendedLeading extends StatelessWidget {
  const AttendedLeading({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.directions_run_rounded, color: t.primary, size: 18),
        const SizedBox(width: 6),
        Text('Completed', style: CatchTextStyles.labelL(context)),
      ],
    );
  }
}
