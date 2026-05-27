import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/bottom_cta.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_domain_readiness.dart';
import 'package:catch_dating_app/events/domain/event_eligibility.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/event_arrival_action.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/event_joined_celebration_screen.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_capacity_presenter.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/domain/profile_readiness.dart';
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
    required this.participation,
    this.inviteCode,
    this.now,
  });

  final Event event;
  final UserProfile userProfile;
  final String clubId;
  final EventParticipation? participation;
  final String? inviteCode;
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referenceNow = now ?? DateTime.now();

    final eligibility = _eligibilityForParticipation(
      event: event,
      userProfile: userProfile,
      participation: participation,
      now: referenceNow,
      hasInviteCode: _hasInviteCode(inviteCode),
    );
    final status = _statusForEligibility(eligibility);
    final requiresHostApproval =
        event.effectiveEventPolicy.admissionPolicy.manualApprovalRequired;
    final hasApprovedJoinRequest =
        requiresHostApproval &&
        participation?.status == EventParticipationStatus.waitlisted &&
        participation?.hasHostApproval == true;
    final canRequestHostApproval =
        requiresHostApproval && eligibility is GenderCapacityReached;
    final supportsPaid = ref
        .watch(paymentRepositoryProvider)
        .supportsPaidBookingsForCurrency(event.currency);
    final quotedPriceInPaise = event.priceInPaiseFor(userProfile);
    final isFreeForViewer = quotedPriceInPaise == 0;
    final needsRunPreferences =
        event.requiresRunPreferences && !userProfile.hasCurrentRunPreferences;

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
        if (canRequestHostApproval)
          BottomCTA(
            label: needsRunPreferences
                ? 'Set run preferences'
                : 'Request to join',
            onPressed: joinWMutation.isPending
                ? null
                : needsRunPreferences
                ? () => _openRunPreferencesGate(context)
                : () => EventBookingController.joinWaitlistMutation.run(
                    ref,
                    (tx) async => tx
                        .get(eventBookingControllerProvider.notifier)
                        .joinWaitlist(event: event, inviteCode: inviteCode),
                  ),
            isLoading: joinWMutation.isPending,
          )
        else
          switch (status) {
            EventSignUpStatus.eligible => BottomCTA(
              label: !isFreeForViewer && !supportsPaid
                  ? 'Paid booking unavailable'
                  : needsRunPreferences
                  ? 'Set run preferences'
                  : hasApprovedJoinRequest
                  ? isFreeForViewer
                        ? 'Join approved event'
                        : 'Complete approved booking'
                  : isFreeForViewer
                  ? 'Join event — ${EventCapacityPresenter(event).joinCtaAvailabilityLabel}'
                  : 'Book event',
              onPressed:
                  bookMutation.isPending || (!isFreeForViewer && !supportsPaid)
                  ? null
                  : needsRunPreferences
                  ? () => _openRunPreferencesGate(context)
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
                      price: EventFormatters.priceInPaise(
                        quotedPriceInPaise,
                        currencyCode: event.currency,
                      ),
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
              label: needsRunPreferences
                  ? 'Set run preferences'
                  : requiresHostApproval
                  ? 'Request to join'
                  : 'Join waitlist',
              onPressed: joinWMutation.isPending
                  ? null
                  : needsRunPreferences
                  ? () => _openRunPreferencesGate(context)
                  : () => EventBookingController.joinWaitlistMutation.run(
                      ref,
                      (tx) async => tx
                          .get(eventBookingControllerProvider.notifier)
                          .joinWaitlist(event: event, inviteCode: inviteCode),
                    ),
              isLoading: joinWMutation.isPending,
            ),
            EventSignUpStatus.waitlisted => BottomCTA(
              label: requiresHostApproval
                  ? 'Withdraw request'
                  : 'Leave waitlist',
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
                GenderCapacityReached() =>
                  requiresHostApproval
                      ? 'Request required'
                      : 'Spots for your gender are full',
                _ => 'Not eligible for this event',
              },
              onPressed: null,
            ),
          },
      ],
    );
  }
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
    EventParticipationStatus.waitlisted
        when participation?.hasHostApproval == true =>
      _hasEventStarted(event, now) ? const EventPast() : const Eligible(),
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

void _openRunPreferencesGate(BuildContext context) {
  final router = GoRouter.maybeOf(context);
  if (router == null) return;
  router.push(
    runPreferencesCompletionLocation(
      from: GoRouterState.of(context).uri.toString(),
    ),
  );
}

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
          style: CatchTextStyles.supporting(
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
        Icon(CatchIcons.checkCircleRounded, color: t.primary, size: 18),
        gapW6,
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
        Icon(CatchIcons.directionsRunRounded, color: t.primary, size: 18),
        gapW6,
        Text('Completed', style: CatchTextStyles.labelL(context)),
      ],
    );
  }
}
