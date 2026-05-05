// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern A: Action controller + static Mutations**
///
/// Owns run-detail side effects that are not booking operations.

@ProviderFor(RunDetailController)
final runDetailControllerProvider = RunDetailControllerProvider._();

/// **Pattern A: Action controller + static Mutations**
///
/// Owns run-detail side effects that are not booking operations.
final class RunDetailControllerProvider
    extends $NotifierProvider<RunDetailController, void> {
  /// **Pattern A: Action controller + static Mutations**
  ///
  /// Owns run-detail side effects that are not booking operations.
  RunDetailControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runDetailControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runDetailControllerHash();

  @$internal
  @override
  RunDetailController create() => RunDetailController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$runDetailControllerHash() =>
    r'd5b67bf887b6285325d6dfd9b60b8eeb0c3e0464';

/// **Pattern A: Action controller + static Mutations**
///
/// Owns run-detail side effects that are not booking operations.

abstract class _$RunDetailController extends $Notifier<void> {
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
