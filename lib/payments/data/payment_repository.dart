import 'dart:async';

import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/payments/data/payment_callable_requests.dart';
import 'package:catch_dating_app/payments/data/payment_callable_responses.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:catch_dating_app/payments/env/env.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_repository.g.dart';

typedef RazorpayFactory = Razorpay Function();

class PaymentRepository {
  PaymentRepository(
    this._functions, {
    RazorpayFactory? razorpayFactory,
    bool? isWebOverride,
    TargetPlatform? targetPlatformOverride,
  }) : _razorpayFactory = razorpayFactory ?? Razorpay.new,
       _isWebOverride = isWebOverride,
       _targetPlatformOverride = targetPlatformOverride;

  final FirebaseFunctions _functions;
  final RazorpayFactory _razorpayFactory;
  final bool? _isWebOverride;
  final TargetPlatform? _targetPlatformOverride;
  Razorpay? _razorpay;

  Completer<PaymentConfirmationData>? _completer;

  /// Captured order data used to build the confirmation payload on success.
  String? _pendingEventId;
  int? _pendingAmountInPaise;
  String? _pendingCurrency;

  bool get supportsPaidBookings {
    if (_isWebOverride ?? kIsWeb) return false;

    final platform = _targetPlatformOverride ?? defaultTargetPlatform;

    return switch (platform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
  }

  // ── Paid event booking ──────────────────────────────────────────────────────

  /// Initiates the full Razorpay payment + sign-up flow for a paid event.
  ///
  /// On success the Cloud Function [verifyRazorpayPayment] atomically verifies
  /// the payment and writes the user's event participation edge.
  ///
  /// Returns [PaymentConfirmationData] with the payment details for the
  /// confirmation screen.
  Future<PaymentConfirmationData> processPayment({
    required String eventId,
    required String description,
    required String userName,
    required String userEmail,
    required String userContact,
    String? inviteCode,
  }) async {
    if (!supportsPaidBookings) {
      throw const PaidBookingUnsupportedException();
    }
    final razorpay = _ensureRazorpay();

    if (_completer != null && !_completer!.isCompleted) {
      throw const PaymentFailedException(
        'Another payment is already in progress.',
      );
    }

    // Step 1: Create a Razorpay order server-side.
    final orderResult = await _createOrder(
      eventId: eventId,
      inviteCode: inviteCode,
    );
    final order = _parseOrderResponse(orderResult.data);

    // Step 2: Open the Razorpay checkout sheet.
    final completer = Completer<PaymentConfirmationData>();
    _completer = completer;
    _pendingEventId = eventId;
    _pendingAmountInPaise = order.amountInPaise;
    _pendingCurrency = order.currency;

    try {
      razorpay.open({
        'key': Env.razorpayKeyId,
        'order_id': order.orderId,
        'amount': order.amountInPaise,
        'currency': order.currency,
        'name': 'Catch',
        'description': description,
        'prefill': {
          'name': userName,
          'email': userEmail,
          'contact': userContact,
        },
        'theme': {'color': '#FF4E1F'},
      });

      // Step 3: Wait for the Razorpay callback with a timeout so a hung
      // sheet doesn't permanently block future payments.
      return await completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          if (identical(_completer, completer)) {
            _completer = null;
          }
          throw const PaymentFailedException(
            'The payment took too long. Please try again.',
          );
        },
      );
    } catch (error, st) {
      if (identical(_completer, completer)) {
        _completer = null;
      }
      throw _normalizePaymentError(
        error,
        stackTrace: st,
        fallbackMessage: 'Unable to launch the payment checkout.',
      );
    }
  }

  // ── Free event booking ──────────────────────────────────────────────────────

  /// Signs the current user up for a free event via the [signUpForFreeEvent]
  /// Cloud Function, which validates the event is free and checks capacity.
  Future<void> bookFreeEvent({required String eventId, String? inviteCode}) =>
      withBackendErrorContext(
        () => _functions
            .httpsCallable('signUpForFreeEvent')
            .call(
              EventBookingCallableRequest(
                eventId: eventId,
                inviteCode: inviteCode,
              ).toJson(),
            ),
        context: const BackendErrorContext(
          service: BackendService.functions,
          action: 'book an event',
          resource: 'events',
        ),
        mapper: _eventBookingErrorMapper(
          fallbackMessage: 'Unable to book this event right now.',
        ),
      );

  // ── Razorpay callbacks ────────────────────────────────────────────────────

  Future<void> _onSuccess(PaymentSuccessResponse response) async {
    final completer = _takeCompleter();
    if (completer == null || completer.isCompleted) return;

    final paymentId = response.paymentId;
    final orderId = response.orderId;
    final signature = response.signature;
    if (paymentId == null || orderId == null || signature == null) {
      completer.completeError(const PaymentVerificationFailedException());
      return;
    }

    try {
      // Step 4: Verify payment signature server-side and sign user up.
      await withBackendErrorContext(
        () => _functions
            .httpsCallable('verifyRazorpayPayment')
            .call(
              VerifyRazorpayPaymentCallableRequest(
                paymentId: paymentId,
                orderId: orderId,
                signature: signature,
              ).toJson(),
            ),
        context: const BackendErrorContext(
          service: BackendService.functions,
          action: 'verify payment',
          resource: 'payments',
        ),
        mapper: _paymentErrorMapper(
          fallbackMessage: 'Unable to complete the payment verification.',
        ),
      );
      completer.complete(
        PaymentConfirmationData(
          paymentId: paymentId,
          orderId: orderId,
          amountInPaise: _pendingAmountInPaise ?? 0,
          currency: _pendingCurrency ?? defaultCurrencyCode,
          eventId: _pendingEventId ?? '',
        ),
      );
    } catch (e, st) {
      completer.completeError(
        _normalizePaymentError(
          e,
          stackTrace: st,
          fallbackMessage: 'Unable to complete the payment verification.',
        ),
      );
    }
  }

  void _onError(PaymentFailureResponse response) {
    final completer = _takeCompleter();
    if (completer == null || completer.isCompleted) return;
    completer.completeError(_mapCheckoutFailure(response));
  }

  Razorpay _ensureRazorpay() {
    final existing = _razorpay;
    if (existing != null) return existing;

    final razorpay = _razorpayFactory();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay = razorpay;
    return razorpay;
  }

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }

  Future<HttpsCallableResult<Object?>> _createOrder({
    required String eventId,
    String? inviteCode,
  }) => withBackendErrorContext(
    () => _functions
        .httpsCallable('createRazorpayOrder')
        .call<Object?>(
          CreateRazorpayOrderCallableRequest(
            eventId: eventId,
            inviteCode: inviteCode,
          ).toJson(),
        ),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'create payment order',
      resource: 'payments',
    ),
    mapper: _paymentErrorMapper(
      fallbackMessage: 'Unable to start the payment.',
    ),
  );

  RazorpayOrderCallableResponse _parseOrderResponse(Object? data) {
    try {
      return RazorpayOrderCallableResponse.fromCallableData(data);
    } on RazorpayOrderCallableResponseFormatException {
      throw const PaymentVerificationFailedException();
    }
  }

  Completer<PaymentConfirmationData>? _takeCompleter() {
    final completer = _completer;
    _completer = null;
    return completer;
  }

  AppException _normalizePaymentError(
    Object error, {
    required String fallbackMessage,
    StackTrace? stackTrace,
  }) {
    return normalizeBackendError(
      error,
      stackTrace: stackTrace,
      context: const BackendErrorContext(
        service: BackendService.payments,
        action: 'process payment',
        resource: 'payments',
      ),
      mapper: _paymentErrorMapper(fallbackMessage: fallbackMessage),
    );
  }

  AppException _mapCheckoutFailure(PaymentFailureResponse response) {
    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      return const PaymentCancelledException(
        context: BackendErrorContext(
          service: BackendService.payments,
          action: 'checkout',
          resource: 'payments',
        ),
      );
    }

    final message = response.message;
    return PaymentFailedException(
      message == null || message.isEmpty ? 'Unknown payment error.' : message,
      context: const BackendErrorContext(
        service: BackendService.payments,
        action: 'checkout',
        resource: 'payments',
      ),
    );
  }
}

