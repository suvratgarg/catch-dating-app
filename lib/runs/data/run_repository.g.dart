// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(runRepository)
final runRepositoryProvider = RunRepositoryProvider._();

final class RunRepositoryProvider
    extends $FunctionalProvider<RunRepository, RunRepository, RunRepository>
    with $Provider<RunRepository> {
  RunRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runRepositoryHash();

  @$internal
  @override
  $ProviderElement<RunRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RunRepository create(Ref ref) {
    return runRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RunRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RunRepository>(value),
    );
  }
}

String _$runRepositoryHash() => r'efce1135c515bcbb4c8809e98b99f5f640c0bd9e';

@ProviderFor(runsForClub)
final runsForClubProvider = RunsForClubFamily._();

final class RunsForClubProvider
    extends
        $FunctionalProvider<AsyncValue<List<Run>>, List<Run>, Stream<List<Run>>>
    with $FutureModifier<List<Run>>, $StreamProvider<List<Run>> {
  RunsForClubProvider._({
    required RunsForClubFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'runsForClubProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$runsForClubHash();

  @override
  String toString() {
    return r'runsForClubProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Run>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Run>> create(Ref ref) {
    final argument = this.argument as String;
    return runsForClub(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RunsForClubProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$runsForClubHash() => r'd60f4b44ccf52c96842898a8623a5ab978c75942';

final class RunsForClubFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Run>>, String> {
  RunsForClubFamily._()
    : super(
        retry: null,
        name: r'runsForClubProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RunsForClubProvider call(String runClubId) =>
      RunsForClubProvider._(argument: runClubId, from: this);

  @override
  String toString() => r'runsForClubProvider';
}

@ProviderFor(attendedRuns)
final attendedRunsProvider = AttendedRunsFamily._();

final class AttendedRunsProvider
    extends
        $FunctionalProvider<AsyncValue<List<Run>>, List<Run>, Stream<List<Run>>>
    with $FutureModifier<List<Run>>, $StreamProvider<List<Run>> {
  AttendedRunsProvider._({
    required AttendedRunsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'attendedRunsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$attendedRunsHash();

  @override
  String toString() {
    return r'attendedRunsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Run>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Run>> create(Ref ref) {
    final argument = this.argument as String;
    return attendedRuns(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AttendedRunsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$attendedRunsHash() => r'2cd166c36327ebd1e4909c2b1b5113bcc0f8d98d';

final class AttendedRunsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Run>>, String> {
  AttendedRunsFamily._()
    : super(
        retry: null,
        name: r'attendedRunsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AttendedRunsProvider call(String uid) =>
      AttendedRunsProvider._(argument: uid, from: this);

  @override
  String toString() => r'attendedRunsProvider';
}

@ProviderFor(signedUpRuns)
final signedUpRunsProvider = SignedUpRunsFamily._();

final class SignedUpRunsProvider
    extends
        $FunctionalProvider<AsyncValue<List<Run>>, List<Run>, Stream<List<Run>>>
    with $FutureModifier<List<Run>>, $StreamProvider<List<Run>> {
  SignedUpRunsProvider._({
    required SignedUpRunsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'signedUpRunsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$signedUpRunsHash();

  @override
  String toString() {
    return r'signedUpRunsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Run>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Run>> create(Ref ref) {
    final argument = this.argument as String;
    return signedUpRuns(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SignedUpRunsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$signedUpRunsHash() => r'fc85fbaaeacd65154ebd9925dfdd83446e289369';

final class SignedUpRunsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Run>>, String> {
  SignedUpRunsFamily._()
    : super(
        retry: null,
        name: r'signedUpRunsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SignedUpRunsProvider call(String uid) =>
      SignedUpRunsProvider._(argument: uid, from: this);

  @override
  String toString() => r'signedUpRunsProvider';
}
