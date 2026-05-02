import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/bottom_cta.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_eligibility.dart';
import 'package:catch_dating_app/runs/presentation/run_booking_controller.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
  });

  final Run run;
  final UserProfile userProfile;
  final String runClubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubAsync = ref.watch(fetchRunClubProvider(runClubId));
    final uid = ref.watch(uidProvider).asData?.value;
    final isHost =
        uid != null && clubAsync.asData?.value?.hostUserId == uid;
    final checkinOpen = DateTime.now()
        .isAfter(run.startTime.subtract(const Duration(minutes: 10)));

    if (isHost && checkinOpen) {
      return BottomCTA(
        label: 'Take Attendance',
        onPressed: () => GoRouter.of(context).pushNamed(
          Routes.attendanceSheet.name,
          pathParameters: {
            'runClubId': runClubId,
            'runId': run.id,
          },
        ),
        leadingContent: Icon(
          Icons.checklist_rounded,
          color: CatchTokens.of(context).primary,
          size: 18,
        ),
      );
    }

    final status = run.statusFor(userProfile);
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
          CatchErrorBanner(
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
                    RunBookingController.bookMutation.run(
                      ref,
                      (tx) async {
                        final data = await tx
                            .get(runBookingControllerProvider.notifier)
                            .book(run: run, user: userProfile);
                        if (data != null && context.mounted) {
                          GoRouter.of(context).pushNamed(
                            Routes.paymentConfirmationScreen.name,
                            extra: data,
                          );
                        }
                      },
                    );
                  },
            isLoading: bookMutation.isPending,
            leadingContent: run.isFree
                ? null
                : PriceLeading(
                    price: RunFormatters.priceInPaise(run.priceInPaise),
                  ),
          ),
          RunSignUpStatus.signedUp => BottomCTA(
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
          ),
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
            label: switch (run.eligibilityFor(userProfile)) {
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

String runBookingErrorMessage(Object error) {
  if (error is AppException) {
    return error.message;
  }
  if (error is FirebaseFunctionsException) {
    if (error.code == 'unauthenticated') {
      return const SignInRequiredException('book a run').message;
    }

    final message = error.message;
    if (message != null && message.trim().isNotEmpty) {
      return message.trim();
    }
  }
  if (error is StateError && error.message.isNotEmpty) {
    return error.message;
  }
  return 'Unable to update this booking right now.';
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
