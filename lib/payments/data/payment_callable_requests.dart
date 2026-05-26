export 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show VerifyRazorpayPaymentCallableRequest;

// EventBookingCallableRequest and CreateRazorpayOrderCallableRequest are
// hand-written because they normalize inviteCode via .trim() before
// serialization.
final class EventBookingCallableRequest {
  const EventBookingCallableRequest({required this.eventId, this.inviteCode});

  final String eventId;
  final String? inviteCode;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'inviteCode': ?inviteCode?.trim(),
  };
}

final class CreateRazorpayOrderCallableRequest {
  const CreateRazorpayOrderCallableRequest({
    required this.eventId,
    this.inviteCode,
  });

  final String eventId;
  final String? inviteCode;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'inviteCode': ?inviteCode?.trim(),
  };
}
