import 'dart:async';

import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
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
       _targetPlatformOverride = targetPlatformOverride {
    if (supportsPaidBookings) {
      _razorpay = _razorpayFactory();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    }
  }

  final FirebaseFunctions _functions;
  final RazorpayFactory _razorpayFactory;
  final bool? _isWebOverride;
  final TargetPlatform? _targetPlatformOverride;
  Razorpay? _razorpay;

  Completer<void>? _completer;

  bool get supportsPaidBookings {
    if (_isWebOverride ?? kIsWeb) return false;

    final platform = _targetPlatformOverride ?? defaultTargetPlatform;

    return switch (platform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
  }

  // ── Paid run booking ──────────────────────────────────────────────────────

  /// Initiates the full Razorpay payment + sign-up flow for a paid run.
  ///
  /// On success the Cloud Function [verifyRazorpayPayment] atomically verifies
  /// the payment and adds [userId] to [runs/{runId}.signedUpUserIds].
  Future<void> processPayment({
    required String runId,
    required String description,
    required String userName,
    required String userEmail,
    required String userContact,
  }) async {
    if (!supportsPaidBookings || _razorpay == null) {
      throw const PaidBookingUnsupportedException();
    }

    if (_completer != null && !_completer!.isCompleted) {
      throw const PaymentFailedException(
        'Another payment is already in progress.',
      );
    }

    // Step 1: Create a Razorpay order server-side.
    final orderResult = await _createOrder(runId: runId);
    final order = _parseOrderResponse(orderResult.data);

    // Step 2: Open the Razorpay checkout sheet.
    final completer = Completer<void>();
    _completer = completer;

    try {
      _razorpay!.open({
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
        'theme': {'color': '#E8445A'},
      });

      // Step 3: Wait for the Razorpay callback.
      await completer.future;
    } catch (error) {
      if (identical(_completer, completer)) {
        _completer = null;
      }
      throw _normalizePaymentError(
        error,
        fallbackMessage: 'Unable to launch the payment checkout.',
      );
    }
  }

  // ── Free run booking ──────────────────────────────────────────────────────

  /// Signs the current user up for a free run via the [signUpForFreeRun]
  /// Cloud Function, which validates the run is free and checks capacity.
  Future<void> bookFreeRun({required String runId}) async {
    try {
      await _functions.httpsCallable('signUpForFreeRun').call({'runId': runId});
    } on FirebaseFunctionsException catch (error) {
      throw _normalizeRunBookingError(
        error,
        fallbackMessage: 'Unable to book this run right now.',
      );
    }
  }

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
      await _functions.httpsCallable('verifyRazorpayPayment').call({
        'paymentId': paymentId,
        'orderId': orderId,
        'signature': signature,
      });
      completer.complete();
    } catch (e) {
      completer.completeError(
        _normalizePaymentError(
          e,
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

  void dispose() {
    _razorpay?.clear();
  }

  Future<HttpsCallableResult<Map<String, dynamic>>> _createOrder({
    required String runId,
  }) async {
    try {
      return await _functions
          .httpsCallable('createRazorpayOrder')
          .call<Map<String, dynamic>>({'runId': runId});
    } on FirebaseFunctionsException catch (error) {
      throw PaymentFailedException(
        error.message ?? 'Unable to start the payment.',
      );
    }
  }

  ({String orderId, int amountInPaise, String currency}) _parseOrderResponse(
    Map<String, dynamic> data,
  ) {
    final orderId = data['orderId'] as String?;
    final amount = (data['amount'] as num?)?.toInt();
    final currency = data['currency'] as String?;

    if (orderId == null ||
        orderId.isEmpty ||
        amount == null ||
        amount <= 0 ||
        currency == null ||
        currency.isEmpty) {
      throw const PaymentVerificationFailedException();
    }

    return (orderId: orderId, amountInPaise: amount, currency: currency);
  }

  Completer<void>? _takeCompleter() {
    final completer = _completer;
    _completer = null;
    return completer;
  }

  AppException _normalizePaymentError(
    Object error, {
    required String fallbackMessage,
  }) {
    if (error is AppException) {
      return error;
    }
    if (error is FirebaseFunctionsException) {
      return PaymentFailedException(error.message ?? fallbackMessage);
    }
    return PaymentFailedException(error.toString());
  }

  AppException _normalizeRunBookingError(
    Object error, {
    required String fallbackMessage,
  }) {
    if (error is AppException) {
      return error;
    }
    if (error is FirebaseFunctionsException) {
      if (error.code == 'unauthenticated') {
        return const SignInRequiredException('book a run');
      }

      final message = error.message;
      return RunBookingFailedException(
        message == null || message.isEmpty ? fallbackMessage : message,
      );
    }
    return RunBookingFailedException(fallbackMessage);
  }

  AppException _mapCheckoutFailure(PaymentFailureResponse response) {
    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      return const PaymentCancelledException();
    }

    final message = response.message;
    return PaymentFailedException(
      message == null || message.isEmpty ? 'Unknown payment error.' : message,
    );
  }
}

@Riverpod(keepAlive: true)
PaymentRepository paymentRepository(Ref ref) {
  final repo = PaymentRepository(ref.watch(firebaseFunctionsProvider));
  ref.onDispose(repo.dispose);
  return repo;
}
