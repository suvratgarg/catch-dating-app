import 'dart:async';

import 'package:catch_dating_app/payments/env/env.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_repository.g.dart';

class PaymentException implements Exception {
  const PaymentException(this.code, this.message);

  final int code;
  final String? message;

  @override
  String toString() => message ?? 'Payment failed (code: $code)';
}

class PaymentRepository {
  PaymentRepository(this._functions) {
    if (!kIsWeb) {
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    }
  }

  final FirebaseFunctions _functions;
  Razorpay? _razorpay;

  Completer<void>? _completer;
  String? _pendingActivityId;
  int? _pendingAmountInPaise;

  // ── Paid run booking ──────────────────────────────────────────────────────

  /// Initiates the full Razorpay payment + sign-up flow for a paid run.
  ///
  /// On success the Cloud Function [verifyRazorpayPayment] atomically verifies
  /// the payment and adds [userId] to [runs/{activityId}.signedUpUserIds].
  Future<void> processPayment({
    required String activityId,
    required int amountInPaise,
    required String description,
    required String userName,
    required String userEmail,
    required String userContact,
  }) async {
    if (kIsWeb || _razorpay == null) {
      throw UnsupportedError('Payments are only supported on Android and iOS.');
    }

    // Step 1: Create a Razorpay order server-side.
    final orderResult = await _functions
        .httpsCallable('createRazorpayOrder')
        .call<Map<String, dynamic>>({
          'activityId': activityId,
          'amount': amountInPaise,
          'currency': 'INR',
        });

    final orderId = orderResult.data['orderId'] as String;

    // Step 2: Open the Razorpay checkout sheet.
    _pendingActivityId = activityId;
    _pendingAmountInPaise = amountInPaise;
    _completer = Completer<void>();

    _razorpay!.open({
      'key': Env.razorpayKeyId,
      'order_id': orderId,
      'amount': amountInPaise,
      'currency': 'INR',
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
    await _completer!.future;
  }

  // ── Free run booking ──────────────────────────────────────────────────────

  /// Signs the current user up for a free run via the [signUpForFreeRun]
  /// Cloud Function, which validates the run is free and checks capacity.
  Future<void> bookFreeRun({required String runId}) =>
      _functions.httpsCallable('signUpForFreeRun').call({'runId': runId});

  // ── Razorpay callbacks ────────────────────────────────────────────────────

  Future<void> _onSuccess(PaymentSuccessResponse response) async {
    final completer = _completer;
    final activityId = _pendingActivityId;
    final amount = _pendingAmountInPaise;
    _completer = null;
    _pendingActivityId = null;
    _pendingAmountInPaise = null;

    if (completer == null || completer.isCompleted) return;

    try {
      // Step 4: Verify payment signature server-side and sign user up.
      await _functions.httpsCallable('verifyRazorpayPayment').call({
        'paymentId': response.paymentId,
        'orderId': response.orderId,
        'signature': response.signature,
        'activityId': activityId,
        'amountInPaise': amount,
      });
      completer.complete();
    } catch (e) {
      completer.completeError(e);
    }
  }

  void _onError(PaymentFailureResponse response) {
    final completer = _completer;
    _completer = null;
    _pendingActivityId = null;
    _pendingAmountInPaise = null;

    if (completer == null || completer.isCompleted) return;
    completer.completeError(
      PaymentException(response.code ?? -1, response.message),
    );
  }

  void dispose() {
    _razorpay?.clear();
  }
}

@riverpod
PaymentRepository paymentRepository(Ref ref) {
  final repo = PaymentRepository(FirebaseFunctions.instance);
  ref.onDispose(repo.dispose);
  return repo;
}
