import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../test_pump_helpers.dart';

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
      'processPayment requests a trusted order and verifies without client event metadata',
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
        )..resultData = {'verified': true, 'eventId': 'trusted-event'};

        final future = repository.processPayment(
          eventId: 'event-1',
          currencyCode: 'INR',
          description: 'Sunrise Event',
          userName: 'Priya',
          userEmail: 'priya@example.com',
          userContact: '+919876543210',
        );
        await flushTestEventQueue();

        expect(functions.callables['createRazorpayOrder']!.calls.single, {
          'eventId': 'event-1',
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

    test('does not initialize Razorpay until a paid checkout starts', () {
      var factoryCalls = 0;
      final lazyRepository = PaymentRepository(
        functions,
        razorpayFactory: () {
          factoryCalls++;
          return FakeRazorpay();
        },
        isWebOverride: false,
        targetPlatformOverride: TargetPlatform.iOS,
      );

      expect(lazyRepository.supportsPaidBookings, isTrue);
      expect(lazyRepository.supportsPaidBookingsForCurrency('INR'), isTrue);
      expect(lazyRepository.supportsPaidBookingsForCurrency('USD'), isTrue);
      expect(factoryCalls, 0);
    });

    test(
      'processPayment opens Stripe checkout for non-INR currencies',
      () async {
        final openedUrls = <Uri>[];
        final stripeRepository = PaymentRepository(
          functions,
          razorpayFactory: () => razorpay,
          externalUrlLauncher:
              (uri, {mode = LaunchMode.platformDefault}) async {
                openedUrls.add(uri);
                return true;
              },
          isWebOverride: true,
        );
        functions.callables['createStripeCheckoutSession'] =
            TestHttpsCallable('createStripeCheckoutSession')
              ..resultData = {
                'sessionId': 'cs_test_123',
                'paymentId': 'payment-doc-1',
                'amountMinor': 1999,
                'currency': 'USD',
                'checkoutUrl': 'https://checkout.stripe.com/c/pay/cs_test_123',
                'provider': 'stripe',
              };

        final data = await stripeRepository.processPayment(
          eventId: 'event-1',
          currencyCode: 'USD',
          description: 'Sunrise Event',
          userName: 'Priya',
          userEmail: 'priya@example.com',
          userContact: '+919876543210',
          inviteCode: ' CATCH ',
          inviteLinkId: ' invite-link-1 ',
        );

        expect(
          functions.callables['createStripeCheckoutSession']!.calls.single,
          {
            'eventId': 'event-1',
            'inviteCode': 'CATCH',
            'inviteLinkId': 'invite-link-1',
          },
        );
        expect(openedUrls.single.toString(), contains('checkout.stripe.com'));
        expect(razorpay.openCalls, isEmpty);
        expect(data.paymentId, 'payment-doc-1');
        expect(data.orderId, 'cs_test_123');
        expect(data.status, PaymentStatus.pending);
        expect(data.provider, 'stripe');
      },
    );

    test('bookFreeEvent calls the free-event booking function', () async {
      await repository.bookFreeEvent(
        eventId: 'event-1',
        inviteCode: ' CATCH ',
        inviteLinkId: ' invite-link-1 ',
      );

      expect(functions.callables['signUpForFreeEvent']!.calls.single, {
        'eventId': 'event-1',
        'inviteCode': 'CATCH',
        'inviteLinkId': 'invite-link-1',
      });
    });

    test(
      'bookFreeEvent maps unauthenticated callable failures to sign-in errors',
      () async {
        functions.callables['signUpForFreeEvent'] =
            TestHttpsCallable('signUpForFreeEvent')
              ..error = TestFirebaseFunctionsException(
                code: 'unauthenticated',
                message: 'UNAUTHENTICATED',
              );

        await expectLater(
          repository.bookFreeEvent(eventId: 'event-1'),
          throwsA(
            isA<SignInRequiredException>().having(
              (error) => error.message,
              'message',
              'You need to be signed in to book an event.',
            ),
          ),
        );
      },
    );

    test(
      'bookFreeEvent preserves server-side booking failure messages',
      () async {
        functions.callables['signUpForFreeEvent'] =
            TestHttpsCallable('signUpForFreeEvent')
              ..error = TestFirebaseFunctionsException(
                code: 'failed-precondition',
                message: 'Event is full.',
              );

        await expectLater(
          repository.bookFreeEvent(eventId: 'event-1'),
          throwsA(
            isA<EventBookingFailedException>().having(
              (error) => error.message,
              'message',
              'Event is full.',
            ),
          ),
        );
      },
    );

    test(
      'processPayment maps callable startup failures to PaymentFailedException',
      () async {
        functions.callables['createRazorpayOrder'] =
            TestHttpsCallable('createRazorpayOrder')
              ..error = TestFirebaseFunctionsException(
                code: 'failed-precondition',
                message: 'Event is full.',
              );

        await expectLater(
          repository.processPayment(
            eventId: 'event-1',
            currencyCode: 'INR',
            description: 'Sunrise Event',
            userName: 'Priya',
            userEmail: 'priya@example.com',
            userContact: '+919876543210',
          ),
          throwsA(
            isA<PaymentFailedException>().having(
              (error) => error.message,
              'message',
              'Payment failed: Event is full.',
            ),
          ),
        );
        expect(razorpay.openCalls, isEmpty);
      },
    );

    test(
      'processPayment rejects malformed order responses before checkout',
      () async {
        functions.callables['createRazorpayOrder'] = TestHttpsCallable(
          'createRazorpayOrder',
        )..resultData = {'orderId': 'order_123', 'currency': 'INR'};

        await expectLater(
          repository.processPayment(
            eventId: 'event-1',
            currencyCode: 'INR',
            description: 'Sunrise Event',
            userName: 'Priya',
            userEmail: 'priya@example.com',
            userContact: '+919876543210',
          ),
          throwsA(isA<PaymentVerificationFailedException>()),
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
          eventId: 'event-1',
          currencyCode: 'INR',
          description: 'Sunrise Event',
          userName: 'Priya',
          userEmail: 'priya@example.com',
          userContact: '+919876543210',
        );
        await flushTestEventQueue();

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
        eventId: 'event-1',
        currencyCode: 'INR',
        description: 'Sunrise Event',
        userName: 'Priya',
        userEmail: 'priya@example.com',
        userContact: '+919876543210',
      );
      await flushTestEventQueue();

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
                message: 'This event is now full.',
              );

        final future = repository.processPayment(
          eventId: 'event-1',
          currencyCode: 'INR',
          description: 'Sunrise Event',
          userName: 'Priya',
          userEmail: 'priya@example.com',
          userContact: '+919876543210',
        );
        await flushTestEventQueue();

        razorpay.emitSuccess(
          PaymentSuccessResponse('pay_123', 'order_123', 'sig_123', {}),
        );

        await expectLater(
          future,
          throwsA(
            isA<PaymentFailedException>().having(
              (error) => error.message,
              'message',
              'Payment failed: This event is now full.',
            ),
          ),
        );
      },
    );
  });
}
