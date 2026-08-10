import 'dart:async';

import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/payments/data/payment_callable_requests.dart';
import 'package:catch_dating_app/payments/data/payment_callable_responses.dart';
import 'package:catch_dating_app/payments/data/razorpay_checkout.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'payment_repository.g.dart';

class PaymentRepository {
  PaymentRepository(
    this._functions, {
    RazorpayCheckoutFactory? razorpayFactory,
    ExternalUrlLauncher? externalUrlLauncher,
    bool? isWebOverride,
    TargetPlatform? targetPlatformOverride,
  }) : // Keep the public adapter-factory name stable for app-package injection.
       // ignore: prefer_initializing_formals
       _razorpayFactory = razorpayFactory,
       _externalUrlLauncher =
           externalUrlLauncher ??
           ((uri, {mode = LaunchMode.platformDefault}) =>
               launchUrl(uri, mode: mode)),
       // Keep these named parameters stable for payment tests and platform overrides.
       // ignore: prefer_initializing_formals
       _isWebOverride = isWebOverride,
       // ignore: prefer_initializing_formals
       _targetPlatformOverride = targetPlatformOverride;

  final FirebaseFunctions _functions;
  final RazorpayCheckoutFactory? _razorpayFactory;
  final ExternalUrlLauncher _externalUrlLauncher;
  final bool? _isWebOverride;
  final TargetPlatform? _targetPlatformOverride;
  RazorpayCheckout? _razorpay;

  Completer<PaymentConfirmationData>? _completer;

  /// Captured order data used to build the confirmation payload on success.
  String? _pendingEventId;
  int? _pendingAmountInPaise;
  String? _pendingCurrency;

  bool get supportsPaidBookings {
    if (_isWebOverride ?? kIsWeb) return false;

    final platform = _targetPlatformOverride ?? defaultTargetPlatform;

    return switch (platform) {
      TargetPlatform.android || TargetPlatform.iOS => _razorpayFactory != null,
      _ => false,
    };
  }

