import 'package:catch_dating_app/payments/data/razorpay_checkout.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

abstract interface class RazorpayGateway {
  void onSuccess(void Function(PaymentSuccessResponse response) handler);

  void onFailure(void Function(PaymentFailureResponse response) handler);

  void open(Map<String, dynamic> options);

  void clear();
}

final class PluginRazorpayGateway implements RazorpayGateway {
  PluginRazorpayGateway({Razorpay? razorpay})
    : _razorpay = razorpay ?? Razorpay();

  final Razorpay _razorpay;

  @override
  void onSuccess(void Function(PaymentSuccessResponse response) handler) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handler);
  }

  @override
  void onFailure(void Function(PaymentFailureResponse response) handler) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handler);
  }

  @override
  void open(Map<String, dynamic> options) => _razorpay.open(options);

  @override
  void clear() => _razorpay.clear();
}

class PluginRazorpayCheckout implements RazorpayCheckout {
  PluginRazorpayCheckout({RazorpayGateway? gateway})
    : _gateway = gateway ?? PluginRazorpayGateway();

  final RazorpayGateway _gateway;

  @override
  void configure({
    required RazorpaySuccessHandler onSuccess,
    required RazorpayFailureHandler onFailure,
  }) {
    _gateway.onSuccess((response) {
      onSuccess(
        RazorpaySuccessResponse(
          paymentId: response.paymentId,
          orderId: response.orderId,
          signature: response.signature,
        ),
      );
    });
    _gateway.onFailure((response) {
      onFailure(
        RazorpayFailureResponse(
          isCancelled: response.code == Razorpay.PAYMENT_CANCELLED,
          message: response.message,
        ),
      );
    });
  }

  @override
  void open(Map<String, dynamic> options) => _gateway.open(options);

  @override
  void clear() => _gateway.clear();
}
