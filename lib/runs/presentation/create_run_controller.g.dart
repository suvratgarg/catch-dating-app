// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_run_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateRunController)
final createRunControllerProvider = CreateRunControllerProvider._();

final class CreateRunControllerProvider
    extends $NotifierProvider<CreateRunController, void> {
  CreateRunControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createRunControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createRunControllerHash();

  @$internal
  @override
  CreateRunController create() => CreateRunController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$createRunControllerHash() =>
    r'613652460da5684347262d3a1efa5a27a3420eda';

abstract class _$CreateRunController extends $Notifier<void> {
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
