// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'who_is_running.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(runnerProfiles)
final runnerProfilesProvider = RunnerProfilesFamily._();

final class RunnerProfilesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, (String, String?)>>,
          Map<String, (String, String?)>,
          FutureOr<Map<String, (String, String?)>>
        >
    with
        $FutureModifier<Map<String, (String, String?)>>,
        $FutureProvider<Map<String, (String, String?)>> {
  RunnerProfilesProvider._({
    required RunnerProfilesFamily super.from,
    required List<String> super.argument,
  }) : super(
         retry: null,
         name: r'runnerProfilesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$runnerProfilesHash();

  @override
  String toString() {
    return r'runnerProfilesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, (String, String?)>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, (String, String?)>> create(Ref ref) {
    final argument = this.argument as List<String>;
    return runnerProfiles(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RunnerProfilesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$runnerProfilesHash() => r'6afab18c66df19da27a304eb654a21ddf2f00103';

final class RunnerProfilesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<String, (String, String?)>>,
          List<String>
        > {
  RunnerProfilesFamily._()
    : super(
        retry: null,
        name: r'runnerProfilesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RunnerProfilesProvider call(List<String> uids) =>
      RunnerProfilesProvider._(argument: uids, from: this);

  @override
  String toString() => r'runnerProfilesProvider';
}