  bool supportsPaidBookingsForCurrency(String currencyCode) {
    final normalized = currencyCode.trim().toUpperCase();
    if (normalized == defaultCurrencyCode) return supportsPaidBookings;
    return normalized.length == 3;
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
    required String currencyCode,
    required String description,
    required String userName,
    required String userEmail,
    required String userContact,
    String? inviteCode,
    String? inviteLinkId,
    String? crossPathsPairHoldId,
  }) async {
    if (currencyCode.trim().toUpperCase() != defaultCurrencyCode) {
      return _processStripeCheckout(
        eventId: eventId,
        inviteCode: inviteCode,
        inviteLinkId: inviteLinkId,
        crossPathsPairHoldId: crossPathsPairHoldId,
      );
    }
    return _processRazorpayPayment(
      eventId: eventId,
      description: description,
      userName: userName,
      userEmail: userEmail,
      userContact: userContact,
      inviteCode: inviteCode,
      inviteLinkId: inviteLinkId,
      crossPathsPairHoldId: crossPathsPairHoldId,
    );
  }

  Future<PaymentConfirmationData> _processRazorpayPayment({
    required String eventId,
    required String description,
    required String userName,
    required String userEmail,
    required String userContact,
    String? inviteCode,
    String? inviteLinkId,
    String? crossPathsPairHoldId,
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
      inviteLinkId: inviteLinkId,
      crossPathsPairHoldId: crossPathsPairHoldId,
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
        'key': order.keyId,
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
        'theme': {'color': '#16140F'},
      });

      // Step 3: Wait for the Razorpay callback. Interactive checkout (card + bank
      // OTP, or switching to a UPI app to enter a PIN) routinely takes minutes,
      // so the guard is long enough not to abandon a real attempt. On timeout we
      // dismiss the native sheet (clear + recreate) so a late success cannot
      // charge the user after we have already surfaced a failure — there is no
      // server-side webhook reconciliation yet (see backlog: payment webhook).
      // architecture:allow stream-timeout -- reason: Razorpay checkout deadline
      return await completer.future.timeout(
        const Duration(minutes: 10),
        onTimeout: () {
          if (identical(_completer, completer)) {
            _completer = null;
          }
          _razorpay?.clear();
          _razorpay = null;
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

  Future<PaymentConfirmationData> _processStripeCheckout({
    required String eventId,
    String? inviteCode,
    String? inviteLinkId,
    String? crossPathsPairHoldId,
  }) async {
    final result = await _createStripeCheckoutSession(
      eventId: eventId,
      inviteCode: inviteCode,
      inviteLinkId: inviteLinkId,
      crossPathsPairHoldId: crossPathsPairHoldId,
    );
    final session = _parseStripeCheckoutResponse(result.data);
    final opened = await withBackendErrorContext(
      () => _externalUrlLauncher(
        session.checkoutUrl,
        mode: LaunchMode.externalApplication,
      ),
      context: const BackendErrorContext(
        service: BackendService.external,
        action: 'open Stripe checkout',
        resource: 'payments',
      ),
      mapper: _paymentErrorMapper(
        fallbackMessage: 'Unable to open Stripe checkout.',
      ),
    );
    if (!opened) {
      throw const PaymentFailedException('Unable to open Stripe checkout.');
    }
    return PaymentConfirmationData(
      paymentId: session.paymentId,
      orderId: session.sessionId,
      amountInPaise: session.amountMinor,
      currency: session.currency,
      eventId: eventId,
      provider: 'stripe',
      status: PaymentStatus.pending,
      checkoutUrl: session.checkoutUrl,
    );
  }

  // ── Free event booking ──────────────────────────────────────────────────────

  /// Signs the current user up for a free event via the [signUpForFreeEvent]
  /// Cloud Function, which validates the event is free and checks capacity.
  Future<void> bookFreeEvent({
    required String eventId,
    String? inviteCode,
    String? inviteLinkId,
    String? crossPathsPairHoldId,
  }) => withBackendErrorContext(
    () => _functions
        .httpsCallable('signUpForFreeEvent')
        .call(
          EventBookingCallableRequest(
            eventId: eventId,
            inviteCode: inviteCode,
            inviteLinkId: inviteLinkId,
            crossPathsPairHoldId: crossPathsPairHoldId,
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

  Future<void> _onSuccess(RazorpaySuccessResponse response) async {
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

  void _onError(RazorpayFailureResponse response) {
    final completer = _takeCompleter();
    if (completer == null || completer.isCompleted) return;
    completer.completeError(_mapCheckoutFailure(response));
  }

  RazorpayCheckout _ensureRazorpay() {
    final existing = _razorpay;
    if (existing != null) return existing;

    final factory = _razorpayFactory;
    if (factory == null) {
      throw const PaidBookingUnsupportedException();
    }
    final razorpay = factory();
    razorpay.configure(onSuccess: _onSuccess, onFailure: _onError);
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
    String? inviteLinkId,
    String? crossPathsPairHoldId,
  }) => withBackendErrorContext(
    () => _functions
        .httpsCallable('createRazorpayOrder')
        .call<Object?>(
          CreateRazorpayOrderCallableRequest(
            eventId: eventId,
            inviteCode: inviteCode,
            inviteLinkId: inviteLinkId,
            crossPathsPairHoldId: crossPathsPairHoldId,
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

  Future<HttpsCallableResult<Object?>> _createStripeCheckoutSession({
    required String eventId,
    String? inviteCode,
    String? inviteLinkId,
    String? crossPathsPairHoldId,
  }) => withBackendErrorContext(
    () => _functions
        .httpsCallable('createStripeCheckoutSession')
        .call<Object?>(
          CreateStripeCheckoutSessionCallableRequest(
            eventId: eventId,
            inviteCode: inviteCode?.trim(),
            inviteLinkId: inviteLinkId?.trim(),
            crossPathsPairHoldId: crossPathsPairHoldId?.trim(),
          ).toJson(),
        ),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'create Stripe checkout session',
      resource: 'payments',
    ),
    mapper: _paymentErrorMapper(
      fallbackMessage: 'Unable to start Stripe checkout.',
    ),
  );

  RazorpayOrderCallableResponse _parseOrderResponse(Object? data) {
    try {
      return RazorpayOrderCallableResponse.fromCallableData(data);
    } on RazorpayOrderCallableResponseFormatException {
      throw const PaymentVerificationFailedException();
    }
  }

  StripeCheckoutSessionCallableResponse _parseStripeCheckoutResponse(
    Object? data,
  ) {
    try {
      return StripeCheckoutSessionCallableResponse.fromCallableData(data);
    } on StripeCheckoutSessionCallableResponseFormatException {
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

  AppException _mapCheckoutFailure(RazorpayFailureResponse response) {
    if (response.isCancelled) {
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
      // Unexpected SDK/runtime errors may contain implementation details or
      // user data. Keep those diagnostics off the user-facing message.
      fallbackMessage,
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

// keepalive: payment repository is a shared Functions/link facade for checkout
// and confirmation flows.
@Riverpod(keepAlive: true)
PaymentRepository paymentRepository(Ref ref) {
  final repo = PaymentRepository(
    ref.watch(firebaseFunctionsProvider),
    razorpayFactory: ref.watch(razorpayCheckoutFactoryProvider),
    externalUrlLauncher: ref.watch(externalUrlLauncherProvider),
  );
  ref.onDispose(repo.dispose);
  return repo;
}
