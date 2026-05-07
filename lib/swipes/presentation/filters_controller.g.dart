// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filters_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern A: Action controller + static Mutations**
///
/// Saves swipe filter preferences to the user profile document.
/// [saveFiltersMutation] tracks the async lifecycle so the UI can
/// show a loading spinner during the save.

@ProviderFor(FiltersController)
final filtersControllerProvider = FiltersControllerProvider._();

/// **Pattern A: Action controller + static Mutations**
///
/// Saves swipe filter preferences to the user profile document.
/// [saveFiltersMutation] tracks the async lifecycle so the UI can
/// show a loading spinner during the save.
final class FiltersControllerProvider
    extends $NotifierProvider<FiltersController, void> {
  /// **Pattern A: Action controller + static Mutations**
  ///
  /// Saves swipe filter preferences to the user profile document.
  /// [saveFiltersMutation] tracks the async lifecycle so the UI can
  /// show a loading spinner during the save.
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

String _$filtersControllerHash() => r'29bdbf8d9fe9896652e583ed1c4764c9ab8945b1';

/// **Pattern A: Action controller + static Mutations**
///
/// Saves swipe filter preferences to the user profile document.
/// [saveFiltersMutation] tracks the async lifecycle so the UI can
/// show a loading spinner during the save.

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
