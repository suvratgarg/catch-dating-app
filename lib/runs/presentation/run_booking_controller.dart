import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_booking_controller.g.dart';

/// **Pattern B: Stateless controller + static Mutations**
///
/// This is the most common mutation pattern in the app (6 controllers use it):
/// - [build()] returns `void` — the controller holds no Riverpod state.
/// - [Mutation]s (`bookMutation`, `cancelMutation`, etc.) are `static final`
///   fields that track the lifecycle of single-shot operations.
/// - The UI watches mutations directly (e.g. `ref.watch(controller.mutation)`)
///   and checks `.isPending`, `.hasError`, `.isSuccess`.
/// - Controller methods delegate to repositories and let errors propagate
///   into the Mutation error state automatically.
///
/// **When to use this pattern:** Single-shot user actions (book, cancel, join,
/// leave, submit, delete) where the UI needs to show loading/error/success
/// state for a specific action.
@riverpod
class RunBookingController extends _$RunBookingController {
  static final bookMutation = Mutation<void>();
  static final cancelMutation = Mutation<void>();
  static final joinWaitlistMutation = Mutation<void>();
  static final leaveWaitlistMutation = Mutation<void>();
  static final markAttendanceMutation = Mutation<void>();
  static final selfCheckInMutation = Mutation<void>();

  @override
  void build() {}

  /// Books the user into [run].
  ///
  /// For free runs, calls the [signUpForFreeRun] Cloud Function directly.
  /// For paid runs, opens the Razorpay checkout sheet; on success the
  /// [verifyRazorpayPayment] Cloud Function atomically signs the user up.
  ///
  /// Returns [PaymentConfirmationData] for paid runs so the caller can
  /// navigate to the confirmation screen. Returns `null` for free runs.
  Future<PaymentConfirmationData?> book({
    required Run run,
    required UserProfile user,
  }) async {
    _requireSignedIn(action: 'book a run');
    final paymentRepo = ref.read(paymentRepositoryProvider);

    if (run.isFree) {
      await paymentRepo.bookFreeRun(runId: run.id);
      return null;
    } else {
      return paymentRepo.processPayment(
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

  /// Toggles attendance for a single user on a run.
  /// Only callable by the club host.
  Future<void> markAttendance({
    required String runId,
    required String userId,
  }) async {
    _requireSignedIn(action: 'mark attendance');
    await ref
        .read(runRepositoryProvider)
        .markAttendance(runId: runId, userId: userId);
  }

  /// Self-check-in for the signed-in user via GPS-verified proximity.
  ///
  /// Reads the device's current location and passes it to the
  /// [selfCheckInAttendance] Cloud Function, which validates that the user
  /// is within 200 m of the run's meeting point during the 30-minute
  /// check-in window around the run start time.
  Future<void> selfCheckIn({required String runId}) async {
    _requireSignedIn(action: 'check in to a run');

    // Obtain current position. On failure (permission denied, GPS off,
    // location services disabled), let the error propagate into the
    // mutation error state so the UI can display it.
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        // 15-second timeout — if GPS can't get a fix, fail fast so the
        // user isn't staring at a spinner.
        timeLimit: Duration(seconds: 15),
      ),
    );

    await ref.read(runRepositoryProvider).selfCheckInAttendance(
      runId: runId,
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  String _requireSignedIn({required String action}) {
    return requireSignedInUid(ref, action: action);
  }
}
