// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern B: Stateless controller + static Mutations**
///
/// Handles block and report actions from the public profile screen.
/// The UI wraps calls in `mutation.run(ref, ...)` to observe lifecycle.

@ProviderFor(PublicProfileController)
final publicProfileControllerProvider = PublicProfileControllerProvider._();

/// **Pattern B: Stateless controller + static Mutations**
///
/// Handles block and report actions from the public profile screen.
/// The UI wraps calls in `mutation.run(ref, ...)` to observe lifecycle.
final class PublicProfileControllerProvider
    extends $NotifierProvider<PublicProfileController, void> {
  /// **Pattern B: Stateless controller + static Mutations**
  ///
  /// Handles block and report actions from the public profile screen.
  /// The UI wraps calls in `mutation.run(ref, ...)` to observe lifecycle.
  PublicProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'publicProfileControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$publicProfileControllerHash();

  @$internal
  @override
  PublicProfileController create() => PublicProfileController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$publicProfileControllerHash() =>
    r'd386670142b872140a99a398cc19bd13858d6f20';

/// **Pattern B: Stateless controller + static Mutations**
///
/// Handles block and report actions from the public profile screen.
/// The UI wraps calls in `mutation.run(ref, ...)` to observe lifecycle.

abstract class _$PublicProfileController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
