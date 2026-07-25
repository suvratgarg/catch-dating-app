import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef RazorpaySuccessHandler =
    Future<void> Function(RazorpaySuccessResponse response);
typedef RazorpayFailureHandler =
    void Function(RazorpayFailureResponse response);
typedef RazorpayCheckoutFactory = RazorpayCheckout Function();

final class RazorpaySuccessResponse {
  const RazorpaySuccessResponse({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });

  final String? paymentId;
  final String? orderId;
  final String? signature;
}

final class RazorpayFailureResponse {
  const RazorpayFailureResponse({required this.isCancelled, this.message});

  final bool isCancelled;
  final String? message;
}

/// Consumer-owned adapter boundary for the native Razorpay SDK.
///
/// The shared Catch package only depends on this contract. Installable app
/// packages opt into the native SDK by overriding
/// [razorpayCheckoutFactoryProvider].
abstract interface class RazorpayCheckout {
  void configure({
    required RazorpaySuccessHandler onSuccess,
    required RazorpayFailureHandler onFailure,
  });

  void open(Map<String, dynamic> options);

  void clear();
}

/// Host and non-native shells intentionally have no Razorpay implementation.
final razorpayCheckoutFactoryProvider = Provider<RazorpayCheckoutFactory?>(
  (ref) => null,
);
