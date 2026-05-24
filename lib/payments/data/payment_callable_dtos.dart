// Re-export generated callable request classes for payments.
export 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show VerifyRazorpayPaymentCallableRequest;

// EventBookingCallableRequest and CreateRazorpayOrderCallableRequest are
// intentionally kept hand-written: contracts/callables/ has no payload schemas
// for these callables yet (the verify side does), and the hand-written code
// normalizes inviteCode via .trim() before serialization. See backlog item
// CONTRACT-DART-GEN-001 for the path to schema-first generation here.
//
// RazorpayOrderCallableResponse and the format-exception type keep their
// hand-written parsers; response decoding is not yet generated.

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

final class RazorpayOrderCallableResponse {
  const RazorpayOrderCallableResponse({
    required this.orderId,
    required this.amountInPaise,
    required this.currency,
  });

  factory RazorpayOrderCallableResponse.fromCallableData(Object? data) {
    if (data case final Map<Object?, Object?> map) {
      final orderId = map['orderId'] as String?;
      final amount = (map['amount'] as num?)?.toInt();
      final currency = map['currency'] as String?;

      if (orderId != null &&
          orderId.isNotEmpty &&
          amount != null &&
          amount > 0 &&
          currency != null &&
          currency.isNotEmpty) {
        return RazorpayOrderCallableResponse(
          orderId: orderId,
          amountInPaise: amount,
          currency: currency,
        );
      }
    }

    throw const RazorpayOrderCallableResponseFormatException();
  }

  final String orderId;
  final int amountInPaise;
  final String currency;
}

final class RazorpayOrderCallableResponseFormatException implements Exception {
  const RazorpayOrderCallableResponseFormatException();
}
