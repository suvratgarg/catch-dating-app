// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filters_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FiltersController)
final filtersControllerProvider = FiltersControllerProvider._();

final class FiltersControllerProvider
    extends $NotifierProvider<FiltersController, void> {
  FiltersControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filtersControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filtersControllerHash();

  @$internal
  @override
  FiltersController create() => FiltersController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$filtersControllerHash() => r'6bad287bb38fab6f444557956be8ffe913a2aeb7';

abstract class _$FiltersController extends $Notifier<void> {
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
