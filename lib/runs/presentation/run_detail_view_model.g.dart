// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_detail_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern D: Pure computed provider combining multiple async streams**
///
/// Watches several stream/future providers and combines them into one
/// [AsyncValue] via [buildRunDetailViewModel]. Each input is individually
/// checked for loading/error so the combined result is [AsyncError] if any
/// input fails or [AsyncLoading] if any input is still loading.
///
/// **When to use this pattern:** Screens that need data from multiple
/// independent sources and want a single `.when(loading:error:data:)` call
/// instead of managing multiple async states.

@ProviderFor(runDetailViewModel)
final runDetailViewModelProvider = RunDetailViewModelFamily._();

/// **Pattern D: Pure computed provider combining multiple async streams**
///
/// Watches several stream/future providers and combines them into one
/// [AsyncValue] via [buildRunDetailViewModel]. Each input is individually
/// checked for loading/error so the combined result is [AsyncError] if any
/// input fails or [AsyncLoading] if any input is still loading.
///
/// **When to use this pattern:** Screens that need data from multiple
/// independent sources and want a single `.when(loading:error:data:)` call
/// instead of managing multiple async states.

final class RunDetailViewModelProvider
    extends
        $FunctionalProvider<
          AsyncValue<RunDetailViewModel?>,
          AsyncValue<RunDetailViewModel?>,
          AsyncValue<RunDetailViewModel?>
        >
    with $Provider<AsyncValue<RunDetailViewModel?>> {
  /// **Pattern D: Pure computed provider combining multiple async streams**
  ///
  /// Watches several stream/future providers and combines them into one
  /// [AsyncValue] via [buildRunDetailViewModel]. Each input is individually
  /// checked for loading/error so the combined result is [AsyncError] if any
  /// input fails or [AsyncLoading] if any input is still loading.
  ///
  /// **When to use this pattern:** Screens that need data from multiple
  /// independent sources and want a single `.when(loading:error:data:)` call
  /// instead of managing multiple async states.
  RunDetailViewModelProvider._({
    required RunDetailViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'runDetailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$runDetailViewModelHash();

  @override
  String toString() {
    return r'runDetailViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<RunDetailViewModel?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<RunDetailViewModel?> create(Ref ref) {
    final argument = this.argument as String;
    return runDetailViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<RunDetailViewModel?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<RunDetailViewModel?>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RunDetailViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$runDetailViewModelHash() =>
    r'ddee5287bffb7e58a9e06b51dd380a75d75736ff';

/// **Pattern D: Pure computed provider combining multiple async streams**
///
/// Watches several stream/future providers and combines them into one
/// [AsyncValue] via [buildRunDetailViewModel]. Each input is individually
/// checked for loading/error so the combined result is [AsyncError] if any
/// input fails or [AsyncLoading] if any input is still loading.
///
/// **When to use this pattern:** Screens that need data from multiple
/// independent sources and want a single `.when(loading:error:data:)` call
/// instead of managing multiple async states.

final class RunDetailViewModelFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<RunDetailViewModel?>, String> {
  RunDetailViewModelFamily._()
    : super(
        retry: null,
        name: r'runDetailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// **Pattern D: Pure computed provider combining multiple async streams**
  ///
  /// Watches several stream/future providers and combines them into one
  /// [AsyncValue] via [buildRunDetailViewModel]. Each input is individually
  /// checked for loading/error so the combined result is [AsyncError] if any
  /// input fails or [AsyncLoading] if any input is still loading.
  ///
  /// **When to use this pattern:** Screens that need data from multiple
  /// independent sources and want a single `.when(loading:error:data:)` call
  /// instead of managing multiple async states.

  RunDetailViewModelProvider call(String runId) =>
      RunDetailViewModelProvider._(argument: runId, from: this);

  @override
  String toString() => r'runDetailViewModelProvider';
}
