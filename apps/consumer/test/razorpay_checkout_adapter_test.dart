import 'package:catch_consumer_app/razorpay_checkout_adapter.dart';
import 'package:catch_dating_app/payments/data/razorpay_checkout.dart'
    as catch_payment;
import 'package:flutter_test/flutter_test.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

void main() {
  test(
    'maps native success payload into the shared payment contract',
    () async {
      final gateway = _FakeRazorpayGateway();
      final checkout = PluginRazorpayCheckout(gateway: gateway);
      catch_payment.RazorpaySuccessResponse? result;
      checkout.configure(
        onSuccess: (response) async => result = response,
        onFailure: (_) {},
      );

      gateway.emitSuccess(
        PaymentSuccessResponse('payment-1', 'order-1', 'signature-1', const {}),
      );
      await Future<void>.delayed(Duration.zero);

      expect(result?.paymentId, 'payment-1');
      expect(result?.orderId, 'order-1');
      expect(result?.signature, 'signature-1');
    },
  );

  test('maps cancellation separately from an ordinary payment error', () {
    final gateway = _FakeRazorpayGateway();
    final checkout = PluginRazorpayCheckout(gateway: gateway);
    final failures = <catch_payment.RazorpayFailureResponse>[];
    checkout.configure(onSuccess: (_) async {}, onFailure: failures.add);

    gateway
      ..emitFailure(
        PaymentFailureResponse(
          Razorpay.PAYMENT_CANCELLED,
          'Checkout closed',
          null,
        ),
      )
      ..emitFailure(
        PaymentFailureResponse(Razorpay.NETWORK_ERROR, 'Try again', null),
      );

    expect(failures, hasLength(2));
    expect(failures.first.isCancelled, isTrue);
    expect(failures.first.message, 'Checkout closed');
    expect(failures.last.isCancelled, isFalse);
    expect(failures.last.message, 'Try again');
  });

  test('delegates open and clear without rewriting checkout options', () {
    final gateway = _FakeRazorpayGateway();
    final checkout = PluginRazorpayCheckout(gateway: gateway);
    final options = <String, dynamic>{'key': 'rzp_test', 'amount': 4200};

    checkout.open(options);
    checkout.clear();

    expect(gateway.openedOptions, same(options));
    expect(gateway.clearCalls, 1);
  });
}

class _FakeRazorpayGateway implements RazorpayGateway {
  void Function(PaymentSuccessResponse response)? successHandler;
  void Function(PaymentFailureResponse response)? failureHandler;
  Map<String, dynamic>? openedOptions;
  int clearCalls = 0;

  @override
  void onSuccess(void Function(PaymentSuccessResponse response) handler) {
    successHandler = handler;
  }

  @override
  void onFailure(void Function(PaymentFailureResponse response) handler) {
    failureHandler = handler;
  }

  void emitSuccess(PaymentSuccessResponse response) =>
      successHandler?.call(response);

  void emitFailure(PaymentFailureResponse response) =>
      failureHandler?.call(response);

  @override
  void open(Map<String, dynamic> options) {
    openedOptions = options;
  }

  @override
  void clear() {
    clearCalls += 1;
  }
}
