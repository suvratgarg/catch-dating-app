import 'package:catch_dating_app/appUser/domain/app_user.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_booking_controller.g.dart';

@riverpod
class RunBookingController extends _$RunBookingController {
  static final bookMutation = Mutation<void>();
  static final cancelMutation = Mutation<void>();
  static final joinWaitlistMutation = Mutation<void>();
  static final leaveWaitlistMutation = Mutation<void>();

  @override
  void build() {}

  /// Books the user into [run].
  ///
  /// For free runs, calls the [signUpForFreeRun] Cloud Function directly.
  /// For paid runs, opens the Razorpay checkout sheet; on success the
  /// [verifyRazorpayPayment] Cloud Function atomically signs the user up.
  Future<void> book({
    required Run run,
    required AppUser user,
  }) async {
    final paymentRepo = ref.read(paymentRepositoryProvider);

    if (run.isFree) {
      await paymentRepo.bookFreeRun(runId: run.id);
    } else {
      await paymentRepo.processPayment(
        activityId: run.id,
        amountInPaise: run.priceInPaise,
        description: '${run.title} · ${_formatDate(run.startTime)}',
        userName: user.name,
        userEmail: user.email,
        userContact: user.phoneNumber,
      );
    }
  }

  /// Cancels the user's sign-up for [run].
  ///
  /// Note: refund handling (if paid) is managed separately.
  Future<void> cancelBooking({required Run run, required AppUser user}) async {
    await ref.read(runRepositoryProvider).cancelSignUp(
          runId: run.id,
          userId: user.uid,
          gender: user.gender,
        );
  }

  /// Adds the user to the waitlist for a full run.
  Future<void> joinWaitlist({required Run run}) async {
    final uid = ref.read(uidProvider).asData?.value ?? '';
    await ref
        .read(runRepositoryProvider)
        .joinWaitlist(runId: run.id, userId: uid);
  }

  /// Removes the user from the waitlist.
  Future<void> leaveWaitlist({required Run run}) async {
    final uid = ref.read(uidProvider).asData?.value ?? '';
    await ref
        .read(runRepositoryProvider)
        .leaveWaitlist(runId: run.id, userId: uid);
  }

  static String _formatDate(DateTime dt) {
    const weekdays = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${weekdays[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]}';
  }
}
