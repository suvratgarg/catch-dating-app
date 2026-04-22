import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/bottom_cta.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_eligibility.dart';
import 'package:catch_dating_app/runs/presentation/run_booking_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunDetailCta extends ConsumerWidget {
  const RunDetailCta({
    super.key,
    required this.run,
    required this.appUser,
  });

  final Run run;
  final AppUser appUser;

  static String _fmtPrice(int paise) {
    final r = paise / 100;
    return r == r.roundToDouble() ? '₹${r.round()}' : '₹${r.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = run.statusFor(appUser);
    final supportsPaid =
        ref.watch(paymentRepositoryProvider).supportsPaidBookings;

    final bookMutation = ref.watch(RunBookingController.bookMutation);
    final cancelMutation = ref.watch(RunBookingController.cancelMutation);
    final joinWMutation = ref.watch(RunBookingController.joinWaitlistMutation);
    final leaveWMutation =
        ref.watch(RunBookingController.leaveWaitlistMutation);

    final errorMutation =
        [bookMutation, cancelMutation, joinWMutation, leaveWMutation]
            .firstWhere((m) => m.hasError, orElse: () => bookMutation);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (errorMutation.hasError)
          CatchErrorBanner(
              message: (errorMutation as MutationError).error.toString()),
        switch (status) {
          RunSignUpStatus.eligible => BottomCTA(
              label: run.isFree
                  ? 'Join run — ${run.capacityLimit - run.signedUpCount} spots left'
                  : supportsPaid
                      ? 'Book run'
                      : 'Unavailable on this platform',
              onPressed:
                  bookMutation.isPending || (!run.isFree && !supportsPaid)
                      ? null
                      : () => RunBookingController.bookMutation.run(
                            ref,
                            (tx) async => tx
                                .get(runBookingControllerProvider.notifier)
                                .book(run: run, user: appUser),
                          ),
              isLoading: bookMutation.isPending,
              leadingContent: run.isFree
                  ? null
                  : PriceLeading(price: _fmtPrice(run.priceInPaise)),
            ),
          RunSignUpStatus.signedUp => BottomCTA(
              label: 'Cancel booking',
              onPressed: cancelMutation.isPending
                  ? null
                  : () => RunBookingController.cancelMutation.run(
                        ref,
                        (tx) async => tx
                            .get(runBookingControllerProvider.notifier)
                            .cancelBooking(run: run, user: appUser),
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
              label: switch (run.eligibilityFor(appUser)) {
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

class PriceLeading extends StatelessWidget {
  const PriceLeading({super.key, required this.price});

  final String price;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(price, style: CatchTextStyles.displaySm(context)),
        Text('per person',
            style: CatchTextStyles.caption(context,
                color: CatchTokens.of(context).ink2)),
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
        Text("You're in!", style: CatchTextStyles.labelMd(context)),
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
        Text('Completed', style: CatchTextStyles.labelMd(context)),
      ],
    );
  }
}
