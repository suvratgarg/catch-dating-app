// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(runDetailViewModel)
final runDetailViewModelProvider = RunDetailViewModelFamily._();

final class RunDetailViewModelProvider
    extends
        $FunctionalProvider<
          AsyncValue<RunDetailViewModel?>,
          AsyncValue<RunDetailViewModel?>,
          AsyncValue<RunDetailViewModel?>
        >
    with $Provider<AsyncValue<RunDetailViewModel?>> {
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
    r'9f07761cbef4731b20f7df352da8ad3ffff59f23';

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

  RunDetailViewModelProvider call(String runId) =>
      RunDetailViewModelProvider._(argument: runId, from: this);

  @override
  String toString() => r'runDetailViewModelProvider';
}
