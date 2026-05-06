// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_recap_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(runRecapViewModel)
final runRecapViewModelProvider = RunRecapViewModelFamily._();

final class RunRecapViewModelProvider
    extends
        $FunctionalProvider<
          AsyncValue<RunRecapViewModel?>,
          AsyncValue<RunRecapViewModel?>,
          AsyncValue<RunRecapViewModel?>
        >
    with $Provider<AsyncValue<RunRecapViewModel?>> {
  RunRecapViewModelProvider._({
    required RunRecapViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'runRecapViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$runRecapViewModelHash();

  @override
  String toString() {
    return r'runRecapViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<RunRecapViewModel?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<RunRecapViewModel?> create(Ref ref) {
    final argument = this.argument as String;
    return runRecapViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<RunRecapViewModel?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<RunRecapViewModel?>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RunRecapViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$runRecapViewModelHash() => r'9d78029bbe5d75b8b6ed16adde05b7ed93a98989';

final class RunRecapViewModelFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<RunRecapViewModel?>, String> {
  RunRecapViewModelFamily._()
    : super(
        retry: null,
        name: r'runRecapViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RunRecapViewModelProvider call(String runId) =>
      RunRecapViewModelProvider._(argument: runId, from: this);

  @override
  String toString() => r'runRecapViewModelProvider';
}
