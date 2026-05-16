import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/bottom_cta.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/host_tools/presentation/host_run_tools.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_eligibility.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/runs/presentation/run_arrival_action.dart';
import 'package:catch_dating_app/runs/presentation/run_booking_controller.dart';
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

    if (isHost) {
      return HostRunBottomActions(
        item: HostRunToolItem(
          run: run,
          attendanceState: _hostAttendanceStateForRun(
            run: run,
            now: referenceNow,
          ),
        ),
        onManageRun: (run) => context.pushNamed(
          Routes.hostRunManageScreen.name,
          pathParameters: {'runClubId': run.runClubId, 'runId': run.id},
        ),
        onTakeAttendance: (run) => context.pushNamed(
          Routes.attendanceSheet.name,
          pathParameters: {'runClubId': run.runClubId, 'runId': run.id},
        ),
      );
    }

    final eligibility = _eligibilityForParticipation(
      run: run,
      userProfile: userProfile,
      participation: participation,
      now: referenceNow,
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
            message: appErrorMessage(
              (errorMutation as MutationError).error,
              context: AppErrorContext.run,
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
                    final router = GoRouter.maybeOf(context);
                    final navigator = Navigator.of(
                      context,
                      rootNavigator: true,
                    );
                    RunBookingController.bookMutation.run(ref, (tx) async {
                      final data = await tx
                          .get(runBookingControllerProvider.notifier)
                          .book(run: run, user: userProfile);
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
                                  RunJoinedCelebrationScreen(
                                    run: run,
                                    onViewRun: () =>
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

HostRunAttendanceState _hostAttendanceStateForRun({
  required Run run,
  required DateTime now,
}) {
  if (isHostAttendanceOpen(run: run, now: now)) {
    return HostRunAttendanceState.open;
  }
  if (now.isBefore(hostAttendanceWindowStartsAt(run))) {
    return HostRunAttendanceState.opensLater;
  }
  return HostRunAttendanceState.closed;
}

RunEligibility _eligibilityForParticipation({
  required Run run,
  required UserProfile userProfile,
  required RunParticipation? participation,
  required DateTime now,
}) {
  return switch (participation?.status) {
    RunParticipationStatus.attended =>
      _hasRunStarted(run, now) ? const Attended() : const AlreadySignedUp(),
    RunParticipationStatus.signedUp => const AlreadySignedUp(),
    RunParticipationStatus.waitlisted => const OnWaitlist(),
    RunParticipationStatus.cancelled ||
    RunParticipationStatus.deleted ||
    null => run.eligibilityFor(userProfile, now: now),
  };
}

bool _hasRunStarted(Run run, DateTime now) => !run.startTime.isAfter(now);

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
