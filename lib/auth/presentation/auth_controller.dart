import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_input.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.freezed.dart';
part 'auth_controller.g.dart';

enum AuthStep { phone, otp }

@Riverpod(keepAlive: true)
String authInitialCountryDialCode(Ref ref) {
  if (AppConfig.appRole.isHost) {
    return defaultCountryDialCode;
  }

  final countryCode = WidgetsFlutterBinding.ensureInitialized()
      .platformDispatcher
      .locale
      .countryCode;
  return marketForIsoCode(countryCode).dialCode;
}

@freezed
abstract class AuthScreenState with _$AuthScreenState {
  const factory AuthScreenState({
    @Default('') String phoneNumber,
    @Default(defaultCountryDialCode) String countryCode,
    String? verificationId,
    @Default(AuthStep.phone) AuthStep step,
  }) = _AuthScreenState;
}

extension AuthScreenStateX on AuthScreenState {
  bool get hasPendingVerification =>
      step == AuthStep.otp &&
      verificationId != null &&
      verificationId!.isNotEmpty;
}

/// **Pattern B: Flow controller with freezed state + Mutations**
///
/// Owns the phone-auth screen state while the user moves between phone entry
/// and OTP verification. [sendOtpMutation] and [verifyOtpMutation] expose the
/// async operation lifecycle to the UI; local text/focus/timer concerns stay in
/// the widgets.
///
/// This provider is keepAlive so the OTP step survives route rebuilds during
/// authentication. Call [reset] or invalidate the provider when the auth flow is
/// cancelled, completed, or the user signs out.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  static final sendOtpMutation = Mutation<void>();
  static final verifyOtpMutation = Mutation<void>();

  int? _resendToken;

  @override
  AuthScreenState build() => AuthScreenState(
    countryCode: ref.watch(authInitialCountryDialCodeProvider),
  );

  void setCountryCode(String code) {
    state = state.copyWith(countryCode: code);
    sendOtpMutation.reset(ref);
  }

  void goToStep(AuthStep step) => state = state.copyWith(step: step);

  Future<void> sendOtp(String phoneNumber, String countryCode) async {
    final normalizedCountryCode = AuthInput.normalizeCountryCode(countryCode);
    final normalizedPhoneNumber = AuthInput.normalizePhoneInput(phoneNumber);
    final formatted = AuthInput.formatPhoneNumber(
      phoneNumber: normalizedPhoneNumber,
      countryCode: normalizedCountryCode,
    );
    final phoneNumberForState = AuthInput.phoneNumberForState(
      phoneNumber: normalizedPhoneNumber,
      countryCode: normalizedCountryCode,
    );
    final forceResendingToken =
        state.phoneNumber == phoneNumberForState &&
            state.countryCode == normalizedCountryCode
        ? _resendToken
        : null;
    if (forceResendingToken == null) _resendToken = null;

    state = state.copyWith(
      verificationId: null,
      phoneNumber: phoneNumberForState,
      countryCode: normalizedCountryCode,
    );

    _debugLogOtpRequest(formatted);

    final completer = Completer<void>();

    unawaited(
      ref
          .read(authRepositoryProvider)
          .verifyPhoneNumber(
            phoneNumber: formatted,
            forceResendingToken: forceResendingToken,
            codeSent: (verificationId, resendToken) {
              _debugLog('AuthController.sendOtp: codeSent');
              _resendToken = resendToken;
              state = state.copyWith(
                verificationId: verificationId,
                step: AuthStep.otp,
              );
              if (!completer.isCompleted) completer.complete();
            },
            verificationFailed: (e) {
              _debugLogAppException(
                'AuthController.sendOtp verificationFailed',
                e,
              );
              if (!completer.isCompleted) completer.completeError(e);
            },
            verificationCompleted: (credential) async {
              _debugLog('AuthController.sendOtp: verificationCompleted (auto)');
              try {
                await withBackendErrorContext(
                  () => ref
                      .read(authRepositoryProvider)
                      .signInWithCredential(credential),
                  context: const BackendErrorContext(
                    service: BackendService.auth,
                    action: 'sign in with credential',
                    resource: 'phone_auth',
                  ),
                );
                if (!completer.isCompleted) completer.complete();
              } catch (e, st) {
                if (!completer.isCompleted) completer.completeError(e, st);
              }
            },
          )
          .catchError((Object e, StackTrace st) {
            _debugLog('AuthController.sendOtp catchError: $e');
            if (!completer.isCompleted) completer.completeError(e, st);
          }),
    );

    return completer.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () => throw const NetworkException(
        'timeout',
        'The verification request timed out. Please check your connection and try again.',
        context: BackendErrorContext(
          service: BackendService.auth,
          action: 'send verification code',
          resource: 'phone_auth',
        ),
      ),
    );
  }

  Future<void> verifyOtp(String code) async {
    final verificationId = state.verificationId;
    if (verificationId == null || verificationId.isEmpty) {
      throw StateError(
        'Verification session expired. Please request a new code.',
      );
    }

    final smsCode = AuthInput.normalizeOtpCode(code);
    await ref
        .read(authRepositoryProvider)
        .signInWithOtp(verificationId: verificationId, smsCode: smsCode);
  }

  void reset() {
    _resendToken = null;
    state = AuthScreenState(
      countryCode: ref.read(authInitialCountryDialCodeProvider),
    );
    sendOtpMutation.reset(ref);
    verifyOtpMutation.reset(ref);
  }

  void _debugLogOtpRequest(String formattedPhoneNumber) {
    _debugLog('── AuthController.sendOtp ──');
    _debugLog('  phone: ${AuthInput.maskedPhoneNumber(formattedPhoneNumber)}');
    _debugLog(
      '  appCheckDebugToken configured: ${AppConfig.firebaseAppCheckDebugToken.isNotEmpty}',
    );
  }

  void _debugLog(String message) {
    if (!kDebugMode || !AppConfig.verboseAuthDebugLogs) {
      return;
    }
    debugPrint(message);
  }

  void _debugLogAppException(String label, AppException error) {
    _debugLog('$label: code=${error.code}');
    final debugMessage = error.debugMessage;
    if (debugMessage != null && debugMessage.isNotEmpty) {
      _debugLog('$label debug: $debugMessage');
    }
    final cause = error.cause;
    if (cause != null) {
      _debugLog('$label cause: ${cause.runtimeType}: $cause');
    }
  }
}
