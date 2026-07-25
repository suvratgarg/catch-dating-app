import 'package:catch_dating_app/payments/data/razorpay_checkout.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PluginRazorpayCheckout implements RazorpayCheckout {
  PluginRazorpayCheckout() : _razorpay = Razorpay();

  final Razorpay _razorpay;

  @override
  void configure({
    required RazorpaySuccessHandler onSuccess,
    required RazorpayFailureHandler onFailure,
  }) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (
      PaymentSuccessResponse response,
    ) {
      onSuccess(
        RazorpaySuccessResponse(
          paymentId: response.paymentId,
          orderId: response.orderId,
          signature: response.signature,
        ),
      );
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (
      PaymentFailureResponse response,
    ) {
      onFailure(
        RazorpayFailureResponse(
          isCancelled: response.code == Razorpay.PAYMENT_CANCELLED,
          message: response.message,
        ),
      );
    });
  }

  @override
  void open(Map<String, dynamic> options) => _razorpay.open(options);

  @override
  void clear() => _razorpay.clear();
}
