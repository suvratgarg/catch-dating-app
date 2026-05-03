// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PublicProfileController)
final publicProfileControllerProvider = PublicProfileControllerProvider._();

final class PublicProfileControllerProvider
    extends $NotifierProvider<PublicProfileController, void> {
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
    r'ce1a4e4dbb0cef99ea7589a045148bd54938de9d';

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
