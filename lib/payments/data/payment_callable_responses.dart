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
