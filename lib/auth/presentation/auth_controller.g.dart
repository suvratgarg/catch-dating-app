// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

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
final class AuthControllerProvider
    extends $NotifierProvider<AuthController, AuthScreenState> {
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
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthScreenState>(value),
    );
  }
}

String _$authControllerHash() => r'dbeffce1bf9c0a1b03d42a7d66532c18b6e93881';

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

abstract class _$AuthController extends $Notifier<AuthScreenState> {
  AuthScreenState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AuthScreenState, AuthScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthScreenState, AuthScreenState>,
              AuthScreenState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
