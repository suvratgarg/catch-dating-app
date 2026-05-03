// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern A: Stateful keepAlive Notifier + freezed state + Mutations**
///
/// This is the only controller in the app using this hybrid pattern:
/// - [OnboardingData] (freezed) holds multi-step form state that must survive
///   navigation between onboarding pages. This is why [keepAlive] is `true`.
/// - [Mutation]s (sendOtp, verifyOtp, saveProfile, complete) handle
///   single-shot async operations while the UI watches their lifecycle
///   (idle / pending / error / success).
/// - The controller self-invalidates at the end of [complete] so its state
///   is freed once onboarding is done.
///
/// **When to use this pattern:** Multi-step flows where state must survive
/// navigation and a freezed data class captures the full form state.

@ProviderFor(OnboardingController)
final onboardingControllerProvider = OnboardingControllerProvider._();

/// **Pattern A: Stateful keepAlive Notifier + freezed state + Mutations**
///
/// This is the only controller in the app using this hybrid pattern:
/// - [OnboardingData] (freezed) holds multi-step form state that must survive
///   navigation between onboarding pages. This is why [keepAlive] is `true`.
/// - [Mutation]s (sendOtp, verifyOtp, saveProfile, complete) handle
///   single-shot async operations while the UI watches their lifecycle
///   (idle / pending / error / success).
/// - The controller self-invalidates at the end of [complete] so its state
///   is freed once onboarding is done.
///
/// **When to use this pattern:** Multi-step flows where state must survive
/// navigation and a freezed data class captures the full form state.
final class OnboardingControllerProvider
    extends $NotifierProvider<OnboardingController, OnboardingData> {
  /// **Pattern A: Stateful keepAlive Notifier + freezed state + Mutations**
  ///
  /// This is the only controller in the app using this hybrid pattern:
  /// - [OnboardingData] (freezed) holds multi-step form state that must survive
  ///   navigation between onboarding pages. This is why [keepAlive] is `true`.
  /// - [Mutation]s (sendOtp, verifyOtp, saveProfile, complete) handle
  ///   single-shot async operations while the UI watches their lifecycle
  ///   (idle / pending / error / success).
  /// - The controller self-invalidates at the end of [complete] so its state
  ///   is freed once onboarding is done.
  ///
  /// **When to use this pattern:** Multi-step flows where state must survive
  /// navigation and a freezed data class captures the full form state.
  OnboardingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingControllerHash();

  @$internal
  @override
  OnboardingController create() => OnboardingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingData>(value),
    );
  }
}

String _$onboardingControllerHash() =>
    r'd47b70e1dec2129e1e6cc0ae0f91ff8ad961ec6a';

/// **Pattern A: Stateful keepAlive Notifier + freezed state + Mutations**
///
/// This is the only controller in the app using this hybrid pattern:
/// - [OnboardingData] (freezed) holds multi-step form state that must survive
///   navigation between onboarding pages. This is why [keepAlive] is `true`.
/// - [Mutation]s (sendOtp, verifyOtp, saveProfile, complete) handle
///   single-shot async operations while the UI watches their lifecycle
///   (idle / pending / error / success).
/// - The controller self-invalidates at the end of [complete] so its state
///   is freed once onboarding is done.
///
/// **When to use this pattern:** Multi-step flows where state must survive
/// navigation and a freezed data class captures the full form state.

abstract class _$OnboardingController extends $Notifier<OnboardingData> {
  OnboardingData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OnboardingData, OnboardingData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OnboardingData, OnboardingData>,
              OnboardingData,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
