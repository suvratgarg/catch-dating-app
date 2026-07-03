import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/events/data/event_check_in_location_service.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_booking_controller.g.dart';

/// **Pattern A: Action controller + static Mutations**
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
class EventBookingController extends _$EventBookingController {
  static final bookMutation = Mutation<void>();
  static final cancelMutation = Mutation<void>();
  static final joinWaitlistMutation = Mutation<void>();
  static final leaveWaitlistMutation = Mutation<void>();
  static final acceptWaitlistOfferMutation = Mutation<void>();
  static final declineWaitlistOfferMutation = Mutation<void>();
  static final selfCheckInMutation = Mutation<void>();

  @override
  void build() {}

  /// Books the user into [event].
  ///
  /// For free events, calls the [signUpForFreeEvent] Cloud Function directly.
  /// For paid events, starts the currency-appropriate payment flow; successful
  /// provider confirmation atomically signs the user up.
  ///
  /// Returns [PaymentConfirmationData] for paid events so the caller can
  /// navigate to the confirmation screen. Returns `null` for free events.
  Future<PaymentConfirmationData?> book({
    required Event event,
    required UserProfile user,
    String? inviteCode,
    String? inviteLinkId,
  }) async {
    _requireSignedIn(action: 'book an event');
    final paymentRepo = ref.read(paymentRepositoryProvider);
    final quotedPriceInPaise = event.priceInPaiseFor(user);

    if (quotedPriceInPaise == 0) {
      await paymentRepo.bookFreeEvent(
        eventId: event.id,
        inviteCode: inviteCode,
        inviteLinkId: inviteLinkId,
      );
      return null;
    } else {
      if (!paymentRepo.supportsPaidBookingsForCurrency(event.currency)) {
        throw PaidBookingUnsupportedException(
          message: 'Paid bookings in ${event.currency} are not available yet.',
        );
      }
      return paymentRepo.processPayment(
        eventId: event.id,
        currencyCode: event.currency,
        description: '${event.title} · ${event.shortDateLabel}',
        userName: user.name,
        userEmail: user.email,
        userContact: user.phoneNumber,
        inviteCode: inviteCode,
        inviteLinkId: inviteLinkId,
      );
    }
  }

  /// Cancels the user's sign-up for [event] via the [cancelEventSignUp] Cloud
  /// Function, which atomically updates their event participation edge and
  /// decrements aggregate booking projections.
  Future<void> cancelBooking({required Event event}) async {
    _requireSignedIn(action: 'cancel a booking');
    await ref
        .read(eventRepositoryProvider)
        .cancelSignUpViaFunction(eventId: event.id);
  }

  /// Adds the user to the waitlist for a full event.
  Future<void> joinWaitlist({
    required Event event,
    String? inviteCode,
    String? inviteLinkId,
  }) async {
    _requireSignedIn(action: 'join a waitlist');
    await ref
        .read(eventRepositoryProvider)
        .joinWaitlistViaFunction(
          eventId: event.id,
          inviteCode: inviteCode,
          inviteLinkId: inviteLinkId,
        );
  }

  /// Removes the user from the waitlist.
  Future<void> leaveWaitlist({required Event event}) async {
    _requireSignedIn(action: 'leave a waitlist');
    await ref.read(eventRepositoryProvider).leaveWaitlist(eventId: event.id);
  }

  /// Accepts an expiring waitlist offer. Free offers book immediately; paid
  /// offers unlock and start the existing checkout flow.
  Future<PaymentConfirmationData?> acceptWaitlistOffer({
    required Event event,
    required UserProfile user,
    String? inviteCode,
    String? inviteLinkId,
  }) async {
    _requireSignedIn(action: 'accept a waitlist offer');
    final response = await ref
        .read(eventRepositoryProvider)
        .acceptWaitlistOffer(eventId: event.id);
    if (response.requiresPayment) {
      return book(
        event: event,
        user: user,
        inviteCode: inviteCode,
        inviteLinkId: inviteLinkId,
      );
    }
    return null;
  }

  /// Declines an expiring waitlist offer without leaving the waitlist.
  Future<void> declineWaitlistOffer({required Event event}) async {
    _requireSignedIn(action: 'decline a waitlist offer');
    await ref
        .read(eventRepositoryProvider)
        .declineWaitlistOffer(eventId: event.id);
  }

  /// Self-check-in for the signed-in user via GPS-verified proximity.
  ///
  /// Reads the device's current location and passes it to the
  /// [selfCheckInAttendance] Cloud Function, which validates that the user
  /// is within the shared business-rules proximity and check-in window around
  /// the event start time.
  Future<void> selfCheckIn({required String eventId}) async {
    _requireSignedIn(action: 'check in to an event');

    // On failure (permission denied, GPS off, location services disabled), let
    // the error propagate into the mutation error state so the UI can display it.
    final position = await ref
        .read(eventCheckInLocationServiceProvider)
        .getCurrentLocation();

    await ref
        .read(eventRepositoryProvider)
        .selfCheckInAttendance(
          eventId: eventId,
          latitude: position.latitude,
          longitude: position.longitude,
        );
  }

  String _requireSignedIn({required String action}) {
    return requireSignedInUid(ref, action: action);
  }
}
