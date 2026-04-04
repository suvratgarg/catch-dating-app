// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateProfileController)
final createProfileControllerProvider = CreateProfileControllerProvider._();

final class CreateProfileControllerProvider
    extends $NotifierProvider<CreateProfileController, void> {
  CreateProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createProfileControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createProfileControllerHash();

  @$internal
  @override
  CreateProfileController create() => CreateProfileController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$createProfileControllerHash() =>
    r'b1f818c8c1ede8b41ec50e0b0c2dfeab748c965e';

abstract class _$CreateProfileController extends $Notifier<void> {
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
