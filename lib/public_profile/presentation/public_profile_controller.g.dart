// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern A: Action controller + static Mutations**
///
/// Handles block and report actions from the public profile screen.
/// The UI wraps calls in `mutation.run(ref, ...)` to observe lifecycle.

@ProviderFor(PublicProfileController)
final publicProfileControllerProvider = PublicProfileControllerProvider._();

/// **Pattern A: Action controller + static Mutations**
///
/// Handles block and report actions from the public profile screen.
/// The UI wraps calls in `mutation.run(ref, ...)` to observe lifecycle.
final class PublicProfileControllerProvider
    extends $NotifierProvider<PublicProfileController, void> {
  /// **Pattern A: Action controller + static Mutations**
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
    r'4f1e3e62c883f9414a13a6347296d8ea125a4c0f';

/// **Pattern A: Action controller + static Mutations**
///
/// Handles block and report actions from the public profile screen.
/// The UI wraps calls in `mutation.run(ref, ...)` to observe lifecycle.

abstract class _$PublicProfileController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
