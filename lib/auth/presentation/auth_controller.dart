import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.freezed.dart';
part 'auth_controller.g.dart';

enum AuthStep { phone, otp }

@freezed
abstract class AuthScreenState with _$AuthScreenState {
  const factory AuthScreenState({
    @Default('') String phoneNumber,
    @Default('+91') String countryCode,
    String? verificationId,
    @Default(AuthStep.phone) AuthStep step,
  }) = _AuthScreenState;
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

  @override
  AuthScreenState build() => const AuthScreenState();

  void setCountryCode(String code) {
    state = state.copyWith(countryCode: code);
    sendOtpMutation.reset(ref);
  }

  void goToStep(AuthStep step) => state = state.copyWith(step: step);

  Future<void> sendOtp(String phoneNumber, String countryCode) async {
    state = state.copyWith(
      verificationId: null,
      phoneNumber: phoneNumber,
      countryCode: countryCode,
    );

    final formatted = _formatPhoneNumber(phoneNumber, countryCode);
    debugPrint('── AuthController.sendOtp ──');
    debugPrint('  national number: $phoneNumber');
    debugPrint('  country code: $countryCode');
    debugPrint('  formatted: $formatted');
    debugPrint(
      '  appCheckDebugToken configured: ${AppConfig.firebaseAppCheckDebugToken.isNotEmpty}',
    );

    final completer = Completer<void>();

    unawaited(
      ref
          .read(authRepositoryProvider)
          .verifyPhoneNumber(
            phoneNumber: formatted,
            codeSent: (verificationId, _) {
              debugPrint('AuthController.sendOtp: codeSent');
              state = state.copyWith(
                verificationId: verificationId,
                step: AuthStep.otp,
              );
              if (!completer.isCompleted) completer.complete();
            },
            verificationFailed: (e) {
              debugPrint(
                'AuthController.sendOtp verificationFailed: code=${e.code}',
              );
              if (!completer.isCompleted) completer.completeError(e);
            },
            verificationCompleted: (credential) async {
              debugPrint(
                'AuthController.sendOtp: verificationCompleted (auto)',
              );
              try {
                await ref
                    .read(authRepositoryProvider)
                    .signInWithCredential(credential);
                if (!completer.isCompleted) completer.complete();
              } catch (e, st) {
                if (!completer.isCompleted) completer.completeError(e, st);
              }
            },
          )
          .catchError((Object e, StackTrace st) {
            debugPrint('AuthController.sendOtp catchError: $e');
            if (!completer.isCompleted) completer.completeError(e, st);
          }),
    );

    return completer.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () => throw FirebaseAuthException(
        code: 'timeout',
        message:
            'The verification request timed out. Please check your connection and try again.',
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

    await ref
        .read(authRepositoryProvider)
        .signInWithOtp(verificationId: verificationId, smsCode: code);
  }

  void reset() {
    state = const AuthScreenState();
    sendOtpMutation.reset(ref);
    verifyOtpMutation.reset(ref);
  }

  String _formatPhoneNumber(String phoneNumber, String countryCode) {
    final normalized = phoneNumber.trim();
    if (normalized.startsWith('+')) {
      return normalized;
    }
    return '$countryCode$normalized';
  }
}
