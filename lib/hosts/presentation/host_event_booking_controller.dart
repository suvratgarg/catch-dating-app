import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_event_booking_controller.g.dart';

@riverpod
class HostEventBookingController extends _$HostEventBookingController {
  static final createWaitlistOfferMutation = Mutation<void>();
  static final approveJoinRequestMutation = Mutation<void>();
  static final declineJoinRequestMutation = Mutation<void>();
  static final markAttendanceMutation = Mutation<void>();
  static final hostCancelEventMutation = Mutation<void>();
  static final deleteEventMutation = Mutation<void>();
  static final updateHostedEventMutation = Mutation<void>();

  static String waitlistOfferMutationKey({
    required String eventId,
    required String userId,
  }) => '$eventId:waitlist-offer:$userId';

  static String bulkWaitlistOfferMutationKey({required String eventId}) =>
      '$eventId:waitlist-offer:bulk';

  static String approveJoinRequestMutationKey({
    required String eventId,
    required String userId,
  }) => '$eventId:approve-request:$userId';

  static String declineJoinRequestMutationKey({
    required String eventId,
    required String userId,
  }) => '$eventId:decline-request:$userId';

  static String markAttendanceMutationKey({
    required String eventId,
    required String userId,
  }) => '$eventId:attendance:$userId';

  @override
  void build() {}

  /// Cancels an event hosted by the signed-in user.
  ///
  /// The Cloud Function enforces host ownership and keeps audit/history
  /// records intact.
  Future<void> cancelHostedEvent({required Event event, String? reason}) async {
    _requireSignedIn(action: 'cancel a hosted event');
    await ref
        .read(eventRepositoryProvider)
        .cancelEvent(eventId: event.id, reason: reason);
  }

  /// Permanently deletes an unused hosted event.
  ///
  /// The Cloud Function rejects events with bookings, payments, reviews, or
  /// other activity. Those events should be cancelled instead.
  Future<void> deleteHostedEvent({required Event event}) async {
    _requireSignedIn(action: 'delete a hosted event');
    await ref.read(eventRepositoryProvider).deleteEvent(eventId: event.id);
  }

  /// Updates host-editable event details via the server-owned callable.
  ///
  /// The backend enforces host ownership, rejects cancelled events, and blocks
  /// schedule changes once participants or waitlisted users exist.
  Future<void> updateHostedEvent({
    required Event event,
    bool includePolicy = false,
    String? inviteCode,
  }) async {
    _requireSignedIn(action: 'edit a hosted event');
    await ref
        .read(eventRepositoryProvider)
        .updateEventDetails(
          event: event,
          includePolicy: includePolicy,
          inviteCode: inviteCode,
        );
  }

  /// Offers one waitlisted person an expiring spot.
  Future<void> createWaitlistOffer({
    required String eventId,
    required String userId,
  }) => createWaitlistOffers(eventId: eventId, userIds: [userId]);

  /// Offers multiple waitlisted people expiring spots in roster order.
  Future<void> createWaitlistOffers({
    required String eventId,
    required List<String> userIds,
  }) async {
    _requireSignedIn(action: 'offer a waitlist spot');
    if (userIds.isEmpty) return;
    await ref
        .read(eventRepositoryProvider)
        .createWaitlistOffers(eventId: eventId, userIds: userIds);
  }

  /// Approves a request-to-join participation. Free approved requests are
  /// booked by the backend; paid approved requests can complete payment.
  Future<void> approveJoinRequest({
    required String eventId,
    required String userId,
  }) async {
    _requireSignedIn(action: 'approve a join request');
    await ref
        .read(eventRepositoryProvider)
        .decideJoinRequest(
          eventId: eventId,
          userId: userId,
          decision: 'approve',
        );
  }

  /// Declines a request-to-join participation.
  Future<void> declineJoinRequest({
    required String eventId,
    required String userId,
  }) async {
    _requireSignedIn(action: 'decline a join request');
    await ref
        .read(eventRepositoryProvider)
        .decideJoinRequest(
          eventId: eventId,
          userId: userId,
          decision: 'decline',
        );
  }

  /// Toggles attendance for a single user on an event.
  /// Only callable by the club host.
  Future<void> markAttendance({
    required String eventId,
    required String userId,
  }) async {
    _requireSignedIn(action: 'mark attendance');
    await ref
        .read(eventRepositoryProvider)
        .markAttendance(eventId: eventId, userId: userId);
  }

  String _requireSignedIn({required String action}) {
    return requireSignedInUid(ref, action: action);
  }
}
