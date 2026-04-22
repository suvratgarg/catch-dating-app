import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class TestFirebaseFunctions extends Fake implements FirebaseFunctions {
  final callables = <String, TestHttpsCallable>{};

  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    return callables.putIfAbsent(name, () => TestHttpsCallable(name));
  }
}

class TestHttpsCallable extends Fake implements HttpsCallable {
  TestHttpsCallable(this.name);

  final String name;
  final calls = <Object?>[];
  Object? resultData;
  Object? error;

  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    calls.add(parameters);
    if (error != null) {
      throw error!;
    }
    return TestHttpsCallableResult<T>(resultData as T);
  }
}

class TestHttpsCallableResult<T> extends Fake
    implements HttpsCallableResult<T> {
  TestHttpsCallableResult(this.dataValue);

  final T dataValue;

  @override
  T get data => dataValue;
}

class FakeRazorpay extends Fake implements Razorpay {
  Future<void> Function(PaymentSuccessResponse response)? successHandler;
  void Function(PaymentFailureResponse response)? errorHandler;
  final openCalls = <Map<String, dynamic>>[];
  bool cleared = false;

  @override
  void on(String event, Function handler) {
    if (event == Razorpay.EVENT_PAYMENT_SUCCESS) {
      successHandler =
          handler as Future<void> Function(PaymentSuccessResponse response);
    } else if (event == Razorpay.EVENT_PAYMENT_ERROR) {
      errorHandler = handler as void Function(PaymentFailureResponse response);
    }
  }

  @override
  void open(Map<String, dynamic> options) {
    openCalls.add(options);
  }

  @override
  void clear() {
    cleared = true;
  }

  void emitSuccess(PaymentSuccessResponse response) {
    successHandler?.call(response);
  }

  void emitError(PaymentFailureResponse response) {
    errorHandler?.call(response);
  }
}

class TestFirebaseFunctionsException extends FirebaseFunctionsException {
  TestFirebaseFunctionsException({required super.code, required super.message});
}

void main() {
  group('PaymentRepository', () {
    late TestFirebaseFunctions functions;
    late FakeRazorpay razorpay;
    late PaymentRepository repository;

    setUp(() {
      functions = TestFirebaseFunctions();
      razorpay = FakeRazorpay();
      repository = PaymentRepository(
        functions,
        razorpayFactory: () => razorpay,
        isWebOverride: false,
        targetPlatformOverride: TargetPlatform.android,
      );
    });

    test(
      'processPayment requests a trusted order and verifies without client run metadata',
      () async {
        functions.callables['createRazorpayOrder'] =
            TestHttpsCallable('createRazorpayOrder')
              ..resultData = {
                'orderId': 'order_123',
                'amount': 25000,
                'currency': 'INR',
              };
        functions.callables['verifyRazorpayPayment'] = TestHttpsCallable(
          'verifyRazorpayPayment',
        )..resultData = {'verified': true, 'runId': 'trusted-run'};

        final future = repository.processPayment(
          runId: 'run-1',
          description: 'Sunrise Run',
          userName: 'Priya',
          userEmail: 'priya@example.com',
          userContact: '+919876543210',
        );
        await Future<void>.delayed(Duration.zero);

        expect(functions.callables['createRazorpayOrder']!.calls.single, {
          'runId': 'run-1',
        });
        expect(razorpay.openCalls.single['order_id'], 'order_123');
        expect(razorpay.openCalls.single['amount'], 25000);
        expect(razorpay.openCalls.single['currency'], 'INR');

        razorpay.emitSuccess(
          PaymentSuccessResponse('pay_123', 'order_123', 'sig_123', {}),
        );
        await future;

        expect(functions.callables['verifyRazorpayPayment']!.calls.single, {
          'paymentId': 'pay_123',
          'orderId': 'order_123',
          'signature': 'sig_123',
        });
      },
    );

    test(
      'processPayment maps callable startup failures to PaymentFailedException',
      () async {
        functions.callables['createRazorpayOrder'] =
            TestHttpsCallable('createRazorpayOrder')
              ..error = TestFirebaseFunctionsException(
                code: 'failed-precondition',
                message: 'Run is full.',
              );

        await expectLater(
          repository.processPayment(
            runId: 'run-1',
            description: 'Sunrise Run',
            userName: 'Priya',
            userEmail: 'priya@example.com',
            userContact: '+919876543210',
          ),
          throwsA(
            isA<PaymentFailedException>().having(
              (error) => error.message,
              'message',
              'Payment failed: Run is full.',
            ),
          ),
        );
        expect(razorpay.openCalls, isEmpty);
      },
    );

    test(
      'success callback fails fast when Razorpay response is incomplete',
      () async {
        functions.callables['createRazorpayOrder'] =
            TestHttpsCallable('createRazorpayOrder')
              ..resultData = {
                'orderId': 'order_123',
                'amount': 25000,
                'currency': 'INR',
              };

        final future = repository.processPayment(
          runId: 'run-1',
          description: 'Sunrise Run',
          userName: 'Priya',
          userEmail: 'priya@example.com',
          userContact: '+919876543210',
        );
        await Future<void>.delayed(Duration.zero);

        razorpay.emitSuccess(
          PaymentSuccessResponse('pay_123', 'order_123', null, {}),
        );

        await expectLater(
          future,
          throwsA(isA<PaymentVerificationFailedException>()),
        );
      },
    );

    test('error callback maps cancelled payments cleanly', () async {
      functions.callables['createRazorpayOrder'] =
          TestHttpsCallable('createRazorpayOrder')
            ..resultData = {
              'orderId': 'order_123',
              'amount': 25000,
              'currency': 'INR',
            };

      final future = repository.processPayment(
        runId: 'run-1',
        description: 'Sunrise Run',
        userName: 'Priya',
        userEmail: 'priya@example.com',
        userContact: '+919876543210',
      );
      await Future<void>.delayed(Duration.zero);

      razorpay.emitError(
        PaymentFailureResponse(
          Razorpay.PAYMENT_CANCELLED,
          'Cancelled by user',
          null,
        ),
      );

      await expectLater(future, throwsA(isA<PaymentCancelledException>()));
    });

    test(
      'verification callable failures surface as PaymentFailedException',
      () async {
        functions.callables['createRazorpayOrder'] =
            TestHttpsCallable('createRazorpayOrder')
              ..resultData = {
                'orderId': 'order_123',
                'amount': 25000,
                'currency': 'INR',
              };
        functions.callables['verifyRazorpayPayment'] =
            TestHttpsCallable('verifyRazorpayPayment')
              ..error = TestFirebaseFunctionsException(
                code: 'failed-precondition',
                message: 'This run is now full.',
              );

        final future = repository.processPayment(
          runId: 'run-1',
          description: 'Sunrise Run',
          userName: 'Priya',
          userEmail: 'priya@example.com',
          userContact: '+919876543210',
        );
        await Future<void>.delayed(Duration.zero);

        razorpay.emitSuccess(
          PaymentSuccessResponse('pay_123', 'order_123', 'sig_123', {}),
        );

        await expectLater(
          future,
          throwsA(
            isA<PaymentFailedException>().having(
              (error) => error.message,
              'message',
              'Payment failed: This run is now full.',
            ),
          ),
        );
      },
    );
  });
}
