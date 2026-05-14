// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_map_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Combines the current user's booked runs and recommended runs for the map.
///
/// The screen owns map selection and tile rendering. This provider owns the
/// feature data seam: profile lookup, run streams, recommendation fetch, merge,
/// de-duplication, chronological sort, and pin filtering.

@ProviderFor(runMapViewModel)
final runMapViewModelProvider = RunMapViewModelProvider._();

/// Combines the current user's booked runs and recommended runs for the map.
///
/// The screen owns map selection and tile rendering. This provider owns the
/// feature data seam: profile lookup, run streams, recommendation fetch, merge,
/// de-duplication, chronological sort, and pin filtering.

final class RunMapViewModelProvider
    extends
        $FunctionalProvider<
          AsyncValue<RunMapViewModel>,
          AsyncValue<RunMapViewModel>,
          AsyncValue<RunMapViewModel>
        >
    with $Provider<AsyncValue<RunMapViewModel>> {
  /// Combines the current user's booked runs and recommended runs for the map.
  ///
  /// The screen owns map selection and tile rendering. This provider owns the
  /// feature data seam: profile lookup, run streams, recommendation fetch, merge,
  /// de-duplication, chronological sort, and pin filtering.
  RunMapViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runMapViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runMapViewModelHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<RunMapViewModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<RunMapViewModel> create(Ref ref) {
    return runMapViewModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<RunMapViewModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<RunMapViewModel>>(value),
    );
  }
}

String _$runMapViewModelHash() => r'4c86d591f1afda6f1d55d36e883e25a984c5956e';
