import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/bottom_cta.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_eligibility.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/runs/presentation/run_arrival_action.dart';
import 'package:catch_dating_app/runs/presentation/run_booking_controller.dart';
import 'package:catch_dating_app/runs/presentation/run_booking_error_message.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:catch_dating_app/runs/presentation/run_joined_celebration_screen.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RunDetailCta extends ConsumerWidget {
  const RunDetailCta({
    super.key,
    required this.run,
    required this.userProfile,
    required this.runClubId,
    required this.isHost,
    required this.participation,
    this.now,
  });

  final Run run;
  final UserProfile userProfile;
  final String runClubId;
  final bool isHost;
  final RunParticipation? participation;
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referenceNow = now ?? DateTime.now();

    if (isHost && isHostAttendanceOpen(run: run, now: referenceNow)) {
      return const SizedBox.shrink();
    }

    final eligibility = _eligibilityForParticipation(
      run: run,
      userProfile: userProfile,
      participation: participation,
    );
    final status = _statusForEligibility(eligibility);
    final supportsPaid = ref
        .watch(paymentRepositoryProvider)
        .supportsPaidBookings;

    final bookMutation = ref.watch(RunBookingController.bookMutation);
    final cancelMutation = ref.watch(RunBookingController.cancelMutation);
    final joinWMutation = ref.watch(RunBookingController.joinWaitlistMutation);
    final leaveWMutation = ref.watch(
      RunBookingController.leaveWaitlistMutation,
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
            message: runBookingErrorMessage(
              (errorMutation as MutationError).error,
            ),
          ),
        switch (status) {
          RunSignUpStatus.eligible => BottomCTA(
            label: run.isFree
                ? 'Join run — ${run.spotsRemaining} spots left'
                : supportsPaid
                ? 'Book run'
                : 'Unavailable on this platform',
            onPressed: bookMutation.isPending || (!run.isFree && !supportsPaid)
                ? null
                : () {
                    RunBookingController.bookMutation.run(ref, (tx) async {
                      final data = await tx
                          .get(runBookingControllerProvider.notifier)
                          .book(run: run, user: userProfile);
                      if (!context.mounted) return;
                      if (data != null) {
                        unawaited(
                          GoRouter.of(context).pushNamed(
                            Routes.paymentConfirmationScreen.name,
                            extra: data,
                          ),
                        );
                      } else {
                        unawaited(
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              fullscreenDialog: true,
                              builder: (routeContext) =>
                                  RunJoinedCelebrationScreen(
                                    run: run,
                                    onViewRun: () =>
                                        Navigator.of(routeContext).pop(),
                                    onBackHome: () {
                                      Navigator.of(routeContext).pop();
                                      GoRouter.of(
                                        context,
                                      ).goNamed(Routes.dashboardScreen.name);
                                    },
                                  ),
                            ),
                          ),
                        );
                      }
                    });
                  },
            isLoading: bookMutation.isPending,
            leadingContent: run.isFree
                ? null
                : PriceLeading(
                    price: RunFormatters.priceInPaise(run.priceInPaise),
                  ),
          ),
          RunSignUpStatus.signedUp => (() {
            if (isSelfCheckInOpenForParticipationStatus(
              run: run,
              status: participation?.status,
              now: referenceNow,
            )) {
              return const SizedBox.shrink();
            }

            return BottomCTA(
              label: 'Cancel booking',
              onPressed: cancelMutation.isPending
                  ? null
                  : () => RunBookingController.cancelMutation.run(
                      ref,
                      (tx) async => tx
                          .get(runBookingControllerProvider.notifier)
                          .cancelBooking(run: run),
                    ),
              isLoading: cancelMutation.isPending,
              leadingContent: const BookedLeading(),
            );
          })(),
          RunSignUpStatus.full => BottomCTA(
            label: 'Join waitlist',
            onPressed: joinWMutation.isPending
                ? null
                : () => RunBookingController.joinWaitlistMutation.run(
                    ref,
                    (tx) async => tx
                        .get(runBookingControllerProvider.notifier)
                        .joinWaitlist(run: run),
                  ),
            isLoading: joinWMutation.isPending,
          ),
          RunSignUpStatus.waitlisted => BottomCTA(
            label: 'Leave waitlist',
            onPressed: leaveWMutation.isPending
                ? null
                : () => RunBookingController.leaveWaitlistMutation.run(
                    ref,
                    (tx) async => tx
                        .get(runBookingControllerProvider.notifier)
                        .leaveWaitlist(run: run),
                  ),
            isLoading: leaveWMutation.isPending,
          ),
          RunSignUpStatus.attended => BottomCTA(
            label: 'You attended this run',
            onPressed: null,
            leadingContent: const AttendedLeading(),
          ),
          RunSignUpStatus.past => BottomCTA(
            label: 'This run has ended',
            onPressed: null,
          ),
          RunSignUpStatus.ineligible => BottomCTA(
            label: switch (eligibility) {
              AgeTooYoung(:final minAge) => 'Must be $minAge+ to join',
              AgeTooOld(:final maxAge) => 'Must be $maxAge or younger',
              GenderCapacityReached() => 'Spots for your gender are full',
              _ => 'Not eligible for this run',
            },
            onPressed: null,
          ),
        },
      ],
    );
  }
}

RunEligibility _eligibilityForParticipation({
  required Run run,
  required UserProfile userProfile,
  required RunParticipation? participation,
}) {
  return switch (participation?.status) {
    RunParticipationStatus.attended => const Attended(),
    RunParticipationStatus.signedUp => const AlreadySignedUp(),
    RunParticipationStatus.waitlisted => const OnWaitlist(),
    RunParticipationStatus.cancelled ||
    RunParticipationStatus.deleted ||
    null => _eligibilityForFreshViewer(run: run, userProfile: userProfile),
  };
}

RunEligibility _eligibilityForFreshViewer({
  required Run run,
  required UserProfile userProfile,
}) {
  if (!run.isUpcoming) return const RunPast();
  if (userProfile.age < run.constraints.minAge) {
    return AgeTooYoung(run.constraints.minAge);
  }
  if (userProfile.age > run.constraints.maxAge) {
    return AgeTooOld(run.constraints.maxAge);
  }
  final cap = run.constraints.maxForGender(userProfile.gender);
  if (cap != null && (run.genderCounts[userProfile.gender.name] ?? 0) >= cap) {
    return const GenderCapacityReached();
  }
  if (run.isFull) return const RunFull();
  return const Eligible();
}

RunSignUpStatus _statusForEligibility(RunEligibility eligibility) {
  return switch (eligibility) {
    Attended() => RunSignUpStatus.attended,
    AlreadySignedUp() => RunSignUpStatus.signedUp,
    RunPast() => RunSignUpStatus.past,
    OnWaitlist() => RunSignUpStatus.waitlisted,
    RunFull() => RunSignUpStatus.full,
    Eligible() => RunSignUpStatus.eligible,
    _ => RunSignUpStatus.ineligible,
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