BackendErrorMapper _paymentErrorMapper({required String fallbackMessage}) {
  return (error, stackTrace, context) {
    if (error is FirebaseFunctionsException) {
      return PaymentFailedException(
        error.message == null || error.message!.isEmpty
            ? fallbackMessage
            : error.message!,
        debugMessage: '${error.plugin}/${error.code}: ${error.message}',
        cause: error,
        stackTrace: stackTrace,
        context: context,
      );
    }
    return PaymentFailedException(
      error.toString().isEmpty ? fallbackMessage : error.toString(),
      debugMessage: '${error.runtimeType}: $error',
      cause: error,
      stackTrace: stackTrace,
      context: context,
    );
  };
}

BackendErrorMapper _eventBookingErrorMapper({required String fallbackMessage}) {
  return (error, stackTrace, context) {
    if (error is FirebaseFunctionsException) {
      if (error.code == 'unauthenticated') {
        return SignInRequiredException(
          'book an event',
          debugMessage: '${error.plugin}/${error.code}: ${error.message}',
          cause: error,
          stackTrace: stackTrace,
          context: context,
        );
      }

      final message = error.message;
      return EventBookingFailedException(
        message == null || message.isEmpty ? fallbackMessage : message,
        debugMessage: '${error.plugin}/${error.code}: ${error.message}',
        cause: error,
        stackTrace: stackTrace,
        context: context,
      );
    }
    return null;
  };
}

@Riverpod(keepAlive: true)
PaymentRepository paymentRepository(Ref ref) {
  final repo = PaymentRepository(ref.watch(firebaseFunctionsProvider));
  ref.onDispose(repo.dispose);
  return repo;
}
