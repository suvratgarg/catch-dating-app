import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
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
  Future<void> book({required Run run, required UserProfile user}) async {
    _requireSignedIn(action: 'book a run');
    final paymentRepo = ref.read(paymentRepositoryProvider);

    if (run.isFree) {
      await paymentRepo.bookFreeRun(runId: run.id);
    } else {
      await paymentRepo.processPayment(
        runId: run.id,
        description: '${run.title} · ${run.shortDateLabel}',
        userName: user.name,
        userEmail: user.email,
        userContact: user.phoneNumber,
      );
    }
  }

  /// Cancels the user's sign-up for [run] via the [cancelRunSignUp] Cloud
  /// Function, which atomically removes them from [signedUpUserIds] and
  /// decrements their gender count.
  Future<void> cancelBooking({required Run run}) async {
    _requireSignedIn(action: 'cancel a booking');
    await ref
        .read(runRepositoryProvider)
        .cancelSignUpViaFunction(runId: run.id);
  }

  /// Adds the user to the waitlist for a full run.
  Future<void> joinWaitlist({required Run run}) async {
    _requireSignedIn(action: 'join a waitlist');
    await ref
        .read(runRepositoryProvider)
        .joinWaitlistViaFunction(runId: run.id);
  }

  /// Removes the user from the waitlist.
  Future<void> leaveWaitlist({required Run run}) async {
    final uid = _requireSignedIn(action: 'leave a waitlist');
    await ref
        .read(runRepositoryProvider)
        .leaveWaitlist(runId: run.id, userId: uid);
  }

  String _requireSignedIn({required String action}) {
    try {
      return requireSignedInUid(ref, action: action);
    } on StateError {
      throw SignInRequiredException(action);
    }
  }
}
